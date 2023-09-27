from patternpiece import PatternPiece

patterns = {(1, 40, 500): 6}
automation = PatternPiece(patterns)
sequences = [[(1, 10, 100), (4, 40, 400), (5, 50, 500)]]
results = automation.match(sequences)
print(results)