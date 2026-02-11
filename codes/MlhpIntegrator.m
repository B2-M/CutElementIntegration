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

classdef MlhpIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Mlhp code to the main code.

    properties(SetAccess = private)

    end

    properties(SetAccess = protected)
        SpaceTreeDepth = 3  % Number of subdivision levels of Quadtree/Octree 
        % used for computation of right-hand side.
        % Protected because it should not be changed by the user (standard
        % setting).
        % Philipp Kopp agreed in an email on the 11.7.25 that
        % there is no perfectly established value for this parameter. He
        % agreed that a value of 3 would be fine.

        SeedPoints  % Philipp Kopp suggested in an email on the 13.6.25 to 
        % choose SeedPoints=degree+3
        ResolutionMarchingCubes % Philipp Kopp suggested in an email on the 13.6.25 to 
        % choose it identical to SeedPoints
    end

    methods(Static)
        function out = Name
            out = "Mlhp";
        end

        function out = InterfaceType
            out = "implicit";
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

                fprintf("Checking for Mlhp packages...\n");
                pe = pyenv;
                if isempty(pe.Version)
                    warning("Mlhp: Python not installed")
                else
                    try
                        insert(py.sys.path, int32(0),fullfile(pwd,'\codes\mlhp\'))
                        out = pyrunfile("Mlhp_check_packages.py","out");
                        if ~out
                            warning("mlhp is missing python package. Please check " + ...
                                "that mlhp is installed. See Readme " + ...
                                "for installation instructions.")
                        else
                            fprintf("...Checking for mlhp packages was successfull.\n")
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
                addpath('./codes/mlhp')
            else
                warning("MlhpIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

    end

    methods

        function obj = MlhpIntegrator(n_quad_pts)
            obj = obj@AbstractIntegrator(n_quad_pts);
            degree = 2 * n_quad_pts - 1;
            obj.SeedPoints = degree + 3;  % Philipp Kopp suggested in an email on the 13.6.25 to 
            % choose SeedPoints=degree+3
            obj.ResolutionMarchingCubes = obj.SeedPoints; % Philipp Kopp suggested in an email on the 13.6.25 to 
            % choose it identical to SeedPoints
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objMlhp )
            out = ['nq' num2str(objMlhp.n_quad_pts)];
        end

        function [measure,objQuadData] = integrateDomain2D( objMlhp, objTest )
            % Function to determine quadrature points and measure of a 2D
            % problem.

            assert(objTest.dim == 2)

            % translate implicit interface
            phi_strings = objMlhp.translate_implicit_boundary(objTest.interface.implicit,objTest.domain);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',int32(objTest.domain.n_refs));

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\mlhp\'))
            
            [~,els_trim,els_trim_ID,els_untrim,els_untrim_ID] = pyrunfile("mlhp_main.py", ...
                ["measure","els_trim_list","els_trim_ID","els_untrim_list","els_untrim_ID"], ...
                domain_inp=domain, ...
                treedepth=int32(objMlhp.SpaceTreeDepth),n_quad_pts=int32(objMlhp.n_quad_pts), ...
                interfaces=phi_strings,integral_type='bulk',nseedpoints=int32(objMlhp.SeedPoints));

            % type conversion, adding of quadrature data and measure
            % computation
            objQuadData = QuadratureData(objTest.dim);
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID)+1;    % +1 because indexing in Python starts from 0
            for i=1:length(els_trim)
                els_trim{i} = double(els_trim{i});
                objQuadData = appendQuadratureData(objQuadData,els_trim{i}', ...
                    els_trim_ID(i),'trimmed');
            end
            els_untrim = cell(els_untrim);
            els_untrim_ID = double(els_untrim_ID)+1;    % +1 because indexing in Python starts from 0
            for i=1:length(els_untrim)
                els_untrim{i} = double(els_untrim{i});
                objQuadData = appendQuadratureData(objQuadData,els_untrim{i}', ...
                    els_untrim_ID(i),'non_trimmed');
            end

            % compute integral for arbitrary integrand (also integrand==1
            % --> volume)
            measure = objQuadData.compute_integral(objTest.integrand);
        end

        function [measure,objQuadData] = integrateDomain3D( objMlhp, objTest )
            % Function to determine quadrature points and measure of a 3D
            % problem.

            assert(objTest.dim == 3)

            % translate implicit interface
            phi_strings = objMlhp.translate_implicit_boundary(objTest.interface.implicit,objTest.domain);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',int32(objTest.domain.n_refs));

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\mlhp\'))
            
            [~,els_trim,els_trim_ID,els_untrim,els_untrim_ID] = pyrunfile("mlhp_main.py", ...
                ["measure","els_trim_list","els_trim_ID","els_untrim_list","els_untrim_ID"], ...
                domain_inp=domain, ...
                treedepth=int32(objMlhp.SpaceTreeDepth),n_quad_pts=int32(objMlhp.n_quad_pts), ...
                interfaces=phi_strings,integral_type='bulk',nseedpoints=int32(objMlhp.SeedPoints));

            % type conversion, adding of quadrature data and measure
            % computation
            objQuadData = QuadratureData(objTest.dim);
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID)+1;    % +1 because indexing in Python starts from 0
            for i=1:length(els_trim)
                els_trim{i} = double(els_trim{i});
                objQuadData = appendQuadratureData(objQuadData,els_trim{i}', ...
                    els_trim_ID(i),'trimmed');
            end
            els_untrim = cell(els_untrim);
            els_untrim_ID = double(els_untrim_ID)+1;    % +1 because indexing in Python starts from 0
            for i=1:length(els_untrim)
                els_untrim{i} = double(els_untrim{i});
                objQuadData = appendQuadratureData(objQuadData,els_untrim{i}', ...
                    els_untrim_ID(i),'non_trimmed');
            end

            % compute integral for arbitrary integrand (also integrand==1
            % --> volume)
            measure = objQuadData.compute_integral(objTest.integrand);
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objMlhp, objTest )
            % Function to determine quadrature points and interface length of a 2D
            % problem.
            warning("%s does not support computeInterfaceCurveLength.", objMlhp.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objMlhp, objTest )
            % Function to determine quadrature points and interface area of a 3D
            % problem.

            assert(objTest.dim == 3)

            % translate implicit interface
            phi_strings = objMlhp.translate_implicit_boundary(objTest.interface.implicit,objTest.domain);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',int32(objTest.domain.n_refs));

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\mlhp\'))
            
            [~,els_trim,els_trim_ID,els_untrim,els_untrim_ID] = pyrunfile("mlhp_main.py", ...
                ["measure","els_trim_list","els_trim_ID","els_untrim_list","els_untrim_ID"], ...
                domain_inp=domain, ...
                treedepth=int32(objMlhp.SpaceTreeDepth),n_quad_pts=int32(objMlhp.n_quad_pts), ...
                interfaces=phi_strings,integral_type='interface',nseedpoints=int32(objMlhp.SeedPoints), ...
                resolutionPerCell=int32(objMlhp.ResolutionMarchingCubes));

            % type conversion, adding of quadrature data and measure
            % computation
            objQuadData = QuadratureData(objTest.dim);
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID)+1;    % +1 because indexing in Python starts from 0
            for i=1:length(els_trim)
                els_trim{i} = double(els_trim{i});
                objQuadData = appendQuadratureData(objQuadData,els_trim{i}', ...
                    els_trim_ID(i),'trimmed');
            end
            els_untrim = cell(els_untrim);
            els_untrim_ID = double(els_untrim_ID)+1;    % +1 because indexing in Python starts from 0
            for i=1:length(els_untrim)
                els_untrim{i} = double(els_untrim{i});
                objQuadData = appendQuadratureData(objQuadData,els_untrim{i}', ...
                    els_untrim_ID(i),'non_trimmed');
            end

            % compute integral for arbitrary integrand (also integrand==1
            % --> volume)
            measure = objQuadData.compute_integral(objTest.integrand);
        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objMlhp, objTest )
            % Function to determine quadrature points and area of a 2D problem 
            % by means of the flux.
            warning("%s does not support computeAreaViaFlux2D.", objMlhp.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objMlhp, objTest )
            % Function to determine quadrature points and volume of a 3D problem 
            % by means of the flux.
            warning("%s does not support computeVolumeViaFlux3D.", objMlhp.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function phi_strings = translate_implicit_boundary(~,implicit,domain)
            % check that interfaces are not defined piecewise
            for ic = 1:length(implicit)
                if contains(func2str(implicit{ic}.phi),'geo_implicit_piecewise')
                    error('MlhpIntegrator cannot handle piecewise defined interfaces.')
                end
            end
        
            % Remove boundary curves which are identical with the
            % domain boundary
            implicit = remove_implicit_domain_boundary(implicit,domain);

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