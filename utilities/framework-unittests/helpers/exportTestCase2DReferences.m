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

function exportTestCase2DReferences()
% EXPORTTESTCASE2DREFERENCES Generate reference configurations for all 2D test cases
%
%   This function creates a reference snapshot of all test case configurations
%   defined in getTestCase2D. These references are used by UtilityFunctionTests
%   to detect unintended changes to test case definitions.
%
%   Purpose:
%   When runExampleTests fails, this helps distinguish between:
%   - Integrator failures (real bugs)
%   - Test case definition changes (requires reference update)
%
%   Usage:
%   Run this function after intentionally modifying test cases in getTestCase2D
%   to update the reference configuration file.
%
%   Output:
%   Creates/updates: utilities/framework-unittests/reference-data/testcase2d_config_ref.mat
%
%   See also: getTestCase2D, UtilityFunctionTests

    fprintf('Generating reference configurations for 2D test cases...\n');

    % Initialize structure array
    config = struct([]);

    % Total number of test cases (from getTestCase2D)
    numTestCases = 49;

    % Extract configuration from each test case
    for id = 1:numTestCases
        try
            % Get test case object
            tc = getTestCase2D(id);

            % Store configuration
            config(id).testCaseId = id;
            config(id).x_min = tc.domain.xmin;
            config(id).x_max = tc.domain.xmax;
            config(id).interfaceId = tc.interface.id;

            % Store reference solutions
            % For constant integrand (integrand=1), all reference values are valid
            % For arbitrary integrands, exact_outside and exact_interface are -1
            if tc.integrand == 1
                config(id).exact_inside = tc.references.exact_inside;
                config(id).exact_outside = tc.references.exact_outside;
                config(id).exact_interface = tc.references.exact_interface;
                config(id).hasArbitraryIntegrand = false;
            else
                config(id).exact_inside = tc.references.exact_inside;
                config(id).exact_outside = tc.references.exact_outside;
                config(id).exact_interface = tc.references.exact_interface;
                config(id).hasArbitraryIntegrand = true;
            end

            fprintf('  [%2d/%2d] Test case %2d: Interface %2d, Domain [%.2f,%.2f]x[%.2f,%.2f]\n', ...
                id, numTestCases, id, tc.interface.id, ...
                tc.domain.xmin(1), tc.domain.xmax(1), ...
                tc.domain.xmin(2), tc.domain.xmax(2));

        catch ME
            warning('Failed to process test case %d: %s', id, ME.message);
            continue;
        end
    end

    % Ensure reference data directory exists
    refDir = 'utilities/framework-unittests/reference-data';
    if ~exist(refDir, 'dir')
        mkdir(refDir);
        fprintf('Created directory: %s\n', refDir);
    end

    % Save reference configuration
    refFile = fullfile(refDir, 'testcase2d_config_ref.mat');
    save(refFile, 'config');

    fprintf('\nSuccessfully generated references for %d test cases\n', length(config));
    fprintf('Saved to: %s\n', refFile);
    fprintf('\nThese references will be used by UtilityFunctionTests.testGetTestCase2D\n');
    fprintf('to detect unintended changes to test case definitions.\n');
end
