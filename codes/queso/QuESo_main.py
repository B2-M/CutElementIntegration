# Add paths
import sys
import os
current_folder = os.path.abspath(os.getcwd())
sys.path.append(os.path.join(current_folder, 'codes', 'queso'))
sys.path.append(os.path.join(current_folder, 'codes', 'queso', 'QuESo'))
sys.path.append(os.path.join(current_folder, 'codes', 'queso', 'data'))

# Import libraries
from QuESo_PythonApplication.PyQuESo import PyQuESo
import numpy as np

def main():

    pyqueso = PyQuESo(os.path.join(current_folder, 'codes', 'queso', 'QuESoParameters.json')) 
    pyqueso.Run()

    els_trim_list = []
    els_trim_ID = []
    els_untrim_list = []
    els_untrim_ID = []
    for element in pyqueso.elements:
        ID = element.ID()
        QP_elem = element.GetIntegrationPoints()
        QPs = np.empty([len(QP_elem),4])
        for count, point in enumerate(QP_elem):
            QPs[count,0] = point[0] # x-coordinate in parametric space of the B-Spline volume
            QPs[count,1] = point[1] # y-coordinate in parametric space of the B-Spline volume
            QPs[count,2] = point[2] # z-coordinate in parametric space of the B-Spline volume
            QPs[count,3] = point.Weight()
        if element.IsTrimmed():
            els_trim_list.append(QPs)
            els_trim_ID.append(ID)
        else:
            els_untrim_list.append(QPs)
            els_untrim_ID.append(ID)
    
    return els_trim_list,els_trim_ID,els_untrim_list,els_untrim_ID

if __name__ == "__main__":
    els_trim_list,els_trim_ID,els_untrim_list,els_untrim_ID = main()


