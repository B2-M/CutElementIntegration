# Import libraries
import os
import numpy as np
# Julia-Python interface
from julia.api import Julia
jlapi = Julia(compiled_modules=False)
from julia import Main as jl
from julia import Pkg as pkg

def main(domain,interfaces,degree,integral_type):
    # Input:
    #   integral_type:  bulk, interface, flux
    current_folder = os.path.abspath(os.getcwd())
    print(current_folder)
    julia_folder = os.path.join(current_folder, 'codes', 'gridap')
    print(julia_folder)
    print(current_folder)

    jl.eval("using Gridap")
    # jl.eval(r'push!(LOAD_PATH, raw"D:\Code\cutelementintegration_gridap\codes\gridap")')
    julia_folder = julia_folder.replace("\\", "/")
    jl.eval(f'cd(raw"{julia_folder}")')
    jl.include("Gridap_main_julia.jl")
    jl.include("eval_module.jl")
    current_folder = current_folder.replace("\\", "/")
    jl.eval(f'cd(raw"{current_folder}")')
    # jl.include("codes\gridap\Gridap_main_julia.jl")
    # jl.include("codes\gridap\eval_module.jl")

    # interfaces comes in as a tuple and is here transferred into a Vector of function handles
    interfaces_julia = []
    for count,interface in enumerate(interfaces):
        interfaces_julia.append(jl.eval_module.eval_function(interface))

    # these fields remain empty in some cases
    els_untrim = -1
    els_untrim_ID = -1
    measure = -1

    # computation
    if integral_type=='bulk':
        [els_trim,els_trim_ID,els_untrim,els_untrim_ID] = jl.Gridap_main_julia.bulk_computation(domain,interfaces_julia,degree)
    elif integral_type=='interface':
        [els_trim,els_trim_ID] = jl.Gridap_main_julia.interface_computation(domain,interfaces_julia,degree)
    elif integral_type=='flux':
        [els_trim,els_trim_ID,measure] = jl.Gridap_main_julia.flux_computation(domain,interfaces_julia,degree)

    return els_trim,els_trim_ID,els_untrim,els_untrim_ID,measure

if __name__ == "__main__":
    els_trim,els_trim_ID,els_untrim,els_untrim_ID,measure = main(domain,interfaces,degree,integral_type)