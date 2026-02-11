### QuESo
This is a C++ code with a Python interface of the QuESo(https://github.com/manuelmessmer/QuESo) library. QuESo is an abriviation for "Quadrature for Embedded Solids". It was formerly calle TIBRA. 3D STL geometries are supported. The quadrature applies a moment fitting approach. More efficient rules for untrimmed regions of B-Spline meshes are supported.

An uncompiled version of this code is included. See [Installation](#installation).

Reference:
* Manuel Meßmer, Tobias Teschemacher, Lukas F. Leidinger, Roland Wüchner, Kai-Uwe Bletzinger, Efficient CAD-integrated isogeometric analysis of trimmed solids, Comput. Methods Appl. Mech. Engrg. 400 (2022) 115584, https://doi.org/10.1016/j.cma.2022.115584
* Manuel Meßmer, Stefan Kollmannsberger, Roland Wüchner, Kai-Uwe Bletzinger, Robust numerical integration of embedded solids described in boundary representation, Comput. Methods Appl. Mech. Engrg. 419 (2024) 116670, https://doi.org/10.1016/j.cma.2023.116670
* Manuel Meßmer, Lukas F. Leidiner, Stefan Hartmann, ..., Kai-Uwe Bletzinger, Isogeometric Analysis on Trimmed Solids: A B-Spline-Based Approach Focusing on Explicit Dynamics, 13th European LS-DYNA Conference, Ulm, Germany, 2021. Meßmer et al. 2022

Interface type: parametric
Operating system: Linux (maybe, not tested yet), Windows

#### Installation

The code comes in an uncompiled version. Compilation details can be found on https://github.com/manuelmessmer/QuESo/wiki/Installation.
* The code has some prerequisites:
  * CMake (unfortunately, problems with CMake 4 were observed)
  * Python (The author of QuESo only tested up to version 3.10 and explicitly states that version 3.11 should not be used.)
* For windows, it is only necessary to change the file "..\codes\queso\QuESo\configure.bat".
* In here, the compiler has to be adapted correctly in line 26: ``cmake -G"Visual Studio 16 2019" -A x64 -H"%APP_SOURCE%" -B"%APP_BUILD%\%CMAKE_BUILD_TYPE%"  ^``
* Make sure that the Python version which you are using to compile is the same which you use in Matlab (might be a problem if you use multiple Python versions). You could change line 14 in the .bat-file: ``set PYTHON_EXECUTABLE=C:\Windows\py.exe``
* Afterwards, the file can be run (double click or call from cmd). That's it.
