classdef StructureValidationTests < matlab.unittest.TestCase
% Tests for project structure integrity validation
% Ensures critical project structure is maintained as framework evolves

    methods (TestClassSetup)
        function setupStructureValidation(testCase)
            % Verify we're running from project root
            % Tests must be run from the project root directory to avoid path issues
            testCase.verifyTrue(isCurrentFolderCorrect(), ...
                'Tests must be run from project root directory containing codes/ folder');
        end
    end
    
    methods (Test)
        function testCodesDirectoryExists(testCase)
            % Verify codes/ directory exists and is accessible
            testCase.verifyTrue(exist('./codes', 'dir') == 7, ...
                'codes/ directory must exist in project root');
        end
        
        function testCodesContainsOnlyIntegratorFiles(testCase)
            % Verify codes/ contains only *Integrator.m files
            codesPath = './codes';
            mFiles = dir(fullfile(codesPath, '*.m'));
            
            testCase.verifyNotEmpty(mFiles, ...
                'codes/ directory should contain integrator files');
            
            % Check naming convention
            invalidFiles = {};
            for i = 1:length(mFiles)
                fileName = mFiles(i).name;
                if ~endsWith(fileName, 'Integrator.m')
                    invalidFiles{end+1} = fileName;
                end
            end
            
            testCase.verifyEmpty(invalidFiles, ...
                sprintf('Invalid files in codes/: %s. Only *Integrator.m files allowed', ...
                strjoin(invalidFiles, ', ')));
        end
        
        function testIntegratorInheritance(testCase)
            % Verify all integrator files inherit from AbstractIntegrator
            codesPath = './codes';
            mFiles = dir(fullfile(codesPath, '*.m'));
            
            invalidInheritance = {};
            
            for i = 1:length(mFiles)
                fileName = mFiles(i).name;
                filePath = fullfile(codesPath, fileName);
                
                % Read file content
                fid = fopen(filePath, 'r');
                testCase.assumeTrue(fid ~= -1, ...
                    sprintf('Cannot read file: %s', fileName));
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Extract class name
                integratorName = fileName(1:end-2); % Remove .m extension
                
                % Parse inheritance using robust method
                hasInheritance = validateIntegratorInheritance(content, integratorName);
                
                if ~hasInheritance
                    invalidInheritance{end+1} = fileName;
                end
            end
            
            testCase.verifyEmpty(invalidInheritance, ...
                sprintf('Files not inheriting from AbstractIntegrator: %s', ...
                strjoin(invalidInheritance, ', ')));
        end
        
        function testNoNonIntegratorFunctionsInCodes(testCase)
            % Verify codes/ contains no regular function files
            codesPath = './codes';
            mFiles = dir(fullfile(codesPath, '*.m'));
            
            nonIntegratorFunctions = {};
            
            for i = 1:length(mFiles)
                fileName = mFiles(i).name;
                filePath = fullfile(codesPath, fileName);
                
                % Read file content
                fid = fopen(filePath, 'r');
                if fid ~= -1
                    content = fread(fid, '*char')';
                    fclose(fid);
                    
                    % Check if it starts with function instead of classdef
                    firstNonEmptyLine = regexp(content, '^\s*\w.*', 'match', 'lineanchors', 'once');
                    if ~isempty(firstNonEmptyLine) && startsWith(strtrim(firstNonEmptyLine), 'function')
                        nonIntegratorFunctions{end+1} = fileName;
                    end
                end
            end
            
            testCase.verifyEmpty(nonIntegratorFunctions, ...
                sprintf(['Non-integrator functions found in codes/: %s. ', ...
                'These break getAccessibleIntegrators.m logic'], ...
                strjoin(nonIntegratorFunctions, ', ')));
        end
        
        function testEssentialDirectoriesExist(testCase)
            % Verify essential project directories exist
            essentialDirs = {'./examples', './utilities', './framework-classes'};
            
            for i = 1:length(essentialDirs)
                testCase.verifyTrue(exist(essentialDirs{i}, 'dir') == 7, ...
                    sprintf('Essential directory %s is missing', essentialDirs{i}));
            end
        end
        
        function testUtilsContainsRequiredFunctions(testCase)
            % Verify utilities/ contains required framework functions in appropriate subfolders
            requiredUtilsPaths = {
                './utilities/integrator-management/getAccessibleIntegrators.m'
                './utilities/file-utilities/isCurrentFolderCorrect.m'
            };
            
            for i = 1:length(requiredUtilsPaths)
                testCase.verifyTrue(exist(requiredUtilsPaths{i}, 'file') == 2, ...
                    sprintf('Required utility function %s is missing', requiredUtilsPaths{i}));
            end
        end
        
        function testExamplesStructure(testCase)
            % Verify examples directory structure
            exampleDirs = dir('./examples');
            exampleDirs = exampleDirs([exampleDirs.isdir] & ~startsWith({exampleDirs.name}, '.'));
            
            testCase.verifyNotEmpty(exampleDirs, ...
                'examples/ directory should contain example categories');
            
            % Check for expected example categories
            expectedCategories = {
                'AreaComputation2D'
                'VolumeComputation3D'
                'InterfaceComputation2D'
            };
            
            foundCategories = {exampleDirs.name};
            for i = 1:length(expectedCategories)
                testCase.verifyTrue(any(strcmp(foundCategories, expectedCategories{i})), ...
                    sprintf('Expected example category %s not found', expectedCategories{i}));
            end
        end
        
        function testHelperFunctionsStructure(testCase)
            % Verify helper functions directory contains required files
            helpersDir = './utilities/examples/runtests';
            testCase.verifyTrue(exist(helpersDir, 'dir') == 7, ...
                'Helper functions directory is missing');
            
            requiredHelpers = {
                'runExampleTests_parseParameters.m'
                'runExampleTests_validateTestNames.m'
                'runExampleTests_resolvePlotSettings.m'
                'runExampleTests_buildConfigurations.m'
                'runExampleTests_getIntegratorNames.m'
                'runExampleTests_createSuite.m'
                'runExampleTests_executeSuite.m'
            };
            
            for i = 1:length(requiredHelpers)
                helperPath = fullfile(helpersDir, requiredHelpers{i});
                testCase.verifyTrue(exist(helperPath, 'file') == 2, ...
                    sprintf('Required helper function %s is missing', requiredHelpers{i}));
            end
        end
        
        function testTestSuiteFilePattern(testCase)
            % Verify test suite files follow expected pattern for directories that have tests
            
            % Find all existing test files first
            testFiles = dir(fullfile('./examples', '**/testExampleChanges_*.m'));
            testCase.verifyNotEmpty(testFiles, 'No testExampleChanges_*.m files found');
            
            % Extract category names from test files and verify directory exists
            for i = 1:length(testFiles)
                [~, fileName, ~] = fileparts(testFiles(i).name);
                categoryName = extractAfter(fileName, 'testExampleChanges_');
                
                categoryDir = fullfile('./examples', categoryName);
                testCase.verifyTrue(exist(categoryDir, 'dir') == 7, ...
                    sprintf('Example directory %s not found for test file %s', categoryName, testFiles(i).name));
            end
        end
    end
end

function hasInheritance = validateIntegratorInheritance(content, expectedClassName)
% Helper function to validate integrator inheritance using robust parsing
    hasInheritance = false;
    
    % Split content into lines
    lines = splitlines(content);
    
    for lineIdx = 1:length(lines)
        line = strtrim(lines{lineIdx});
        
        % Search for classdef line
        if startsWith(line, 'classdef')
            % Extract content after 'classdef'
            afterClassdef = strtrim(line(9:end));
            
            % Split at '<' for inheritance
            if contains(afterClassdef, '<')
                parts = split(afterClassdef, '<');
                if length(parts) >= 2
                    className = strtrim(parts{1});
                    parentClass = strtrim(parts{2});
                    
                    % Check if matches expected pattern
                    if strcmp(className, expectedClassName) && strcmp(parentClass, 'AbstractIntegrator')
                        hasInheritance = true;
                        return;
                    end
                end
            end
        end
    end
end