classdef QuadratureAnalysis < QuasiStaticAnalysis
    % Analysis definition in the style of the Fcmlab code. Necessary to
    % compute GP and store GP for a defined analysis.

    methods
        % constructor
        function obj = QuadratureAnalysis(meshFactories)
            obj = obj@QuasiStaticAnalysis(meshFactories);
        end

        function [area,objQuadData] = get_quadrature_points(obj,objTest)
            % Compute quadrature points. Same code used for 2D and 3D,
            % whereby the dimension is determined by the dimension of
            % objTest.
            % 
            % Output:
            %   area:   computed area/volume (depending whether problem is
            %           2D or 3D)
            
            dim = objTest.dim;

            els = getElements(obj.meshes{1});   % since many of the properties are not public, they have to be accessed by get functions
            
            GP = cell(length(els),1);
            GW = cell(length(els),1);
            objQuadData = QuadratureData(dim);
            area = 0;
            for iel = 1:length(els)

                el = els(iel);
                integrator = getIntegrator(el);
                domain = getGeometricSupport(el);
                subDomains = integrator.getIntegrationCells(domain);
                for isub = 1:length(subDomains) % Quadtree subdivisions in element
                    [GP_el,GW_el] = integrator.getQuadraturePoints(subDomains(isub));
                    GP_el_mapped = zeros(length(GW_el),3);
                    GW_el_mapped = zeros(length(GW_el),1);
                    is_inactive = true(length(GW_el),1);
                    for iGP = 1:length(GW_el)
                        GP_el_mapped(iGP,:) = subDomains(isub).mapLocalToGlobal(GP_el(iGP,:));
                        GW_el_mapped(iGP) = GW_el(iGP)*subDomains(isub).calcDetJacobian(GP_el(iGP,:))*domain.calcDetJacobian(GP_el_mapped(iGP,:));
                        mat = el.getMaterialAtPoint(GP_el_mapped(iGP,:));   % use local coordinates because the map to global is performed inside of this function
                        alpha = getScalingFactor(mat);
                        GP_el_mapped(iGP,:) = el.mapLocalToGlobal(GP_el_mapped(iGP,:));
                        GW_el_mapped(iGP) = alpha * GW_el_mapped(iGP);  % GW in invisible domain are almost zero, but not exactly to counteract flying nodes
                        if alpha==1
                            is_inactive(iGP) = false;
                            area = area + GW_el_mapped(iGP);
                        end
                    end
                    GP_el_mapped(is_inactive,:) = [];
                    GW_el_mapped(is_inactive) = [];
                    GP{iel} = [GP{iel}; GP_el_mapped];
                    GW{iel} = [GW{iel}; GW_el_mapped];
                    if ~isempty(GW_el_mapped)
                        if length(subDomains)==1
                            objQuadData = appendQuadratureData(objQuadData,[GP_el_mapped(:,1:dim)'; GW_el_mapped'],iel,'non_trimmed');
                        else
                            objQuadData = appendQuadratureData(objQuadData,[GP_el_mapped(:,1:dim)'; GW_el_mapped'],iel,'trimmed');
                        end
                    end
                end

            end
            
        end
    end
end