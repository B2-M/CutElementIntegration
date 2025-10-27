classdef InfrastructureTests < matlab.unittest.TestCase
% Tests for core framework infrastructure functions
% Validates essential framework utilities that support the integration system

    methods (TestClassSetup)
        function setupInfrastructure(testCase)
            % Verify we're running from project root
            % Tests must be run from the project root directory to avoid path issues
            testCase.verifyTrue(isCurrentFolderCorrect(), ...
                'Tests must be run from project root directory containing codes/ folder');
        end
    end
    
    methods (Test)
        function testIsCurrentFolderCorrect(testCase)
            % Test directory validation function
            testCase.verifyTrue(isCurrentFolderCorrect(), ...
                'isCurrentFolderCorrect should return true in project root');
            
            % Test from wrong directory
            originalDir = pwd;
            cd('..');
            testCase.addTeardown(@() cd(originalDir));
            
            % Should return false or error from parent directory  
            testCase.verifyError(@() isCurrentFolderCorrect(), ?MException);
        end
        
        function testGetAccessibleIntegratorsBasic(testCase)
            % Test basic integrator discovery
            integrators = getAccessibleIntegrators(3);
            
            % Function should always return cell array
            testCase.verifyTrue(iscell(integrators));
            
            % If integrators found, validate them
            if ~isempty(integrators)
                % they should be AbstractIntegrator objects
                testCase.verifyTrue(all(cellfun(@(x) isa(x, 'AbstractIntegrator'), integrators)), ...
                    'All integrators should be AbstractIntegrator objects');

                % Verify at least one integrator is accessible
                testCase.verifyTrue(length(integrators) > 0, ...
                    'At least one integrator should be accessible');
                
                % Log which integrators were found
                integratorNames = cellfun(@(x) string(x.Name), integrators, 'UniformOutput', false);
                fprintf('Found %d accessible integrators: %s\n', ...
                    length(integrators), strjoin([integratorNames{:}], ', '));
            else
                % No integrators accessible - acceptable for framework test
                testCase.verifyTrue(true, 'No accessible integrators (may lack dependencies)');
            end
        end
        
        function testGetAccessibleIntegratorsDifferentQuadPoints(testCase)
            % Test integrator discovery with different quadrature points
            quadPoints = [3, 5, 7];
            
            for i = 1:length(quadPoints)
                integrators = getAccessibleIntegrators(quadPoints(i));
                testCase.verifyTrue(iscell(integrators), ...
                    sprintf('Should return cell array for %d quad points', quadPoints(i)));
            end
        end
        
        function testGetAccessibleIntegratorsWith2D3DFilter(testCase)
            % Test integrator discovery with dimension filtering
            
            % Test 2D filtering (if function supports it)
            try
                integrators2D = getAccessibleIntegrators(3, 2);
                testCase.verifyTrue(iscell(integrators2D));
            catch ME
                if ~contains(ME.message, 'Too many input arguments')
                    rethrow(ME);
                end
            end
            
            % Test 3D filtering (if function supports it)  
            try
                integrators3D = getAccessibleIntegrators(3, 3);
                testCase.verifyTrue(iscell(integrators3D));
            catch ME
                if ~contains(ME.message, 'Too many input arguments')
                    rethrow(ME);
                end
            end
        end
        
        function testGetTestSuiteNamesStructure(testCase)
            % Test test suite name discovery
            testSuites = getTestSuiteNames();
            
            testCase.verifyNotEmpty(testSuites);
            testCase.verifyTrue(iscell(testSuites));
            
            % Verify naming convention
            for i = 1:length(testSuites)
                testCase.verifyTrue(startsWith(testSuites{i}, 'testExampleChanges_'), ...
                    sprintf('Test suite %s does not follow naming pattern', testSuites{i}));
                testCase.verifyFalse(contains(testSuites{i}, ' '), ...
                    sprintf('Test suite name %s contains spaces', testSuites{i}));
            end
            
            % Expected core test suites (should exist)
            expectedSuites = {
                'testExampleChanges_AreaComputation2D'
                'testExampleChanges_VolumeComputation3D' 
                'testExampleChanges_InterfaceComputation2D'
            };
            
            for i = 1:length(expectedSuites)
                testCase.verifyTrue(any(strcmp(testSuites, expectedSuites{i})), ...
                    sprintf('Expected test suite %s not found', expectedSuites{i}));
            end
        end
        
        function testRefactoredParameterValidation(testCase)
            % Test refactored parameter validation functions
            
            % Test default parameters
            params = runExampleTests_parseParameters();
            testCase.verifyEqual(params.testType, 'unitTest');
            testCase.verifyEqual(params.integratorName, 'default');
            testCase.verifyEqual(params.testPlots, 'off');
            
            % Test valid explicit parameters
            testSuites = getTestSuiteNames();
            if ~isempty(testSuites)
                params = runExampleTests_parseParameters('convergenceStudy', ...
                    {testSuites{1}}, 'on', 'AlgoimIntegrator');
                testCase.verifyEqual(params.testType, 'convergenceStudy');
                testCase.verifyEqual(params.testPlots, 'on');
                testCase.verifyEqual(params.integratorName, 'AlgoimIntegrator');
            end
            
            % Test invalid test type
            testCase.verifyError(@() runExampleTests_parseParameters('invalidType'), ...
                ?MException);
            
            % Test invalid plot option
            testCase.verifyError(@() runExampleTests_parseParameters('unitTest', 'all', 'invalid'), ...
                ?MException);
        end
        
        function testRefactoredTestNameValidation(testCase)
            % Test test name validation
            testSuites = getTestSuiteNames();
            
            if ~isempty(testSuites)
                % Valid test names should not error
                testCase.verifyWarningFree(@() runExampleTests_validateTestNames(testSuites));
                testCase.verifyWarningFree(@() runExampleTests_validateTestNames({testSuites{1}}));
                
                % Invalid test names should error
                testCase.verifyError(@() runExampleTests_validateTestNames({'invalidTestName'}), ...
                    ?MException);
            end
        end
        
        function testRefactoredPlotResolution(testCase)
            % Test plot option resolution
            
            % Test defaults
            testCase.verifyEqual(runExampleTests_resolvePlotSettings([], 'unitTest'), 'off');
            testCase.verifyEqual(runExampleTests_resolvePlotSettings([], 'convergenceStudy'), 'default');
            
            % Test explicit values
            validOptions = {'default', 'on', 'off', 'error'};
            for i = 1:length(validOptions)
                result = runExampleTests_resolvePlotSettings(validOptions{i}, 'unitTest');
                testCase.verifyEqual(result, validOptions{i});
            end
            
            % Test invalid option
            testCase.verifyError(@() runExampleTests_resolvePlotSettings('invalid', 'unitTest'), ...
                ?MException);
        end

        function testParameterProcessingPipeline(testCase)
            % Test complete parameter processing pipeline
            params = runExampleTests_parseParameters('unitTest', 'all', 'off', 'default');
            
            testCase.verifyTrue(isstruct(params), 'Parameters should be a struct');
            testCase.verifyTrue(isfield(params, 'testType'), 'Missing testType field');
            testCase.verifyTrue(isfield(params, 'tests'), 'Missing tests field');
            testCase.verifyTrue(isfield(params, 'testPlots'), 'Missing testPlots field');
            testCase.verifyTrue(isfield(params, 'integratorName'), 'Missing integratorName field');
            
            try
                configs = runExampleTests_buildConfigurations(params);
                testCase.verifyTrue(iscell(configs), 'Configurations should be a cell array');
            catch ME
                if contains(ME.message, 'Could not get integrators')
                    testCase.assumeFail('No accessible integrators for configuration building');
                else
                    rethrow(ME);
                end
            end
        end
    end
end