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
% EXEMPLARY, OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function results = queryExampleDetails(varargin)
% QUERYEXAMPLEDETAILS Interactive query interface for finding test case example details
%
% Provides a user-friendly way to search and explore the test case example details
% in the CutElementIntegration framework. Queries the reference data generated
% by exportExampleReference().
%
% Syntax:
%   queryExampleDetails()                              % Show all examples
%   queryExampleDetails(searchText)                    % Quick text search
%   queryExampleDetails('Category', category)          % Filter by category
%   queryExampleDetails('TestCaseId', id)              % Find specific test case
%   queryExampleDetails('InterfaceId', id)             % Find by interface ID
%   queryExampleDetails('ExampleFile', filename)       % Find specific example file
%   queryExampleDetails('Dimension', dim)              % Filter by dimension (2 or 3)
%   results = queryExampleDetails(...)                 % Return results table
%
% Inputs:
%   searchText   - Quick search string (searches in ExampleFile and Category)
%   'Category'   - Example category name (e.g., 'AreaComputation2D')
%   'TestCaseId' - Test case ID number
%   'InterfaceId' - Interface ID number
%   'ExampleFile' - Example filename (e.g., 'example_circle_1.m')
%   'Dimension'  - Problem dimension: 2 or 3
%
% Outputs:
%   results - Table of matching examples (if output argument provided)
%             Otherwise displays formatted output to console
%
% Examples:
%   % Show all examples
%   queryExampleDetails()
%
%   % Quick search for "circle"
%   queryExampleDetails('circle')
%
%   % Find all area computation examples
%   queryExampleDetails('Category', 'AreaComputation2D')
%
%   % Find specific test case
%   queryExampleDetails('TestCaseId', 15)
%
%   % Find all 3D examples
%   queryExampleDetails('Dimension', 3)
%
%   % Combine filters (all 2D area examples)
%   queryExampleDetails('Category', 'AreaComputation2D', 'Dimension', 2)
%
%   % Get results as table for further processing
%   circleExamples = queryExampleDetails('circle');
%   disp(circleExamples);
%
%   % Find where a specific test case is defined
%   entry = queryExampleDetails('TestCaseId', 1);
%   fprintf('Defined at: getTestCase2D.m:%d\n', entry.TestCaseLine(1));
%
% Notes:
%   - If reference data is missing, run: exportExampleReference()
%   - Reference data is stored in: utilities/framework-unittests/reference-data/example_registry.mat
%   - The reference is a snapshot - run exportExampleReference() after adding examples
%
% See also: exportExampleReference, buildExampleIdMap, runExampleTests

% Load reference data
refData = loadReferenceData();
exampleMap = refData.exampleMap;
metadata = refData.metadata;

% Parse inputs
if nargin == 0
    % Show all examples
    filtered = exampleMap;
    queryDescription = 'all examples';
elseif nargin == 1 && ~ischar(varargin{1})
    error('First argument must be a search string or parameter name.');
elseif nargin == 1
    % Quick search mode
    searchText = varargin{1};
    mask = contains(exampleMap.ExampleFile, searchText, 'IgnoreCase', true) | ...
           contains(exampleMap.ExampleCategory, searchText, 'IgnoreCase', true);
    filtered = exampleMap(mask, :);
    queryDescription = sprintf('search: "%s"', searchText);
else
    % Parse name-value pairs
    p = inputParser;
    addParameter(p, 'Category', '', @ischar);
    addParameter(p, 'TestCaseId', [], @isnumeric);
    addParameter(p, 'InterfaceId', [], @isnumeric);
    addParameter(p, 'ExampleFile', '', @ischar);
    addParameter(p, 'Dimension', [], @(x) isnumeric(x) && ismember(x, [2, 3]));
    parse(p, varargin{:});

    % Apply filters
    filtered = exampleMap;
    filters = {};

    if ~isempty(p.Results.Category)
        filtered = filtered(strcmp(filtered.ExampleCategory, p.Results.Category), :);
        filters{end+1} = sprintf('Category=%s', p.Results.Category);
    end

    if ~isempty(p.Results.TestCaseId)
        filtered = filtered(filtered.TestCaseId == p.Results.TestCaseId, :);
        filters{end+1} = sprintf('TestCaseId=%d', p.Results.TestCaseId);
    end

    if ~isempty(p.Results.InterfaceId)
        filtered = filtered(filtered.InterfaceId == p.Results.InterfaceId, :);
        filters{end+1} = sprintf('InterfaceId=%d', p.Results.InterfaceId);
    end

    if ~isempty(p.Results.ExampleFile)
        filtered = filtered(strcmp(filtered.ExampleFile, p.Results.ExampleFile), :);
        filters{end+1} = sprintf('ExampleFile=%s', p.Results.ExampleFile);
    end

    if ~isempty(p.Results.Dimension)
        dim = p.Results.Dimension;
        dimPattern = sprintf('%dD', dim);
        filtered = filtered(contains(filtered.ExampleCategory, dimPattern), :);
        filters{end+1} = sprintf('Dimension=%d', dim);
    end

    queryDescription = strjoin(filters, ', ');
end

% Sort results by category and testCaseId for consistent display
if ~isempty(filtered)
    filtered = sortrows(filtered, {'ExampleCategory', 'TestCaseId'});
end

% Display or return results
if nargout == 0
    % Display to console
    displayResults(filtered, queryDescription, metadata);
else
    % Return table
    results = filtered;
end

end

%% Helper Functions

function refData = loadReferenceData()
% Load reference data from MAT-file

    % Find reference file
    projectRoot = pwd;
    refFile = fullfile(projectRoot, 'utilities', 'framework-unittests', ...
                      'reference-data', 'example_registry.mat');

    if ~exist(refFile, 'file')
        error(['Reference data not found: %s\n\n' ...
               'Please run exportExampleReference() first to generate the reference data.\n' ...
               'This creates a snapshot of all test case definitions.'], refFile);
    end

    % Load data
    try
        refData = load(refFile);
    catch ME
        error('Failed to load reference data: %s', ME.message);
    end

    % Validate structure
    if ~isfield(refData, 'exampleMap') || ~isfield(refData, 'metadata')
        error(['Invalid reference file format.\n' ...
               'Please regenerate by running: exportExampleReference()']);
    end
end

function displayResults(filtered, queryDescription, metadata)
% Display formatted results to console

    fprintf('\n');
    fprintf('=================================================================\n');
    fprintf('  CutElementIntegration - Example Query Results\n');
    fprintf('=================================================================\n');
    fprintf('Query: %s\n', queryDescription);
    fprintf('Found: %d example(s)\n', height(filtered));
    fprintf('Reference date: %s\n', metadata.generatedDate);
    fprintf('=================================================================\n\n');

    if isempty(filtered)
        fprintf('No examples match the query criteria.\n');
        fprintf('\nTry:\n');
        fprintf('  - queryExamples()  % Show all examples\n');
        fprintf('  - queryExamples(''Category'', ''AreaComputation2D'')\n');
        fprintf('  - queryExamples(''Dimension'', 2)\n');
        fprintf('\n');
        return;
    end

    % Group by category for organized display
    categories = unique(filtered.ExampleCategory, 'stable');

    for i = 1:length(categories)
        category = categories{i};
        catExamples = filtered(strcmp(filtered.ExampleCategory, category), :);

        fprintf('--- %s (%d example(s)) ---\n\n', category, height(catExamples));

        % Display as formatted table
        fprintf('%-40s | TestCaseId | InterfaceID | SuiteIndex | Lines\n', 'Example File');
        fprintf('%s\n', repmat('-', 1, 100));

        for j = 1:height(catExamples)
            row = catExamples(j, :);
            fprintf('%-40s | %10d | %11d | %10s | TC:%4d, IF:%4d\n', ...
                    row.ExampleFile{1}, ...
                    row.TestCaseId, ...
                    row.InterfaceId, ...
                    row.TestSuiteIndex{1}, ...
                    row.TestCaseLine, ...
                    row.InterfaceLine);
        end
        fprintf('%s\n', repmat('-', 1, 100));
        
        % Explain line number references
        if contains(category, '2D')
            dim = 2;
        else
            dim = 3;
        end
        fprintf('Lines column: TC=getTestCase%dD.m line, IF=getInterfaceCase%dD.m line\n\n', dim, dim);
    end

    fprintf('=================================================================\n');
    fprintf('Total: %d example(s) across %d categor%s\n', ...
            height(filtered), ...
            length(categories), ...
            ternary(length(categories) == 1, 'y', 'ies'));
    fprintf('=================================================================\n\n');

    % Show usage hints for first-time users
    if height(filtered) == metadata.totalExamples
        fprintf('TIP: Filter results with:\n');
        fprintf('  queryExamples(''circle'')                    %% Quick search\n');
        fprintf('  queryExamples(''Category'', ''AreaComputation2D'')  %% By category\n');
        fprintf('  queryExamples(''TestCaseId'', 15)                %% By test case ID\n');
        fprintf('  queryExamples(''Dimension'', 3)                  %% 3D examples only\n');
        fprintf('\n');
    end
end

function result = ternary(condition, trueVal, falseVal)
% Simple ternary operator
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end
