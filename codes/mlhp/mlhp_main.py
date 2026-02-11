import mlhp
import numpy as np

def main(domain_inp,treedepth,n_quad_pts,interfaces,integral_type,nseedpoints,resolutionPerCell):

    # get problem dimension
    D = len(domain_inp['xmin'])

    # set number of cells
    ncells = [2**domain_inp['n_refs']] * D
    
    # Setup mesh
    for i,interface in enumerate(interfaces):
        domain_temp = mlhp.implicitFunction(D, f"{interface} < {0}")
        if i==0:
            domain = domain_temp
        else:
            domain = mlhp.implicitIntersection([domain, domain_temp])
    if D==2:
        baseGrid = mlhp.makeGrid(nelements=ncells, lengths=[domain_inp['xmax'][0]-domain_inp['xmin'][0],
                                                            domain_inp['xmax'][1]-domain_inp['xmin'][1]], 
                                origin=[domain_inp['xmin'][0],domain_inp['xmin'][1]])
    elif D==3:
        baseGrid = mlhp.makeGrid(nelements=ncells, lengths=[domain_inp['xmax'][0]-domain_inp['xmin'][0],
                                                    domain_inp['xmax'][1]-domain_inp['xmin'][1],
                                                    domain_inp['xmax'][2]-domain_inp['xmin'][2]],
                        origin=domain_inp['xmin'])
    filteredGrid = mlhp.makeFilteredGrid(baseGrid, domain=domain, nseedpoints=nseedpoints)

    mesh = mlhp.makeRefinedGrid(filteredGrid)
    basis = mlhp.makeDummyBasis(mesh)
    
    # Choose quadrature

    # Hier definieren wir schonmal die Integrationsordnung für integrateOnDomain. Diese Ordnung wird
    # auch für die rechte Seite der Momentfitting Integrale verwendet.
    # Wenn in integrateOnDomain nicht explizit angegeben, dann wird p + 1 verwendet 
    # (mlhp.relativeQuadratureOrder(D, offset=1, factor=1)).
    # ML (10.07.2025): Der Begriff Integrationsordnung ist hier insofern irreführend, da 
    # der Input die Anzahl an Integrationspunkte ist.
    quadratureOrder = mlhp.absoluteQuadratureOrder([n_quad_pts] * D)
    
    # Hier wird noch die Anzahl der zu fittenden Gewichte festgelegt. Der standard wäre 
    # doppelt so viele Punkte zu verwenden wie durch die Integrationsordnung festgelegt:
    # mlhp.relativeQuadratureOrder(D, offset=0, factor=2)
    # Mehr als ein Faktor 2 macht hier keinen Sinn, denn dann werden die Momentfitting Integrale
    # nicht mehr exakt ausgewertet. Aber z.B. bei linearen Elementen sind die FE integranten 
    # quadratisch und es reichen damit drei Momentfitting Punkte/Gewichte pro Raumdimension.
    # Genauer gesagt braucht man nur 2*p + 1 und nicht 2*(p + 1).
    # ML: If one is directly considering the order of the integrand (which is 2*p in FE), one
    # could also say that order+1 points are needed.
    momentFittingWeights = mlhp.absoluteQuadratureOrder([n_quad_pts * 2] * D)

    quadrature = mlhp.momentFittingQuadrature(
        function=domain, 
        depth=treedepth, 
        epsilon=0.0, 
        cutOrders=momentFittingWeights
    )

    #quadrature = mlhp.spaceTreeQuadrature(
    #    function=domain, 
    #    depth=treedepth, 
    #    epsilon=0.0
    #)

    # # Integrate function
    # function = mlhp.scalarField(D, f"1")
    # result = mlhp.ScalarDouble(0.0)
    # integrand = mlhp.functionIntegrand(function)
    # mlhp.integrateOnDomain(basis, integrand, [result], quadrature=quadrature, orderDeterminor=quadratureOrder)
    # print(f"Function integral: {result.get()}", flush=True)

    if integral_type=='bulk':
        # get cell states
        cutstate = mlhp.cutstate(baseGrid, domain=domain, nseedpoints=nseedpoints)
        filteredGrid = mlhp.makeFilteredGrid(baseGrid, cutstate=cutstate)
        filteredCutstate = [state for state in cutstate if state != -1]
        insideIds = [i for i, state in enumerate(cutstate) if state == 1]
        cutIds = [i for i, state in enumerate(cutstate) if state == 0]

        # getting QPs
        els_trim_list = []
        els_trim_ID = []
        els_untrim_list = []
        els_untrim_ID = []
        count_ele_trim = 0
        count_ele_untrim = 0
        measure = 0
        for icell in range(mesh.ncells()):
            for partition in quadrature.evaluate(mesh, icell, [n_quad_pts]*D):
                measure += sum(partition.weights)
                QPs = np.empty([len(partition.xyz),D+1])
                for count, point in enumerate(partition.xyz):
                    for ix in range(D):
                        QPs[count,ix] = point[ix]
                    QPs[count,D] = partition.weights[count]
            if filteredCutstate[icell]==0:  # cut element
                ID = cutIds[count_ele_trim]
                els_trim_list.append(QPs)
                els_trim_ID.append(ID)
                count_ele_trim += 1
            elif filteredCutstate[icell]==1:    # active, uncut element
                ID = insideIds[count_ele_untrim]
                els_untrim_list.append(QPs)
                els_untrim_ID.append(ID)
                count_ele_untrim += 1
    elif integral_type=='interface':    # Reconstruct surface (marching squares for 2D surface recovery is not implemented yet)
        if D == 3:
            resolutionPerCell = [4] * D
            triangulation, celldata = mlhp.marchingCubesBoundary(mesh, domain, resolutionPerCell)
            measure = triangulation.area()
        else:
            raise ValueError("Interface integrals are only supported for 3D.")
    else:
        raise ValueError("The requested integral type is not available.")

    # measure = 0
    # els_trim_list=0
    # els_trim_ID=0
    # els_untrim_list=0
    # els_untrim_ID=0
    return measure,els_trim_list,els_trim_ID,els_untrim_list,els_untrim_ID

if __name__ == "__main__":
    variables = locals().keys()

    if "nseedpoints" not in variables:
        nseedpoints = 4
    if "resolutionPerCell" not in variables:
        resolutionPerCell = 4

    measure,els_trim_list,els_trim_ID,els_untrim_list,els_untrim_ID = main(domain_inp,treedepth,n_quad_pts,
                                                                           interfaces,integral_type,
                                                                           nseedpoints,resolutionPerCell)