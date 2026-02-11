%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, University of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guilherme H. Teixeira, Graz University of Technology  
%    Teoman Toprak, Technische Universität Darmstadt
%  
%
%% Copyright (C) 2025, Graz University of Technology 
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
% notice, this list of conditions and the following disclaimer in the 
% documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from 
% this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
% “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER 
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

classdef QUGaRIntegrator < AbstractIntegrator

    properties(SetAccess = private)
        reparam_degree = 1 % Degree of the trim curve reparametrization
    end

    methods(Static)

        function out = Name
            out = "QUGaR";
        end

        function out = InterfaceType
            out = "parametric";
        end
        
        function out = OperatingSystem
            out = "Windows";
        end

        function out = SupportedDimensions
            out = "2D";
        end        

        function out = IsAccessible
            out = false;
            if isCurrentFolderCorrect
                if exist('./codes/qugar','dir') == 7
                    out = true;
                else
                    warning("QUGaRIntegrator has not been found.")
                end
            end
        end

    end

    
    methods(Access = private)
        %%
        %%%%%%%% Load required paths during initialization %%%%%%%%
        function addIntegratorPaths( this )
            if exist('./codes','dir') == 7
                addpath('./codes/qugar/qugar')
                addpath('./codes/qugar/utils')
                addpath('./nurbs-1.4.3')
            else
                warning("QUGaRIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

        %%%%%%%% Interfaces %%%%%%%%
        function out = getTrimLoops( this, objTest )
            out = objTest.interface.parametric;
        end
        function square = getBackgroundmesh( this, objTest )
            degree = 1;
            origin = getOrigin( objTest.domain );
            domain_lengths = getDomainLengths( objTest.domain );
            n_elem = getNumberOfElementsPerDirection( objTest.domain );
            square = nrbsquare (origin, domain_lengths(1), domain_lengths(2), degree, n_elem);
            % transform parameter space [0,1] to physical domain obtain unity map
            for d = 1 : length(square.knots)
                tmp = square.knots{d};
                square.knots{d} = origin(d) + domain_lengths(d) .* tmp;
            end
        end

        %%%%%%%% Helper functions %%%%%%%%
        function [dir,normal,const_value] = getNonTrimElemBoundaryData( ...
                 ~, param_side, elems)
            % +----- 1 -----+
            % |             |
            % |             |
            % 4             2
            % |             |
            % |             |
            % +----- 3 -----+
            normal = zeros(2,1);
            if param_side == 1
                dir = 1;
                normal(2,:) = 1;
                const_value = elems(end).max(2);
            elseif param_side == 2
                dir = 2;
                normal(1,:) = 1;
                const_value = elems(end).max(1);
            elseif param_side == 3
                dir = 1;
                normal(2,:) = -1;
                const_value = elems(1).min(2);
            elseif param_side == 4
                dir = 2;
                normal(1,:) = -1;
                const_value = elems(1).min(1);
            end
        end

        function [measure,objQuadData] = getDomainViaFlux(this, trimmed_srf, objTest)
            measure = 0;

            % get integration points for trimmed elements
            n_refinements = 0;
            reparam_pts = ref_trimmed_srfs(n_refinements, trimmed_srf, ...
                'nb_quad_pts', this.n_quad_pts, ...
                'reparam_deg', this.reparam_degree ); 
    	    dim = objTest.dim;
            objQuadData = QuadratureData( dim );

            % base integration rule for edges of non trimmed elements
            [bp,wf] = grule(this.n_quad_pts);
            grule1D = [bp';wf'];            
            elems = objTest.domain.getElementDomains;

            %Quadrature data
            for j = 1 : length(reparam_pts(1).trim_srfs.boundaries)
                for i = 1 : reparam_pts(1).trim_srfs.boundaries(j).nb_reparam_elems
                    pts = reparam_pts(1).trim_srfs.boundaries(j).reparam_elems(i).quad_pts;
                    weights = reparam_pts(1).trim_srfs.boundaries(j).reparam_elems(i).quad_weights;
                    elem_id = reparam_pts(1).trim_srfs.boundaries(j).reparam_elems(i).elem_id;
                    normals = reparam_pts(1).trim_srfs.boundaries(j).reparam_elems(i).normals;
                    objQuadData = appendQuadratureData(objQuadData, [pts; weights], elem_id, 'interface' );
                    %Compute the flux n.P
                    measure=measure+sum(dot(pts,normals.*weights,1));
                end

                if reparam_pts(1).trim_srfs.boundaries(j).nb_non_trim_elems > 0

                    [dir,normal,const_value] = this.getNonTrimElemBoundaryData( ...
                        reparam_pts(1).trim_srfs.boundaries(j).param_side, ...
                        elems);                

                    const_dir = rem(dir,2)+1;
                    normals = repelem(normal,1,size(grule1D,2)); 
                    quadData = zeros(dim + 1,size(grule1D,2));
                    quadData(const_dir,:) = const_value;
                    for i = 1 : reparam_pts(1).trim_srfs.boundaries(j).nb_non_trim_elems
                        elem_id = reparam_pts(1).trim_srfs.boundaries(j).non_trim_elem_bd_ids( i ); 
                        breaks = [elems(elem_id).min(dir) elems(elem_id).max(dir)];
                        [qn, qw] = msh_set_quad_nodes (breaks, {grule1D});
                        quadData(dir,:) = qn;
                        quadData(dim+1,:) = qw;
                        objQuadData = appendQuadratureData(objQuadData, quadData, elem_id, 'interface' );
                        %Compute the flux n.P
                        measure=measure+sum(dot(quadData(1:2,:),normals.*quadData(3,:),1));
                    end
                end
            end
        
            %Correction to dimension
            divDimFactor = 1/dim;
            measure = measure * divDimFactor;
        end


    end
 
    methods
    %% 
        function obj = QUGaRIntegrator(n_quad_pts, reparam_degree ) 
            obj = obj@AbstractIntegrator(n_quad_pts);
            if nargin==2 && ~isempty(reparam_degree)
                obj.reparam_degree = reparam_degree;
            end
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objQugar )
            out = ['q' num2str(objQugar.reparam_degree) '-nq' num2str(objQugar.n_quad_pts)];
        end
        
        %%%%%%%% Measure/Area 2D %%%%%%%%
        function [measure,objQuadData] = integrateDomain2D( objQugar, objTest )

            assert(objTest.dim == 2)

            %Backgroundmesh
            trimmed_srf.srf = objQugar.getBackgroundmesh( objTest );
            trimmed_srf.trim_loops = objQugar.getTrimLoops( objTest );

            % get integration points
            n_refinements = 0;
            reparam_pts = ref_trimmed_srfs(n_refinements, trimmed_srf, ...
                'nb_quad_pts', objQugar.n_quad_pts, ...
                'reparam_deg', objQugar.reparam_degree ); 
            objQuadData = QuadratureData( objTest.dim );
            for i = 1 : reparam_pts(1).trim_srfs.nb_trim_elems
                pts = reparam_pts(1).trim_srfs.trim_elems(i).quad_pts;
                weights = reparam_pts(1).trim_srfs.trim_elems(i).quad_weights;
                elem_id = reparam_pts(1).trim_srfs.trim_elems(i).elem_id;
                objQuadData = appendQuadratureData(objQuadData, [pts; weights], elem_id, 'trimmed' );
            end
            elems=objTest.domain.getElementDomains;
            for i = 1 : reparam_pts(1).trim_srfs.nb_non_trim_elems
                elem_id = reparam_pts(1).trim_srfs.non_trim_elem_ids(i);
                rule=msh_gauss_nodes([objQugar.n_quad_pts objQugar.n_quad_pts]);
                [qn,qw] = msh_set_quad_nodes([{[elems(elem_id).min(1) elems(elem_id).max(1)]} {[elems(elem_id).min(2) elems(elem_id).max(2)]} ],rule);
                cont=1;
                pts=zeros(2,objQugar.n_quad_pts*objQugar.n_quad_pts);
                for ii=1:objQugar.n_quad_pts
                    for jj=1:objQugar.n_quad_pts
                        pts(1,cont)=qn{1}(jj);
                        pts(2,cont)=qn{2}(ii);
                        cont=cont+1;
                    end
                end
                weights = kron(qw{1},qw{2})';
                objQuadData = appendQuadratureData(objQuadData, [pts; weights], elem_id, 'non_trimmed' );
            end

            % compute integral for arbitrary integrand (also integrand==1
            % --> area)
            measure = objQuadData.compute_integral(objTest.integrand);
        end
        
        %%%%%%%% Volume 3D %%%%%%%% - NOT AVAILABLE
        function [vol, objQuadData] = integrateDomain3D( objQugar, objTest )
            warning("The provided version of %s does not support 3D integration.", objQugar.Name);
            objQuadData = QuadratureData( objTest.dim );
            vol = -1;
        end
        
        %%%%%%%% Interface Length %%%%%%%%
        function [measure,objQuadData] = computeInterfaceCurveLength( objQugar, objTest )
            %Initialization
            assert(objTest.dim == 2)

            %Backgroundmesh
            trimmed_srf.srf = objQugar.getBackgroundmesh( objTest );
            trimmed_srf.trim_loops = objQugar.getTrimLoops( objTest );

            % get integration points
            n_refinements = 0;
            reparam_pts = ref_trimmed_srfs(n_refinements, trimmed_srf, ...
                'nb_quad_pts', objQugar.n_quad_pts, ...
                'reparam_deg', objQugar.reparam_degree ); 
            objQuadData = QuadratureData( objTest.dim );

            % base integration rule for edges of non trimmed elements
            [bp,wf] = grule(objQugar.n_quad_pts);
            grule1D = [bp';wf'];
            elems = objTest.domain.getElementDomains;
       
            % quadrature data        
            for j = 1 : length(reparam_pts(1).trim_srfs.boundaries)
                for i = 1 : reparam_pts(1).trim_srfs.boundaries(j).nb_reparam_elems
                    pts = reparam_pts(1).trim_srfs.boundaries(j).reparam_elems(i).quad_pts;
                    weights = reparam_pts(1).trim_srfs.boundaries(j).reparam_elems(i).quad_weights;
                    elem_id = reparam_pts(1).trim_srfs.boundaries(j).reparam_elems(i).elem_id;
                    objQuadData = appendQuadratureData(objQuadData, [pts; weights], elem_id, 'interface' );
                end

                if reparam_pts(1).trim_srfs.boundaries(j).nb_non_trim_elems > 0

                    [dir,~,const_value] = objQugar.getNonTrimElemBoundaryData( ...
                        reparam_pts(1).trim_srfs.boundaries(j).param_side, ...
                        elems);

                    const_dir = rem(dir,2)+1;
                    quadData = zeros(objTest.dim + 1,size(grule1D,2));
                    quadData(const_dir,:) = const_value;
                    for i = 1 : reparam_pts(1).trim_srfs.boundaries(j).nb_non_trim_elems
                        elem_id = reparam_pts(1).trim_srfs.boundaries(j).non_trim_elem_bd_ids( i );
                        breaks = [elems(elem_id).min(dir) elems(elem_id).max(dir)];
                        [qn, qw] = msh_set_quad_nodes (breaks, {grule1D});
                        quadData(dir,:) = qn;
                        quadData(end,:) = qw;
                        objQuadData = appendQuadratureData(objQuadData, quadData, elem_id, 'interface' );
                    end

                end

            end
        
            % computing length of the interface
            measure = 0;
            for j = 1 : length(objQuadData.interface_pts)
                measure = measure + sum(objQuadData.interface_pts(j).quad_data(end,:));
            end
        
        end
        
        %%%%%%%% Interface Surface Area %%%%%%%% - NOT AVAILABLE
        function [measure,objQuadData] = computeInterfaceSurfaceArea( objQugar, objTest )
            warning("The provided version of %s does not support 3D integration.", objQugar.Name);
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end
        
        %%%%%%%% Area via Flux 2D %%%%%%%%
        function [measure,objQuadData] = computeAreaViaFlux2D( objQugar, objTest )
            %Backgroundmesh
            trimmed_srf.srf = objQugar.getBackgroundmesh( objTest );
            trimmed_srf.trim_loops = objQugar.getTrimLoops( objTest );

            %Integration over the curve
            [measure,objQuadData]=objQugar.getDomainViaFlux( trimmed_srf, objTest );
        end

        %%%%%%%% Volume via Flux 3D %%%%%%%% - NOT AVAILABLE
        function [measure,objQuadData] = computeVolumeViaFlux3D( objQugar, objTest )
            warning("The provided version of %s does not support 3D integration.", objQugar.Name);
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end
    end

end