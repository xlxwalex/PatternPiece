from typing import List, Dict
import multiprocessing


class PatternPiece(object):
    """ Pattern piece matching class, used to call the AC automaton's Cython implementation.

    Multi-pattern, multi-element sequence matching.

    Examples
    --------
    >>> patterns = {(1, 2, 3): 0, (4, 5, 6) : 1}  # In this dict, key -> pattern, value -> index
    >>> automation = PatternPiece(patterns)

    """

    def __init__(self, patterns: Dict[tuple, int], mode: str = "memory"):
        """
        Initialize the automaton.

        Parameters
        ----------
        patterns : Dict[tuple, int]
            A dictionary to encode the input patterns.
        mode : str, optional, default: 'memory'
            The mode for the AC automaton. It can be either 'memory' or 'speed'. In memory mode, less memory is consumed
             when creating the trie, but the performance decreases during the search phase. Conversely, in speed mode,
             the performance is better, but it consumes more memory. The default mode is memory.

        Raises
        ------
        Exception
            If the provided `mode` is not 'memory' or 'speed'.
        """
        from .ac_matcher_nogil import ACMatcherSpeed, ACMatcherMemory
        if mode == "memory":
            self._automaton = ACMatcherMemory(patterns)
        elif mode == "speed":
            self._automaton = ACMatcherSpeed(patterns)
        else:
            raise Exception("Error `mode`, you can only choose [`memory`, `speed`]")

    def match(self, encoded: List[List[int]], num_workers: int = -1):
        """
        Search for the added patterns in the given sequences.

        Parameters
        ----------
        encoded : List[List[int]]
            The encoded sequences to search patterns in.
        num_workers : int, optional, default: -1
            The number of worker processes to use. If -1, all available CPUs are used.
            If greater than the number of available CPUs, an exception is raised.

        Returns
        -------
        list[list[tuple[int, int, int]]]
            A list of found patterns with their positions and indexes (Index, start, end).


        Examples
        --------
        >>> patterns = {(1, 40, 500): 6}
        >>> automation = PatternPiece(patterns)
        >>> sequences = [[(1, 10, 100), (4, 40, 400), (5, 50, 500)]]
        >>> results = automation.match(sequences)
        >>> # results = [[(6, 0, 3)]]

        Raises
        ------
        Exception
            If `num_workers` is not an integer, or exceeds the maximum number of available CPUs.
        ValueError
            If the automaton has not been built.
        """

        # Determine workers
        num_cpus = multiprocessing.cpu_count()
        if not isinstance(num_workers, int):
            raise Exception("The `num_workers` need to be `int` type.")
        if num_workers < 0: num_workers = num_cpus
        elif num_workers == 0: num_workers = 1
        elif num_workers > num_cpus:
            raise Exception("The `num_workers` has exceeded the maximum physical limits, please check.")
        # Parallel matching
        matched = self._automaton.match(encoded, num_workers)
        return matched
