# Ngsxfem

This code is an add-on library (https://github.com/ngsxfem) written in Python and C++ to the finite element package Netgen/NGSolve (https://ngsolve.org/). It applies a mapped quadrature rule. In particular, the quadrature algorithms for implicitly-defined geometries are accessed. 2D and 3D geometries are supported. For 2D geometries, the quadrature rule is enhanced by a quadratic mesh mapping.

Reference:
* C. Lehrenfeld, F. Heimann, J. Preuß and H. von Wahl
ngsxfem: Add-on to NGSolve for geometrically unfitted finite element discretizations
Journal of Open Source Software, 6(64), 3237,
https://doi.org/10.21105/joss.03237

Interface type: implicit
Operating System: Linux, Windows

## Installation
The following python packages have to installed:
* xfem (should automatically install the netgen and ngsolve packages, too)

pip installation is tested for the stated versions and recommended as installation procedure:
```
pip install xfem==2.1.2406.dev18
```

Two problems did arise in the past:
* Specific packaged versions were not available for all Python versions (https://forum.ngsolve.org/t/pip-install-xfem-pre-fails-for-ngsolve-6-2-2405/3108/4).
* .dev version did loose their correct dependencies with packaged ngsolve versions.