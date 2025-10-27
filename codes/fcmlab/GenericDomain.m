classdef GenericDomain < AbsEmbeddedDomain
    % Domain definition in the style of the Fcmlab code. It deals with a level
    % set function taking 3D coordinates. Necessary to handle level set
    % functions of the main code correctly.

    properties
        interface
        n_bounds	% curves or surface for 2D resp. 3D
    end

    methods (Access = public)
        % constructor
        function obj = GenericDomain(FuncHandle,n_bounds)
            obj.n_bounds = n_bounds;
            obj.interface = FuncHandle;
        end

        function domainIndex = getDomainIndex(obj,Coord)
            domainIndex = 2; % inside
            for icurve = 1:obj.n_bounds
                if obj.interface(Coord,icurve) > 0    % level set definition (greater than 0 is outside)
                    domainIndex = 1;    % outside
                    break   % if one curve says that it is outside, it is outside
                end
            end
        end

    end

end