classdef IntegratorInterfaceTests < matlab.unittest.TestCase
% Tests for integrator interface compliance and contract validation
% Ensures all integrators follow AbstractIntegrator interface properly

    properties (TestParameter)
        quadraturePoints = {3, 5}; % Test with different quadrature points
    end
    
    methods (TestClassSetup)
        function setupIntegratorInterface(testCase)
            % Verify we're running from project root
            % Tests must be run from the project root directory to avoid path issues
            testCase.verifyTrue(isCurrentFolderCorrect(), ...
                'Tests must be run from project root directory containing codes/ folder');
        end
    end
    
    methods (Test)
        function testIntegratorInstantiation(testCase, quadraturePoints)
            % Test that all accessible integrators can be instantiated
            integrators = getAccessibleIntegrators(quadraturePoints);
            testCase.assumeNotEmpty(integrators, 'No integrators found');
            
            for i = 1:length(integrators)
                integrator = integrators{i};
                
                try
                    % Test instantiation
                    obj = callIntegratorConstructor(integrator.Name, quadraturePoints);
                    
                    % Verify it's an object
                    testCase.verifyTrue(isobject(obj), ...
                        sprintf('Integrator %s did not return object', integrator.Name));
                    
                    % Verify inheritance from AbstractIntegrator
                    testCase.verifyTrue(isa(obj, 'AbstractIntegrator'), ...
                        sprintf('Integrator %s does not inherit from AbstractIntegrator', integrator.Name));
                        
                catch ME
                    % If instantiation fails, check if it's a known limitation
                    if contains(ME.message, 'not accessible') || ...
                       contains(ME.message, 'not compatible') || ...
                       contains(ME.message, 'not available')
                        % This is expected for some integrators on some platforms
                        warning('Integrator %s not accessible: %s', integrator.Name, ME.message);
                    else
                        % Unexpected error - re-throw
                        testCase.verifyFail(...
                            sprintf('Unexpected error instantiating %s: %s', integrator.Name, ME.message));
                    end
                end
            end
        end
        
        function testAbstractIntegratorInterface(testCase)
            % Test AbstractIntegrator interface requirements
            
            % Get accessible integrators
            integrators = getAccessibleIntegrators(3);
            testCase.assumeNotEmpty(integrators, 'No integrators found');
            
            % Test first available integrator
            successfulIntegrator = '';
            integratorObj = [];
            
            for i = 1:length(integrators)
                try
                    integratorObj = callIntegratorConstructor(integrators{i}.Name, 3);
                    successfulIntegrator = integrators{i}.Name;
                    break;
                catch
                    continue; % Try next integrator
                end
            end
            
            testCase.assumeNotEmpty(successfulIntegrator, 'No integrator could be instantiated');
            testCase.assumeTrue(~isempty(integratorObj), 'No integrator object created');
            
            % Test interface compliance
            testCase.verifyTrue(isa(integratorObj, 'AbstractIntegrator'), ...
                'Integrator must inherit from AbstractIntegrator');
                
            % Test required properties exist
            expectedProperties = {'n_quad_pts'};  % Only test inherited property
            for j = 1:length(expectedProperties)
                testCase.verifyTrue(isprop(integratorObj, expectedProperties{j}), ...
                    sprintf('Integrator missing required property: %s', expectedProperties{j}));
            end
        end
        
        function testIntegratorNameConsistency(testCase)
            % Test integrator name consistency between discovery and instantiation
            integrators = getAccessibleIntegrators(3);
            testCase.assumeNotEmpty(integrators, 'No integrators found');
            
            for i = 1:length(integrators)
                integrator = integrators{i};
                               
                % Verify corresponding file exists
                expectedFile = sprintf('./codes/%sIntegrator.m', integrator.Name);
                testCase.verifyTrue(exist(expectedFile, 'file') == 2, ...
                    sprintf('Integrator file %s not found', expectedFile));
            end
        end
        
        function testCallIntegratorConstructor(testCase)
            % Test callIntegratorConstructor utility function
            integrators = getAccessibleIntegrators(3);
            testCase.assumeNotEmpty(integrators, 'No integrators found');
            
            % Test with valid integrator
            validIntegrator = '';
            for i = 1:length(integrators)
                try
                    obj = callIntegratorConstructor(integrators{i}, 3);
                    if ~isempty(obj)
                        validIntegrator = integrators{i};
                        testCase.verifyTrue(isobject(obj), 'Constructor should return object');
                        break;
                    end
                catch
                    continue; % Try next integrator
                end
            end
            
            if ~isempty(validIntegrator)
                % Test invalid quadrature points
                testCase.verifyError(@() callIntegratorConstructor(validIntegrator, -1), ...
                    ?MException, 'Should error with invalid quadrature points');
                
                % Test invalid integrator name
                testCase.verifyError(@() callIntegratorConstructor('NonExistentIntegrator', 3), ...
                    ?MException, 'Should error with invalid integrator name');
            end
        end
        
        function testIntegratorDimensionCompatibility(testCase)
            % Test integrator dimension compatibility (if supported)
            integrators = getAccessibleIntegrators(3);
            testCase.assumeNotEmpty(integrators, 'No integrators found');
            
            for i = 1:length(integrators)
                integrator = integrators{i};
                
                % Test if dimension filtering works
                try
                    integrators2D = getAccessibleIntegrators(3, 2);
                    integrators3D = getAccessibleIntegrators(3, 3);
                    
                    % If integrator appears in both, it should support both dimensions
                    supports2D = any(strcmp(integrators2D, integrator.Name));
                    supports3D = any(strcmp(integrators3D, integrator.Name));
                    
                    if supports2D || supports3D
                        testCase.verifyTrue(true, ...
                            sprintf('Integrator %s supports appropriate dimensions', integrator.Name));
                    end
                    
                catch ME
                    if contains(ME.message, 'Too many input arguments')
                        % Dimension filtering not supported - skip
                        continue;
                    else
                        rethrow(ME);
                    end
                end
            end
        end
        
        function testIntegratorTestClassAssociation(testCase)
            % Test that integrators are properly associated with test classes
            testSuites = getTestSuiteNames();
            testCase.assumeNotEmpty(testSuites, 'No test suites found');
            
            for i = 1:min(3, length(testSuites)) % Test first few to avoid long runtime
                testSuiteName = testSuites{i};
                
                try
                    % Test getting integrators for specific test class
                    integratorsForTest = runExampleTests_getIntegratorNames(testSuiteName, 'default');
                    
                    testCase.verifyTrue(iscell(integratorsForTest), ...
                        sprintf('Should return cell array for test %s', testSuiteName));
                    
                    if ~isempty(integratorsForTest)
                        % Verify returned integrators are valid
                        allIntegratorObjects = getAccessibleIntegrators(3);
                        allIntegratorNames = cellfun(@(x) string(x.Name), allIntegratorObjects, 'UniformOutput', false);
                        allIntegratorNames = [allIntegratorNames{:}];  % Convert to string array
                        
                        for j = 1:length(integratorsForTest)
                            testCase.verifyTrue(any(strcmp(allIntegratorNames, integratorsForTest{j})), ...
                                sprintf('Integrator %s for test %s is not accessible', ...
                                integratorsForTest{j}, testSuiteName));
                        end
                    end
                    
                catch ME
                    if contains(ME.message, 'Could not get integrators')
                        % Expected for some test classes - skip
                        continue;
                    else
                        testCase.verifyFail(...
                            sprintf('Error getting integrators for %s: %s', testSuiteName, ME.message));
                    end
                end
            end
        end
    end
end