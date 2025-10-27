%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, Universtiy of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guliherme H. Teixeira, Graz University of Technology  
%    Muhammed Toprak, Technische Universität Darmstadt
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
% “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER 
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function runExampleTests( testType, testNameCell, testPlots, integratorName )
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.selectors.HasParameter

%% optional inputs:
% testType: 'convergenceStudy' or 'unitTest' (the latter runs only 1-2 steps of the former)
% testNameCell: cell of specific tests to be run or 'all'
% testPlots: 
% 'default' takes plot_settings from test class 
% 'on' sets all plot options to 'on' 
% 'off' sets all plot options to 'off'
% 'error' sets 'PlotError' to 'on'
% integratorName: name of a specific integrators


%% example calls:
% runExampleTests                       % default: run all tests as unit tests
% runExampleTests( 'convergenceStudy' ) % all tests with all refinement steps
% runExampleTests( 'convergenceStudy', {'testExampleChanges_AreaComputation2D'} )
% runExampleTests( 'unitTest', {'testExampleChanges_AreaComputation2D','testExampleChanges_InterfaceComputation2D'} )
% runExampleTests( 'unitTest', {'testExampleChanges_AreaComputation2D'}, 'on' )
% runExampleTests( 'convergenceStudy', {'testExampleChanges_AreaComputation2D'}, 'error', 'Ginkgo' )
% runExampleTests( 'unitTest', 'all', 'off', 'Ginkgo' )

% set external parameter -> unitTest or full convergenceStudy
if nargin < 1
    testType = 'unitTest';
    testPlots = 'off';
elseif ~strcmp(testType,'unitTest') && ~strcmp(testType,'convergenceStudy')
    error("Test type %s is not known; choose 'unitTest' or 'convergenceStudy'.", testType)
end

% get testnames
if nargin < 2 || any(strcmp(testNameCell,'all'))
    tests = { ...
        'testExampleChanges_AreaComputation2D',...
        'testExampleChanges_AreaComputation3D',...
        'testExampleChanges_InterfaceComputation2D',...
        'testExampleChanges_InterfaceComputation3D',...
        'testExampleChanges_AreaFluxComputation2D',...
        'testExampleChanges_AreaFluxComputation3D',...
        'testExampleChanges_AreaComputationMoving2D'...
        };
else 
    tests = testNameCell;
end

if nargin < 3
    if strcmp(testType,'unitTest')
        testPlots = 'off';
    else
        testPlots = 'default';
    end
end

if nargin < 4
    integratorName = 'default';
end

% add tests to testsuite
suite = [];
for i = 1 : length(tests)
    testObj = meta.class.fromName(tests{i});
    if strcmp(testType,'unitTest')
        % get all integrators for this test
        integrator_names = local_get_integrator_names(testObj,integratorName);
        % set up a test for each integrator separately for clearer error reports
        for j = 1 : length(integrator_names)
            para = matlab.unittest.parameters.Parameter.fromData( ...
                'eTestType', {testType}, ...
                'eIntegrator', {integrator_names{j}}, ...
                'ePlots', {testPlots}); %#ok<CCAT1>
            suite = [suite, TestSuite.fromClass(testObj, 'ExternalParameters', para)]; %#ok<AGROW>
        end
    else
        % for convergence studies set up one test for all integrators
        if strcmp(integratorName,'default')
            para = matlab.unittest.parameters.Parameter.fromData( ...
                'eTestType', {testType} );
        else
            integrator_names = local_get_integrator_names(testObj,integratorName);
            if isempty(integrator_names)
                continue
            end
            para = matlab.unittest.parameters.Parameter.fromData( ...
                'eTestType', {testType}, ...
                'eIntegrator', integrator_names, ...
                'ePlots', {testPlots} );
        end
        suite = [suite, TestSuite.fromClass(testObj, 'ExternalParameters', para)]; %#ok<AGROW>
    end
end

% run tests
if ~isempty(suite)
    runner = TestRunner.withTextOutput;
    result = runner.run(suite);
    reportPath = "reports/"+integratorName;
    mkdir(reportPath)
    result.generateHTMLReport(reportPath)    

     % Check if any test failed
    if any([result.Failed])    
        error("Some tests have failed"); 
    end
end

end

function integrator_names = local_get_integrator_names( testObj, integratorName )

% get all integrators for this test
testObjProp = findobj(testObj.PropertyList,'Name','integrator_names');
integrator_names = testObjProp.DefaultValue;

% limit to integratorName if this input option is set
if ~strcmp(integratorName,'default')
    index = cellfun(@(x) strcmp(x,integratorName), integrator_names, 'UniformOutput', 1);
    integrator_names = {integrator_names{index}};
    if isempty(integrator_names)
        warning("Integrator %s is not known for %s", integratorName, testObj.Name)
    end
end

end