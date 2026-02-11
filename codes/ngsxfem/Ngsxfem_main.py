# Import libraries
# import ngsolve
from ngsolve import *
# basic geometry features (for the background mesh)
from netgen.occ import *
# basic xfem functionality
from xfem import *
# for isoparametric mapping
from xfem.lsetcurv import *

def main(domain,interfaces,order,reparam_degree,integral_type,integrand):

    # # print version info for debugging
    # import sys
    # info = sys.version_info
    # print(f"Running on Python {info.major}.{info.minor}.{info.micro}")
    # print(getattr(ngsolve, "__version__", "no __version__ attribute"))
    # import xfem
    # print(getattr(xfem, "__version__", "no __version__ attribute"))
    # import numpy
    # print(getattr(numpy, "__version__", "no __version__ attribute"))
    # numpy.show_config()
    # print(domain)
    # print(interfaces)
    # print(order)
    # print(reparam_degree)
    # print(integral_type)
    # print(integrand)

    # generate background mesh
    dim = len(domain['xmin'])
    scaling = domain['xmax'][0]-domain['xmin'][0]
    if dim==2:
        geo = OCCGeometry(unit_square_shape.Scale((0,0,0),scaling).Move((domain['xmin'][0],domain['xmin'][1],0)), dim=2)
    elif dim==3:
        box = Box(Pnt(domain['xmin'][0],domain['xmin'][1],domain['xmin'][2]), Pnt(domain['xmax'][0],domain['xmax'][1],domain['xmax'][2]))
        geo = OCCGeometry(box, dim=3)
    maxh = scaling/2**domain['n_refs']
    nr_interfaces = len(interfaces)
    if nr_interfaces==1 and dim==2:
        mesh = Mesh(geo.GenerateMesh(maxh=maxh,quad_dominated=True))
    else:   # multiple level-set functions are only possible for triangle or tetrahedra meshes
        mesh = Mesh(geo.GenerateMesh(maxh=maxh))

    # define level-set function and interpolate them linearily
    level_sets = []
    for i,interface in enumerate(interfaces):
        level_sets.append(eval(interface))
    nr_ls = len(level_sets)
    level_sets_p1 = tuple(GridFunction(H1(mesh, order=1)) for i in range(nr_ls))
    for i, lset_p1 in enumerate(level_sets_p1):
        InterpolateToP1(level_sets[i], lset_p1)

    # second order mesh mapping
    if integral_type=='bulk':
        domain_type = NEG
    elif integral_type=='interface' or integral_type=='flux':
        domain_type = IF
    if nr_interfaces==1:
        lsetmeshadap = LevelSetMeshAdaptation(mesh, order=reparam_degree, threshold=1000, discontinuous_qn=True)
        deformation = lsetmeshadap.CalcDeformation(level_sets)
        lsetp1 = lsetmeshadap.lset_p1
        dx = dCut(levelset=lsetp1, domain_type=domain_type, order=order, deformation=deformation)
    else:   # no second order mapping supported for multiple level-set functions
        if integral_type=='interface':
            domain_list = [None] * nr_interfaces
            for j in range(nr_interfaces):
                domain_list_entry = [None] * nr_interfaces
                for i in range(nr_interfaces):
                    if i==j:
                        domain_list_entry[i] = IF
                    else:
                        domain_list_entry[i] = NEG
                domain_list[j] = tuple(domain_list_entry)
            dx = dCut(levelset=level_sets_p1, domain_type=domain_list, order=order)
        else:
            dx = dCut(levelset=level_sets_p1, domain_type=tuple([domain_type]*nr_interfaces), order=order)

    # integrate
    if integral_type=='bulk' or integral_type=='interface':
        f = CoefficientFunction(eval(integrand))  # constant integrand
        # f = CoefficientFunction(integrand)  # constant integrand
    elif integral_type=='flux':
        if len(interfaces)==1 and dim==2:
            n = Normalize(grad(lsetp1))
        else:
            n = Normalize(grad(level_sets_p1[0]))
        if dim==2:
            f = n[0]*x+n[1]*y
        elif dim==3:
            f = n[0]*x+n[1]*y+n[2]*z
    measure = Integrate(f * dx, mesh=mesh)
    # # possibility to integrate element-wise
    # # returns a vector of element-wise integrals 
    # # (see https://forum.ngsolve.org/t/integrate-gridfunction-over-certain-elements/3280)
    # measure = Integrate(f * dx, mesh=mesh, element_wise=True)

    if integral_type=='flux':
        measure = measure/dim
    
    # # print version info for debugging
    # print(f)
    # print(dx)
    # print(mesh)
    # print(measure)

    return measure

if __name__ == "__main__":
    measure = main(domain,interfaces,order,reparam_degree,integral_type,integrand)