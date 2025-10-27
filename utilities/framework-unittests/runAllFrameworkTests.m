function runAllFrameworkTests()
% RUNALLFRAMEWORKTESTS Run framework tests with code coverage analysis and test reporting
%
% This script runs the complete FrameworkTestSuite with both code coverage
% reporting and detailed test result reporting, generating HTML reports for both.
%
% Usage:
%   runAllFrameworkTests()
%
% Output:
%   - Console test results
%   - HTML test report in ./coverage-report/test-results/ directory
%     (includes diagnostic figures for failed tests)
%   - HTML coverage report in ./coverage-report/ directory
%   - Test and coverage statistics summary

    fprintf('Running FrameworkTestSuite with code coverage analysis...\n');

    try
        % Import required classes
        import matlab.unittest.plugins.CodeCoveragePlugin
        import matlab.unittest.plugins.codecoverage.CoverageReport
        import matlab.unittest.plugins.TestReportPlugin

        % Create test suite for framework tests
        suite = [testsuite('FrameworkTestSuite'), ...
            testsuite('InfrastructureTests'), ...
            testsuite('IntegratorInterfaceTests'), ...
            testsuite('StructureValidationTests'), ...
            testsuite('TestCaseValidationTests'), ...
            testsuite('UtilityFunctionTests')];

        % Create test runner with text output
        runner = testrunner('textoutput');

        % Add test report plugin
        testReportDir = fullfile(pwd, 'coverage-report', 'test-results');
        if ~exist(testReportDir, 'dir')
            mkdir(testReportDir);
        end
        runner.addPlugin(TestReportPlugin.producingHTML(testReportDir, ...
            'IncludingPassingDiagnostics', true, ...
            'IncludingCommandWindowText', true, ...
            'LoggingLevel', 3));

        % Add coverage plugin for utilities folder and all its subfolders
        coverageReportDir = fullfile(pwd, 'coverage-report');

        % Find project root (where utilities folder is located)
        currentDir = pwd;
        projectRoot = currentDir;
        while ~exist(fullfile(projectRoot, 'utilities'), 'dir') && ~strcmp(projectRoot, fileparts(projectRoot))
            projectRoot = fileparts(projectRoot);
        end

        utilitiesPath = fullfile(projectRoot, 'utilities');

        % Verify utilities path exists
        if ~exist(utilitiesPath, 'dir')
            error('Utilities folder not found. Current dir: %s, Searched for: %s', currentDir, utilitiesPath);
        end

        % Get all subdirectories of utilities for comprehensive coverage
        utilitiesSubdirs = dir(utilitiesPath);
        utilitiesSubdirs = utilitiesSubdirs([utilitiesSubdirs.isdir]);
        utilitiesSubdirs = utilitiesSubdirs(~ismember({utilitiesSubdirs.name}, {'.', '..'}));

        % Build list of all utilities subdirectories
        coverageFolders = {utilitiesPath};
        for i = 1:length(utilitiesSubdirs)
            subfolderPath = fullfile(utilitiesPath, utilitiesSubdirs(i).name);
            coverageFolders{end+1} = subfolderPath;
            fprintf('Including coverage for: %s\n', subfolderPath);
        end

        fprintf('Using utilities path: %s\n', utilitiesPath);
        fprintf('Total coverage folders: %d\n', length(coverageFolders));
        runner.addPlugin(CodeCoveragePlugin.forFolder(coverageFolders, ...
            'Producing', CoverageReport(coverageReportDir)));

        % Run tests and collect results
        fprintf('\nExecuting tests with coverage analysis...\n');
        results = run(runner, suite);

        % Display test summary
        numPassed = sum([results.Passed]);
        numFailed = sum([results.Failed]);
        numTotal = length(results);

        fprintf('\n=== TEST RESULTS SUMMARY ===\n');
        fprintf('Total tests: %d\n', numTotal);
        fprintf('Passed: %d\n', numPassed);
        fprintf('Failed: %d\n', numFailed);
        fprintf('Success rate: %.1f%%\n', (numPassed/numTotal)*100);

        % Display test report location
        if exist(testReportDir, 'dir')
            fprintf('\n=== TEST REPORT ===\n');
            testReportIndex = fullfile(testReportDir, 'index.html');
            if exist(testReportIndex, 'file')
                fprintf('Test report generated in: %s\n', testReportDir);
                fprintf('Open index.html to view detailed test results with diagnostics.\n');
            end
        end

        % Display coverage report location
        if exist(coverageReportDir, 'dir')
            fprintf('\n=== COVERAGE REPORT ===\n');
            fprintf('Coverage report generated in: %s\n', coverageReportDir);
            fprintf('Open index.html to view detailed code coverage.\n');

            % Try to open the coverage report automatically (Windows)
            indexFile = fullfile(coverageReportDir, 'index.html');
            if exist(indexFile, 'file') && ispc
                try
                    system(['start "" "' indexFile '"']);
                    fprintf('Coverage report opened in default browser.\n');
                catch
                    fprintf('Could not auto-open browser. Please open manually.\n');
                end
            end
        end

        % Return success/failure status
        if numFailed == 0
            fprintf('\nAll tests passed! ✓\n');
        else
            fprintf('\n%d test(s) failed! ✗\n', numFailed);
        end

    catch ME
        fprintf('Error running code coverage analysis:\n');
        fprintf('%s\n', ME.message);

        % Display stack trace for debugging
        if ~isempty(ME.stack)
            fprintf('\nStack trace:\n');
            for i = 1:length(ME.stack)
                fprintf('  %s (line %d)\n', ME.stack(i).file, ME.stack(i).line);
            end
        end

        rethrow(ME);
    end

end
