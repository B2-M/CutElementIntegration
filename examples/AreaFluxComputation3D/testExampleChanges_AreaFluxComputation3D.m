%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, Universtiy of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guliherme H. Teixeira, Graz University of Technology  
%    Muhammed Toprak, Technische Universität Darmstadt
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

classdef testExampleChanges_AreaFluxComputation3D < TestCases3D


    properties
        % define columne names of the result table that shall be compared
        col_names ={'relError','absError','h','nbQuadptsInterface'};
        folder_name = 'AreaFluxComputation3D';
        integrator_names = getAccessibleIntegratorNames(3);        
        plot_settings = {'PlotError','off','PlotPoints','off','PlotInterface','off'};
        testType = 'convergenceStudy' % default test type
    end

    methods (Test)

        function runTestCoverage( testCase )
            checkTestCoverage( testCase );
        end

        function names = checkForChanges_example_ellipsoid_1_flux( testCase )

            % set number of refinements 
            n_refs_min = 1;
            n_refs_max = 3;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);
            
            % run example
            [~,~,names] = example_ellipsoid_1_flux(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end 

    end

end