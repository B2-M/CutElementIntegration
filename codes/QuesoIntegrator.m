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

classdef QuesoIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Quahog code to the main code.
    % It uses the SPECTRAL method which applies Gauss quadrature to the
    % intermediate and the antiderivative quadrature.

    properties(SetAccess = private)
        n_stl_pts = 5     % number of points per patch used for the stl-generation
        polynomial_order = 2
    end

    methods(Static)
        function out = Name
            out = "Queso";
        end

        function out = InterfaceType
            out = "parametric";
        end
        
        function out = OperatingSystem
            out = ["Linux","Windows"];
        end

        function out = SupportedDimensions
            out = "3D";
        end        

        function out = IsAccessible
            out = false;
            if isCurrentFolderCorrect
                if exist('./codes/queso/QuESo','dir') == 7  % 7=name is a folder
                    if exist('./codes/queso/QuESo/libs','dir') == 7
                        out = true;
                    else
                        warning("QuesoIntegrator is not compiled. See Readme for installation instructions.")
                    end
                else
                    warning("QuesoIntegrator has not been found.")
                end
            end
        end

    end


    methods(Access = private)

        %% load required paths during initialization
        function addIntegratorPaths( ~ )
            if exist('./codes','dir') == 7
                addpath(genpath('./codes/queso'))
            else
                warning("QuesoIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

        function queso_create_stl(objQueso,objTest)
            % check number of interfaces
            if length(objTest.interface.parametric)>1
                error('queso_create_stl cannot deal with multiple interfaces so far!')
            end

            if objTest.id~=2 && objTest.id~=4 && objTest.id~=5 && objTest.id~=7
            % if objTest.id~=2 && objTest.id~=4 && objTest.id~=5 % Exclude case 
            %     % 2 (torus), case 4 (cube) and case 5 (torus with integrand) 
            %     % because the STLs are quite bad if created here; instead, 
            %     % STLs from Rhino are used. The tori in objTest2.stl and in 
            %     % objTest5.stl are generated with a tolerance of 1e-2.

                % points
                n_points = objQueso.n_stl_pts;
                points = zeros(n_points^2*length(objTest.interface.parametric{1}),3);
                count = 0;
                for ip = 1:length(objTest.interface.parametric{1})
                    if (objTest.interface.parametric{1}(ip).surf.knots{1}(1)~=0 || ...
                            objTest.interface.parametric{1}(ip).surf.knots{1}(end)~=1 || ...
                            objTest.interface.parametric{1}(ip).surf.knots{2}(1)~=0 || ...
                            objTest.interface.parametric{1}(ip).surf.knots{2}(end)~=1)
                        error('Knot vectors are not defined from 0 to 1.')
                    end
                    for iu = linspace(0,1,n_points)
                        for iv = linspace(0,1,n_points)
                            count = count + 1;
                            points(count,:) = nrbeval(objTest.interface.parametric{1}(ip).surf,{iu,iv});
                        end
                    end
                end
    
                % tet delaunay
                % Problem with this delaunayTriangulation functionality:
                % Creates overlapping edges for 3D which creates very pointed
                % faces.
                points = uniquetol(points,1e-15,'ByRows',true);
                tri = delaunayTriangulation(points(:,1),points(:,2),points(:,3));
    
%                 % plot with tetramesh
%                 tetramesh(tri)

                % get surface faces and nodes
                [F,P] = freeBoundary(tri);
    
%                 % plot with trisurf
%                 figure
%                 trisurf(F,P(:,1),P(:,2),P(:,3),'FaceColor','red');
%                 % or use patch
%                 figure
%                 patch('Faces',F,'Vertices',P,'FaceColor','red');
    
                % write stl
                filename = fullfile(pwd,'codes','queso','data',['objTest' num2str(objTest.id) '.stl']);
                TR = triangulation(F,P);
    
    %             % Alternative via convex hull
    %             [C,V] = convexHull(tri);
    %             TR = triangulation(C,tri.Points);
    
                stlwrite(TR,filename);
            end
        end

        function queso_write_json(objQueso,objTest)

            input_filename = fullfile(pwd,'codes','queso','data',['objTest' num2str(objTest.id) '.stl']);
            %             input_filename = fullfile(pwd,'codes','queso','data','cube_1.stl');	% alternative stl-mesh for example_cube_1
            %             input_filename = fullfile(pwd,'codes','queso','data','objTest2_tol1e-5.stl');
            if ~isfile(input_filename)
                error(['The geometry is not available as STL-file so far. The ' ...
                    'Queso code only runs with STLs.'])
            end

            % recover polynomial order from n_quad_pts
            % polynomial_order = 2*objQueso.n_quad_pts-1;

            % create json struct
            json_struct = struct('general_settings',struct('input_filename',input_filename, ...
                'echo_level',1),'mesh_settings',struct('b_spline_mesh',true,'lower_bound_xyz', ...
                objTest.domain.xmin,'upper_bound_xyz',objTest.domain.xmax,'lower_bound_uvw', ...
                objTest.domain.xmin,'upper_bound_uvw',objTest.domain.xmax,'polynomial_order', ...
                [objQueso.polynomial_order, objQueso.polynomial_order, objQueso.polynomial_order],'number_of_elements', ...
                [2^objTest.domain.n_refs,2^objTest.domain.n_refs,2^objTest.domain.n_refs]), ...
                'trimmed_quadrature_rule_settings', ...
                struct('moment_fitting_residual',1e-8,'min_element_volume_ratio',0.0), ...
                'non_trimmed_quadrature_rule_settings', ...
                struct('integration_method','Gauss'),'conditions', ...
                {{struct('PenaltySupportCondition',struct('input_filename',input_filename, ...
                'value',[0.0, 0.0, 0.0],'penalty_factor',1e10))}});
            % Polynomial degree of 2 is recommended
            % moment_fitting_residual: 1e-8 (standard value in code
            % (default?)); changing the value is still not pushing the
            % quadrature to machine precision -> Accuracy of the exact
            % integral?
            % Additional quadrature setting (neglect small trimmed
            % elements): "min_element_volume_ratio": 0.0 (default 1e-3,
            % ratio V_trim/V_0 on element level)
            % "conditions" are used to define boundary integration mesh which
            % might be finer than the actual stl-mesh

            txt = jsonencode(json_struct);
            fId = fopen('codes/queso/QuESoParameters.json','w');
            fwrite(fId,txt)
            fclose(fId);

        end

    end

    methods

        function obj = QuesoIntegrator(n_quad_pts)   
            obj = obj@AbstractIntegrator(n_quad_pts);
            obj.polynomial_order = ceil(n_quad_pts-0.5);
            if obj.polynomial_order > 4
                obj.polynomial_order = 4;
                warning(['Queso: polynomial_order is set to 4 which is the recommended ' ...
                    'maximum, even though n_quad_pts was chosen higher.'])
            end
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objQueso )
            out = ['nq' num2str(objQueso.n_quad_pts)];
        end
        
        function [area,objQuadData] = integrateDomain2D(~,objTest)
            warning("The provided version of Queso does not support 2D integration.");
            objQuadData = QuadratureData( objTest.dim );
            area = -1;
        end

        function [measure,objQuadData] = integrateDomain3D( objQueso, objTest )
            % Function to determine quadrature points and measure of a 3D
            % problem.
            % No elements are properly determined for coarse meshes.
            
            assert(objTest.dim == 3)

            % create stl
            objQueso.queso_create_stl(objTest);

            % write json
            objQueso.queso_write_json(objTest);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\queso\'));
            [els_trim,els_trim_ID,els_untrim,els_untrim_ID] = pyrunfile("QuESo_main.py", ...
                ["els_trim_list","els_trim_ID","els_untrim_list","els_untrim_ID"]);

            % type conversion, adding of quadrature data and measure
            % computation
            objQuadData = QuadratureData(objTest.dim);
            els_trim = cell(els_trim);
            els_trim_ID = double(els_trim_ID);
            for i=1:length(els_trim)
                els_trim{i} = double(els_trim{i});
                els_trim{i}(:,4) = els_trim{i}(:,4);
                objQuadData = appendQuadratureData(objQuadData,els_trim{i}',els_trim_ID(i),'trimmed');
            end
            els_untrim = cell(els_untrim);
            els_untrim_ID = double(els_untrim_ID);
            for i=1:length(els_untrim)
                els_untrim{i} = double(els_untrim{i});
                els_untrim{i}(:,4) = els_untrim{i}(:,4);
                objQuadData = appendQuadratureData(objQuadData,els_untrim{i}',els_untrim_ID(i),'non_trimmed');
            end

            % compute integral for arbitrary integrand (also integrand==1
            % --> volume)
            measure = objQuadData.compute_integral(objTest.integrand);
            
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objQueso, objTest )
            warning("%s does not support computeInterfaceCurveLength.", objQueso.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objQueso, objTest )
            % Function to determine quadrature points and interface surface of a 3D
            % problem.

            assert(objTest.dim == 3)

            % create stl
            objQueso.queso_create_stl(objTest);

            % write json
            objQueso.queso_write_json(objTest);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\queso\'))
            [QPs] = pyrunfile("QuESo_main_interface.py","QPs");

            % type conversion, adding of quadrature data and volume
            % computation
            objQuadData = QuadratureData(objTest.dim);
            QPs = double(QPs);
            objQuadData = appendQuadratureData(objQuadData,QPs',[],'interface');
            measure = sum(QPs(:,4));
        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objQueso, objTest )
            warning("%s does not support computeAreaViaFlux2D.", objQueso.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objQueso, objTest )
            % Function to determine quadrature points and volume of a 3D
            % problem.

            assert(objTest.dim == 3)

            % create stl
            objQueso.queso_create_stl(objTest);

            % write json
            objQueso.queso_write_json(objTest);

            insert(py.sys.path, int32(0),fullfile(pwd,'\codes\queso\'))
            [QPs,n_vecs] = pyrunfile("QuESo_main_flux.py",["QPs","n_vecs"]);

            % type conversion, adding of quadrature data and volume
            % computation
            objQuadData = QuadratureData(objTest.dim);
            QPs = double(QPs);
            n_vecs = double(n_vecs);            
            measure = 0;
            for iGP = size(QPs,1):-1:1
                if isnan(n_vecs(iGP,1)) % delete zero weights; problem is documented, but not understood
                    QPs(iGP,:) = [];
                    n_vecs(iGP,:) = [];
                else
                    measure = measure + n_vecs(iGP,:)*(QPs(iGP,1:3).*QPs(iGP,4)).'; % mapping dS seems to be already included in weight
                end
            end
            measure = measure/3;
            objQuadData = appendQuadratureData(objQuadData,QPs',[],'interface');
        end
    end

end