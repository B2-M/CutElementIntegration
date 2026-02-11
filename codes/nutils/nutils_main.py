# Import libraries
# import os
# print(os.environ)
# os.environ['NUTILS_RICHOUTPUT']='False'

from nutils import mesh, function
from nutils.expression_v2 import Namespace
import numpy as np

def main(domain,maxrefine,degree,interfaces,integral_type):

    # create domain
    dim = len(domain['xmin'])
    nelems = int(2**domain['n_refs'])
    if dim==2:
        domain0, geom = mesh.rectilinear([np.linspace(domain['xmin'][0],domain['xmax'][0],nelems+1),\
                                          np.linspace(domain['xmin'][1],domain['xmax'][1],nelems+1)])
        x,y = geom
    elif dim==3:
        domain0, geom = mesh.rectilinear([np.linspace(domain['xmin'][0],domain['xmax'][0],nelems+1),\
                                          np.linspace(domain['xmin'][1],domain['xmax'][1],nelems+1),\
                                          np.linspace(domain['xmin'][2],domain['xmax'][2],nelems+1)])
        x,y,z = geom

    ns = Namespace()
    ns.x = geom
    ns.define_for('x', gradient='∇', normal='n', jacobians=('dV', 'dS'))

    # create trimmed domain
    domain = domain0
    for i,interface in enumerate(interfaces):
        domain = domain.trim(-eval(interface), maxrefine=maxrefine, name='trim')

    # gauss integration scheme
    if integral_type=='bulk':
        gauss = domain.sample('gauss',degree)
        measure = gauss.integral('dV' @ ns)
    elif integral_type=='interface':
        gauss = domain.boundary['trim'].sample('gauss',degree)
        measure = gauss.integral('dS' @ ns)
    elif integral_type=='flux':
        gauss = domain.boundary['trim'].sample('gauss',degree)
        measure = gauss.integral('(n_i x_i) dS' @ ns)
        measure = measure/dim

    class Weights(function.Array):
        def __init__(self, sample):
            self.sample = sample
            super().__init__(shape=(), dtype=float, spaces=domain.spaces, arguments={})
        def lower(self, lowerargs):
            _, index = lowerargs.transform_chains[self.sample.space]
            weights = self.sample.get_evaluable_weights(index)
            if lowerargs.points_shape != weights.shape:
                raise ValueError('the Weights evaluable can only be evaluated on the sample for which it was created')
            return weights
            
    QP = gauss.eval('x_i' @ ns)
    weights = gauss.eval(Weights(gauss)*function.J(geom))

    return measure.eval(),QP,weights

if __name__ == "__main__":
    measure,QP,weights = main(domain,maxrefine,degree,interfaces,integral_type)