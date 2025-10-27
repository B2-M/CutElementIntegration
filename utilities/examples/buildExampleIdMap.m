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
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function idMap = buildExampleIdMap(varargin)
% BUILDEXAMPLEIDMAP Automatically extracts and maps IDs from example files
%
% Scans all example_*.m files in the examples/ subfolders and builds a
% comprehensive map linking:
%   - Example file name
%   - testCaseId (extracted from example file)
%   - interfaceId (extracted from getTestCase2D/3D)
%   - Geometry description (extracted from getInterfaceCase2D/3D)
%   - File locations for debugging
%
% Syntax:
%   idMap = buildExampleIdMap()
%   idMap = buildExampleIdMap(dimension)
%   idMap = buildExampleIdMap(dimension, 'OutputFormat', format)
%   idMap = buildExampleIdMap('ExampleCategory', category)
%
% Inputs:
%   dimension - (optional) Problem dimension: 2 or 3, or 'all' (default: 'all')
%   'OutputFormat' - 'table' (default), 'struct', or 'map'
%   'ExampleCategory' - Specific example category folder name (e.g., 'AreaComputation2D')
%
% Outputs:
%   idMap - Table, struct array, or containers.Map with columns/fields:
%       ExampleFile      - Name of example file
%       ExampleCategory  - Example category (e.g., 'AreaComputation2D')
%       TestCaseId       - ID used in getTestCase2D/3D
%       InterfaceId      - ID used in getInterfaceCase2D/3D
%       TestCaseLine     - Line number in getTestCase file
%       InterfaceLine    - Line number in getInterfaceCase file
%       TestSuiteIndex   - Test suite index (e.g., '3/26' = 3rd of 26 tests, '1/1' for standalone)
%
% Examples:
%   % Basic usage - get all examples as table
%   idMap = buildExampleIdMap();
%
%   % Filter by dimension
%   idMap2D = buildExampleIdMap(2);
%   idMap3D = buildExampleIdMap(3);
%
%   % Filter by category
%   idMapArea = buildExampleIdMap('ExampleCategory', 'AreaComputation2D');
%
%   % Get as map for fast lookups
%   idMap = buildExampleIdMap('OutputFormat', 'map');
%   if idMap.isKey('example_circle_1.m')
%       info = idMap('example_circle_1.m');
%       fprintf('testCaseId=%d, interfaceId=%d\n', info.TestCaseId, info.InterfaceId);
%   end
%
%   % Find all examples in a category
%   idTable = buildExampleIdMap();
%   areaExamples = idTable(strcmp(idTable.ExampleCategory, 'AreaComputation2D'), :);
%   fprintf('Found %d area computation examples\n', height(areaExamples));
%
%   % Look up specific testCaseId
%   tc15Examples = idTable(idTable.TestCaseId == 15, :);
%   fprintf('testCaseId=15 is used by:\n');
%   disp(tc15Examples(:, {'ExampleFile', 'ExampleCategory', 'InterfaceId'}));
%
%   % Debugging workflow: find where an example is defined
%   exampleName = 'example_triangle_1.m';
%   entry = idTable(strcmp(idTable.ExampleFile, exampleName), :);
%   if ~isempty(entry)
%       fprintf('Example: %s\n', exampleName);
%       fprintf('  testCaseId: %d (defined at getTestCase2D.m:%d)\n', ...
%               entry.TestCaseId, entry.TestCaseLine);
%       fprintf('  interfaceId: %d (defined at getInterfaceCase2D.m:%d)\n', ...
%               entry.InterfaceId, entry.InterfaceLine);
%   end
%
%   % Export to CSV for external analysis
%   idTable = buildExampleIdMap();
%   writetable(idTable, 'example_registry.csv');
%
%   % Count test suites vs standalone examples
%   idTable = buildExampleIdMap();
%   isSuite = ~strcmp(idTable.TestSuiteIndex, '1/1');
%   fprintf('Standalone: %d, Test suites: %d\n', ...
%           sum(~isSuite), sum(isSuite));
%
% See also: queryExampleDetails, getTestCase2D, getTestCase3D, getInterfaceCase2D, getInterfaceCase3D

% Parse inputs
p = inputParser;
addOptional(p, 'dimension', 'all', @(x) isnumeric(x) || strcmp(x, 'all'));
addParameter(p, 'OutputFormat', 'table', @(x) ismember(x, {'table', 'struct', 'map'}));
addParameter(p, 'ExampleCategory', '', @ischar);
addParameter(p, 'Verbose', false, @islogical);
parse(p, varargin{:});

dimension = p.Results.dimension;
outputFormat = p.Results.OutputFormat;
categoryFilter = p.Results.ExampleCategory;
verbose = p.Results.Verbose;

% Get project root
% mfilename('fullpath') = .../utilities/examples/buildExampleIdMap.m
% So we need to go up 2 levels to get to project root
utilExamplesPath = fileparts(mfilename('fullpath'));   % .../utilities/examples
utilitiesPath = fileparts(utilExamplesPath);           % .../utilities
projectRoot = fileparts(utilitiesPath);                % project root
examplesRoot = fullfile(projectRoot, 'examples');

% Determine which dimensions to process
if strcmp(dimension, 'all')
    dimensions = [2, 3];
else
    dimensions = dimension;
end

% Initialize results
results = {};

% Process each dimension
for dim = dimensions
    if verbose
        fprintf('Processing %dD examples...\n', dim);
    end

    % Find all example categories for this dimension
    if isempty(categoryFilter)
        % Get all categories
        exampleDirs = dir(examplesRoot);
        exampleDirs = exampleDirs([exampleDirs.isdir]);
        exampleDirs = exampleDirs(~ismember({exampleDirs.name}, {'.', '..'}));

        % Filter by dimension pattern
        dimPattern = sprintf('%dD', dim);
        categoryNames = {exampleDirs.name};
        categoryNames = categoryNames(contains(categoryNames, dimPattern));
    else
        categoryNames = {categoryFilter};
    end

    % Process each category
    for i = 1:length(categoryNames)
        categoryName = categoryNames{i};
        categoryPath = fullfile(examplesRoot, categoryName);

        if ~exist(categoryPath, 'dir')
            if verbose
                warning('Category folder not found: %s', categoryPath);
            end
            continue;
        end

        % Find all example_*.m files
        exampleFiles = dir(fullfile(categoryPath, 'example_*.m'));

        if verbose
            fprintf('  Found %d examples in %s\n', length(exampleFiles), categoryName);
        end

        % Process each example file
        for j = 1:length(exampleFiles)
            exampleName = exampleFiles(j).name;
            examplePath = fullfile(categoryPath, exampleName);

            try
                % Extract testCaseId(s) from example file
                testCaseIds = extractTestCaseId(examplePath);

                if isnan(testCaseIds)
                    if verbose
                        fprintf('    WARNING: Could not extract testCaseId from %s\n', exampleName);
                    end
                    continue;
                end

                % Determine if this is a test suite (multiple testCaseIds)
                isSuite = length(testCaseIds) > 1;
                numTestsInSuite = length(testCaseIds);

                if isSuite && verbose
                    fprintf('    Test suite found: %s (testCaseIds %d:%d)\n', ...
                            exampleName, testCaseIds(1), testCaseIds(end));
                end

                % Process each testCaseId (loop handles both single and suite)
                for k = 1:numTestsInSuite
                    testCaseId = testCaseIds(k);

                    % Create suite index string (e.g., "3/26" for suites, "1/1" for standalone)
                    testSuiteIndex = sprintf('%d/%d', k, numTestsInSuite);

                    % Extract interfaceId and line number from getTestCase file
                    [interfaceId, testCaseLine] = extractInterfaceId(dim, testCaseId);

                    if isnan(interfaceId)
                        if verbose
                            fprintf('    WARNING: Could not extract interfaceId for testCaseId=%d in %s\n', ...
                                    testCaseId, exampleName);
                        end
                        interfaceId = NaN;
                        testCaseLine = NaN;
                    end

                    % Extract line number from getInterfaceCase file
                    interfaceLine = extractInterfaceLine(dim, interfaceId);

                    % Add to results
                    results{end+1} = struct(...
                        'ExampleFile', exampleName, ...
                        'ExampleCategory', categoryName, ...
                        'TestCaseId', testCaseId, ...
                        'InterfaceId', interfaceId, ...
                        'TestCaseLine', testCaseLine, ...
                        'InterfaceLine', interfaceLine, ...
                        'TestSuiteIndex', testSuiteIndex); %#ok<AGROW>

                    if verbose && ~isSuite
                        fprintf('    ✓ %s: testCaseId=%d, interfaceId=%d\n', ...
                                exampleName, testCaseId, interfaceId);
                    end
                end

                if verbose && isSuite
                    fprintf('    ✓ Processed %d test cases from suite\n', numTestsInSuite);
                end

            catch ME
                if verbose
                    fprintf('    ERROR processing %s: %s\n', exampleName, ME.message);
                end
            end
        end
    end
end

% Convert to requested format
if isempty(results)
    warning('No examples found matching the criteria');
    if strcmp(outputFormat, 'table')
        idMap = table();
    elseif strcmp(outputFormat, 'struct')
        idMap = struct([]);
    else
        idMap = containers.Map();
    end
    return;
end

switch outputFormat
    case 'table'
        idMap = struct2table(vertcat(results{:}));

    case 'struct'
        idMap = vertcat(results{:});

    case 'map'
        idMap = containers.Map();
        for i = 1:length(results)
            key = results{i}.ExampleFile;
            idMap(key) = results{i};
        end
end

end

%% Helper Functions

function testCaseIds = extractTestCaseId(exampleFilePath)
% Extract testCaseId(s) from example file
% Returns: scalar for single test, array for test suite, NaN if not found
    fileContent = fileread(exampleFilePath);

    % Look for pattern 1: testCaseId = <number> (single test)
    pattern1 = 'testCaseId\s*=\s*(\d+)';
    match1 = regexp(fileContent, pattern1, 'tokens', 'once');

    if ~isempty(match1)
        testCaseIds = str2double(match1{1});
        return;
    end

    % Look for pattern 2: test_cases = (start:end) (test suite)
    pattern2 = 'test_cases\s*=\s*\((\d+):(\d+)\)';
    match2 = regexp(fileContent, pattern2, 'tokens', 'once');

    if ~isempty(match2)
        rangeStart = str2double(match2{1});
        rangeEnd = str2double(match2{2});
        testCaseIds = rangeStart:rangeEnd;
        return;
    end

    % Not found
    testCaseIds = NaN;
end

function [interfaceId, lineNumber] = extractInterfaceId(dimension, testCaseId)
% Extract interfaceId from getTestCase2D/3D file for given testCaseId

    % Find getTestCase file
    utilPath = fileparts(mfilename('fullpath'));
    testCaseFile = fullfile(utilPath, sprintf('getTestCase%dD.m', dimension));

    if ~exist(testCaseFile, 'file')
        interfaceId = NaN;
        lineNumber = NaN;
        return;
    end

    % Read file
    fileContent = fileread(testCaseFile);
    lines = strsplit(fileContent, '\n');

    % Find the testCaseId block
    % Pattern: if testCaseId == <number> or elseif testCaseId == <number>
    % Allow for optional comments after the condition
    blockStartPattern = sprintf('(if|elseif)\\s+.*testCaseId\\s*==\\s*%d', testCaseId);

    % Also handle range patterns like: any(testCaseId==(4:7))
    blockStartPatternRange = 'any\(testCaseId==\((\d+):(\d+)\)\)';

    interfaceId = NaN;
    lineNumber = NaN;

    for i = 1:length(lines)
        line = strtrim(lines{i});

        % Check for exact match
        if ~isempty(regexp(line, blockStartPattern, 'once'))
            % Found the block, now search for InterfaceId in next lines
            for j = i:min(i+30, length(lines))  % Search next 30 lines
                innerLine = strtrim(lines{j});
                idPattern = 'InterfaceId\s*=\s*(\d+)';
                match = regexp(innerLine, idPattern, 'tokens', 'once');
                if ~isempty(match)
                    interfaceId = str2double(match{1});
                    lineNumber = j;
                    return;
                end
            end
        end

        % Check for range pattern
        match = regexp(line, blockStartPatternRange, 'tokens', 'once');
        if ~isempty(match)
            rangeStart = str2double(match{1});
            rangeEnd = str2double(match{2});
            if testCaseId >= rangeStart && testCaseId <= rangeEnd
                % Found range block, search for InterfaceId
                for j = i:min(i+40, length(lines))
                    innerLine = strtrim(lines{j});

                    % Look for conditional InterfaceId assignment
                    condPattern = sprintf('if\\s+testCaseId\\s*==\\s*%d', testCaseId);
                    if contains(innerLine, condPattern)
                        % Search next few lines for InterfaceId
                        for k = j:min(j+5, length(lines))
                            idPattern = 'InterfaceId\s*=\s*(\d+)';
                            match2 = regexp(lines{k}, idPattern, 'tokens', 'once');
                            if ~isempty(match2)
                                interfaceId = str2double(match2{1});
                                lineNumber = k;
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end

function lineNumber = extractInterfaceLine(dimension, interfaceId)
% Extract line number from getInterfaceCase2D/3D file for given interfaceId

    if isnan(interfaceId)
        lineNumber = NaN;
        return;
    end

    % Find getInterfaceCase file
    utilPath = fileparts(mfilename('fullpath'));
    interfaceFile = fullfile(utilPath, sprintf('getInterfaceCase%dD.m', dimension));

    if ~exist(interfaceFile, 'file')
        lineNumber = NaN;
        return;
    end

    % Read file
    fileContent = fileread(interfaceFile);
    lines = strsplit(fileContent, '\n');

    % Find the interfaceId block
    % Note: No $ anchor at end to allow inline comments like "elseif InterfaceId == 43 % comment"
    blockStartPattern = sprintf('(if|elseif)\\s+InterfaceId\\s*==\\s*%d', interfaceId);

    lineNumber = NaN;

    for i = 1:length(lines)
        line = strtrim(lines{i});

        if ~isempty(regexp(line, blockStartPattern, 'once'))
            lineNumber = i;
            return;
        end
    end
end
