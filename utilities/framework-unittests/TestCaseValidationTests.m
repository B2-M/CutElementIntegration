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

classdef TestCaseValidationTests < matlab.unittest.TestCase
% Test suite for validating interface and test case definitions
%
% This test class validates the correctness and consistency of:
% - Interface definitions (2D and 3D geometries)
% - Test case configurations (domain, interface mapping, reference solutions)
% - Cross-validation between implicit and parametric geometry representations
%
% Purpose:
% - Ensure interface definitions are valid and mathematically consistent
% - Detect unintended changes to test case configurations
% - Help distinguish between integrator failures vs test definition changes
%
% Usage:
%   suite = testsuite('TestCaseValidationTests');
%   results = run(suite);
%   results.generateHTMLReport
%
% Calling specific examples:
%   testCase = TestCaseValidationTests;
%   testCase.testGetStaticInterfaceCase2D(staticInterface2DId); 


    properties (TestParameter)
        % Parameterized test data for static 2D interfaces (no 'd' parameter needed)
        staticInterface2DId = num2cell([1:4, 10:36, 38, 43:45]);
        % Parameterized test data for moving 2D interfaces (require 'd' parameter)
        movingInterface2DId = num2cell([5:9, 37, 39:42, 46]);
        % Parameterized test data for 3D interfaces
        interface3DId = num2cell(1:5);
        % Parameterized test data for 2D test cases
        testCase2DId = num2cell([1:49]);
        % Parameterized test data for 3D test cases
        testCase3DId = num2cell([1:5]);
    end

    methods (TestClassSetup)
        function setupValidationTests(testCase)
            % Verify we're running from project root
            testCase.verifyTrue(isCurrentFolderCorrect(), ...
                'Tests must be run from project root directory containing codes/ folder');
        end
    end

    methods(Test)

        %% Interface Validation Tests

        function testGetStaticInterfaceCase2D(testCase, staticInterface2DId)
            % Test static 2D interface case creation - one test per interface ID (parameterized)
            % Static interfaces do not require 'd' parameter (use default d=0)

            % Call function and verify it returns an Interface object
            interface = getInterfaceCase2D(staticInterface2DId);
            testCase.verifyTrue(isa(interface, 'Interface'), ...
                sprintf('Should return Interface object'));

            % Verify interface dimension is 2D
            testCase.verifyEqual(interface.dim, 2, 'Should be 2D');

            % Verify interface has valid domain sizes
            testCase.verifyGreaterThan(interface.domainGamma, 0, ...
                'domainGamma (interface length) must be positive');
            testCase.verifyGreaterThanOrEqual(interface.domainEnclosed, 0, ...
                'domainEnclosed (area) must be non-negative');

            % Verify either implicit or parametric definition exists
            hasImplicit = ~isempty(interface.implicit);
            hasParametric = ~isempty(interface.parametric);
            testCase.verifyTrue(hasImplicit || hasParametric, ...
                'Must have either implicit or parametric definition');

            % Verify interface ID is set correctly
            testCase.verifyEqual(interface.id, staticInterface2DId, 'ID should match');

            % CROSS-VALIDATION: Verify implicit and parametric representations match
            if hasImplicit && hasParametric
                testCase.performCrossValidation2D(interface, staticInterface2DId);
            end
        end

        function testGetMovingInterfaceCase2D(testCase, movingInterface2DId)
            % Test moving 2D interface case creation - one test per interface ID (parameterized)
            % Moving interfaces require 'd' parameter (tested at rest position d=0.1)

            for d = [0,0.1]
                interface = getInterfaceCase2D(movingInterface2DId, d);
                testCase.verifyTrue(isa(interface, 'Interface'), ...
                    sprintf('Should return Interface object'));

                % Verify interface dimension is 2D
                testCase.verifyEqual(interface.dim, 2, 'Should be 2D');

                % Verify interface has valid domain sizes
                testCase.verifyGreaterThan(interface.domainGamma, 0, ...
                    'domainGamma (interface length) must be positive');
                testCase.verifyGreaterThanOrEqual(interface.domainEnclosed, 0, ...
                    'domainEnclosed (area) must be non-negative');

                % Verify either implicit or parametric definition exists
                hasImplicit = ~isempty(interface.implicit);
                hasParametric = ~isempty(interface.parametric);
                testCase.verifyTrue(hasImplicit || hasParametric, ...
                    'Must have either implicit or parametric definition');

                % Verify interface ID is set correctly
                testCase.verifyEqual(interface.id, movingInterface2DId, 'ID should match');

                % CROSS-VALIDATION: Verify implicit and parametric representations match
                if hasImplicit && hasParametric
                    testCase.performCrossValidation2D(interface, movingInterface2DId);
                end
            end
        end

        function testInvalidInterfaceCase2D(testCase)
            % Test that invalid interface ID throws error
            testCase.verifyError(@() getInterfaceCase2D(999), ?MException);
        end

        function testGetStaticInterfaceCase3D(testCase, interface3DId)
            % Test static 3D interface case creation - one test per interface ID (parameterized)
            % All 3D interfaces are currently static (no 'd' parameter)

            % Call function and verify it returns an Interface object
            interface = getInterfaceCase3D(interface3DId);
            testCase.verifyTrue(isa(interface, 'Interface'), ...
                sprintf('Should return Interface object'));

            % Verify interface dimension is 3D
            testCase.verifyEqual(interface.dim, 3, 'Should be 3D');

            % Verify interface has valid domain sizes
            testCase.verifyGreaterThan(interface.domainGamma, 0, ...
                'domainGamma (interface area) must be positive');
            testCase.verifyGreaterThanOrEqual(interface.domainEnclosed, 0, ...
                'domainEnclosed (volume) must be non-negative');

            % Verify either implicit or parametric definition exists
            hasImplicit = ~isempty(interface.implicit);
            hasParametric = ~isempty(interface.parametric);
            testCase.verifyTrue(hasImplicit || hasParametric, ...
                'Must have either implicit or parametric definition');

            % Verify interface ID is set correctly
            testCase.verifyEqual(interface.id, interface3DId, 'ID should match');

            % CROSS-VALIDATION: Verify implicit and parametric representations match
            if hasImplicit && hasParametric
                testCase.performCrossValidation3D(interface, interface3DId);
            end
        end

        function testInvalidInterfaceCase3D(testCase)
            % Test that invalid interface ID throws error
            testCase.verifyError(@() getInterfaceCase3D(999), ?MException);
        end

        %% Test Case Configuration Validation Tests

        function testGetTestCase2D(testCase, testCase2DId)
            % Test 2D test case configuration - detects unintended changes to test definitions
            %
            % Purpose: When runExampleTests fails, this helps distinguish between:
            %   - Integrator failures (real bugs)
            %   - Test case definition changes (requires reference update)
            %
            % This test compares current test case configuration against stored references.
            % If test case definitions are intentionally modified, update references by running:
            %   >> exportTestCase2DReferences()

            % Load reference configurations (cached for performance)
            persistent refConfigs;
            if isempty(refConfigs)
                refDataPath = fullfile('utilities', 'framework-unittests', ...
                    'reference-data', 'testcase2d_config_ref.mat');

                testCase.assertTrue(exist(refDataPath, 'file') == 2, ...
                    sprintf(['Reference file not found: %s\n' ...
                    'Run exportTestCase2DReferences() to generate it.'], refDataPath));

                refData = load(refDataPath);
                refConfigs = refData.config;
            end

            % Get current test case
            tc = getTestCase2D(testCase2DId);

            % Find reference for this test case ID
            refIdx = find([refConfigs.testCaseId] == testCase2DId, 1);
            testCase.assertNotEmpty(refIdx, ...
                sprintf('No reference found for testCaseId=%d. Regenerate references.', testCase2DId));

            ref = refConfigs(refIdx);

            % Compare domain configuration
            testCase.verifyEqual(tc.domain.xmin, ref.x_min, ...
                sprintf(['Domain x_min changed for testCaseId=%d.\n' ...
                'Expected: [%.4f, %.4f], Got: [%.4f, %.4f]\n' ...
                'If intentional, run exportTestCase2DReferences() to update.'], ...
                testCase2DId, ref.x_min(1), ref.x_min(2), tc.domain.xmin(1), tc.domain.xmin(2)));

            testCase.verifyEqual(tc.domain.xmax, ref.x_max, ...
                sprintf(['Domain x_max changed for testCaseId=%d.\n' ...
                'Expected: [%.4f, %.4f], Got: [%.4f, %.4f]\n' ...
                'If intentional, run exportTestCase2DReferences() to update.'], ...
                testCase2DId, ref.x_max(1), ref.x_max(2), tc.domain.xmax(1), tc.domain.xmax(2)));

            % Compare interface ID
            testCase.verifyEqual(tc.interface.id, ref.interfaceId, ...
                sprintf(['InterfaceId changed for testCaseId=%d.\n' ...
                'Expected: %d, Got: %d\n' ...
                'If intentional, run exportTestCase2DReferences() to update.'], ...
                testCase2DId, ref.interfaceId, tc.interface.id));

            % Compare reference solutions
            % Note: For arbitrary integrands (test cases 46-49), exact_outside and
            % exact_interface are -1 (not applicable)
            testCase.verifyEqual(tc.references.exact_inside, ref.exact_inside, 'RelTol', 1e-14, ...
                sprintf(['Reference exact_inside changed for testCaseId=%d.\n' ...
                'Expected: %.15g, Got: %.15g\n' ...
                'If intentional, run exportTestCase2DReferences() to update.'], ...
                testCase2DId, ref.exact_inside, tc.references.exact_inside));

            if ~ref.hasArbitraryIntegrand
                % For constant integrand, all reference values should match
                testCase.verifyEqual(tc.references.exact_outside, ref.exact_outside, 'RelTol', 1e-14, ...
                    sprintf(['Reference exact_outside changed for testCaseId=%d.\n' ...
                    'Expected: %.15g, Got: %.15g\n' ...
                    'If intentional, run exportTestCase2DReferences() to update.'], ...
                    testCase2DId, ref.exact_outside, tc.references.exact_outside));

                testCase.verifyEqual(tc.references.exact_interface, ref.exact_interface, 'RelTol', 1e-14, ...
                    sprintf(['Reference exact_interface changed for testCaseId=%d.\n' ...
                    'Expected: %.15g, Got: %.15g\n' ...
                    'If intentional, run exportTestCase2DReferences() to update.'], ...
                    testCase2DId, ref.exact_interface, tc.references.exact_interface));
            end

            % Basic sanity checks
            testCase.verifyClass(tc, 'TestCase');
            testCase.verifyEqual(tc.id, testCase2DId);
            testCase.verifyEqual(tc.dim, 2);
        end

        function testGetTestCase3D(testCase, testCase3DId)
            % Test 3D test case configuration - detects unintended changes to test definitions
            %
            % Purpose: When runExampleTests fails, this helps distinguish between:
            %   - Integrator failures (real bugs)
            %   - Test case definition changes (requires reference update)
            %
            % This test compares current test case configuration against stored references.
            % If test case definitions are intentionally modified, update references by running:
            %   >> exportTestCase3DReferences()

            % Load reference configurations (cached for performance)
            persistent refConfigs;
            if isempty(refConfigs)
                refDataPath = fullfile('utilities', 'framework-unittests', ...
                    'reference-data', 'testcase3d_config_ref.mat');

                testCase.assertTrue(exist(refDataPath, 'file') == 2, ...
                    sprintf(['Reference file not found: %s\n' ...
                    'Run exportTestCase3DReferences() to generate it.'], refDataPath));

                refData = load(refDataPath);
                refConfigs = refData.config;
            end

            % Get current test case
            tc = getTestCase3D(testCase3DId);

            % Find reference for this test case ID
            refIdx = find([refConfigs.testCaseId] == testCase3DId, 1);
            testCase.assertNotEmpty(refIdx, ...
                sprintf('No reference found for testCaseId=%d. Regenerate references.', testCase3DId));

            ref = refConfigs(refIdx);

            % Compare domain configuration
            testCase.verifyEqual(tc.domain.xmin, ref.x_min, ...
                sprintf(['Domain x_min changed for testCaseId=%d.\n' ...
                'Expected: [%.4f, %.4f, %.4f], Got: [%.4f, %.4f, %.4f]\n' ...
                'If intentional, run exportTestCase3DReferences() to update.'], ...
                testCase3DId, ref.x_min(1), ref.x_min(2), ref.x_min(3), ...
                tc.domain.xmin(1), tc.domain.xmin(2), tc.domain.xmin(3)));

            testCase.verifyEqual(tc.domain.xmax, ref.x_max, ...
                sprintf(['Domain x_max changed for testCaseId=%d.\n' ...
                'Expected: [%.4f, %.4f, %.4f], Got: [%.4f, %.4f, %.4f]\n' ...
                'If intentional, run exportTestCase3DReferences() to update.'], ...
                testCase3DId, ref.x_max(1), ref.x_max(2), ref.x_max(3), ...
                tc.domain.xmax(1), tc.domain.xmax(2), tc.domain.xmax(3)));

            % Compare interface ID
            testCase.verifyEqual(tc.interface.id, ref.interfaceId, ...
                sprintf(['InterfaceId changed for testCaseId=%d.\n' ...
                'Expected: %d, Got: %d\n' ...
                'If intentional, run exportTestCase3DReferences() to update.'], ...
                testCase3DId, ref.interfaceId, tc.interface.id));

            % Compare reference solutions
            % Note: For arbitrary integrands (test case 5), exact_outside and
            % exact_interface are -1 (not applicable)
            testCase.verifyEqual(tc.references.exact_inside, ref.exact_inside, 'RelTol', 1e-14, ...
                sprintf(['Reference exact_inside changed for testCaseId=%d.\n' ...
                'Expected: %.15g, Got: %.15g\n' ...
                'If intentional, run exportTestCase3DReferences() to update.'], ...
                testCase3DId, ref.exact_inside, tc.references.exact_inside));

            if ~ref.hasArbitraryIntegrand
                % For constant integrand, all reference values should match
                testCase.verifyEqual(tc.references.exact_outside, ref.exact_outside, 'RelTol', 1e-14, ...
                    sprintf(['Reference exact_outside changed for testCaseId=%d.\n' ...
                    'Expected: %.15g, Got: %.15g\n' ...
                    'If intentional, run exportTestCase3DReferences() to update.'], ...
                    testCase3DId, ref.exact_outside, tc.references.exact_outside));

                testCase.verifyEqual(tc.references.exact_interface, ref.exact_interface, 'RelTol', 1e-14, ...
                    sprintf(['Reference exact_interface changed for testCaseId=%d.\n' ...
                    'Expected: %.15g, Got: %.15g\n' ...
                    'If intentional, run exportTestCase3DReferences() to update.'], ...
                    testCase3DId, ref.exact_interface, tc.references.exact_interface));
            end

            % Basic sanity checks
            testCase.verifyClass(tc, 'TestCase');
            testCase.verifyEqual(tc.id, testCase3DId);
            testCase.verifyEqual(tc.dim, 3);
        end

        %% Example Definition Consistency Tests

        function testExampleDefinitionsUnchanged(testCase)
            % Test that example definitions haven't changed from reference
            %
            % This test compares current example definitions (testCaseId, interfaceId,
            % line numbers) against the stored reference to detect unintended modifications.
            %
            % Purpose: When runExampleTests fails, this helps distinguish between:
            %   - Integrator failures (real bugs)
            %   - Example definition changes (requires reference update)
            %
            % If example definitions are intentionally modified, update the reference:
            %   >> exportExampleReference()

            % Load reference data
            refDataPath = fullfile('utilities', 'framework-unittests', ...
                'reference-data', 'example_registry.mat');

            testCase.assertTrue(exist(refDataPath, 'file') == 2, ...
                sprintf(['Reference file not found: %s\n' ...
                'Run exportExampleReference() to generate it.'], refDataPath));

            refData = load(refDataPath);
            refMap = refData.exampleMap;

            % Get current state
            currentMap = buildExampleIdMap('all');

            % Create unique keys for comparison (ExampleFile|TestCaseId)
            refKeys = strcat(refMap.ExampleFile, '|', string(refMap.TestCaseId));
            curKeys = strcat(currentMap.ExampleFile, '|', string(currentMap.TestCaseId));

            % Check for added examples
            added = setdiff(curKeys, refKeys);
            testCase.verifyEmpty(added, ...
                sprintf(['New examples detected:\n  %s\n\n' ...
                'If these additions are intentional:\n' ...
                '  1. Run: exportExampleReference()\n' ...
                '  2. Verify changes with: queryExampleDetails()\n' ...
                '  3. Commit the updated reference file'], ...
                strjoin(added, '\n  ')));

            % Check for removed examples
            removed = setdiff(refKeys, curKeys);
            testCase.verifyEmpty(removed, ...
                sprintf(['Examples removed:\n  %s\n\n' ...
                'If these deletions are intentional:\n' ...
                '  1. Run: exportExampleReference()\n' ...
                '  2. Verify changes with: queryExampleDetails()\n' ...
                '  3. Commit the updated reference file'], ...
                strjoin(removed, '\n  ')));

            % Check for modifications in common entries
            commonKeys = intersect(refKeys, curKeys);
            modifications = {};

            for i = 1:length(commonKeys)
                key = commonKeys{i};
                refEntry = refMap(strcmp(refKeys, key), :);
                curEntry = currentMap(strcmp(curKeys, key), :);

                % Check if any relevant fields changed
                if refEntry.InterfaceId ~= curEntry.InterfaceId
                    modifications{end+1} = sprintf('%s: InterfaceId %d -> %d', ...
                        char(key), refEntry.InterfaceId, curEntry.InterfaceId); %#ok<AGROW>
                end

                if refEntry.TestCaseLine ~= curEntry.TestCaseLine
                    modifications{end+1} = sprintf('%s: TestCaseLine %d -> %d', ...
                        char(key), refEntry.TestCaseLine, curEntry.TestCaseLine); %#ok<AGROW>
                end

                if refEntry.InterfaceLine ~= curEntry.InterfaceLine
                    modifications{end+1} = sprintf('%s: InterfaceLine %d -> %d', ...
                        char(key), refEntry.InterfaceLine, curEntry.InterfaceLine); %#ok<AGROW>
                end

                if ~strcmp(refEntry.TestSuiteIndex{1}, curEntry.TestSuiteIndex{1})
                    modifications{end+1} = sprintf('%s: TestSuiteIndex %s -> %s', ...
                        char(key), refEntry.TestSuiteIndex{1}, curEntry.TestSuiteIndex{1}); %#ok<AGROW>
                end
            end

            testCase.verifyEmpty(modifications, ...
                sprintf(['Example definitions modified:\n  %s\n\n' ...
                'If these changes are intentional:\n' ...
                '  1. Run: exportExampleReference()\n' ...
                '  2. Review changes with: queryExampleDetails()\n' ...
                '  3. Commit the updated reference file\n\n' ...
                'Common causes:\n' ...
                '  - Edited getTestCase2D/3D or getInterfaceCase2D/3D\n' ...
                '  - Added/removed test cases in example files\n' ...
                '  - Modified test suite ranges'], ...
                strjoin(modifications, '\n  ')));
        end

    end

    methods (Access = private)
        %% Helper methods for cross-validation of geometric representations

        function performCrossValidation2D(testCase, interface, interfaceId)
            % Cross-validate that parametric and implicit representations define the same geometry
            % This is the crucial test for geometric consistency

            tolerance = 1e-6;  % Tolerance for level set value at parametric points
            numSamplePoints = 50;  % Number of points to sample along each curve

            % For each parametric loop
            for loopIdx = 1:length(interface.parametric)
                loop = interface.parametric{loopIdx};

                % For each curve in the loop
                for curveIdx = 1:length(loop)
                    curve = loop(curveIdx).curve;

                    % Sample points along the parametric curve
                    params = linspace(0, 1, numSamplePoints);
                    points = nrbeval(curve, params);

                    % Extract x, y coordinates (points is [x; y; z] matrix)
                    x_coords = points(1, :);
                    y_coords = points(2, :);

                    % For each implicit level set function
                    implMatch = [];
                    for implIdx = 1:length(interface.implicit)
                        phi = interface.implicit{implIdx}.phi;

                        % Evaluate implicit function at all parametric points
                        if any( abs( phi(x_coords,y_coords) ) > tolerance )
                            % Points on parametric curve should satisfy the
                            % implicit equation (phi ≈ 0)
                            % If this fails, check the next phi
                            continue
                        else
                            implMatch = [implMatch, implIdx];
                        end
                    end

                    if isempty(implMatch)
                        % Create figure for diagnostics (invisible)
                        clf
                        fig = figure('Visible', 'off');
                        hold on

                        % Plot implicit interfaces
                        v_max = max(max(x_coords),max(y_coords)) + 0.5;
                        v_min = min(min(x_coords),min(y_coords)) - 0.5;
                        gridsteps_level_set = v_min:0.1:v_max;
                        plot_level_set( interface.implicit, gridsteps_level_set, [0,-0.1] );
                        h_implicit = findobj(gca, 'Type', 'contour');  % Get contour handles
                        title(sprintf('Interface ID: %d - Cross-Validation Failed', interfaceId))

                        % Plot parametric curve
                        plot_domain(loop, 50);
                        h_parametric = findobj(gca, 'Type', 'line', '-not', 'Tag', 'contour');

                        % Plot parametric points that failed validation
                        h_points = scatter(x_coords, y_coords, 50, 'r', 'filled', 'DisplayName', 'Test Points');

                        % Create legend with explicit handles
                        % Use only the first handle of each type to avoid duplicates
                        legend_handles = [];
                        legend_labels = {};
                        if ~isempty(h_implicit)
                            legend_handles(end+1) = h_implicit(1);
                            legend_labels{end+1} = 'Implicit';
                        end
                        if ~isempty(h_parametric)
                            legend_handles(end+1) = h_parametric(1);
                            legend_labels{end+1} = 'Parametric';
                        end
                        legend_handles(end+1) = h_points;
                        legend_labels{end+1} = 'Test Points';
                        legend(legend_handles, legend_labels);

                        % Create diagnostic with figure
                        import matlab.unittest.diagnostics.FigureDiagnostic;
                        failMsg = sprintf(['Cross-validation FAILED!\n' ...
                            'Interface ID: %d\n' ...
                            'No implicit function matches parametric curve at loop %d, curve %d\n' ...
                            'See figure for visualization.'], ...
                            interfaceId, loopIdx, curveIdx);

                        testCase.verifyFail([failMsg, FigureDiagnostic(fig)]);

                        close(fig);
                        return;
                    end
                end
            end
        end


        function performCrossValidation3D(testCase, interface, interfaceId)
            % Cross-validate that parametric and implicit representations define the same geometry in 3D

            tolerance = 1e-6;  % Tolerance for level set value at parametric points
            numSamplePoints = 20;  % Number of points to sample along each direction

            % Skip if no parametric representation
            if isempty(interface.parametric)
                return;
            end

            % For each parametric loop
            for loopIdx = 1:length(interface.parametric)
                loop = interface.parametric{loopIdx};

                % For each surface/curve in the loop
                for surfIdx = 1:length(loop)
                    surface = loop(surfIdx).surf;

                    % Check if it's a surface (2-parameter) or curve (1-parameter)
                    if iscell(surface.knots) && length(surface.knots) == 2
                        % It's a surface with (u,v) parameters
                        u_params = linspace(0, 1, numSamplePoints);
                        v_params = linspace(0, 1, numSamplePoints);
                        points = nrbeval(surface, {u_params, v_params});

                        % points is [x; y; z; 1] with size [4 x numU x numV]
                        x_coords = squeeze(points(1, :, :));
                        y_coords = squeeze(points(2, :, :));
                        z_coords = squeeze(points(3, :, :));

                        % Flatten to vectors
                        x_vec = x_coords(:);
                        y_vec = y_coords(:);
                        z_vec = z_coords(:);
                    else
                        % It's a curve with single parameter
                        params = linspace(0, 1, numSamplePoints);
                        points = nrbeval(surface, params);

                        x_vec = points(1, :)';
                        y_vec = points(2, :)';
                        z_vec = points(3, :)';
                    end

                    % For each implicit level set function, check if it matches
                    implMatch = [];
                    for implIdx = 1:length(interface.implicit)
                        phi = interface.implicit{implIdx}.phi;

                        % Evaluate implicit function at all parametric points
                        if any( abs( phi(x_vec, y_vec, z_vec) ) > tolerance )
                            % Points on parametric surface should satisfy the
                            % implicit equation (phi ≈ 0)
                            % If this fails, check the next phi
                            continue
                        else
                            implMatch = [implMatch, implIdx];
                        end
                    end

                    if isempty(implMatch)
                        % Create figure for diagnostics (invisible)
                        fig = figure('Visible', 'off');
                        hold on

                        % Plot parametric points that failed validation
                        scatter3(x_vec, y_vec, z_vec, 50, 'r', 'filled', 'DisplayName', 'Test Points');

                        % Plot parametric surface
                        if iscell(surface.knots) && length(surface.knots) == 2
                            surf(x_coords, y_coords, z_coords, 'FaceAlpha', 0.5, 'DisplayName', 'Parametric');
                        else
                            plot3(x_vec, y_vec, z_vec, 'b-', 'LineWidth', 2, 'DisplayName', 'Parametric');
                        end

                        title(sprintf('Interface ID: %d - Cross-Validation Failed (3D)', interfaceId))
                        xlabel('x'); ylabel('y'); zlabel('z');
                        grid on; axis equal;
                        legend();

                        % Create diagnostic with figure
                        import matlab.unittest.diagnostics.FigureDiagnostic;
                        failMsg = sprintf(['Cross-validation FAILED!\n' ...
                            'Interface ID: %d\n' ...
                            'No implicit function matches parametric surface at loop %d, surface %d\n' ...
                            'See figure for visualization.'], ...
                            interfaceId, loopIdx, surfIdx);

                        testCase.verifyFail([failMsg, FigureDiagnostic(fig)]);

                        close(fig);
                        return;
                    end
                end
            end
        end
    end
end
