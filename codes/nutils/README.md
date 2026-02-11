# Nutils

This code is written in Python (https://github.com/evalf/nutils). It works with quadtree and octree subdivision, and a triangulation on the lowest subdivision level. In particular, the quadrature algorithms for implicitly-defined geometries are accessed. 2D and 3D geometries are supported.

Reference:
* J. van Zwieten, G. van Zwieten, W. Hoitinga, Nutils 8.0 (2023). doi:https://doi.org/10.5281/zenodo.10068507

Operating System: Linux, Windows

## Installation
The following python packages have to installed:
* nutils

pip installation is tested for the stated version and recommended as installation procedure:
```
pip install nutils==8.8
```

In addition, a manual change in the nutils package is required because a function has a conflicting name if called from Matlab. For this reason:
* go to ``Lib\sitepackages\nutils\_util.py``
  * you can find your Python installation path in Windows by typing `where python` in the terminal
* replace ``sys.stdout.isatty()`` with ``False``