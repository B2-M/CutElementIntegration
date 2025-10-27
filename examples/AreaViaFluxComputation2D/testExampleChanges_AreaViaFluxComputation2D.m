classdef testExampleChanges_AreaViaFluxComputation2D < TestCases2D

    properties
        % define columne names of the result table that shall be compared
        col_names ={'relError','absError','h','nbQuadptsInterface'};
        folder_name = 'AreaFluxComputation2D';
        integrator_names = getAccessibleIntegratorNames(2);
        plot_settings = {'PlotError','off','PlotPoints','off'};
        testType = 'convergenceStudy' % default test type
    end

    methods (Test)

        function runTestCoverage( testCase )
            checkTestCoverage( testCase );
        end

        function names = checkForChanges_example_circle_1_flux( testCase )

            % set number of refinements 
            n_refs_min = 1;
            n_refs_max = 3;
            if strcmp( testCase.testType , 'unitTest' )
                n_refs_max = n_refs_min;
            end

            % set up integrators
            n_quad_pts = 4;         % Number of quadrature point per element in each direction
            reparam_degree = 5;     % Degree of the reparametrisation of cut elements
            objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);
            
            % run example
            [~,~,names] = example_circle_1_flux(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});
            
            % compare with reference
            checkForChanges( testCase, names );

        end 








        %function names = checkForChanges_example_inner_knot_flux( testCase )
        %
        %    % set number of refinements 
        %    n_refs_min = 1;
        %    n_refs_max = 6;
        %    if strcmp( testCase.testType , 'unitTest' )
        %        n_refs_max = n_refs_min+1;
        %    end
        %
        %    % set up integrators
        %    n_quad_pts = 3;         % Number of quadrature point per element in each direction
        %    reparam_degree = 3;     % Degree of the reparametrisation of cut elements
        %    objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);
        %    
        %    % run example
        %    [~,~,names] = example_inner_knot_flux(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});
        %    
        %    % compare with reference
        %    checkForChanges( testCase, names );
        %
        %end 

        %function names = checkForChanges_example_punched_plate_flux( testCase )
        %
        %    % set number of refinements
        %    n_refs_min = 1;
        %    n_refs_max = 6;
        %    if strcmp( testCase.testType , 'unitTest' )
        %        n_refs_max = n_refs_min+1;
        %    end
        %
        %    % set up integrators
        %    n_quad_pts = 2;         % Number of quadrature point per element in each direction
        %    reparam_degree = 2;     % Degree of the reparametrisation of cut elements
        %    objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);
        %
        %    % run example
        %    [~,~,names] = example_punched_plate_flux(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});
        %
        %    % compare with reference
        %    checkForChanges( testCase, names );
        %
        %end

        %function names = checkForChanges_example_multiple_connected_curves_flux( testCase )
        %
        %    % set number of refinements
        %    n_refs_min = 1;
        %    n_refs_max = 4;
        %    if strcmp( testCase.testType , 'unitTest' )
        %        n_refs_max = n_refs_min+1;
        %    end
        %
        %    % set up integrators
        %    n_quad_pts = 3;         % Number of quadrature point per element in each direction
        %    reparam_degree = 3;     % Degree of the reparametrisation of cut elements
        %    objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);
        %
        %    % run example
        %    [~,~,names] = example_multiple_connected_curves_flux(n_refs_min,n_refs_max,objInt,testCase.plot_settings{:});
        %
        %    % compare with reference
        %    checkForChanges( testCase, names );
        %
        %end
        
        %function names = checkForChanges_example_testsuite_unibw_flux( testCase )
        %
        %    % set number of refinements 
        %    n_refs_min = 0;
        %
        %    % set up integrators
        %    n_quad_pts = 4;         % Number of quadrature point per element in each direction
        %    reparam_degree = 4;     % Degree of the reparametrisation of cut elements
        %    objInt = getTestIntegrators(testCase, n_quad_pts, reparam_degree);
        %    
        %    % run example
        %    [~,~,names] = example_testsuite_unibw_flux(n_refs_min,objInt,testCase.plot_settings{:});
        %    
        %    % compare with reference
        %    checkForChanges( testCase, names );        
        %end
    end

end
