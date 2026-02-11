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

classdef NgsxfemIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Quahog code to the main code.
    % It uses the SPECTRAL method which applies Gauss quadrature to the
    % intermediate and the antiderivative quadrature.

    properties(SetAccess = private)
        quad_degree     % Degree of the quadrature rule
        reparam_degree
    end

    methods(Static)
        function out = Name
            out = "Ngsxfem";
        end

        function out = InterfaceType
            out = "implicit";
        end

        function out = OperatingSystem
            out = ["Windows"]; % "Linux","Windows"] % the Linux support is de-activated as the server currently does not support it
        end

        function out = SupportedDimensions
            out = ["2D","3D"];
        end

        function out = IsAccessible
            out = false; % Default to false in case of failure
            if isCurrentFolderCorrect
                fprintf("Checking for Ngsxfem packages...\n");
                pe = pyenv;
                if isempty(pe.Version)
                    warning("Ngsxfem: Python not installed")
                else
                    try
                        insert(py.sys.path, int32(0), fullfile(pwd, '\codes\ngsxfem\'));
                        out = pyrunfile("Ngsxfem_check_packages.py", "out");
                        if ~out
                            warning("Ngsxfem is missing python packages. Please check " + ...
                                "that ngsolve, netgen, and xfem are installed. See Readme " + ...
                                "for installation instructions.");
                        else
                            fprintf("...Checking for Ngsxfem packages was successful.\n");
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
        function addIntegratorPaths( ~ )
            if exist('./codes','dir') == 7
                addpath(genpath('./codes/ngsxfem'))
            else
                warning("NgsxfemIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

    end

    methods

        function obj = NgsxfemIntegrator(n_quad_pts,reparam_degree)
            obj = obj@AbstractIntegrator(n_quad_pts);
            obj.quad_degree = 2*n_quad_pts-1;
            if nargin==2 && ~isempty(reparam_degree)
                obj.reparam_degree = reparam_degree;
            end
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objNgsxfem )
            out = ['p' num2str(objNgsxfem.quad_degree)];
        end

        function [measure,objQuadData] = integrateDomain2D( objNgsxfem, objTest )
            % Function to determine measure of a 2D problem.

            assert(objTest.dim == 2)

            % check that curves are not defined piecewise
            for ic = 1:length(objTest.interface.implicit)
                if contains(func2str(objTest.interface.implicit{ic}.phi),'geo_implicit_piecewise')
                    error('NgsxfemIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',int8(objTest.domain.n_refs));
            order = int8((objNgsxfem.n_quad_pts*2)-1);    % jumps over certain orders which have same number of QP

            % translate implicit interface
            phi_strings = objNgsxfem.translate_implicit_boundary(objTest.interface.implicit, ...
                objTest.domain);

            % translate integrand
            integrand = strrep(string(objTest.integrand),'^','**');

            % check reparam degree
            objNgsxfem = check_reparam_degree(objNgsxfem,objTest);

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\ngsxfem\'))
            [measure] = pyrunfile("Ngsxfem_main.py","measure",domain=domain,interfaces=phi_strings, ...
                order=order,reparam_degree=int8(objNgsxfem.reparam_degree),integral_type='bulk',integrand=integrand);

            % Create empty QuadData
            % It was not possible so far to obtain quadrature points from
            % this code.
            objQuadData = QuadratureData(objTest.dim);
        end

        function [measure,objQuadData] = integrateDomain3D( objNgsxfem, objTest )
            % Function to determine area of a 3D problem.

            assert(objTest.dim == 3)

            % check that curves are not defined piecewise
            for ic = 1:length(objTest.interface.implicit)
                if contains(func2str(objTest.interface.implicit{ic}.phi),'geo_implicit_piecewise')
                    error('NgsxfemIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);
            order = int8((objNgsxfem.n_quad_pts*2)-1);    % jumps over certain orders which have same number of QP

            % translate implicit interface
            phi_strings = objNgsxfem.translate_implicit_boundary(objTest.interface.implicit, ...
                objTest.domain);

            % translate integrand
            integrand = strrep(string(objTest.integrand),'^','**');

            % check reparam degree
            objNgsxfem = check_reparam_degree(objNgsxfem,objTest);

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\ngsxfem\'))
            [measure] = pyrunfile("Ngsxfem_main.py","measure",domain=domain,interfaces=phi_strings, ...
                order=order,reparam_degree=int8(objNgsxfem.reparam_degree),integral_type='bulk',integrand=integrand);

            % Create empty QuadData
            % It was not possible so far to obtain quadrature points from
            % this code.
            objQuadData = QuadratureData(objTest.dim);
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objNgsxfem, objTest )
            % Function to determine interface length of a 2D
            % problem.

            assert(objTest.dim == 2)

            % check that curves are not defined piecewise
            for ic = 1:length(objTest.interface.implicit)
                if contains(func2str(objTest.interface.implicit{ic}.phi),'geo_implicit_piecewise')
                    error('NgsxfemIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);
            order = int8((objNgsxfem.n_quad_pts*2)-1);    % jumps over certain orders which have same number of QP

            % translate implicit interface
            phi_strings = objNgsxfem.translate_implicit_boundary(objTest.interface.implicit, ...
                objTest.domain);

            % check reparam degree
            objNgsxfem = check_reparam_degree(objNgsxfem,objTest);

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\ngsxfem\'))
            [measure] = pyrunfile("Ngsxfem_main.py","measure",domain=domain,interfaces=phi_strings, ...
                order=order,reparam_degree=int8(objNgsxfem.reparam_degree), ...
                integral_type='interface',integrand='1');

            % Create empty QuadData
            % It was not possible so far to obtain quadrature points from
            % this code.
            objQuadData = QuadratureData(objTest.dim);
        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objNgsxfem, objTest )
            % Function to determine quadrature points and interface surface of a 3D
            % problem.

            assert(objTest.dim == 3)

            % check that curves are not defined piecewise
            for ic = 1:length(objTest.interface.implicit)
                if contains(func2str(objTest.interface.implicit{ic}.phi),'geo_implicit_piecewise')
                    error('NgsxfemIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);
            order = int8((objNgsxfem.n_quad_pts*2)-1);    % jumps over certain orders which have same number of QP

            % translate implicit interface
            phi_strings = objNgsxfem.translate_implicit_boundary(objTest.interface.implicit, ...
                objTest.domain);

            % check reparam degree
            objNgsxfem = check_reparam_degree(objNgsxfem,objTest);

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\ngsxfem\'))
            [measure] = pyrunfile("Ngsxfem_main.py","measure",domain=domain,interfaces=phi_strings, ...
                order=order,reparam_degree=int8(objNgsxfem.reparam_degree), ...
                integral_type='interface',integrand='1');

            % Create empty QuadData
            % It was not possible so far to obtain quadrature points from
            % this code.
            objQuadData = QuadratureData(objTest.dim);
        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objNgsxfem, objTest )
            % Function to determine area of a 2D problem by means of the flux.

            assert(objTest.dim == 2)

            if length(objTest.interface.implicit) > 1
                error('NgsxfemIntegrator cannot handle multiple level-set functions in flux computation.')
            end

            % check that curves are not defined piecewise
            for ic = 1:length(objTest.interface.implicit)
                if contains(func2str(objTest.interface.implicit{ic}.phi),'geo_implicit_piecewise')
                    error('NgsxfemIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);
            order = int8((objNgsxfem.n_quad_pts*2)-1);    % jumps over certain orders which have same number of QP

            % translate implicit interface
            phi_strings = objNgsxfem.translate_implicit_boundary(objTest.interface.implicit, ...
                objTest.domain);

            % check reparam degree
            objNgsxfem = check_reparam_degree(objNgsxfem,objTest);

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\ngsxfem\'))
            [measure] = pyrunfile("Ngsxfem_main.py","measure",domain=domain,interfaces=phi_strings, ...
                order=order,reparam_degree=int8(objNgsxfem.reparam_degree), ...
                integral_type='flux',integrand='1');

            % Create empty QuadData
            % It was not possible so far to obtain quadrature points from
            % this code.
            objQuadData = QuadratureData(objTest.dim);
        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objNgsxfem, objTest )
            % Function to determine area of a 3D problem by means of the flux.

            assert(objTest.dim == 3)

            if length(objTest.interface.implicit) > 1
                error('NgsxfemIntegrator cannot handle multiple level-set functions in flux computation.')
            end

            % check that curves are not defined piecewise
            for ic = 1:length(objTest.interface.implicit)
                if contains(func2str(objTest.interface.implicit{ic}.phi),'geo_implicit_piecewise')
                    error('NgsxfemIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',int8(objTest.domain.n_refs));
            order = int8((objNgsxfem.n_quad_pts*2)-1);    % jumps over certain orders which have same number of QP

            % translate implicit interface
            phi_strings = objNgsxfem.translate_implicit_boundary(objTest.interface.implicit, ...
                objTest.domain);

            % check reparam degree
            objNgsxfem = check_reparam_degree(objNgsxfem,objTest);

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\ngsxfem\'))
            [measure] = pyrunfile("Ngsxfem_main.py","measure",domain=domain,interfaces=phi_strings, ...
                order=order,reparam_degree=int8(objNgsxfem.reparam_degree),integral_type='flux',integrand='1');

            % Create empty QuadData
            % It was not possible so far to obtain quadrature points from
            % this code.
            objQuadData = QuadratureData(objTest.dim);
        end

        function objNgsxfem = check_reparam_degree(objNgsxfem,objTest)
            % It was observed that ngsxfem generates unstable results if
            % the mesh mapping order (reparam_degree) is higher than the
            % actual curve degree. Therefore, this is checked here and in
            % case the setting reparam_degree is higher than the curve
            % degree, it is set to that one. If the degree cannot be
            % determined because the curve is not a polynomial,
            % reparam_degree is set to two.

            implicit = objTest.interface.implicit;
            if objNgsxfem.reparam_degree>2
                syms x y z
                deg_max = 0;
                if objTest.dim==2 && any(objTest.id==[12,13,21,24,25]) % write explicit exemption for problematic case
                    objNgsxfem.reparam_degree = 2;
                else
                    for ic = 1:length(implicit)
                        phi=implicit{ic}.phi;
                        try
                            f(x,y,z) = sym(phi); %#ok<AGROW>
                            deg = polynomialDegree(f,[x,y,z]);
                            if deg > deg_max
                                deg_max = deg;
                            end
                        catch
                            objNgsxfem.reparam_degree = 2;
                            break
                        end
                    end
                    if objNgsxfem.reparam_degree > deg_max
                        objNgsxfem.reparam_degree = deg_max;
                    end
                end
            end
        end

        function phi_strings = translate_implicit_boundary(~,implicit,domain)
            % remove boundary curves which are identical with the
            % domain boundary
            implicit = remove_implicit_domain_boundary(implicit,domain);

            phi_strings = cell(1,length(implicit));
            for ic = 1:length(implicit)
                phi=implicit{ic}.phi;
                phi_strings{ic} = strrep(char(sym(phi)),'^','**');
            end
        end
    end

end