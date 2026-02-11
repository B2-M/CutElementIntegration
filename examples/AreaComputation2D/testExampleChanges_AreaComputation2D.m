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

classdef testExampleChanges_AreaComputation2D < TestCases2D

    properties
        % define columne names of the result table that shall be compared
        col_names ={'relError','absError','h','nbQuadptsTrimmedElems','nbQuadptsNonTrimmedElems'};
        folder_name = 'AreaComputation2D';
        integrator_names = getAccessibleIntegratorNames(2); % default integrators
        plot_settings = {'PlotError','off','PlotPoints','off'};
        testType = 'convergenceStudy' % default test type
    end

    methods (Test)

        function runTestCoverage( testCase )
            checkTestCoverage( testCase );
        end

        function names = checkForChanges_example_circle_1( testCase )

            % set number of refinements 
            n_refs_min = 1;
            n_refs_max = 5;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 4;         % Number of quadrature point per element in each direction
            reparam_degree = 2;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         

            % run example
            [~,~,names] = example_circle_1(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_ellipse( testCase )

            % set number of refinements 
            n_refs_min = 0;
            n_refs_max = 2;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         

            % run example
            [~,~,names] = example_ellipse(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
      
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_foliumloop_1( testCase )

            % set number of refinements 
            n_refs_min = 2;
            n_refs_max = 5;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);

            % run example
            [~,~,names] = example_foliumloop_1(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_inner_knot( testCase )

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
            [~,~,names] = example_inner_knot(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_multiple_connected_curves( testCase )

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
            [~,~,names] = example_multiple_connected_curves(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_punched_plate( testCase )

            % set number of refinements 
            n_refs_min = 1;
            n_refs_max = 4;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);

            % run example
            [~,~,names] = example_punched_plate(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_saye2022_sec44( testCase )

            % set number of refinements 
            n_refs_min = 0;
            n_refs_max = 0;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 5;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);

            % run example
            [~,~,names] = example_saye2022_sec44(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_semicircle_1( testCase )

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
            [~,~,names] = example_semicircle_1(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_testsuite_unibw( testCase )

            % set number of refinements 
            n_refs_min = 0;
            n_refs_max = 0;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = ones(26,1)*3;         % Number of quadrature point per element in each direction
            reparam_degree = ones(26,1)*5;     % Degree of the reparametrisation of cut elements
            n_quad_pts_green = ones(26,1)*5;
            objInt = cell(26,1);
            for i=1:26
                objInt{i} = getTestIntegrators(testCase, n_quad_pts(i), reparam_degree(i), ...
                    n_quad_pts_green(i));
            end
            % run example
            [~,~,names] = example_testsuite_unibw(n_refs_min,n_refs_max,objInt, ...
                testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

        function names = checkForChanges_example_triangle_1( testCase )

            % set number of refinements 
            n_refs_min = 1;
            n_refs_max = 3;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 2;         % Number of quadrature point per element in each direction
            reparam_degree = 2;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);

            % run example
            [~,~,names] = example_triangle_1(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});

            % compare with reference
            checkForChanges( testCase, names );

        end

    end

end