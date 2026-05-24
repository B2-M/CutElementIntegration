# mlhp

This code is written in Python and C++ (https://gitlab.com/hpfem/code/mlhp). It works with a moment fitted quadrature where the reference integral is computed by a quadtree respectively octree. The boundary is implicitly defined. 2D and 3D geometries are supported. The triangulation of the 3D boundary is performed by a marching cubes algorithm.

Operating System: Linux, Windows

## Installation
The following python packages have to installed:
* mlhp
* numpy

pip installation is tested for the stated versions and recommended as installation procedure:
```
pip install mlhp==0.0.7
```