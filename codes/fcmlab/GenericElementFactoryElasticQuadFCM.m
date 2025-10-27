classdef GenericElementFactoryElasticQuadFCM < ElementFactoryElasticQuadFCM
    % Element Factory definition in the style of the Fcmlab code. Necessary
    % to define a GenericIntegrator for a 2D domain.
    
    methods
        % constructor
        function obj = GenericElementFactoryElasticQuadFCM(Material,Domain,integrationOrder,refinementDepth)
            obj = obj@ElementFactoryElasticQuadFCM(Material,Domain,integrationOrder,refinementDepth)
            Integrator = GenericIntegrator(QuadTree(Domain,refinementDepth),integrationOrder);
            obj.material = Material;
            obj.integrator = Integrator;
            obj.domain = Domain;
        end
    end
    
end