classdef GenericIntegrator < Integrator
    % Integrator definition in the style of the Fcmlab code. Necessary to
    % obtain GP from the core. Therefore, integrationScheme is defined as
    % public property in contrast to the superclass Integrator.
    
    properties
        integrationScheme
    end

    methods

        % constructor
        function obj = GenericIntegrator(partitioner,integrationOrder)
            obj = obj@Integrator(partitioner,integrationOrder);
            obj.integrationScheme = GaussLegendre(integrationOrder);
        end
    
        % obtain GP from core
        function [GP,GW] = getQuadraturePoints(obj,geometry)
            GP = obj.integrationScheme.getCoordinates(geometry);
            GW = obj.integrationScheme.getWeights(geometry);
        end

    end
end