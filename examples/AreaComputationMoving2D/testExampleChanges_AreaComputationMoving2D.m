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

classdef testExampleChanges_AreaComputationMoving2D < TestCases2D

    properties
        % define columne names of the result table that shall be compared
        col_names ={'relError','absError','step','nbQuadptsTrimmedElems','nbQuadptsNonTrimmedElems'};
        folder_name = 'AreaComputationMoving2D';
        integrator_names = getAccessibleIntegratorNames(2);
        plot_settings = {'PlotError','off','PlotPoints','off'};
        testType = 'convergenceStudy' % default test type
    end 

    methods (Test)

        function runTestCoverage( testCase )
            checkTestCoverage( testCase );
        end
        
        %% example_circle_1_moving
        function names = checkForChanges_example_circle_1_moving( testCase )

            % set number of refinements and steps
            n_refs = 3;
            n_points = 7;
            di=1e-2;
            dsteps = linspace(0,di*n_points,n_points+1);
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_circle_1_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end 
        %% example_intersected_circles_moving
        function names = checkForChanges_example_intersected_circles_moving( testCase )

            % set number of refinements and steps
            n_refs= 2; %Level of refinement of the mesh
            n_points= 3;
            di=0.09;    % 0.9*2R/3
            dsteps = linspace(0,di*n_points,n_points+1); %steps
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_intersected_circles_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end
        %% example_line_1_moving
        function names = checkForChanges_example_line_1_moving( testCase )

            % set number of refinements and steps
            n_refs= 3;
            n_points= 10;
            di=1e-2;
            dsteps = linspace(0,n_points*di,n_points+1);
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_line_1_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end 
        %% example_line_2_moving
        function names = checkForChanges_example_line_2_moving( testCase )

            % set number of refinements and steps
            n_refs= 3;
            n_points= 10;
            di=pi/((n_points+1)*2);
            dsteps = linspace(0,di*n_points,n_points+1);
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_line_2_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end
        %% example_line_3_moving
        function names = checkForChanges_example_line_3_moving( testCase )

            % set number of refinements and steps
            n_refs= 3;
            n_points= 10;
            di=0.5/(n_points+1);
            dsteps = linspace(0,di*n_points,n_points+1);
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_line_3_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end 
        %% example_line_4_moving
        function names = checkForChanges_example_line_4_moving( testCase )

            % set number of refinements and steps
            n_refs= 1;
            dsteps = [0,0.1:0.1:0.3,0.31:0.01:0.39,0.399999];
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_line_4_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end
        %% example_parabola_moving
        function names = checkForChanges_example_parabola_moving( testCase )

            % set number of refinements and steps
            n_refs= 2;
            dsteps = [0,0.03125,0.06,0.062499,0.0625,0.062501,0.065,0.09375,0.125];
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_parabola_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end
        %% example_square_moving
        function names = checkForChanges_example_square_moving( testCase )

            % set number of refinements and steps
            n_refs= 2;
            dsteps = [0,(0.04:0.001:0.048),0.049999,0.05,0.050001,0.2,0.289999];
            if strcmp( testCase.testType , 'unitTest' )
                dsteps = dsteps(1:2);
            end

            % set up integrators
            n_quad_pts = 3;         % Number of quadrature point per element in each direction
            reparam_degree = 3;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);         
            
            % run example
            [~,~,names] = example_square_moving(n_refs,dsteps,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end
        
    end

end