# cython: language_level=3

cdef class ACNode:
    cdef public dict children
    cdef public ACNode fail
    cdef public int word_end
    cdef public int word_id

    def __init__(self):
        self.children = {}
        self.fail = None
        self.word_end = -1
        self.word_id = -1

cdef class ACMatcher:
    cdef ACNode root
    cdef dict encoder

    def __init__(self, cxs_encoder):
        self.root = ACNode()
        self.encoder = cxs_encoder
        self.construct_trie()

    def construct_trie(self):
        for key, value in self.encoder.items():
            self.add_word(key, value)
        self.build()

    def add_word(self, word, word_id):
        cdef ACNode node = self.root
        cdef int num
        for num in word:
            node = node.children.setdefault(num, ACNode())
        node.word_end = len(word)
        node.word_id = word_id

    def build(self):
        cdef list queue = []
        queue.append(self.root)
        while queue:
            curr_node = queue.pop(0)
            for key, child_node in curr_node.children.items():
                if curr_node == self.root:
                    child_node.fail = self.root
                else:
                    p = curr_node.fail
                    while p:
                        if key in p.children:
                            child_node.fail = p.children[key]
                            break
                        p = p.fail
                    if not p:
                        child_node.fail = self.root
                queue.append(child_node)

    def search(self, num_lists):
        results = []
        seen = set()
        queue = [(self.root, 0)]

        while queue:
            node, i = queue.pop(0)

            if i >= len(num_lists):
                continue

            matched_nodes = [node.children.get(num) for num in num_lists[i] if node.children.get(num)]
            for matched_node in matched_nodes:
                temp = matched_node
                while temp and temp != self.root:
                    if temp.word_end != -1:
                        position = i - temp.word_end + 1
                        if (temp.word_id, position, i + 1) not in seen:
                            results.append((temp.word_id, position, i + 1))
                            seen.add((temp.word_id, position, i + 1))
                    temp = temp.fail
                if (matched_node, i + 1) not in seen:
                    queue.append((matched_node, i + 1))
                    seen.add((matched_node, i + 1))

            if not matched_nodes or node != self.root:
                if node == self.root:
                    if (node, i + 1) not in seen:
                        queue.append((node, i + 1))
                        seen.add((node, i + 1))
                else:
                    if (node.fail, i) not in seen:
                        queue.append((node.fail, i))
                        seen.add((node.fail, i))

        return results
