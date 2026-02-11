classdef GridapIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Quahog code to the main code.
    % It uses the SPECTRAL method which applies Gauss quadrature to the
    % intermediate and the antiderivative quadrature.

    properties(SetAccess = private)
        quad_degree     % Degree of the quadrature rule
    end

    methods(Static)
        function out = Name
            out = "Gridap";
        end

        function out = InterfaceType
            out = "parametric";
        end
        
        function out = OperatingSystem
            out = "Windows";
        end

        function out = SupportedDimensions
            out = ["2D","3D"];
        end        

        function out = IsAccessible
            out = false;
            if isCurrentFolderCorrect
                fprintf("Checking for Gridap packages...\n");
                pe = pyenv;
                if isempty(pe.Version)
                    warning("Gridap: Python not installed")
                else
                    try
                        insert(py.sys.path, int32(0), fullfile(pwd, '\codes\gridap\'));
                        out = pyrunfile("Gridap_check_packages.py", "out");
                        if ~out
                            warning("Gridap is missing python packages. Please check " + ...
                                "that ngsolve, netgen, and xfem are installed. See Readme " + ...
                                "for installation instructions.");
                        else
                            fprintf("...Checking for Gridap packages was successful.\n");
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
                addpath(genpath('./codes/gridap'))
            else
                warning("GridapIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

    end

    methods

        function obj = GridapIntegrator(n_quad_pts)
            obj = obj@AbstractIntegrator(n_quad_pts);
            obj.quad_degree = 2*n_quad_pts-1;
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objGridap )
            out = ['p' num2str(objGridap.quad_degree)];
        end
        
        function [measure,objQuadData] = integrateDomain2D( objGridap, objTest)
            % Function to determine quadrature points and measure of a 2D
            % problem.
            
            assert(objTest.dim == 2)

            % check test object
            objGridap.check_objTest(objTest);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            % translate implicit interface
            phi_strings = cell(1,length(objTest.interface.implicit));
            for ic = 1:length(objTest.interface.implicit)
                phi=objTest.interface.implicit{ic}.phi;
                phi = strrep(char(sym(phi)),'x','x[1]');
                phi = strrep(phi,'y','x[2]');
                phi_strings{ic} = strrep(phi,'z','x[3]');
            end
%             phi=objTest.interface.implicit{ic}.phi;
%             phi = strrep(char(sym(phi)),'x','x[1]');
%             phi = strrep(phi,'y','x[2]');
%             phi_strings = strrep(phi,'z','x[3]');

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\gridap\'))
            disp(fullfile(pwd,'\codes\gridap\'))
%             current_folder = pwd;
%             cd(fullfile(current_folder,'\codes\gridap\'))
            [els_trim,els_trim_ID,els_untrim,els_untrim_ID,~] = pyrunfile("Gridap_main.py", ...
                ["els_trim","els_trim_ID","els_untrim","els_untrim_ID","measure"], ...
                domain=domain,interfaces=phi_strings,degree=int8(objGridap.quad_degree), ...
                integral_type='bulk');
%             cd(current_folder)

            % type conversion, adding of quadrature data and measure
            % computation
            objQuadData = QuadratureData(objTest.dim);
            measure = 0;
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID);
            for i=1:length(els_trim)
                el_temp = cell(els_trim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_trim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_trim_ID(i),'trimmed');
                measure = measure + sum(el(3,:));
            end
            els_untrim = cell(els_untrim);
            els_untrim_ID = double(els_untrim_ID);
            for i=1:length(els_untrim)
                el_temp = cell(els_untrim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_untrim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_untrim_ID(i),'non_trimmed');
                measure = measure + sum(el(3,:));
            end

            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the area is not 
                % requested as computed above but an integral with an 
                % integrand ~=1
            end
        end

        function [measure,objQuadData] = integrateDomain3D( objGridap, objTest )
            % Function to determine quadrature points and measure of a 3D
            % problem.
            
            assert(objTest.dim == 3)

            % check test object
            objGridap.check_objTest(objTest);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            % translate implicit interface
            phi_strings = cell(1,length(objTest.interface.implicit));
            for ic = 1:length(objTest.interface.implicit)
                phi = objTest.interface.implicit{ic}.phi;
                phi = strrep(char(sym(phi)),'x','x[1]');
                phi = strrep(phi,'y','x[2]');
                phi_strings{ic} = strrep(phi,'z','x[3]');
            end
%             phi=objTest.interface.implicit{ic}.phi;
%             phi = strrep(char(sym(phi)),'x','x[1]');
%             phi = strrep(phi,'y','x[2]');
%             phi_strings = strrep(phi,'z','x[3]');

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\gridap\'))
            [els_trim,els_trim_ID,els_untrim,els_untrim_ID,~] = pyrunfile("Gridap_main.py", ...
                ["els_trim","els_trim_ID","els_untrim","els_untrim_ID","measure"], ...
                domain=domain,interfaces=phi_strings,degree=int8(objGridap.quad_degree), ...
                integral_type='bulk');

            % type conversion, adding of quadrature data and area
            % computation
            objQuadData = QuadratureData(objTest.dim);
            measure = 0;
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID);
            for i=1:length(els_trim)
                el_temp = cell(els_trim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_trim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_trim_ID(i),'trimmed');
                measure = measure + sum(el(4,:));
            end
            els_untrim = cell(els_untrim);
            els_untrim_ID = double(els_untrim_ID);
            for i=1:length(els_untrim)
                el_temp = cell(els_untrim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_untrim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_untrim_ID(i),'trimmed');
                measure = measure + sum(el(4,:));
            end

            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the volume is not 
                % requested as computed above but an integral with an 
                % integrand ~=1
            end
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objGridap, objTest )
            % Function to determine quadrature points and interface length of a 2D
            % problem.

            assert(objTest.dim == 2)

            % check test object
            objGridap.check_objTest(objTest);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            % translate implicit interface
            phi_strings = cell(1,length(objTest.interface.implicit));
            for ic = 1:length(objTest.interface.implicit)
                phi=objTest.interface.implicit{ic}.phi;
                phi = strrep(char(sym(phi)),'x','x[1]');
                phi = strrep(phi,'y','x[2]');
                phi_strings{ic} = strrep(phi,'z','x[3]');
            end

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\gridap\'))
            [els_trim,els_trim_ID,~,~,~] = pyrunfile("Gridap_main.py", ...
                ["els_trim","els_trim_ID","els_untrim","els_untrim_ID","measure"], ...
                domain=domain,interfaces=phi_strings,degree=int8(objGridap.quad_degree), ...
                integral_type='interface');

            % type conversion, adding of quadrature data and area
            % computation
            objQuadData = QuadratureData(objTest.dim);
            measure = 0;
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID);
            for i=1:length(els_trim)
                el_temp = cell(els_trim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_trim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_trim_ID(i),'interface');
                measure = measure + sum(el(3,:));
            end
        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objGridap, objTest )
            % Function to determine quadrature points and interface surface of a 3D
            % problem.

            assert(objTest.dim == 3)

            % check test object
            objGridap.check_objTest(objTest);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            % translate implicit interface
            phi_strings = cell(1,length(objTest.interface.implicit));
            for ic = 1:length(objTest.interface.implicit)
                phi=objTest.interface.implicit{ic}.phi;
                phi = strrep(char(sym(phi)),'x','x[1]');
                phi = strrep(phi,'y','x[2]');
                phi_strings{ic} = strrep(phi,'z','x[3]');
            end

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\gridap\'))
            [els_trim,els_trim_ID,~,~,~] = pyrunfile("Gridap_main.py", ...
                ["els_trim","els_trim_ID","els_untrim","els_untrim_ID","measure"], ...
                domain=domain,interfaces=phi_strings,degree=int8(objGridap.quad_degree), ...
                integral_type='interface');

            % type conversion, adding of quadrature data and area
            % computation
            objQuadData = QuadratureData(objTest.dim);
            measure = 0;
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID);
            for i=1:length(els_trim)
                el_temp = cell(els_trim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_trim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_trim_ID(i),'interface');
                measure = measure + sum(el(3,:));
            end
        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objGridap, objTest )
            % Function to determine quadrature points along interface and to
            % compute the area of a 2D problem by means of a flux term.

            assert(objTest.dim == 2)

            % check test object
            objGridap.check_objTest(objTest);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            % translate implicit interface
            phi_strings = cell(1,length(objTest.interface.implicit));
            for ic = 1:length(objTest.interface.implicit)
                phi=objTest.interface.implicit{ic}.phi;
                phi = strrep(char(sym(phi)),'x','x[1]');
                phi = strrep(phi,'y','x[2]');
                phi_strings{ic} = strrep(phi,'z','x[3]');
            end

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\gridap\'))
            [els_trim,els_trim_ID,~,~,measure] = pyrunfile("Gridap_main.py", ...
                ["els_trim","els_trim_ID","els_untrim","els_untrim_ID","measure"],domain=domain, ...
                interfaces=phi_strings,degree=int8(objGridap.quad_degree),integral_type='flux');

            % type conversion, adding of quadrature data and area
            % computation
            objQuadData = QuadratureData(objTest.dim);
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID);
            for i=1:length(els_trim)
                el_temp = cell(els_trim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_trim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_trim_ID(i),'interface');
            end
        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objGridap, objTest )
            % Function to determine quadrature points along interface and to
            % compute the volume of a 3D problem by means of a flux term.

            assert(objTest.dim == 3)

            % check test object
            objGridap.check_objTest(objTest);

            % translate data
            domain = struct('xmin',objTest.domain.xmin,'xmax',objTest.domain.xmax, ...
                'n_refs',objTest.domain.n_refs);

            % translate implicit interface
            phi_strings = cell(1,length(objTest.interface.implicit));
            for ic = 1:length(objTest.interface.implicit)
                phi=objTest.interface.implicit{ic}.phi;
                phi = strrep(char(sym(phi)),'x','x[1]');
                phi = strrep(phi,'y','x[2]');
                phi_strings{ic} = strrep(phi,'z','x[3]');
            end

            % compute integral
            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\gridap\'))
            [els_trim,els_trim_ID,~,~,measure] = pyrunfile("Gridap_main.py", ...
                ["els_trim","els_trim_ID","els_untrim","els_untrim_ID","measure"], ...
                domain=domain,interfaces=phi_strings,degree=int8(objGridap.quad_degree), ...
                integral_type='flux');

            % type conversion, adding of quadrature data and area
            % computation
            objQuadData = QuadratureData(objTest.dim);
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID);
            for i=1:length(els_trim)
                el_temp = cell(els_trim{i});
                el = [];
                for j=1:length(el_temp)
                    el = [el,double(el_temp{j})']; %#ok<AGROW> 
                end
                els_trim{i} = el;
                objQuadData = appendQuadratureData(objQuadData,el,els_trim_ID(i),'interface');
            end
        end

        function check_objTest(~,objTest)
            % check that curves are not defined piecewise
            for ic = 1:length(objTest.interface.implicit)
                if contains(func2str(objTest.interface.implicit{ic}.phi),'geo_implicit_piecewise')
                    error('GridapIntegrator cannot handle piecewise defined interfaces.')
                end
            end

            % Check that not a single element is used as mesh because that
            % causes problems when distinguishing in trimmed and untrimmed
            % elements in the Julia code.
            if objTest.domain.n_refs == 0
                error('GridapIntegrator cannot handle single element meshes.')
            end
        end

    end % methods

end