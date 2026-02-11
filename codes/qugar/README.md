# QUGaR (Quadratures for Unfitted GeometRies)

This integrator employs the reparametrization techniques from [https://github.com/pantolin/qugar](https://github.com/pantolin/qugar).

The integrator wraps a trimming plugin for MATLAB (version from 18.10.2023) provided by Pablo Antolin (EPFL).
The underlying code (formerly referenced as Ginkgo in this framework) is a trimming plugin for MATLAB.
It requires the NURBS toolbox to work. It is not strictly mandatory, but all the input/output geometries follow the format of the toolbox.

The included version is not limited to single patch trimming, but also has some (minimal) support for non-conforming multi-patch trimming (see example trimming_reparameterization_2D_example_4.m), including shells defined in STEP files (non_confom_shells_example.m).

In the folder you will find:
 - A couple of binaries (trimmed_srfs.mexw64 and trimmed_srfs_to_step.mex64), i.e., the actual C++ code bundled for MATLAB.
 - Documentation files for those functions (trimmed_srfs.m and trimmed_srfs_to_step.m)
 - Helper function for performing dyadic refinement of trimmed geometries (ref_trimmed_srfs.m). It is documented.
 - Functions for plotting the generated reparameterizations (trimmed_srfs_plot.m).  It is documented.
 - A few examples (trimming_reparameterization_2D_example*.m and non_confom_shells_example.m + step example)
 - The license file.

Interface type: parametric 
Operating system: Windows