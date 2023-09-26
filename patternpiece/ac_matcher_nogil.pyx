# cython: language_level=3

cdef extern from *:
    """
    #define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION
    """

from libc.stdlib cimport malloc, realloc, free
import numpy as np
cimport numpy as np
from libc.stdint cimport uintptr_t
from cython.parallel cimport prange


cdef struct ACNodeStruct:
    ACNodeStruct** children
    ACNodeStruct* fail
    int word_end
    int word_id
    int children_capacity

cdef struct Result:
    int word_id
    int start
    int end

cdef struct SequenceResult:
    Result* results
    int results_size

cdef struct ArrayInfo:
    int *data
    int rows
    int cols

cdef class ACMatcher:
    cdef ACNodeStruct root
    cdef dict encoder

    def __init__(self, cxs_encoder):
        self.root.children = NULL
        self.root.children_capacity = 0
        self.root.fail = NULL
        self.root.word_end = -1
        self.root.word_id = -1
        self.encoder = cxs_encoder
        self.construct_trie()

    def __dealloc__(self):
        if self.root.children != NULL:
            for i in range(self.root.children_capacity):
                if self.root.children[i] != NULL:
                    free(self.root.children[i])
            free(self.root.children)

    def construct_trie(self):
        for key, value in self.encoder.items():
            self.add_word(key, value)
        self.build()

    def add_word(self, word, word_id):
        cdef ACNodeStruct * node = &self.root
        cdef int num
        for num in word:
            if num < 0:
                raise ValueError("Negative value found in word")
            if node.children_capacity <= num:
                old_capacity = node.children_capacity
                node.children_capacity = num + 10
                node.children = <ACNodeStruct**> realloc(node.children, sizeof(ACNodeStruct *) * node.children_capacity)
                if not node.children:
                    raise MemoryError("Unable to reallocate memory for children array")
                for i in range(old_capacity, node.children_capacity):
                    node.children[i] = NULL
            if not node.children[num]:
                node.children[num] = <ACNodeStruct *> malloc(sizeof(ACNodeStruct))
                if not node.children[num]:
                    raise MemoryError("Unable to allocate memory for ACNodeStruct")
                node.children[num].children = NULL
                node.children[num].children_capacity = 0
                node.children[num].fail = NULL
                node.children[num].word_end = -1
                node.children[num].word_id = -1
            node = node.children[num]
        node.word_end = len(word)
        node.word_id = word_id

    def build(self):
        cdef:
            ACNodeStruct* curr_node
            ACNodeStruct** queue
            int queue_capacity = 1000
            int queue_start = 0, queue_end = 0
            int key

        queue = <ACNodeStruct**>malloc(sizeof(ACNodeStruct*) * queue_capacity)

        queue[queue_end] = &self.root
        queue_end += 1

        while queue_start < queue_end:
            curr_node = queue[queue_start]
            queue_start += 1
            for key in range(curr_node.children_capacity):
                child_node = curr_node.children[key]
                if child_node:
                    if queue_end >= queue_capacity:
                        queue_capacity *= 2
                        queue = <ACNodeStruct**>realloc(queue, sizeof(ACNodeStruct*) * queue_capacity)
                    if curr_node == &self.root:
                        child_node.fail = &self.root
                    else:
                        p = curr_node.fail
                        while p:
                            if p.children and key < p.children_capacity and p.children[key]:
                                child_node.fail = p.children[key]
                                break
                            p = p.fail
                        if not p:
                            child_node.fail = &self.root
                    queue[queue_end] = child_node
                    queue_end += 1
        free(queue)

    cdef Result * parallel_search(self, int * data, int num_rows, int num_cols, int * results_size) nogil:
        cdef:
            Result * results = NULL
            int results_capacity = 1000
            uintptr_t * queue = NULL
            int queue_capacity = 1000
            int queue_start = 0, queue_end = 0
            uintptr_t node_ptr
            ACNodeStruct * node
            int i, j
            int num

        results = <Result *> malloc(sizeof(Result) * results_capacity)
        queue = <uintptr_t *> malloc(sizeof(uintptr_t) * queue_capacity * 2)

        queue[queue_end] = <uintptr_t> &self.root
        queue_end += 1
        queue[queue_end] = 0
        queue_end += 1
        results_size[0] = 0

        while queue_start < queue_end:
            node_ptr = queue[queue_start]
            queue_start += 1
            i = <int> queue[queue_start]
            queue_start += 1
            node = <ACNodeStruct *> node_ptr

            if i >= num_rows:
                continue

            for j in range(num_cols):
                num = data[i * num_cols + j]
                if num < node.children_capacity and node.children[num]:
                    child_node = node.children[num]
                    temp = child_node
                    while temp and temp != &self.root:
                        if temp.word_end != -1:
                            if results_size[0] >= results_capacity:
                                results_capacity *= 2
                                results = <Result *> realloc(results, sizeof(Result) * results_capacity)
                            results[results_size[0]].word_id = temp.word_id
                            results[results_size[0]].start = i - temp.word_end + 1
                            results[results_size[0]].end = i + 1
                            results_size[0] += 1
                        temp = temp.fail

                    if queue_end + 2 > queue_capacity:
                        queue_capacity *= 2
                        queue = <uintptr_t *> realloc(queue, sizeof(uintptr_t) * queue_capacity * 2)
                    queue[queue_end] = <uintptr_t> child_node
                    queue_end += 1
                    queue[queue_end] = i + 1
                    queue_end += 1

            if node == &self.root or (not node.children):
                if queue_end + 2 > queue_capacity:
                    queue_capacity *= 2
                    queue = <uintptr_t *> realloc(queue, sizeof(uintptr_t) * queue_capacity * 2)
                if node == &self.root:
                    queue[queue_end] = <uintptr_t> &self.root
                    queue_end += 1
                    queue[queue_end] = i + 1
                    queue_end += 1
                elif node.fail:
                    queue[queue_end] = <uintptr_t> node.fail
                    queue_end += 1
                    queue[queue_end] = i
                    queue_end += 1

        free(queue)
        return results

    cpdef match(self, list sequences, int num_workers):
        cdef:
            int num_sequences = len(sequences)
            list results = []
            int i
            int num_rows
            int num_cols
            Result * res
            SequenceResult * sequence_results = <SequenceResult *> malloc(sizeof(SequenceResult) * num_sequences)
            SequenceResult *thread_results
            ArrayInfo *arrays = <ArrayInfo *>malloc(num_sequences * sizeof(ArrayInfo))
            int[:, :] arr
            int *data

        if arrays == NULL or sequence_results == NULL:
            raise MemoryError("Unable to allocate memory")

        for i in range(num_sequences):
            arr = np.ascontiguousarray(sequences[i], dtype=np.int32)
            arrays[i].data = &arr[0, 0]
            arrays[i].rows = arr.shape[0]
            arrays[i].cols = arr.shape[1]

        for i in prange(num_sequences, nogil=True, num_threads=num_workers):
            data = arrays[i].data
            num_rows = arrays[i].rows
            num_cols = arrays[i].cols
            sequence_results[i].results = self.parallel_search(data, num_rows, num_cols,
                                                               &sequence_results[i].results_size)

        for i in range(num_sequences):
            thread_result = sequence_results[i]
            res_list = []
            for j in range(thread_result.results_size):
                res_list.append((thread_result.results[j].word_id, thread_result.results[j].start, thread_result.results[j].end))
            results.append(list(set(res_list)))
            free(thread_result.results)

        free(sequence_results)
        return results
