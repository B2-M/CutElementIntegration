# QuaHOG

This is a Matlab code of the QuaHOG (https://github.com/davidgunderman/QuaHOG) library. QuaHOG is an abriviation for "Quadrature for High-Order Geometries". 2D parametric geometries are supported. The quadrature applies Green's Theorem. Two versions are incorporated:
- Gaussian quadrature for the intermediate and the antiderivative quadrature (Quahog)
- rational quadrature for the intermediate quadrature and Gaussian quadrature for the antiderivative quadrature (QuahogPE) which is exact with a pre-defined number of quadrature points for integrands up to a certain polynomial degree (PE = polynomial exact)

The QuaHOG code contains a submodule TrIGA which is not needed in here and also not accessible.

Reference:
* Gunderman, D., Weiss, K., Evans, J.A.. Spectral mesh-free quadrature for planar regions bounded by rational parametric curves. Computer Aided Design, 130(102944) (2021). https://www.sciencedirect.com/science/article/abs/pii/S0010448520301378?via%3Dihub

Interface type: parametric 
Operating system: Linux, Windows