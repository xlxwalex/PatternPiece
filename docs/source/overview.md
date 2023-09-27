Overview
========

## Welcome to Patternpiece’s documentation!
The `patternpiece` package is an versatile Python software library designed to facilitate multi-pattern and multi-element sequence matching through the implementation of the Aho-Corasick (AC) automaton in Cython. This package serves as a preliminary tool for users and developers seeking efficient and accurate pattern matching solutions in large sequences of data.

### Features
1. **AC Automaton Implementation:**

The core of this package revolves around the Aho-Corasick (AC) automaton, a powerful pattern matching algorithm, implemented in Cython for enhanced performance.

2. **Multi-Pattern and Multi-Element Sequence Matching:**

The library is designed to handle both multiple patterns and multiple elements in sequences, making it adaptable for various matching requirements.

3. **Customizable Modes:**

Users have the flexibility to operate the automaton in different modes (memory and speed), allowing for optimization according to the specific needs of the task.

4. **Parallel Matching:**

The package offers parallel matching capabilities, utilizing multiple worker processes to accelerate the search for patterns in the provided sequences.

## Getting Started
Follow the installation [instructions](installation.md) for your platform of choice.

### An Example
1. Firstly, we can construct a toy pattern dicts.
```python
patterns = {(1, 200, 30) : 1}
```
> **Note:** Note, the pattern needs to be a dictionary, where the key is the pattern tuple, and the value is the index of the pattern.

2. Then, let us import the `patternpiece` and instantiate a `matcher`.
```python
from patternpiece import PatternPiece
matcher = PatternPiece(patterns, mode='memory')
```
> **Note:** The mode can be either `memory` or `speed`, with the default being `memory`. Their implementations are linked lists and arrays, respectively. Therefore, if less memory usage is required, you can use the default value; if faster speed is needed, please set it to speed, but be aware that this will result in higher memory consumption. This repository is a preliminary version, and we are very hopeful that interested individuals can contribute more efficient implementations.

3. Parallel Pattern Searching
```python
sequences = [[(1, 10, 100), (2, 20, 200), (3, 30, 300)]]
results = matcher.match(sequences)
```

4. You can get the results as:
```
results:
[[(1, 0, 3)]] # (Index, start, end)
```


## Indices and tables

```{eval-rst}
* :ref:`genindex`
* :ref:`modindex`
```