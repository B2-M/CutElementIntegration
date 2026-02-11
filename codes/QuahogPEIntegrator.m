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


classdef QuahogPEIntegrator < AbstractIntegrator
    % Integrator definition as interface of the Quahog code to the main code.
    % It uses the SPECTRALPE (PE = polynomial exact) method which applies 
    % a rational quadrature rule to the intermediate and a Gauss quadrature
    % the antiderivative quadrature. It is exact with a defined number of
    % quadrature points for all polynomials of a certain degree.

    properties(SetAccess = private)
        quad_degree    % degree of the polynomial integrand
    end

    methods(Static)
        function out = Name
            out = "QuahogPE";
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
                    warning("QuahogPEIntegrator has not been found.")
                end
            end
        end

    end

    methods(Access = private)

        %% load required paths during initialization
        function addIntegratorPaths(~)
            if exist('./codes','dir') == 7
                addpath(genpath('./codes/quahog/quahog/Integration_Operations/Rational_Quadrature/Matlab'))
            else
                warning("QuahogIntegrator::addIntegratorPaths failed. Load the folder such that './codes' can be found.")
            end
        end

    end

    methods

        function obj = QuahogPEIntegrator(n_quad_pts)
            % call constructor of parent class
            obj = obj@AbstractIntegrator(n_quad_pts);
            obj.quad_degree = 2*n_quad_pts-1;
            obj.addIntegratorPaths;
        end

        function out = PropertyString( objQuahog )
            out = ['p' num2str(objQuahog.quad_degree)];
        end

        function [measure,objQuadData] = integrateDomain2D( objQuahog, objTest )
            % Function to determine quadrature points and measure of a 2D
            % problem.

            assert(objTest.dim == 2)

            objQuadData = QuadratureData(objTest.dim);

            % Create interface (not part of original Quahog code)
            [quahog_interface_2D,n_quad_rational] = quahog_get_interface(objTest,objQuahog.quad_degree);  % corresponds to CPWmat in Quahog code

            % Gaussian quadrature for antiderivative quadrature and rational
            % qaudrature rule for intermediate quadrature
            [xtrue,ytrue,wtrue] = SPECTRALPE_quads(quahog_interface_2D, ...
                0,n_quad_rational,ceil((objQuahog.quad_degree+1)/2));

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