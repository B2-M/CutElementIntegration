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

classdef FcmlabIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Fcmlab to the main code.

    properties(SetAccess = private)
        SpaceTreeDepth = 1  % number of subdivision levels of Quadtree/Octree; 
                            % in original code most of the time 3 used, but 
                            % at first reduced for speed-up
        SeedPoints = 10     % number of intermediate points on element to find 
                            % intersections; default number as in
                            % "AnnularPlateLinesElementwise.m"
    end

    methods(Static)
        function out = Name
            out = "Fcmlab";
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
                if exist('./codes/fcmlab/fcmlab','dir') == 7
                    if numel(dir('./codes/fcmlab/fcmlab')) > 2
                            out = true;
                    end
                else
                    warning("FcmlabIntegrator has not been found.")
                end
            end
        end

    end


    methods(Access = private)

        %% load required paths during initialization
        function addIntegratorPaths( this )
            if exist('./codes','dir') == 7
                addpath('./codes/fcmlab/')
                addpath(genpath('./codes/fcmlab/fcmlab/src'))   % also include all subfolders
            else
                warning("FcmlabIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

    end

    methods

        function obj = FcmlabIntegrator(n_quad_pts, SpaceTreeDepth )
            obj = obj@AbstractIntegrator(n_quad_pts);
            if nargin==2 && ~isempty(SpaceTreeDepth)
                obj.SpaceTreeDepth = SpaceTreeDepth;
            end
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objFcmlab )
            out = ['nq' num2str(objFcmlab.n_quad_pts) '-sub' num2str(objFcmlab.SpaceTreeDepth)];
        end

        function [measure,objQuadData] = integrateDomain2D( objFcmlab, objTest )
            % Function to determine quadrature points and measure of a 2D
            % problem.

            assert(objTest.dim == 2)

            % Create interface (not part of original Fcmlab code)
            if length(objTest.interface) > 1
                error('Fcmlab::integrateDomain2D not prepared for multiple interfaces so far!')
            end
            n_curves = length(objTest.interface.implicit);
            fcmlab_interface_2D = cell(n_curves,1);
            for icurve = 1:n_curves
                fcmlab_interface_2D{icurve} = objTest.interface.implicit{icurve}.phi;
            end
            fcmlab_interface = @(coord,index)fcmlab_interface_2D{index}(coord(1),coord(2));
            fcmlab_domain = GenericDomain(fcmlab_interface,n_curves);

            % Numerical parameters
            domain = objTest.domain;
            NumEle = getNumberOfElementsPerDirection( domain ); % number of elements per direction (same in both directions)
            MeshOrigin = [domain.xmin,0];
            MeshLengthX = domain.xmax(1)-domain.xmin(1);
            MeshLengthY = domain.xmax(2)-domain.xmin(2);
            NumberOfXDivisions = NumEle;
            NumberOfYDivisions = NumEle;
            PolynomialDegree = 1; % not used, but needed for constructor of Mesh                            Factory
            
            % Finite Cell Method Parameter
            Alpha = 1e-10;
            
            % Creation of Materials (needed because it determines inside
            % and outside in the code; kind of treatment of flying nodes)
            YoungsModulus = 1.0;    % dummy value
            PoissonsRatio = 0.0;    % dummy value
            Density = 1.0;          % dummy value
            Materials(1) = HookePlaneStress( ...
                YoungsModulus, PoissonsRatio, ...
                Density, Alpha );
            Materials(2) = HookePlaneStress( ...
                YoungsModulus, PoissonsRatio, ...
                Density, 1 );

            % Creation of the FEM system
            DofDimension = 2;
            
            ElementFactory = GenericElementFactoryElasticQuadFCM(Materials,fcmlab_domain,...
                objFcmlab.n_quad_pts,objFcmlab.SpaceTreeDepth);
            
            MeshFactory = MeshFactory2DUniform(NumberOfXDivisions,NumberOfYDivisions, ...
                PolynomialDegree,PolynomialDegreeSorting,...    % PolynomialDegreeSorting is a constructor call
                DofDimension,MeshOrigin,MeshLengthX,MeshLengthY,ElementFactory);
            
            % Create Analysis
            Analysis = QuadratureAnalysis( MeshFactory );

            % get integration points (not part of original Fcmlab code)
            [measure,objQuadData] = Analysis.get_quadrature_points(objTest);

            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the measure is not 
                % requested as computed above but as an integral with an 
                % integrand ~=1
            end
        end

        function [measure,objQuadData] = integrateDomain3D( objFcmlab, objTest )
            % Function to determine quadrature points and area of a 3D
            % problem.

            assert(objTest.dim == 3)

            % Create interface (not part of original Fcmlab code)
            if length(objTest.interface) > 1
                error('Fcmlab::integrateDomain3D not prepared for multiple interfaces so far!')
            end
            n_curves = length(objTest.interface.implicit);
            fcmlab_interface_3D = cell(n_curves,1);
            for icurve = 1:n_curves
                fcmlab_interface_3D{icurve} = objTest.interface.implicit{icurve}.phi;
            end
            fcmlab_interface = @(coord,index)fcmlab_interface_3D{index}(coord(1),coord(2),coord(3));
            fcmlab_domain = GenericDomain(fcmlab_interface,n_curves);

            % Numerical parameters
            domain = objTest.domain;
            NumEle = getNumberOfElementsPerDirection( domain );
            MeshOrigin = domain.xmin;
            MeshLengthX = domain.xmax(1)-domain.xmin(1);
            MeshLengthY = domain.xmax(2)-domain.xmin(2);
            MeshLengthZ = domain.xmax(3)-domain.xmin(3);
            NumberOfXDivisions = NumEle;
            NumberOfYDivisions = NumEle;
            NumberOfZDivisions = NumEle;
            PolynomialDegree = 1;
            
            % Finite Cell Method Parameter
            Alpha = 1e-10;
            
            % Creation of Materials (needed because it determines inside
            % and outside in the code; kind of treatment of flying nodes)
            YoungsModulus = 1.0;    % dummy value
            PoissonsRatio = 0.0;    % dummy value
            Density = 1.0;          % dummy value
            Materials(1) = Hooke3D( ...
                YoungsModulus, PoissonsRatio, ...
                Density, Alpha );
            Materials(2) = Hooke3D( ...
                YoungsModulus, PoissonsRatio, ...
                Density, 1 );

            % Creation of the FEM system
            DofDimension = 3;
            
            ElementFactory = GenericElementFactoryElasticHexaFCM(Materials,fcmlab_domain,...
                objFcmlab.n_quad_pts,objFcmlab.SpaceTreeDepth);
            
            MeshFactory = MeshFactory3DUniform(NumberOfXDivisions,NumberOfYDivisions, ...
                NumberOfZDivisions,PolynomialDegree,PolynomialDegreeSorting(),...    % PolynomialDegreeSorting is a constructor call
                DofDimension,MeshOrigin,MeshLengthX,MeshLengthY,MeshLengthZ,ElementFactory);
            
            % Create Analysis
            Analysis = QuadratureAnalysis( MeshFactory );

            % get integration points (not part of original Fcmlab code)
            [measure,objQuadData] = Analysis.get_quadrature_points(objTest);

            % compute integral for arbitrary integrand
            if objTest.integrand~=1
                measure = objQuadData.compute_integral(objTest.integrand); % recompute 
                % the measure since the measure is not 
                % requested as computed above but as an integral with an 
                % integrand ~=1
            end
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objFcmlab, objTest )
            % Function to determine quadrature points and curve length of
            % the boundary of a 2D problem.

            assert(objTest.dim == 2)

            % Create interface (not part of original Fcmlab code)
            if length(objTest.interface) > 1
                error('Fcmlab::computeInterfaceCurveLength not prepared for multiple interfaces so far!')
            end
            n_curves = length(objTest.interface.implicit);
            fcmlab_interface_2D = cell(n_curves,1);
            for icurve = 1:n_curves
                fcmlab_interface_2D{icurve} = objTest.interface.implicit{icurve}.phi;
            end
            fcmlab_interface = @(coord,index)fcmlab_interface_2D{index}(coord(1),coord(2));
            fcmlab_domain = GenericDomain(fcmlab_interface,n_curves);

            % Numerical parameters
            domain = objTest.domain;
            NumEle = getNumberOfElementsPerDirection( domain ); % number of elements per direction (same in both directions)
            MeshOrigin = [domain.xmin,0];
            MeshLengthX = domain.xmax(1)-domain.xmin(1);
            MeshLengthY = domain.xmax(2)-domain.xmin(2);
            NumberOfXDivisions = NumEle;
            NumberOfYDivisions = NumEle;
            PolynomialDegree = 1; % not used, but needed for constructor of Mesh                            Factory
            
            % Finite Cell Method Parameter
            Alpha = 1e-10;
            
            % Creation of Materials (needed because it determines inside
            % and outside in the code; kind of treatment of flying nodes)
            YoungsModulus = 1.0;    % dummy value
            PoissonsRatio = 0.0;    % dummy value
            Density = 1.0;          % dummy value
            Materials(1) = HookePlaneStress( ...
                YoungsModulus, PoissonsRatio, ...
                Density, Alpha );
            Materials(2) = HookePlaneStress( ...
                YoungsModulus, PoissonsRatio, ...
                Density, 1 );

            % Creation of the FEM system
            DofDimension = 2;
            
            ElementFactory = GenericElementFactoryElasticQuadFCM(Materials,fcmlab_domain,...
                objFcmlab.n_quad_pts,objFcmlab.SpaceTreeDepth);
            
            MeshFactory = MeshFactory2DUniform(NumberOfXDivisions,NumberOfYDivisions, ...
                PolynomialDegree,PolynomialDegreeSorting,...    % PolynomialDegreeSorting is a constructor call
                DofDimension,MeshOrigin,MeshLengthX,MeshLengthY,ElementFactory);
            
            % Create Analysis
            Analysis = QuadratureAnalysis( MeshFactory );

            % Create Boundary
            BoundaryFactory = BoundaryRecoveryElementwiseFactory(fcmlab_domain, ...
                [domain.xmin(1),domain.xmax(1)],[domain.xmin(2),domain.xmax(2)], ...
                objFcmlab.SpaceTreeDepth,objFcmlab.SeedPoints,Analysis);    
            % comment from Fcmlab code file (aAnnularPlateLinesElementwiseNitsche.m) 
            % regarding the choice that PartitionDepth=SpaceTreeDepth: 
            % "leads to good results, because ensuring that boundary segments 
            % start and end at integration subcells"

            Boundary = BoundaryFactory.getBoundary();

            IntegrationScheme = ...
                GaussLegendre( objFcmlab.n_quad_pts );
            objQuadData = QuadratureData( objTest.dim );
            measure = 0;
            for ib = 1:length(Boundary)
                IntegrationPoints = IntegrationScheme.getCoordinates(Boundary(ib));
                IntegrationWeights = IntegrationScheme.getWeights(Boundary(ib));
                for iGP = 1:size(IntegrationPoints,1)
                    detJ = Boundary(ib).calcDetJacobian(IntegrationPoints(iGP,:));
                    IntegrationPoints(iGP,:) = Boundary(ib).mapLocalToGlobal(IntegrationPoints(iGP,:));
                    IntegrationWeights(iGP) = IntegrationWeights(iGP)*detJ;
                end
                Element = getMesh(Analysis).findElementByPoint(IntegrationPoints(1,:));
                elem_id = getId(Element);

                objQuadData = appendQuadratureData(objQuadData, [IntegrationPoints(:,1:2), IntegrationWeights]', elem_id, 'interface' );
            
                % computing length of the interface
                measure = measure + sum(IntegrationWeights);
            end

        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objFcmlab, objTest )
            % Function to determine quadrature points and area of
            % the boundary of a 3D problem.

            assert(objTest.dim == 3)

            % Create interface (not part of original Fcmlab code)
            if length(objTest.interface) > 1
                error('Fcmlab::computeInterfaceSurfaceArea not prepared for multiple interfaces so far!')
            end
            n_curves = length(objTest.interface.implicit);
            fcmlab_interface_3D = cell(n_curves,1);
            for icurve = 1:n_curves
                fcmlab_interface_3D{icurve} = objTest.interface.implicit{icurve}.phi;
            end
            fcmlab_interface = @(coord,index)fcmlab_interface_3D{index}(coord(1),coord(2),coord(3));
            fcmlab_domain = GenericDomain(fcmlab_interface,n_curves);

            % Numerical parameters
            domain = objTest.domain;
            NumEle = getNumberOfElementsPerDirection( domain );
            MeshOrigin = domain.xmin;
            MeshLengthX = domain.xmax(1)-domain.xmin(1);
            MeshLengthY = domain.xmax(2)-domain.xmin(2);
            MeshLengthZ = domain.xmax(3)-domain.xmin(3);
            NumberOfXDivisions = NumEle;
            NumberOfYDivisions = NumEle;
            NumberOfZDivisions = NumEle;
            PolynomialDegree = 1;
            
            % Finite Cell Method Parameter
            Alpha = 1e-10;
            
            % Creation of Materials (needed because it determines inside
            % and outside in the code; kind of treatment of flying nodes)
            YoungsModulus = 1.0;    % dummy value
            PoissonsRatio = 0.0;    % dummy value
            Density = 1.0;          % dummy value
            Materials(1) = Hooke3D( ...
                YoungsModulus, PoissonsRatio, ...
                Density, Alpha );
            Materials(2) = Hooke3D( ...
                YoungsModulus, PoissonsRatio, ...
                Density, 1 );

            % Creation of the FEM system
            DofDimension = 3;
            
            ElementFactory = GenericElementFactoryElasticHexaFCM(Materials,fcmlab_domain,...
                objFcmlab.n_quad_pts,objFcmlab.SpaceTreeDepth);
            
            MeshFactory = MeshFactory3DUniform(NumberOfXDivisions,NumberOfYDivisions, ...
                NumberOfZDivisions,PolynomialDegree,PolynomialDegreeSorting(),...    % PolynomialDegreeSorting is a constructor call
                DofDimension,MeshOrigin,MeshLengthX,MeshLengthY,MeshLengthZ,ElementFactory);
            
            % Create Analysis
            Analysis = QuadratureAnalysis( MeshFactory );

            % Create Boundary
            BoundingBox = [domain.xmin(1),domain.xmax(1),domain.xmin(2), ...
                domain.xmax(2),domain.xmin(3),domain.xmax(3)];

            NumEle = 2^(objFcmlab.SpaceTreeDepth + max(domain.n_refs));
            BoundaryFactory = BoundaryRecoveryFactory3D(fcmlab_domain, ...
                BoundingBox,NumEle);    % The last input is called PartitionDepth in the constructor, but is actually the number of elements after subdivision

            Boundary = BoundaryFactory.getBoundary();

            IntegrationScheme = ...
                GaussLegendre( objFcmlab.n_quad_pts );
            objQuadData = QuadratureData( objTest.dim );
            measure = 0;
            for ib = 1:length(Boundary)
                IntegrationPoints = IntegrationScheme.getCoordinates(Boundary(ib));
                IntegrationWeights = IntegrationScheme.getWeights(Boundary(ib));
                for iGP = 1:size(IntegrationPoints,1)
                    detJ = Boundary(ib).calcDetJacobian(IntegrationPoints(iGP,:));
                    IntegrationPoints(iGP,:) = Boundary(ib).mapLocalToGlobal(IntegrationPoints(iGP,:));
                    IntegrationWeights(iGP) = IntegrationWeights(iGP)*detJ;
                end
                Element = getMesh(Analysis).findElementByPoint(IntegrationPoints(1,:));
                elem_id = getId(Element);

                objQuadData = appendQuadratureData(objQuadData, [IntegrationPoints, IntegrationWeights]', elem_id, 'interface' );
            
                % computing area of the interface
                measure = measure + sum(IntegrationWeights);
            end
        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objFcmlab, objTest )
            warning("%s does not support computeAreaViaFlux2D yet.", objFcmlab.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objFcmlab, objTest )
            warning("%s does not support computeVolumeViaFlux3D yet.", objFcmlab.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

    end

end