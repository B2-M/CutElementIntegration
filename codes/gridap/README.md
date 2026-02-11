# Gridap

## Installation

* Install Julia (https://julialang.org/)
* Install Packages within Julia
  * How to install packages?
    * Open a terminal
    * Start Julia: ```Julia```
    * Enter the package mode: ```]``` (comment: you exit it on Windows with Ctrl+C)
    * Add a package: ```add package_name```
  * Which packages are required?
    * ```PyCall@1.96.4```
    * ```Gridap@0.18.8```
    * ```GridapEmbedded#master``` (comment: the current master is required since some used functionality is not available in the last release (state: 18.12.2024))
* Install the Julia-Python interface "julia" for Python: ```pip julia```
* Enable packages for the interface:
  * start Python ```python```
  * run the following commands (https://pyjulia.readthedocs.io/en/latest/installation.html):
```
>>> import julia
>>> julia.install()
```
   * If you get the message "WARNING: The scripts julia-py.exe and python-jl.exe are installed in 'C:\Users\Loibl\AppData\Roaming\Python\Python310\Scripts' which is not on PATH." on the last command. Please make
   sure that the respective folder is on the path.
   * you can test the interface as described here https://pyjulia.readthedocs.io/en/latest/usage.html