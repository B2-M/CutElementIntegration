# BoSSS

This is a C# code with a Matlab interface of the BoSSS code (https://github.com/FDYdarmstadt/BoSSS) library. BoSSS is an abbreviation for "Bounded Support Spectral Solver".  The quadrature applies a high-order moment fitting approach.

An uncompiled version of this code is included. See [Installation](#installation).

Reference:
* Florian Kummer, Jens Weber, Martin Smuda, BoSSS: A package for multigrid extended discontinuous Galerkin methods, Comput. Math. Appl. 81 (2021) 237-257, https://doi.org/10.1016/j.camwa.2020.05.001
* B. Müller, F. Kummer, M. Oberlack, Highly accurate surface and volume integration on implicit domains by means of moment-fitting, Int. J. Numer. Meth. Engng 96 (2013) 512-528, https://doi.org/10.1002/nme.4569

Interface type: implicit
Operating System: Windows, (Linux: BoSSS works but Matlab does not support C# interface)

## Installation

The code comes in an uncompiled version.
The installation process could look like this:
* An installer with required native libraries can be found at this address: https://bosss-public.pages.rwth-aachen.de/documentation-pages/index.html. First, run this installer or compile BoSSS from source.
* Unfortunately, the latest developments are still not in the public repository. Therefore, we exclussively distribute the current version as a subtree at the "privateRepository" folder. 
* The "repository" folder contains the public version as a submodule, and will become the only reference for the execution after the updates.
* The Matlab interface can be compiled with using .NET 6+ with the below command (still requires native libraries):
"dotnet build "./codes/bosss/privateRepository/public/src/L4-application/MatlabCutCellQuadInterface/MatlabCutCellQuadInterface.csproj" -c Release -v q"

The Integrator uses function from the Algoim code interface. Therefore, make sure that the algoim submodule is also initialized successfully.