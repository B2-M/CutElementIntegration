# Add paths
import sys
import os
current_folder = os.path.abspath(os.getcwd())
sys.path.append(os.path.join(current_folder, 'codes', 'queso'))
sys.path.append(os.path.join(current_folder, 'codes', 'queso', 'QuESo'))
sys.path.append(os.path.join(current_folder, 'codes', 'queso', 'data'))

# Import libraries
from PyQuESo_child import PyQuESo_child
import numpy as np

def main():

    pyqueso = PyQuESo_child(os.path.join(current_folder, 'codes', 'queso', 'QuESoParameters.json'))
    pyqueso.Run()

    conditions = pyqueso.GetConditions()
    for count,condition in enumerate(conditions):
        triangle_mesh = condition.GetTriangleMesh()
    if count > 0:
        raise ValueError('The json-file should only contain one condition')
    
    num_tries = triangle_mesh.NumOfTriangles()
    QPs = []
    for i in range(num_tries):
        integration_method = 1

        ips = triangle_mesh.GetIntegrationPointsGlobal(i,integration_method)

        for count, point in enumerate(ips):
            QP = []
            count = count + 1
            QP.append(point[0]) # x-coordinate in parametric space of the B-Spline volume
            QP.append(point[1]) # y-coordinate in parametric space of the B-Spline volume
            QP.append(point[2]) # z-coordinate in parametric space of the B-Spline volume
            QP.append(point.Weight())
            QPs.append(QP)
    
    QPs = np.array(QPs)

    return QPs

if __name__ == "__main__":
    QPs = main()