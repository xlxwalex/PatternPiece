#! -*- coding: utf-8 -*-

from setuptools import setup, find_packages, Extension
from Cython.Build import cythonize
import numpy

compiler_directives = {
    'boundscheck': False,
    'wraparound': False,
    'profile': True,
    'linetrace': True,
}

extensions = Extension("patternpiece.ac_matcher_nogil",
          sources=["patternpiece/ac_matcher_nogil.pyx"],
          extra_compile_args=["-fopenmp"],
          extra_link_args=["-fopenmp"],
          )

setup(
    ext_modules=cythonize(extensions, compiler_directives=compiler_directives),
    include_dirs = [numpy.get_include()]
)
