# PatternPiece

<a href="http://www.repostatus.org/#active"><img src="http://www.repostatus.org/badges/latest/active.svg" /></a>
<a href="https://github.com/xlxwalex/HyCxG/blob/main/LICENSE"><img alt="GitHub" src="https://img.shields.io/github/license/xlxwalex/PatternPiece.svg"> </a>

[**English**](https://github.com/xlxwalex/PatternPiece/tree/main/PatternPiece/) | [**简体中文**](https://github.com/xlxwalex/PatternPiece/blob/master/README_ZH.md)

***PatternPiece*** is a extended, lightweight Aho-Corasick sequence multi-pattern, multi-element matching algorithm library, serving as the initial design for the matching method.

***PatternPiece*** is implemented in `Cython` and tested on Python 3.8 and up. It works on 64 bits Linux, macOS and Windows. The [license](https://github.com/xlxwalex/PatternPiece/blob/master/LICENSE) is Apache-2.0. 

## Download and source code
You can fetch PatternPiece from:

+ GitHub https://github.com/xlxwalex/PatternPiece
+ Pypi https://pypi.python.org/pypi/patternpiece/

## Quick start
This module is written in Cython. You need a C compiler installed to compile native extensions. In addition, due to the requirements for parallel computing, you also need to have [`OpenMP`](https://www.openmp.org/resources/openmp-compilers-tools/) installed. To install:
```bash
pip install patternpiece
```
Or you can also install from source, first clone the repository:
```bash
git clone https://github.com/xlxwalex/PatternPiece.git
cd PatternPiece
pip install -e .
```

Firstly, we can construct a toy pattern dicts.
```python
>>> patterns = {(1, 200, 30) : 1} # (key -> pattern tuple, value -> pattern index)
```

Then create an PatternPiece:
```python
>>> from patternpiece import PatternPiece
>>> matcher = PatternPiece(patterns)
```
It will automatically convert the patterns from a trie to an Aho-Corasick automaton to enable Aho-Corasick search, and then you can match the patterns in sequences:
```python
>>> sequences = [[(1, 10, 100), (2, 20, 200), (3, 30, 300)]]
>>> results = matcher.match(sequences)
```

***Note:*** you can input multiple sequences, and they will be matched in parallel.

Finally, you can get the results:
```bash
results:
[[(1, 0, 3)]]  # (Index, start, end)
```

## License
This library is licensed under very liberal [Apache-2.0](https://github.com/xlxwalex/PatternPiece/blob/master/LICENSE) license. 