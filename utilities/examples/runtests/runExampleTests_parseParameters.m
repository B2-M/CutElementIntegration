function params = runExampleTests_parseParameters(testType, testNameCell, testPlots, integratorName)
% Refactored parameter validation function
% Pure function - easy to test

% Validate testType
if nargin < 1 || isempty(testType)
    params.testType = 'unitTest';
elseif ismember(testType, {'unitTest', 'convergenceStudy'})
    params.testType = testType;
else
    error("Test type %s is not known; choose 'unitTest' or 'convergenceStudy'.", testType)
end

% Validate and resolve test names
if nargin < 2 || isempty(testNameCell) || any(strcmp(testNameCell, 'all'))
    params.tests = getTestSuiteNames();
else
    runExampleTests_validateTestNames(testNameCell); % Can throw error
    params.tests = testNameCell;
end

% Validate plot settings
if nargin < 3 
    testPlots = [];
end
params.testPlots = runExampleTests_resolvePlotSettings(testPlots, params.testType);

% Validate integrator
if nargin < 4 || isempty(integratorName)
    params.integratorName = 'default';
else
    params.integratorName = integratorName;
end

end