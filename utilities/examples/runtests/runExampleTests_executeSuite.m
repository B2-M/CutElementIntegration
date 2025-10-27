function results = runExampleTests_executeSuite(suite, integratorName)
% Pure execution logic - separated from orchestration

import matlab.unittest.TestRunner

if isempty(suite)
    results = [];
    return;
end

runner = TestRunner.withTextOutput;
results = runner.run(suite);

% Generate reports
reportPath = "reports/" + integratorName;
mkdir(reportPath);
results.generateHTMLReport(reportPath);

% Check for failures
if any([results.Failed])
    error("Some tests have failed");
end

end