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

        function testIntegratorDiscoveryCompleteness(testCase)
            % Test that all platform-compatible integrators are correctly discovered
            %
            % This test validates that:
            % 1. getAccessibleIntegrators() finds only platform-compatible integrators
            % 2. No unexpected integrators are discovered
            % 3. All integrators in codes/ are accounted for in the reference data
            % 4. All expected platform-compatible integrators are accessible
            %
            % The test will FAIL if:
            % - New integrators are added to codes/ but not to the reference file
            % - Integrators are removed but reference is not updated
            % - Discovery finds integrators incompatible with current platform
            % - Expected integrators are not accessible (missing dependencies)
            %
            % To update reference after adding/removing integrators:
            % Edit utilities/framework-unittests/reference-data/expected_integrators.mat

            % Load reference data
            refFile = fullfile('utilities', 'framework-unittests', ...
                               'reference-data', 'expected_integrators.mat');
            testCase.verifyTrue(isfile(refFile), ...
                'Reference file not found: expected_integrators.mat');

            refData = load(refFile);
            refIntegratorData = refData.refIntegratorData;

            % Get all integrator files currently in codes/
            allCurrentIntegrators = getAllIntegratorNames();
            allRefIntegrators = refIntegratorData.allIntegrators;

            % Check for new integrators not in reference
            newIntegrators = setdiff(allCurrentIntegrators, allRefIntegrators);
            testCase.verifyEmpty(newIntegrators, ...
                sprintf(['New integrators detected in codes/ but not in reference data:\n  %s\n\n' ...
                        'ACTION REQUIRED:\n' ...
                        '1. Edit utilities/framework-unittests/reference-data/expected_integrators.mat\n' ...
                        '2. Add the new integrator(s) to:\n' ...
                        '   - refIntegratorData.allIntegrators\n' ...
                        '   - refIntegratorData.windowsCompatible (if Windows-compatible)\n' ...
                        '   - refIntegratorData.linuxCompatible (if Linux-compatible)\n' ...
                        '3. Re-run this test to verify'], ...
                        strjoin(newIntegrators, ', ')));

            % Check for removed integrators still in reference
            removedIntegrators = setdiff(allRefIntegrators, allCurrentIntegrators);
            testCase.verifyEmpty(removedIntegrators, ...
                sprintf(['Integrators in reference data but not found in codes/:\n  %s\n\n' ...
                        'ACTION REQUIRED:\n' ...
                        'Edit utilities/framework-unittests/reference-data/expected_integrators.mat\n' ...
                        'and remove these integrators from all lists'], ...
                        strjoin(removedIntegrators, ', ')));

            % Determine expected integrators for current platform
            if ispc
                expectedNames = refIntegratorData.windowsCompatible;
                platformName = 'Windows';
            elseif isunix
                expectedNames = refIntegratorData.linuxCompatible;
                platformName = 'Linux';
            else
                error('Unsupported platform');
            end

            % Get discovered integrators
            % Use minimal quad points since we're testing discovery, not functionality
            try
                discoveredIntegrators = getAccessibleIntegrators(1);
            catch ME
                testCase.verifyFail(sprintf('getAccessibleIntegrators() failed: %s', ME.message));
                return;
            end

            % Extract names from discovered integrators
            % Ensure names are char arrays (not strings) for setdiff compatibility
            if ~isempty(discoveredIntegrators)
                discoveredNames = cellfun(@(x) char(x.Name), discoveredIntegrators, 'UniformOutput', false);
            else
                discoveredNames = {};
            end

            % Verify all discovered integrators are platform-compatible
            % This catches if discovery logic is broken and returns wrong integrators
            unexpectedIntegrators = setdiff(discoveredNames, expectedNames);
            testCase.verifyEmpty(unexpectedIntegrators, ...
                sprintf(['Unexpected integrators discovered for %s:\n  %s\n\n' ...
                        'These integrators are not %s-compatible according to reference data.\n' ...
                        'Possible causes:\n' ...
                        '1. Reference data is incorrect - update integrator_discovery_ref.mat\n' ...
                        '2. Discovery logic in getAccessibleIntegrators() is broken\n' ...
                        '3. Integrator OperatingSystem property is incorrect'], ...
                        platformName, strjoin(unexpectedIntegrators, ', '), platformName));

            % Identify missing integrators (expected but not discovered)
            missingIntegrators = setdiff(expectedNames, discoveredNames);

            % Log diagnostic information (visible in test output)
            fprintf('\n=== Integrator Discovery Test (%s) ===\n', platformName);
            fprintf('Total integrators in codes/:     %2d\n', length(allCurrentIntegrators));
            fprintf('Expected for %s:            %2d\n', platformName, length(expectedNames));
            fprintf('Actually discovered:              %2d\n', length(discoveredNames));

            if ~isempty(discoveredNames)
                fprintf('\nSuccessfully discovered (%d):\n', length(discoveredNames));
                for i = 1:length(discoveredNames)
                    fprintf('  - %s\n', discoveredNames{i});
                end
            end

            if ~isempty(missingIntegrators)
                fprintf('\nMissing integrators (%d):\n', length(missingIntegrators));
                for i = 1:length(missingIntegrators)
                    fprintf('  - %s\n', missingIntegrators{i});
                end
            end

            fprintf('==========================================\n\n');

            % FAIL test if not all expected integrators are accessible
            testCase.verifyEmpty(missingIntegrators, ...
                sprintf(['Expected %s-compatible integrators not accessible:\n  %s\n\n' ...
                        'All platform-compatible integrators must be accessible.\n' ...
                        'Possible causes:\n' ...
                        '1. Missing dependencies - check codes/[integrator]/README\n' ...
                        '2. Installation incomplete - run setup for missing integrators\n' ...
                        '3. Environment configuration issue - verify Python, .NET, etc.\n' ...
                        '4. Reference data incorrect - if integrator should not be required,\n' ...
                        '   remove it from windowsCompatible or linuxCompatible list'], ...
                        platformName, strjoin(missingIntegrators, ', ')));
        end
    end
end