from typing import List, Dict
import multiprocessing


class PatternPiece(object):
    def __init__(self, cxs_encoder: Dict[tuple, int], mode: str = "memory"):
        from .ac_matcher_nogil import ACMatcherSpeed, ACMatcherMemory
        self.encoder = cxs_encoder
        if mode == "memory":
            self._automaton = ACMatcherMemory(cxs_encoder)
        elif mode == "speed":
            self._automaton = ACMatcherSpeed(cxs_encoder)
        else:
            raise Exception("Error `mode`, you can only choose [`memory`, `speed`]")

    def match(self, encoded: List[List[int]], num_workers: int = -1):
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
