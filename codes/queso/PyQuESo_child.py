from queso.python_scripts.helper import *
import os
import shutil

# import QuESo_PythonApplication.PyQuESo as PyQuESo
from QuESo_PythonApplication.PyQuESo import PyQuESo

class PyQuESo_child(PyQuESo):
    def __init__(self, json_filename):
        super().__init__(json_filename)
    
    def GetTriangleMesh(self):
        return self.queso.GetTriangleMesh()