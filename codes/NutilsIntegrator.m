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

classdef NutilsIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Nutils code to the main code.
    % It uses the SPECTRAL method which applies Gauss quadrature to the
    % intermediate and the antiderivative quadrature.

    properties(SetAccess = private)
        quad_degree         % Degree of the quadrature rule
        SpaceTreeDepth = 3  % number of subdivision levels of Quadtree/Octree, 
        % additional tessellation on lowest level
    end

    methods(Static)
        function out = Name
            out = "Nutils";
        end

        function out = InterfaceType
            out = "parametric";
        end
        
        function out = OperatingSystem
            out = ["Linux","Windows"];
        end

        function out = SupportedDimensions
            out = ["2D","3D"];
        end        

        function out = IsAccessible
            out = false;
            if isCurrentFolderCorrect

                fprintf("Checking for Nutils packages...\n");
                pe = pyenv;
                if isempty(pe.Version)
                    warning("Nutils: Python not installed")
                else
                    try
                        insert(py.sys.path, int32(0),fullfile(pwd,'\codes\nutils\'))
                        out = pyrunfile("check_packages.py","out");
                        if ~out
                            warning("Nutils is missing python package. Please check " + ...
                                "that nutils is installed. See Readme " + ...
                                "for installation instructions.")
                        else
                            fprintf("...Checking for Nutils packages was successfull.\n") 
                        end
                    catch
                        warning("An error occurred while checking the packages.");
                    end
                end
            end
        end

    end


    methods(Access = private)

        %% load required paths during initialization
        function addIntegratorPaths( this )
            if exist('./codes','dir') == 7
                addpath('./codes/nutils')
            else
                warning("NutilsIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

    end

    methods

        function obj = NutilsIntegrator(n_quad_pts, SpaceTreeDepth )
            obj = obj@AbstractIntegrator(n_quad_pts);
            if nargin==2 && ~isempty(SpaceTreeDepth)
                obj.SpaceTreeDepth = SpaceTreeDepth;
            end
            obj.quad_degree = 2*n_quad_pts-1;
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objNutils )
            out = ['p' num2str(objNutils.quad_degree) '-sub' num2str(objNutils.SpaceTreeDepth)];
        end

        function [measure,objQuadData] = integrateDomain2D( objNutils, objTest )
            % Function to determine quadrature points and measure of a 2D
            % problem.

            assert(objTest.dim == 2)

            objQuadData = QuadratureData(objTest.dim);

            % translate implicit interface
            phi_strings = objNutils.translate_implicit_boundary(objTest.interface.implicit);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\nutils\'))
            
            [measure,QP,weights] = pyrunfile("nutils_main.py",["measure","QP","weights"],domain=domain, ...
                maxrefine=int32(objNutils.SpaceTreeDepth),degree=int32(objNutils.quad_degree), ...
                interfaces=phi_strings,integral_type='bulk');

            % Place all points in one element because it was not possible so 
            % far to order the quadrature points elementwise from this code.
            QP = double(QP)';
            weights = double(weights);
            if ~isempty(weights)
                objQuadData = objQuadData.appendQuadratureData([QP;weights],1,'trimmed');
            end

            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the measure is not 
                % requested as computed above but as an integral with an 
                % integrand ~=1
            end
        end

        function [measure,objQuadData] = integrateDomain3D( objNutils, objTest )
            % Function to determine quadrature points and measure of a 3D
            % problem.

            assert(objTest.dim == 3)

            objQuadData = QuadratureData(objTest.dim);

            % translate implicit interface
            phi_strings = objNutils.translate_implicit_boundary(objTest.interface.implicit);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\nutils\'))
            
            [measure,QP,weights] = pyrunfile("nutils_main.py",["measure","QP","weights"],domain=domain, ...
                maxrefine=int32(objNutils.SpaceTreeDepth),degree=int32(objNutils.quad_degree), ...
                interfaces=phi_strings,integral_type='bulk');

            % Place all points in one element because it was not possible so 
            % far to order the quadrature points elementwise from this code.
            QP = double(QP)';
            weights = double(weights);
            if ~isempty(weights)
                objQuadData = objQuadData.appendQuadratureData([QP;weights],1,'trimmed');
            end

            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the measure is not 
                % requested as computed above but as an integral with an 
                % integrand ~=1
            end
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objNutils, objTest )
            % Function to determine quadrature points and interface length of a 2D
            % problem.

            assert(objTest.dim == 2)

            objQuadData = QuadratureData(objTest.dim);

            % translate implicit interface
            phi_strings = objNutils.translate_implicit_boundary(objTest.interface.implicit);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\nutils\'))
            
            [measure,QP,weights] = pyrunfile("nutils_main.py",["measure","QP","weights"],domain=domain, ...
                maxrefine=int32(objNutils.SpaceTreeDepth),degree=int32(objNutils.quad_degree), ...
                interfaces=phi_strings,integral_type='interface');
            
            % Place all points in one element because it was not possible so 
            % far to order the quadrature points elementwise from this code.
            QP = double(QP)';
            weights = double(weights);
            if ~isempty(weights)
                objQuadData = objQuadData.appendQuadratureData([QP;weights],1,'interface');
            end
        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objNutils, objTest )
            % Function to determine quadrature points and interface area of a 3D
            % problem.

            assert(objTest.dim == 3)

            objQuadData = QuadratureData(objTest.dim);

            % translate implicit interface
            phi_strings = objNutils.translate_implicit_boundary(objTest.interface.implicit);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\nutils\'))
            
            [measure,QP,weights] = pyrunfile("nutils_main.py",["measure","QP","weights"],domain=domain, ...
                maxrefine=int32(objNutils.SpaceTreeDepth),degree=int32(objNutils.quad_degree), ...
                interfaces=phi_strings,integral_type='interface');
            
            % Place all points in one element because it was not possible so 
            % far to order the quadrature points elementwise from this code.
            QP = double(QP)';
            weights = double(weights);
            if ~isempty(weights)
                objQuadData = objQuadData.appendQuadratureData([QP;weights],1,'interface');
            end
        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objNutils, objTest )
            % Function to determine quadrature points and area of a 2D problem 
            % by means of the flux.

            assert(objTest.dim == 2)

            objQuadData = QuadratureData(objTest.dim);

            % translate implicit interface
            phi_strings = objNutils.translate_implicit_boundary(objTest.interface.implicit);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\nutils\'))
            
            [measure,QP,weights] = pyrunfile("nutils_main.py",["measure","QP","weights"],domain=domain, ...
                maxrefine=int32(objNutils.SpaceTreeDepth),degree=int32(objNutils.quad_degree), ...
                interfaces=phi_strings,integral_type='flux');
            
            % Place all points in one element because it was not possible so 
            % far to order the quadrature points elementwise from this code.
            QP = double(QP)';
            weights = double(weights);
            if ~isempty(weights)
                objQuadData = objQuadData.appendQuadratureData([QP;weights],1,'interface');
            end
        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objNutils, objTest )
            % Function to determine quadrature points and volume of a 3D problem 
            % by means of the flux.

            assert(objTest.dim == 3)

            objQuadData = QuadratureData(objTest.dim);

            % translate implicit interface
            phi_strings = objNutils.translate_implicit_boundary(objTest.interface.implicit);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\nutils\'))
            
            [measure,QP,weights] = pyrunfile("nutils_main.py",["measure","QP","weights"],domain=domain, ...
                maxrefine=int32(objNutils.SpaceTreeDepth),degree=int32(objNutils.quad_degree), ...
                interfaces=phi_strings,integral_type='flux');

            % Place all points in one element because it was not possible so 
            % far to order the quadrature points elementwise from this code.
            QP = double(QP)';
            weights = double(weights);
            if ~isempty(weights)
                objQuadData = objQuadData.appendQuadratureData([QP;weights],1,'interface');
            end
        end

        function phi_strings = translate_implicit_boundary(~,implicit)
            % check that interfaces are not defined piecewise
            for ic = 1:length(implicit)
                if contains(func2str(implicit{ic}.phi),'geo_implicit_piecewise')
                    error('NutilsIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % translate implicit interface
            phi_strings = cell(1,length(implicit));
            for ic = 1:length(implicit)
                phi = implicit{ic}.phi;
                phi = strrep(char(sym(phi)),'^','**');
                phi = insert_dot_after_number(phi); % Necessary because of 
                % problematic treatment of long integers. for windows, it was 
                % sufficient to check whether int64 is used. However, problems 
                % were observed for linux independent of the integer type. It 
                % seems to function with this workaround.
                phi_strings{ic} = phi;
            end
        end
    end

end