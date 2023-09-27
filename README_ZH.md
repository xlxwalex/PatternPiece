# PatternPiece

<a href="http://www.repostatus.org/#active"><img src="http://www.repostatus.org/badges/latest/active.svg" /></a>
<a href="https://github.com/xlxwalex/HyCxG/blob/main/LICENSE"><img alt="GitHub" src="https://img.shields.io/github/license/xlxwalex/PatternPiece.svg"> </a>
[![Documentation Status](https://readthedocs.org/projects/patternpiece/badge/?version=latest)](https://patternpiece.readthedocs.io/en/latest/?badge=latest)

[**English**](https://github.com/xlxwalex/PatternPiece/tree/main/PatternPiece/) | [**简体中文**](https://github.com/xlxwalex/PatternPiece/blob/master/README_ZH.md)

***PatternPiece*** 是一个扩展的、轻量级的 Aho-Corasick 序列多模式、多元素匹配算法库，作为匹配方法的初步设计。

***PatternPiece*** 使用 Cython 实现，并在 Python 3.8 及更高版本上进行了测试。它适用于 64 位的 Linux、macOS 和 Windows。[license](https://github.com/xlxwalex/PatternPiece/blob/master/LICENSE)为 Apache-2.0。

## 下载以及源代码位置
您可以从以下位置获取 PatternPiece：

+ GitHub https://github.com/xlxwalex/PatternPiece
+ Pypi https://pypi.python.org/pypi/patternpiece/

Patternpiece**文档** https://patternpiece.readthedocs.io/en/latest/

## 快速开始
此模块是用Cython编写的。您需要安装C编译器来编译原生扩展。此外，由于需要进行并行计算，您还需要安装[`OpenMP`](https://www.openmp.org/resources/openmp-compilers-tools/)。安装方法：
```bash
pip install patternpiece
```
或者，您也可以从源代码安装，首先克隆本仓库：
```bash
git clone https://github.com/xlxwalex/PatternPiece.git
cd PatternPiece
pip install -e .
```

首先，我们可以构造一个示例模式字典：
```python
>>> patterns = {(1, 200, 30) : 1} # (键 -> 模式组成的元组, 值 -> 模式索引)
```

然后实例化一个PatternPiece：
```python
>>> from patternpiece import PatternPiece
>>> matcher = PatternPiece(patterns)
```
它将自动将模式从字典树转换为Aho-Corasick自动机，以启用 Aho-Corasick 搜索，然后您可以在序列中匹配模式
```python
>>> sequences = [[(1, 10, 100), (2, 20, 200), (3, 30, 300)]]
>>> results = matcher.match(sequences)
```

***注意:*** 您可以输入多个序列，它们会被并行地进行匹配

最后，你可以得到匹配的结果
```bash
results:
[[(1, 0, 3)]]  # (索引, 起始位置索引, 终止位置索引)
```

## License
此库根据 [Apache-2.0](https://github.com/xlxwalex/PatternPiece/blob/master/LICENSE) 许可证进行许可