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

function runExampleTests(testType, testNameCell, testPlots, integratorName)
%
% REFACTORED ARCHITECTURE:
% This function has been refactored from a monolithic implementation into a 
% modular architecture with clear separation of concerns. The implementation 
% follows functional programming principles with pure functions for parameter 
% validation, configuration building, and isolated side effects for execution.
%
% DESIGN PRINCIPLES:
% - Modular design: Each step is handled by a dedicated helper function
% - Testability: Pure functions enable easy unit testing of individual components
% - Maintainability: Clear ownership and naming conventions (runExampleTests_*)
% - Backward compatibility: Same API as original monolithic implementation
%
% HELPER FUNCTIONS (utilities/examples/runtests/runExampleTests_*.m):
% - parseParameters: Input validation and default value assignment
% - buildConfigurations: Test suite configuration creation
% - createSuite: MATLAB test suite instantiation
% - executeSuite: Test execution with progress reporting
%

%% optional inputs:
% testType: 'convergenceStudy' or 'unitTest' (the latter runs only 1-2 steps of the former)
% testNameCell: cell of specific tests to be run or 'all'
% testPlots: 
% 'default' takes plot_settings from test class 
% 'on' sets all plot options to 'on' 
% 'off' sets all plot options to 'off'
% 'error' sets 'PlotError' to 'on'
% integratorName: 
% 'name' of a specific integrators or 
% 'default' picks all integrators of testExampleChanges*.m (see test properties)

%% example calls:
% runExampleTests                       % default: run all tests as unit tests
% runExampleTests( 'convergenceStudy' ) % all tests with all refinement steps
% runExampleTests( 'convergenceStudy', {'testExampleChanges_AreaComputation2D'} )
% runExampleTests( 'unitTest', {'testExampleChanges_AreaComputation2D','testExampleChanges_InterfaceComputation2D'} )
% runExampleTests( 'unitTest', {'testExampleChanges_AreaComputation2D'}, 'on' )
% runExampleTests( 'convergenceStudy', {'testExampleChanges_AreaComputation2D'}, 'error', 'Ginkgo' )
% runExampleTests( 'unitTest', 'all', 'off', 'Ginkgo' )

% Add helpers path for helper functions
addpath('./examples/utils/unittest/helpers');

% Step 1: Validate and parse parameters (pure function - easily testable)
if nargin < 1, testType = []; end
if nargin < 2, testNameCell = []; end  
if nargin < 3, testPlots = []; end
if nargin < 4, integratorName = []; end

params = runExampleTests_parseParameters(testType, testNameCell, testPlots, integratorName);

% Step 2: Build test configurations (pure function - easily testable)  
suiteConfigs = runExampleTests_buildConfigurations(params);

% Step 3: Create MATLAB test suite (isolated dependency)
suite = runExampleTests_createSuite(suiteConfigs);

% Step 4: Execute tests (isolated side effects)
runExampleTests_executeSuite(suite, params.integratorName);

end