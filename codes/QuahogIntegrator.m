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

classdef QuahogIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Quahog code to the main code.
    % It uses the SPECTRAL method which applies Gauss quadrature to the
    % intermediate and the antiderivative quadrature.

    properties(SetAccess = private)
        n_quad_pts_green = 5;   % number of quadrature points for the line 
        % integral within Green's Theorem; 55 used when exact reference was 
        % computed in Gundermann et al. (2021)
    end

    methods(Static)
        function out = Name
            out = "Quahog";
        end

        function out = InterfaceType
            out = "parametric";
        end
        
        function out = OperatingSystem
            out = ["Linux","Windows"];
        end

        function out = SupportedDimensions
            out = "2D";
        end        

        function out = IsAccessible
            out = false;
            if isCurrentFolderCorrect
                if exist('./codes/quahog/quahog','dir') == 7
                    if numel(dir('./codes/quahog/quahog')) > 2
                            out = true;
                    end
                else
                    warning("QuahogIntegrator has not been found.")
                end
            end
        end

    end


    methods(Access = private)

        %% load required paths during initialization
        function addIntegratorPaths( this )
            if exist('./codes','dir') == 7
                addpath('./codes/quahog/quahog')
                addpath('./codes/quahog/quahog/Integration_Operations')
                addpath('./codes/quahog/quahog/Geometric_Operations')
                % It is important that this folder is added later than the 
                % one above "Geometric_Operations" because it contains a 
                % file which should be used instead of the file with the 
                % same name in the folder "Geometric_Operations".
                addpath('./codes/quahog')
            else
                warning("QuahogIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

    end

    methods

        function obj = QuahogIntegrator(n_quad_pts,n_quad_pts_green)
            obj = obj@AbstractIntegrator(n_quad_pts);
            if nargin==2 && ~isempty(n_quad_pts_green)
                obj.n_quad_pts_green = n_quad_pts_green;
            end
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objQuahog )
            out = ['nqg' num2str(objQuahog.n_quad_pts_green)];
        end

        function [measure,objQuadData] = integrateDomain2D( objQuahog, objTest )
            % Function to determine quadrature points and measure of a 2D
            % problem.

            assert(objTest.dim == 2)

            objQuadData = QuadratureData(objTest.dim);

            % Create interface (not part of original Quahog code)
            quahog_interface_2D = quahog_get_interface(objTest,-1);  % corresponds to CPWmat in Quahog code

            % Gaussian quadrature for both the intermediate and the
            % antiderivative quadrature; second input: intermediate GP,
            % third input: antiderivative GP
            [xtrue,ytrue,wtrue] = SPECTRAL_quads(quahog_interface_2D, ...
                objQuahog.n_quad_pts_green,objQuahog.n_quad_pts_green);

            % append quadrature data
            objQuadData = objQuadData.appendQuadratureData([xtrue';ytrue';wtrue'],1,'trimmed');   % the quadrature method is mesh-free; therefore, there is no notion of elements

            % compute integral for arbitrary integrand (also integrand==1
            % --> area)
            measure = objQuadData.compute_integral(objTest.integrand);

        end

        function [vol,objQuadData] = integrateDomain3D(~,objTest)
            warning("The provided version of Quahog does not support 3D integration.");
            objQuadData = QuadratureData( objTest.dim );
            vol = -1;
        end

        function [measure,objQuadData] = computeInterfaceCurveLength( objQuahog, objTest )
            warning("%s does not support computeInterfaceCurveLength.", objQuahog.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeInterfaceSurfaceArea( objQuahog, objTest )
            warning("%s does not support computeInterfaceSurfaceArea.", objQuahog.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeAreaViaFlux2D( objQuahog, objTest )
            warning("%s does not support computeAreaViaFlux2D.", objQuahog.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

        function [measure,objQuadData] = computeVolumeViaFlux3D( objQuahog, objTest )
            warning("%s does not support computeVolumeViaFlux3D.", objQuahog.Name );
            objQuadData = QuadratureData( objTest.dim );
            measure = -1;
        end

    end

end