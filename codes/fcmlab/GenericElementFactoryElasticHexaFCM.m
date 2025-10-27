classdef GenericElementFactoryElasticHexaFCM < ElementFactoryElasticHexaFCM
    % Element Factory definition in the style of the Fcmlab code. Necessary
    % to define a GenericIntegrator for a 3D domain.
    
    methods
        % constructor
        function obj = GenericElementFactoryElasticHexaFCM(Material,Domain,integrationOrder,refinementDepth)
            obj = obj@ElementFactoryElasticHexaFCM(Material,Domain,integrationOrder,refinementDepth)
            Integrator = GenericIntegrator(OctTree(Domain,refinementDepth),integrationOrder);   % Important that the scheme is here OctTree
            obj.material = Material;
            obj.integrator = Integrator;
            obj.domain = Domain;
        end
    end
    
end