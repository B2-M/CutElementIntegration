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

function exportExampleReference()
% EXPORTEXAMPLEREFERENCE Generate reference data for example definitions
%
% Creates a MAT-file containing the current state of all example test case
% definitions. This reference is used by:
%   1. queryExampleDetails() - User-friendly query interface for finding examples
%   2. TestCaseValidationTests.testExampleDefinitionsUnchanged() - Automated validation
%
% The reference file serves as a snapshot of test case definitions, allowing
% detection of unintended changes during development and CI/CD.
%
% Syntax:
%   exportExampleReference()
%
% Output File:
%   utilities/framework-unittests/reference-data/example_registry.mat
%
% The MAT-file contains:
%   exampleMap      - Table with all example metadata (from buildExampleIdMap)
%   metadata        - Struct with generation info:
%       .generatedDate    - Timestamp of reference generation
%       .matlabVersion    - MATLAB version used
%       .totalExamples    - Total number of examples
%       .numStandalone    - Number of standalone examples
%       .numSuite         - Number of test suite cases
%       .num2D            - Number of 2D test cases
%       .num3D            - Number of 3D test cases
%       .categories       - Cell array of category names
%
% Workflow:
%   1. Modify or add test cases in your code
%   2. Run exportExampleReference() to update the reference
%   3. Review changes with queryExampleDetails() or via git diff
%   4. Commit both code changes and updated reference-data/example_registry.mat
%   5. Framework tests will automatically validate against this reference
%
% Examples:
%   % Update reference after adding new examples
%   exportExampleReference();
%
%   % Verify the update worked
%   queryExampleDetails();  % Should show your new examples
%
% See also: buildExampleIdMap, queryExampleDetails, TestCaseValidationTests

fprintf('Generating example reference data...\n');

% Build current example map
fprintf('  Building example ID map...\n');
exampleMap = buildExampleIdMap('all');

if isempty(exampleMap)
    error('No examples found. Check that you are in the project root directory.');
end

% Generate metadata
metadata = struct();
metadata.generatedDate = datestr(now, 'yyyy-mm-dd HH:MM:SS');
metadata.matlabVersion = version;
metadata.totalExamples = height(exampleMap);

% Count standalone vs suite
isSuite = ~strcmp(exampleMap.TestSuiteIndex, '1/1');
metadata.numStandalone = sum(~isSuite);
metadata.numSuite = sum(isSuite);

% Count by dimension
categories = unique(exampleMap.ExampleCategory);
is2D = contains(categories, '2D');
is3D = contains(categories, '3D');
metadata.num2D = sum(ismember(exampleMap.ExampleCategory, categories(is2D)));
metadata.num3D = sum(ismember(exampleMap.ExampleCategory, categories(is3D)));

% Get unique categories
metadata.categories = categories;

% Determine output path
% mfilename('fullpath') = .../utilities/framework-unittests/helpers/exportExampleReference.m
helpersPath = fileparts(mfilename('fullpath'));              % .../helpers
frameworkTestsPath = fileparts(helpersPath);                 % .../framework-unittests
refDataDir = fullfile(frameworkTestsPath, 'reference-data');
outputFile = fullfile(refDataDir, 'example_registry.mat');

% Create directory if needed
if ~exist(refDataDir, 'dir')
    fprintf('  Creating reference-data directory...\n');
    mkdir(refDataDir);
end

% Save reference data
fprintf('  Saving to: %s\n', outputFile);
save(outputFile, 'exampleMap', 'metadata', '-v7.3');

% Display summary
fprintf('\n');
fprintf('=================================================\n');
fprintf('  Example Reference Generated\n');
fprintf('=================================================\n');
fprintf('Date: %s\n', metadata.generatedDate);
fprintf('MATLAB: %s\n', metadata.matlabVersion);
fprintf('\n');
fprintf('Statistics:\n');
fprintf('  Total examples:      %3d\n', metadata.totalExamples);
fprintf('  Standalone:          %3d\n', metadata.numStandalone);
fprintf('  Test suite cases:    %3d\n', metadata.numSuite);
fprintf('  2D test cases:       %3d\n', metadata.num2D);
fprintf('  3D test cases:       %3d\n', metadata.num3D);
fprintf('  Categories:          %3d\n', length(metadata.categories));
fprintf('\n');
fprintf('Categories:\n');
for i = 1:length(metadata.categories)
    numInCategory = sum(strcmp(exampleMap.ExampleCategory, metadata.categories{i}));
    fprintf('  %-30s %3d examples\n', metadata.categories{i}, numInCategory);
end
fprintf('\n');
fprintf('Reference file saved: %s\n', outputFile);
fprintf('=================================================\n');
fprintf('\n');
fprintf('Next steps:\n');
fprintf('  1. Review changes with: queryExampleDetails()\n');
fprintf('  2. Run framework tests: runAllFrameworkTests()\n');
fprintf('  3. Commit the updated reference file to version control\n');
fprintf('\n');

end
