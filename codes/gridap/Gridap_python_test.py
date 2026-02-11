# Script is used as standalone test of the interface to Julia from Python

# Import libraries
import numpy as np
# Julia-Python interface
from julia.api import Julia
jlapi = Julia(compiled_modules=False)
from julia import Main as jl
from julia import Pkg as pkg

def main():
    jl.eval("using Gridap")
    jl.include("Gridap_main_julia.jl")
    jl.include("eval_module.jl")
    
    # domain={'xmin': [0.0, 0.0], 'xmax': [1.0, 1.0], 'n_refs': 1.0}
    # interfaces = "(x[1] - 1/2)^2 + (x[2] - 1/2)^2 - 1/25"
    # domain={'xmin': [-0.1, -0.1], 'xmax': [1.6, 1.6], 'n_refs': 2.0}
    # interfaces = ("- (2^(1/2)*x[1])/2 - (2^(1/2)*(x[2] - 9/10))/2","x[1] - 9/10","x[2] - 9/10")
    domain={'xmin': [-0.6, -0.6, 0], 'xmax': [0.65, 0.65,1], 'n_refs': 2.0}
    interfaces = ("4*x[1]^2 + 16*x[2]^2 - 1",)
    degree = 3
    integral_type = "interface"
    print(interfaces)
    print(type(interfaces))

    interfaces_julia = []
    for count,interface in enumerate(interfaces):
        interfaces_julia.append(jl.eval_module.eval_function(interface))
    
    # interfaces_julia = []
    # interfaces_julia.append(jl.eval_module.eval_function(interfaces[0]))
    # interfaces_julia.append(jl.eval_module.eval_function(interfaces[1]))
    # interfaces_julia.append(jl.eval_module.eval_function(interfaces[2]))

    print(interfaces_julia)
    print(type(interfaces_julia))

    # [els_trim,els_trim_ID,measure] = jl.Gridap_main_julia.flux_computation(domain,interfaces_julia,degree)
    [els_trim,els_trim_ID,els_untrim,els_untrim_ID] = jl.Gridap_main_julia.bulk_computation(domain,interfaces_julia,degree)
    
    # [els_trim,els_trim_ID,els_untrim,els_untrim_ID] = jl.Gridap_main_julia.gridap_run(domain,interfaces_julia,degree,integral_type)
    # print(result)
    # el = result[0]
    # print(el)
    # print(el[0])
    # print(type(el[0][0]))
    # print(type(el[0][1]))
    # print(type(el[0][2]))
    # for iel,el in enumerate(result):
    #     for iQP,QP in enumerate(el):
    #         for i,val in enumerate(QP):
    #             okay = 0
    #             # result[iel,iQP,i] = val

    status = pkg.status()
    print(status)

    jl.println("success")

    print(measure)

    return measure

if __name__ == "__main__":
    measure = main()