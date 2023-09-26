from typing import List, Dict
class PatternPiece(object):
    def __init__(self, cxs_encoder: Dict[tuple, int]):
        from .ac_matcher_nogil import ACMatcher
        self.encoder = cxs_encoder
        self._automaton = ACMatcher(cxs_encoder)

    def match(self, encoded: List[List[int]], num_workers: int = 96):
        matched = self._automaton.match(encoded, num_workers)
        return matched
