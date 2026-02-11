# Add paths
import sys
import os
current_folder = os.path.abspath(os.getcwd())
sys.path.append(current_folder+'\codes\nutils\nutils')

# # Import libraries
# from nutils import mesh, function, solver, export, cli, testing
# from nutils.expression_v2 import Namespace
# import numpy
# import treelog

def main(func):
    
    x=0
    y=0
    z = func(x,y)
    print(z)
    print(type(func))

    return True

if __name__ == "__main__":
    main(func)