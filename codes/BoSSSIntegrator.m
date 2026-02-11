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

classdef BoSSSIntegrator < AbstractIntegrator
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess = private)
        quad_degree     % Degree of the quadrature rule
        reparam_degree  % Degree of the level set
    end

    methods(Static)

        function out = Name
            out = "BoSSS";
        end

        function out = InterfaceType
            out = "implicit";
        end

        function out = OperatingSystem
            out = "Windows";
        end

        function out = SupportedDimensions
            out = ["2D", "3D"];
        end

        function out = IsAccessible
            out = false;
            if isCurrentFolderCorrect
                if exist('./codes/bosss/repository','dir') == 7
                    % Also check if the .NET assembly exists
                    pstr = fullfile(pwd + "\codes\bosss\repository\src\L4-application\MatlabCutCellQuadInterface\bin\Release\net6.0\BoSSS.Application.MatlabCutCellQuadInterface.dll");
                    if exist(pstr, 'file') == 2
                        out = true;
                    else
                        warning("BoSSSIntegrator .NET assembly not found. Please build BoSSS first.")
                    end
                else
                    warning("BoSSSIntegrator repository not found.")
                end
            end
        end

        function LoadLibrary()
            if ispc
                dotnetenv("core");
                %TO DO: Dotnet version should not be hardcoded
                pstr = fullfile(pwd + "\codes\bosss\repository\src\L4-application\MatlabCutCellQuadInterface\bin\Release\net6.0\BoSSS.Application.MatlabCutCellQuadInterface.dll");
                if exist(pstr, 'file') == 2
                    NET.addAssembly(pstr);
                else
                    warning('BoSSS .NET assembly not found at: %s', pstr);
                    error('BoSSS .NET assembly is required but not available. Please build BoSSS first.');
                end
            end
        end
    end

    methods(Access = private)

        %% load required paths during initialization
        function addIntegratorPaths( this )
            if this.IsAccessible
                addpath('./codes/bosss')
            end
        end

        %% interfaces
        function out = getLevelSets(this, objTest)
            lsAndGrad = objTest.interface.implicit;
        
            % Remove boundary curves which are identical with the
            % domain boundary
            lsAndGrad = remove_implicit_domain_boundary(lsAndGrad,objTest.domain);
            n_ls      = length(lsAndGrad);
            if n_ls == 1
                origPhi = lsAndGrad{1}.phi;
                negPhi  = @(varargin) -origPhi(varargin{:});
                out     = LevelSetFunction(negPhi);
            else
                out = cell(1,n_ls);
                for i = 1:n_ls
                    origPhi   = lsAndGrad{i}.phi;
                    negPhi    = @(varargin) -origPhi(varargin{:});
                    out{i}    = LevelSetFunction(negPhi);
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
                warning("NaN weights computed!")
                nan_filter = sum(TF,1)==0;
            end
        end

    end

    methods

        function obj = BoSSSIntegrator(n_quad_pts, reparam_degree)
            obj = obj@AbstractIntegrator(n_quad_pts);
            obj.quad_degree = obj.HMF_order(n_quad_pts); % for 1D degree=n_quad_pts- 1. For 2D: 
            if nargin==2 && ~isempty(reparam_degree)
                obj.reparam_degree = reparam_degree;
            end
            obj.addIntegratorPaths;
            obj.LoadLibrary;
        end

        function out = PropertyString( objBoSSS )
            if ~isempty(objBoSSS.reparam_degree)
                out = ['q' num2str(objBoSSS.reparam_degree) '-nq' num2str(objBoSSS.n_quad_pts)];
            else
                error("reparam_degree is stricly required for BoSSS")
            end
        end

        function [measure,objQuadData] = integrateDomain2D( objBoSSS, objTest )
            %
            % THIS FUNCTION COMPUTES THE AREA OF AN IMPLICIT CURVE
            %
            % INPUT
            %  objBoSSS... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   measure... the measure computed
            %   objQuadData... the quadrature points used

            assert(objTest.dim == 2)
            dim = int32(2);
            phaseIndicator = 1; %phaseIndicator: -1 - external points; +1 - inner points; 0 - boundary points

            % Create an instance of the class and initialize BoSSS
            caller = BoSSS.Application.ExternalBinding.MatlabCutCellQuadInterface.MatlabCutCellQuadInterface();
            hmfType = objBoSSS.bosss_MomentFitting("Classic");
            caller.BoSSSInitialize();

            % convert test data
            ls2D = objBoSSS.getLevelSets( objTest );
            elem_domains = objBoSSS.getBackgroundmesh( objTest );
            xnodes = zeros(length(elem_domains)+1,1);
            ynodes = zeros(length(elem_domains)+1,1);

            for e = 1 : length(elem_domains)
                xnodes(e) = elem_domains(e).min(1);
                ynodes(e) = elem_domains(e).min(2);
            end

            xnodes(e+1) = elem_domains(end).max(1);
            ynodes(e+1) = elem_domains(end).max(2);

            xnodes = sortrows(unique(xnodes));
            ynodes = sortrows(unique(ynodes));

            % initate mesh for 2d
            % SetDomain(dimension of space, xnodes, ynodes)
            caller.SetDomain(dim, xnodes, ynodes);

            % set level set
            n_ls = length(ls2D);
            if n_ls > 1
                for l = 1: n_ls
                    caller.Submit2DLevelSet(ls2D{l}.phi)
                end
            else
                %delegate2D = @(x, y) ls2D.phi(x, y);
                caller.Submit2DLevelSet(ls2D.phi)
            end

            caller.ProjectLevelSet(objBoSSS.reparam_degree,hmfType, "Min")
            
            % calculate quadrature rules
            bosssDegree = objBoSSS.HMF_order(objBoSSS.n_quad_pts,2);
            caller.CompileQuadRules(bosssDegree, phaseIndicator);

            % get integration points
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1; %weight index

            for e = 1 : length(elem_domains)
                % GetQuadRules(number of element (from starting 0), phaseIndicator)
                quadData = caller.GetQuadRules(e-1, phaseIndicator); %

                % if not an interior point, continue to the next element
                if isempty(quadData)
                    continue
                end

                % get data
                numberOfNodes = quadData.Lengths(1);
                dArray = quadData.Storage;

                % convert it to matlab format
                quadMtx = zeros(numberOfNodes,3);
                for n= 1:numberOfNodes
                    quadMtx(n,:) = [dArray(3*n-2) dArray(3*n-1) dArray(3*n)];
                end

                quadMtx = quadMtx';

                if( ~isempty( quadMtx) )
                    measure = measure + sum(quadMtx(wIndex,:));

                    % store quad data
                    if caller.IsItACutCell(e-1) == true
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'trimmed' );
                    else
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'non_trimmed' );
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

            %caller.PlotCurrentState(3); % for debugging purposes
            clear caller
            disp("BoSSS has successfuly returned")
        end

        function [measure,objQuadData] = integrateDomain3D( objBoSSS, objTest )
            %
            % THIS FUNCTION COMPUTES THE AREA OF AN IMPLICIT CURVE
            %
            % INPUT
            %  objBoSSS... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   measure... the measure computed
            %   objQuadData... the quadrature points used
            assert(objTest.dim == 3)
            dim = int32(3);
            phaseIndicator = 1; %phaseIndicator: 1 - external points; -1 - inner points; 0 - boundary points

            % Create an instance of the class and initialize BoSSS
            caller = BoSSS.Application.ExternalBinding.MatlabCutCellQuadInterface.MatlabCutCellQuadInterface();
			hmfType = objBoSSS.bosss_MomentFitting("Classic");
            caller.BoSSSInitialize();

            % convert test data
            ls3D = objBoSSS.getLevelSets( objTest );
            elem_domains = objBoSSS.getBackgroundmesh( objTest );
            xnodes = zeros(length(elem_domains)+1,1);
            ynodes = zeros(length(elem_domains)+1,1);
            znodes = zeros(length(elem_domains));

            for e = 1 : length(elem_domains)
                xnodes(e) = elem_domains(e).min(1);
                ynodes(e) = elem_domains(e).min(2);
                znodes(e) = elem_domains(e).min(3);
            end

            xnodes(e+1) = elem_domains(end).max(1);
            ynodes(e+1) = elem_domains(end).max(2);
            znodes(e+1) = elem_domains(end).max(3);

            xnodes = sortrows(unique(xnodes));
            ynodes = sortrows(unique(ynodes));
            znodes = sortrows(unique(znodes));

            % initate mesh for 3d
            % SetDomain(dimension of space, xnodes, ynodes, znodes)
            caller.SetDomain(dim, xnodes, ynodes, znodes);

            % set level set
            n_ls = length(ls3D);
            if n_ls > 1
                for l = 1: n_ls
                    %delegate3D = @(x, y, z) ls3D{l}.phi(x, y, z);
                    caller.Submit3DLevelSet(ls3D{l}.phi)
                end
            else
                %delegate3D = @(x, y, z) ls3D.phi(x, y, z);
                caller.Submit3DLevelSet(ls3D.phi)
            end

            caller.ProjectLevelSet(objBoSSS.reparam_degree,hmfType, "Min")
            
            % SetLevelSets(degree of LS, LS function)
            %caller.SetLevelSets(objBoSSS.reparam_degree,ls2D.phi);

            % calculate quadrature rules
            bosssDegree = objBoSSS.HMF_order(objBoSSS.n_quad_pts,3);
            caller.CompileQuadRules(bosssDegree, phaseIndicator);

            % get integration points
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1;
            % phases = [1,-1,0]; %1 - external points; -1 - inner points; 0 - boundary points

            for e = 1 : length(elem_domains)
                quadData = caller.GetQuadRules(e-1, phaseIndicator); %number of element (from starting 0), phaseIndicator

                % if not an interior point, continue to the next element
                if isempty(quadData)
                    continue
                end

                % get data
                numberOfNodes = quadData.Lengths(1);
                dArray = quadData.Storage;

                % convert it to matlab format
                quadMtx = zeros(numberOfNodes,4);
                for n= 1:numberOfNodes
                    quadMtx(n,:) = [dArray(4*n-3) dArray(4*n-2) dArray(4*n-1) dArray(4*n)];

                end

                quadMtx = quadMtx';

                if( ~isempty( quadMtx) )
                    measure = measure + sum(quadMtx(wIndex,:));

                    % store quad data
                    if caller.IsItACutCell(e-1) == true
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'trimmed' );
                    else
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'non_trimmed' );
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

            clear caller
            disp("BoSSS has successfuly returned")
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objBoSSS, objTest )
            %
            % THIS FUNCTION COMPUTES THE LENGT OF THE ZERO-LEVEL SET - AN IMPLICIT CURVE
            %
            % INPUT
            %  objBoSSS... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   area... the area computed
            %   objQuadData... the quadrature points used

            assert(objTest.dim == 2)
            dim = int32(2);
            phaseIndicator = 0; %phaseIndicator: 1 - external points; -1 - inner points; 0 - boundary points

            % Create an instance of the class and initialize BoSSS
            caller = BoSSS.Application.ExternalBinding.MatlabCutCellQuadInterface.MatlabCutCellQuadInterface();
			hmfType = objBoSSS.bosss_MomentFitting("Classic");
            caller.BoSSSInitialize();

            % convert test data
            ls2D = objBoSSS.getLevelSets( objTest );
            elem_domains = objBoSSS.getBackgroundmesh( objTest );
            xnodes = zeros(length(elem_domains)+1,1);
            ynodes = zeros(length(elem_domains)+1,1);

            for e = 1 : length(elem_domains)
                xnodes(e) = elem_domains(e).min(1);
                ynodes(e) = elem_domains(e).min(2);
            end

            xnodes(e+1) = elem_domains(end).max(1);
            ynodes(e+1) = elem_domains(end).max(2);

            xnodes = sortrows(unique(xnodes));
            ynodes = sortrows(unique(ynodes));

            % initate mesh for 2d
            % SetDomain(dimension of space, xnodes, ynodes)
            caller.SetDomain(dim, xnodes, ynodes);

            % set level set
            n_ls = length(ls2D);
            if n_ls > 1
                for l = 1: n_ls
                    caller.Submit2DLevelSet(ls2D{l}.phi)
                end
            else
                %delegate2D = @(x, y) ls2D.phi(x, y);
                caller.Submit2DLevelSet(ls2D.phi)
            end

            caller.ProjectLevelSet(objBoSSS.reparam_degree,hmfType, "Min")
            
            % calculate quadrature rules
            bosssDegree = objBoSSS.HMF_order(objBoSSS.n_quad_pts,2);
            caller.CompileQuadRules(bosssDegree, phaseIndicator);

            % get integration points
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1; %weight index

            for e = 1 : length(elem_domains)
                % GetQuadRules(number of element (from starting 0), phaseIndicator)
                quadData = caller.GetQuadRules(e-1, phaseIndicator); %

                % if not an interior point, continue to the next element
                if isempty(quadData)
                    continue
                end

                % get data
                numberOfNodes = quadData.Lengths(1);
                dArray = quadData.Storage;

                % convert it to matlab format
                quadMtx = zeros(numberOfNodes,3);
                for n= 1:numberOfNodes
                    quadMtx(n,:) = [dArray(3*n-2) dArray(3*n-1) dArray(3*n)];
                end

                quadMtx = quadMtx';

                if( ~isempty( quadMtx) )
                    measure = measure + sum(quadMtx(wIndex,:));

                    % store quad data
                    if caller.IsItACutCell(e-1) == true
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'trimmed' );
                    else
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'non_trimmed' );
                    end
                end

            end
            %caller.PlotCurrentState(3); % for debugging purposes
            clear caller
            disp("BoSSS has successfuly returned")
        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objBoSSS, objTest )
            %
            % THIS FUNCTION COMPUTES THE LENGT OF THE ZERO-LEVEL SET - AN IMPLICIT CURVE
            %
            % INPUT
            %  objBoSSS... integrator class
            %  objTest... test classclf
            % OUTPUT
            %   area... the area computed
            %   objQuadData... the quadrature points used
            assert(objTest.dim == 3)
            dim = int32(3);
            phaseIndicator = 0; %phaseIndicator: 1 - external points; -1 - inner points; 0 - boundary points

            % Create an instance of the class and initialize BoSSS
            caller = BoSSS.Application.ExternalBinding.MatlabCutCellQuadInterface.MatlabCutCellQuadInterface();
			hmfType = objBoSSS.bosss_MomentFitting("Classic");
            caller.BoSSSInitialize();

            % convert test data
            ls3D = objBoSSS.getLevelSets( objTest );
            elem_domains = objBoSSS.getBackgroundmesh( objTest );
            xnodes = zeros(length(elem_domains)+1,1);
            ynodes = zeros(length(elem_domains)+1,1);
            znodes = zeros(length(elem_domains));

            for e = 1 : length(elem_domains)
                xnodes(e) = elem_domains(e).min(1);
                ynodes(e) = elem_domains(e).min(2);
                znodes(e) = elem_domains(e).min(3);
            end

            xnodes(e+1) = elem_domains(end).max(1);
            ynodes(e+1) = elem_domains(end).max(2);
            znodes(e+1) = elem_domains(end).max(3);

            xnodes = sortrows(unique(xnodes));
            ynodes = sortrows(unique(ynodes));
            znodes = sortrows(unique(znodes));

            % initate mesh for 3d
            % SetDomain(dimension of space, xnodes, ynodes, znodes)
            caller.SetDomain(dim, xnodes, ynodes, znodes);

            % set level set
            n_ls = length(ls3D);
            if n_ls > 1
                for l = 1: n_ls
                    %delegate3D = @(x, y, z) ls3D{l}.phi(x, y, z);
                    caller.Submit3DLevelSet(ls3D{l}.phi)
                end
            else
                %delegate3D = @(x, y, z) ls3D.phi(x, y, z);
                caller.Submit3DLevelSet(ls3D.phi)
            end

            caller.ProjectLevelSet(objBoSSS.reparam_degree,hmfType, "Min")
            
            % calculate quadrature rules
            bosssDegree = objBoSSS.HMF_order(objBoSSS.n_quad_pts,3);
            caller.CompileQuadRules(bosssDegree, phaseIndicator);

            % get integration points
            measure = 0;
            objQuadData = QuadratureData( objTest.dim );
            wIndex = objTest.dim + 1;
            % phases = [1,-1,0]; %1 - external points; -1 - inner points; 0 - boundary points

            for e = 1 : length(elem_domains)
                quadData = caller.GetQuadRules(e-1, phaseIndicator); %number of element (from starting 0), phaseIndicator

                % if not an interior point, continue to the next element
                if isempty(quadData)
                    continue
                end

                % get data
                numberOfNodes = quadData.Lengths(1);
                dArray = quadData.Storage;

                % convert it to matlab format
                quadMtx = zeros(numberOfNodes,4);
                for n= 1:numberOfNodes
                    quadMtx(n,:) = [dArray(4*n-3) dArray(4*n-2) dArray(4*n-1) dArray(4*n)];

                end

                quadMtx = quadMtx';

                if( ~isempty( quadMtx) )
                    measure = measure + sum(quadMtx(wIndex,:));

                    % store quad data
                    if caller.IsItACutCell(e-1) == true
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'trimmed' );
                    else
                        objQuadData = appendQuadratureData(objQuadData, quadMtx, e, 'non_trimmed' );
                    end
                end
            end
            
            clear caller
            disp("BoSSS has successfuly returned")
        end

        %dummy function to avoid abstact error (the function is a replica of computeInterfaceCurveLength)
        function [measure,objQuadData] = computeAreaViaFlux2D( objBoSSS, objTest )
            warning("%s does not support computeVolumeViaFlux2D yet.", objBoSSS.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end
        
        %dummy function to avoid abstact error (the function is a replica of computeInterfaceSurfaceArea)
        function [measure,objQuadData] = computeVolumeViaFlux3D( objBoSSS, objTest )
            warning("%s does not support computeVolumeViaFlux3D yet.", objBoSSS.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end
        
        function P = HMF_order(~, Q, d)
        %HMF_ORDER  Highest polynomial degree P for HMF
        %   P = HMF_ORDER(Q, d) returns the largest integer P such that
        %   nchoosek(P + d, d) ≤ Q^d.
        %
        %   Inputs
        %     Q : number of 1-D Gauss points per axis (positive integer)
        %     d : spatial dimension (1, 2, or 3)
        %
        %   Output
        %     P : maximal polynomial degree exact for the tensor grid
            % 07.08.2025: Michael and Teoman discussed and decided to use the old
            % version to be compatible with the rest of the libraries
            % % P = 0;
            % % while nchoosek(P + d, d) <= Q^d
            % %     P = P + 1;
            % % end
            % % P = P - 1;
            P = 2*Q-1;
            if (P > 14)
                P = 14;
                disp("BoSSS does not support more polynomials having greater degree than 14. So, it will use p=14.")
            end
        end
        
        function mf = bosss_MomentFitting(~, variantName)
            asm   = NET.addAssembly(fullfile(pwd,'codes','bosss','repository','src','L4-application', ...
                'MatlabCutCellQuadInterface','bin','Release','net6.0','BoSSS.Foundation.XDG.dll'));
        
            baseT = asm.AssemblyHandle.GetType('BoSSS.Foundation.XDG.XQuadFactoryHelperBase', true);
            enumT = baseT.GetNestedType('MomentFittingVariants', System.Reflection.BindingFlags.Public);
        
            mf = System.Enum.Parse(enumT, variantName);
        end


    end

end