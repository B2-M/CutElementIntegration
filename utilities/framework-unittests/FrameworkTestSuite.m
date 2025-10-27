classdef FrameworkTestSuite < matlab.unittest.TestCase
% Main test suite for CutElementIntegration framework infrastructure
% Tests core framework components independent of specific integration examples
%
% This suite validates:
% - Framework function reliability
% - Project structure integrity  
% - Integrator interface compliance
% - Configuration and parameter handling
%
% Usage:
%   suite = testsuite('FrameworkTestSuite');
%   results = run(suite);

    properties (TestParameter)
        % Test parameters for parameterized tests
        quadraturePoints = {3, 5, 7}; % Common quadrature point counts
    end
    
    methods (TestClassSetup)
        function setupFrameworkPaths(testCase)
            % Verify we're running from project root
            % Tests must be run from the project root directory to avoid path issues
            testCase.verifyTrue(isCurrentFolderCorrect(), ...
                'Tests must be run from project root directory containing codes/ folder');

            % Verify required functions are accessible
            testCase.assumeTrue(exist('getAccessibleIntegrators', 'file') == 2, ...
                'getAccessibleIntegrators function not found - run StartUpCall first');
            testCase.assumeTrue(exist('getTestSuiteNames', 'file') == 2, ...
                'getTestSuiteNames function not found - run StartUpCall first');
        end
    end
    
    methods (Test)
        function testFrameworkAccessibility(testCase)
            % Verify core framework functions are accessible
            testCase.verifyTrue(exist('getAccessibleIntegrators', 'file') == 2, ...
                'getAccessibleIntegrators function not found');
            testCase.verifyTrue(exist('getTestSuiteNames', 'file') == 2, ...
                'getTestSuiteNames function not found');
            testCase.verifyTrue(exist('isCurrentFolderCorrect', 'file') == 2, ...
                'isCurrentFolderCorrect function not found');
        end
        
        function testProjectStructureIntegrity(testCase)
            % Verify essential project structure exists
            testCase.verifyTrue(exist('./codes', 'dir') == 7, ...
                'codes/ directory missing');
            testCase.verifyTrue(exist('./examples', 'dir') == 7, ...
                'examples/ directory missing');
            testCase.verifyTrue(exist('./utilities', 'dir') == 7, ...
                'utilities/ directory missing');
            testCase.verifyTrue(exist('./framework-classes', 'dir') == 7, ...
                'framework-classes/ directory missing');
        end
        
        function testGetAccessibleIntegrators(testCase, quadraturePoints)
            % Test integrator discovery functionality
            
            % Verify function exists before calling
            testCase.verifyTrue(exist('getAccessibleIntegrators', 'file') == 2, ...
                'getAccessibleIntegrators function not accessible');
            
            % Validate that quadraturePoints is a scalar integer
            testCase.verifyTrue(isscalar(quadraturePoints) && isnumeric(quadraturePoints), ...
                'quadraturePoints should be a scalar numeric value');
            
            try
                integrators = getAccessibleIntegrators(quadraturePoints);
            catch ME
                testCase.verifyFail(sprintf('getAccessibleIntegrators failed: %s', ME.message));
            end
            
            % Function should return a cell array (even if empty)
            testCase.verifyTrue(iscell(integrators), ...
                'Integrators should be returned as cell array');
            
            % If integrators are found, they should be AbstractIntegrator objects
            if ~isempty(integrators)
                testCase.verifyTrue(all(cellfun(@(x) isa(x, 'AbstractIntegrator'), integrators)), ...
                    'All integrators should be AbstractIntegrator objects');
                fprintf('Found %d accessible integrators\n', length(integrators));
            else
                % No integrators accessible - this may be expected on some systems
                fprintf('No integrators accessible (may be due to missing dependencies)\n');
                testCase.verifyTrue(true, 'Function executed successfully even with no accessible integrators');
            end
        end
        
        function testGetTestSuiteNames(testCase)
            % Test test suite discovery functionality
            testSuites = getTestSuiteNames();
            
            testCase.verifyNotEmpty(testSuites, ...
                'No test suites found');
            testCase.verifyTrue(iscell(testSuites), ...
                'Test suites should be returned as cell array');
            testCase.verifyTrue(all(cellfun(@ischar, testSuites)), ...
                'All test suite names should be strings');
            
            % Verify expected naming pattern
            for i = 1:length(testSuites)
                testCase.verifyTrue(startsWith(testSuites{i}, 'testExampleChanges_'), ...
                    sprintf('Test suite %s does not follow naming convention', testSuites{i}));
            end
        end
        
        function testRefactoredFunctionAvailability(testCase)
            % Verify refactored functions are available
            refactoredFunctions = {
                'runExampleTests_parseParameters'
                'runExampleTests_validateTestNames'  
                'runExampleTests_resolvePlotSettings'
                'runExampleTests_buildConfigurations'
                'runExampleTests_getIntegratorNames'
            };
            
            for i = 1:length(refactoredFunctions)
                testCase.verifyTrue(exist(refactoredFunctions{i}, 'file') == 2, ...
                    sprintf('Refactored function %s not found', refactoredFunctions{i}));
            end
        end
    end
    
    methods (Static)
        function runAllFrameworkTests()
            % Convenience method to run all framework tests
            suite = testsuite('FrameworkTestSuite');
            results = run(suite);
            disp(results);
        end
    end
end