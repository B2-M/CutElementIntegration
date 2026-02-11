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

classdef AlgoimIntegrator < AbstractIntegrator
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess = private)
        reparam_degree = 1 % Degree of the bernstein polynomial 
        % mask_eval_mode = 'bernstein_approx'  % Mask evaluation mode (default: fast)
        mask_eval_mode = 'matlab_exact' % Evaluates source of truth directly (Matlab)
    end

    methods(Static)

        function out = Name
            out = "Algoim";
        end

        function out = InterfaceType
            out = "implicit";
        end
        
        function out = OperatingSystem
            out = "Linux";
        end

        function out = SupportedDimensions
            out = ["2D","3D"];
        end

        function out = IsAccessible
            out = false;
            if isCurrentFolderCorrect
                if exist('./codes/algoim/matlabalgoimwrapper/algoim','dir') == 7
                    out = true;
                else
                    warning("AlgoimIntegrator has not been found.")
                end
            end
        end

    end

    methods(Access = private)

        %% load required paths during initialization
        function addIntegratorPaths( this )
            if this.IsAccessible
                addpath('./codes/algoim/matlabalgoimwrapper')
            end
        end

        function out = isDomainBoundary( this, lsAndGrad, domain)
            out = false;            
            tol = 10 * eps;

            if domain.dim == 2
                % check if the gradient constant -> level set is linear
                bIsLinear = true;
                grad = zeros(domain.dim,1);
                for d = 1 : domain.dim
                    grad(d) = lsAndGrad.grad{d}(domain.xmin(1),domain.xmin(2));
                end
                n = 3;
                gradB = zeros(domain.dim,1);
                for y = linspace(domain.xmin(2),domain.xmax(2), n )
                    for x = linspace(domain.xmin(1),domain.xmax(1), n )
                        for d = 1 : domain.dim
                            gradB(d) = lsAndGrad.grad{d}(x,y);
                        end
                        if norm(grad-gradB) > tol
                            bIsLinear = false;
                            break
                        end
                    end
                end

                if bIsLinear
                    % check if level set is axis aligned line or plane
                    gradIsZero = zeros(domain.dim,1);
                    for d = 1 : domain.dim
                        gradIsZero(d) = abs(grad(d)) < tol;
                    end
                    zero_dim = find(gradIsZero);
                    if ~isempty(zero_dim)
                        % check if zero level set coincides with boundary
                        vmin = lsAndGrad.phi(domain.xmin(1),domain.xmin(2));
                        vmax = lsAndGrad.phi(domain.xmax(1),domain.xmax(2));
                        if abs(vmin) < tol || abs(vmax) < tol
                            out = true;
                        end
                    end

                end
            end           

        end

        %% interfaces
        function out = getLevelSets( this, objTest, bFilterBoundary )
            lsAndGrad = objTest.interface.implicit;
            n_ls = length(lsAndGrad);
            if n_ls == 1
                out = LevelSetFunction(lsAndGrad{1}.phi);
            else
                out = cell(1,n_ls);
                for i = 1 : n_ls               
                    out{i} = LevelSetFunction(lsAndGrad{i}.phi);
                end
                if nargin == 3 && bFilterBoundary
                    bIsBoundary = ones(1,n_ls);
                    for i = 1 : n_ls
                        bIsBoundary(i) = isDomainBoundary( this, lsAndGrad{i}, objTest.domain);                                          
                    end
                    out = out(bIsBoundary==0);
                    if isscalar(out)
                        out = out{1};
                    end
                end
            end
        end

        function elem_domains = getBackgroundmesh( this, objTest )
            elem_domains = objTest.domain.getElementDomains;
        end

        %% helper functions
        function nan_filter = checkNaN( this, quadPts )
            nan_filter = [];
            TF = isnan( quadPts);
            if sum( any( TF ) ) ~= 0
                warning("NaN weights computed! Consider increasing reparametrization degree")
                nan_filter = sum(TF,1)==0;
            end
        end

        function [measure,objQuadData] = getDomainViaFlux(this,ls,elem_domains,dim)

            measure = 0;
            objQuadData = QuadratureData( dim );

            % get integration points            
            % phases = [1,-1,0]; %1 - external points; -1 - inner points; 0 - boundary points  
            phases = [0];    
            wIndex = dim+2:dim+1+dim;            
            for e = 1 : length(elem_domains)

                quadPtsPerPhase = algoim_quad_multipoly(ls, ...
                    this.reparam_degree, this.n_quad_pts, ...
                    elem_domains(e).min, elem_domains(e).max, phases);
                if( ~isempty( quadPtsPerPhase{1} ) )

                    col_filter = this.checkNaN(quadPtsPerPhase{1});                    
                    if ~isempty( col_filter )
                        quadPtsPerPhase{1} = quadPtsPerPhase{1}(:,col_filter);
                    end
               
                    % for q = 1:size(quadPtsPerPhase{1},2)
                    %     x  = quadPtsPerPhase{1}(1:dim,q);
                    %     wn = quadPtsPerPhase{1}(wIndex,q);
                    %     measure = measure + dot(x,wn);
                    % end
                    x = quadPtsPerPhase{1}(1:dim, :); % Extract all x vectors at once
                    wn = quadPtsPerPhase{1}(wIndex, :);       % Extract all wn vectors at once
                    measure = measure + sum(dot(x, wn, 1));   % Compute the dot products and sum them up

                    % store quad data
                    % NOTE: stores the value of the interface quadrature w,
                    % not the flux version wn!!! The latter would require a
                    % new point type in the QuadData class
                    if ~isempty( quadPtsPerPhase{1} )
                        objQuadData = appendQuadratureData(objQuadData, ...
                            quadPtsPerPhase{1}(1:dim+1,:), e, 'interface' );
                    end

                end

            end

            divDimFactor = 1/dim;
            measure = measure * divDimFactor;

        end

    end

    methods

        function obj = AlgoimIntegrator(n_quad_pts, reparam_degree)
            obj = obj@AbstractIntegrator(n_quad_pts);
            if nargin==2 && ~isempty(reparam_degree)
                obj.reparam_degree = reparam_degree;
            end
            obj.addIntegratorPaths;   
            % Set default mode
            algoim_set_mask_eval_mode(obj.mask_eval_mode);  
            % Enable debug output
            % algoim_quad_multipoly('set_debug_mode', 1);
            % % Disable debug output
            % algoim_quad_multipoly('set_debug_mode', 0);
        end

        function out = PropertyString( objAlgoim )
            out = ['q' num2str(objAlgoim.reparam_degree) '-nq' num2str(objAlgoim.n_quad_pts)];
        end

        function [measure,objQuadData] = integrateDomain2D( objAlgoim, objTest )
            %
            % THIS FUNCTION COMPUTES THE AREA OF AN IMPLICIT CURVE
            %
            % INPUT
            %  objAlgoim... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   measure... the measure computed
            %   objQuadData... the quadrature points used
            assert(objTest.dim == 2)
        
            % convert test data   
            ls2D = objAlgoim.getLevelSets( objTest, true );       
            elem_domains = objAlgoim.getBackgroundmesh( objTest );


            % get integration points            
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1;
            % phases = [1,-1,0]; %1 - external points; -1 - inner points; 0 - boundary points
            phases = [-1,1];             
            for e = 1 : length(elem_domains)
                % box = [elem_domains(e).min, elem_domains(e).max]
                quadPtsPerPhase = algoim_quad_multipoly(ls2D, ...
                    objAlgoim.reparam_degree, objAlgoim.n_quad_pts, ...
                    elem_domains(e).min, elem_domains(e).max, phases);
                if( ~isempty( quadPtsPerPhase{1} ) )

                    col_filter = objAlgoim.checkNaN(quadPtsPerPhase{1});                    
                    if ~isempty( col_filter )
                        quadPtsPerPhase{1} = quadPtsPerPhase{1}(:,col_filter);
                    end
               
                    measure = measure + sum(quadPtsPerPhase{1}(wIndex,:));

                    % store quad data
                    if isempty( quadPtsPerPhase{2} )
                        objQuadData = appendQuadratureData(objQuadData, quadPtsPerPhase{1}, e, 'non_trimmed' );
                    else
                        objQuadData = appendQuadratureData(objQuadData, quadPtsPerPhase{1}, e, 'trimmed' );
                    end

                end

            end
            
            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the area is not 
                % requested as computed above but an integral with an 
                % integrand ~=1
            end

        end % integrateDomain2D

        function [measure,objQuadData] = integrateDomain3D( objAlgoim, objTest )
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            % outputArg = obj.Property1 + inputArg;
            assert(objTest.dim == 3)        
            % convert test data 
            ls3D = objAlgoim.getLevelSets( objTest );          
            elem_domains = objAlgoim.getBackgroundmesh( objTest );

            % get integration points            
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1;
            % phases = [1,-1,0]; %1 - external points; -1 - inner points; 0 - boundary points
            phases = [-1,1];             
            for e = 1 : length(elem_domains)

                quadPtsPerPhase = algoim_quad_multipoly(ls3D, ...
                    objAlgoim.reparam_degree, objAlgoim.n_quad_pts, ...
                    elem_domains(e).min, elem_domains(e).max, phases);
                if( ~isempty( quadPtsPerPhase{1} ) )

                    col_filter = objAlgoim.checkNaN(quadPtsPerPhase{1});                    
                    if ~isempty( col_filter )
                        quadPtsPerPhase{1} = quadPtsPerPhase{1}(:,col_filter);
                    end
                    measure = measure + sum(quadPtsPerPhase{1}(wIndex,:));

                    % store quad data
                    if isempty( quadPtsPerPhase{2} )
                        objQuadData = appendQuadratureData(objQuadData, quadPtsPerPhase{1}, e, 'non_trimmed' );
                    else
                        objQuadData = appendQuadratureData(objQuadData, quadPtsPerPhase{1}, e, 'trimmed' );
                    end

                end

            end

            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the volume is not 
                % requested as computed above but an integral with an 
                % integrand ~=1
            end
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objAlgoim, objTest )
            %
            % THIS FUNCTION COMPUTES THE LENGT OF THE ZERO-LEVEL SET - AN IMPLICIT CURVE
            %
            % INPUT
            %  objAlgoim... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   area... the area computed
            %   objQuadData... the quadrature points used
            assert(objTest.dim == 2)
        
            % convert test data 
            ls2D = objAlgoim.getLevelSets( objTest );          
            elem_domains = objAlgoim.getBackgroundmesh( objTest );


            % get integration points            
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1;
            % phases = [1,-1,0]; %1 - external points; -1 - inner points; 0 - boundary points
            phases = [0];             
            for e = 1 : length(elem_domains)

                quadPtsPerPhase = algoim_quad_multipoly(ls2D, ...
                    objAlgoim.reparam_degree, objAlgoim.n_quad_pts, ...
                    elem_domains(e).min, elem_domains(e).max, phases);
                if( ~isempty( quadPtsPerPhase{1} ) )

                    col_filter = objAlgoim.checkNaN(quadPtsPerPhase{1});                    
                    if ~isempty( col_filter )
                        quadPtsPerPhase{1} = quadPtsPerPhase{1}(:,col_filter);
                    end
               
                    measure = measure + sum(quadPtsPerPhase{1}(wIndex,:));

                    % store quad data
                    if ~isempty( quadPtsPerPhase{1} )
                        objQuadData = appendQuadratureData(objQuadData, ...
                            quadPtsPerPhase{1}(1:wIndex,:), e, 'interface' );
                    end

                end

            end

        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objAlgoim, objTest )
            %
            % THIS FUNCTION COMPUTES THE LENGT OF THE ZERO-LEVEL SET - AN IMPLICIT CURVE
            %
            % INPUT
            %  objAlgoim... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   area... the area computed
            %   objQuadData... the quadrature points used
            assert(objTest.dim == 3)

            % convert test data
            ls3D = objAlgoim.getLevelSets( objTest );
            elem_domains = objAlgoim.getBackgroundmesh( objTest );


            % get integration points
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1;
            % phases = [1,-1,0]; %1 - external points; -1 - inner points; 0 - boundary points
            phases = [0];
            for e = 1 : length(elem_domains)

                quadPtsPerPhase = algoim_quad_multipoly(ls3D, ...
                    objAlgoim.reparam_degree, objAlgoim.n_quad_pts, ...
                    elem_domains(e).min, elem_domains(e).max, phases);
                if( ~isempty( quadPtsPerPhase{1} ) )

                    col_filter = objAlgoim.checkNaN(quadPtsPerPhase{1});
                    if ~isempty( col_filter )
                        quadPtsPerPhase{1} = quadPtsPerPhase{1}(:,col_filter);
                    end

                    measure = measure + sum(quadPtsPerPhase{1}(wIndex,:));

                    % store quad data
                    if ~isempty( quadPtsPerPhase{1} )
                        objQuadData = appendQuadratureData(objQuadData, ...
                            quadPtsPerPhase{1}(1:wIndex,:), e, 'interface' );
                    end

                end

            end

        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objAlgoim, objTest )
            %
            % THIS FUNCTION COMPUTES FLUXES ALONG THE ZERO-LEVEL SET - AN IMPLICIT CURVE
            %
            % INPUT
            %  objAlgoim... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   measure... the area computed
            %   objQuadData... the quadrature points used
            assert(objTest.dim == 2)
        
            % convert test data 
            bFilterBoundary = false; % note: line integral must be closed
            ls2D = objAlgoim.getLevelSets( objTest, bFilterBoundary );         
            elem_domains = objAlgoim.getBackgroundmesh( objTest );

            % integrate over levelsets
            [measure,objQuadData] = objAlgoim.getDomainViaFlux(ls2D,elem_domains,objTest.dim);

        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objAlgoim, objTest )
            %
            % THIS FUNCTION COMPUTES FLUXES ALONG THE ZERO-LEVEL SET - AN
            % IMPLICIT SURFACE
            %
            % INPUT
            %  objAlgoim... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   measure... the volume computed
            %   objQuadData... the quadrature points used
            assert(objTest.dim == 3)

            % convert test data
            ls3D = objAlgoim.getLevelSets( objTest );
            elem_domains = objAlgoim.getBackgroundmesh( objTest );

            % integrate over levelsets
            [measure,objQuadData] = objAlgoim.getDomainViaFlux(ls3D,elem_domains,objTest.dim);

        end


    end


end