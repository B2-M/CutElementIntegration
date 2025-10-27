function runExampleTests_validateTestNames(testNameCell)
% Separate validation logic - pure function

testsKnown = getTestSuiteNames();
for i = 1:length(testNameCell)
    if ~any(cellfun(@(x) isequal(x, testNameCell{i}), testsKnown))
        error("Test %s is not known", testNameCell{i})
    end
end

end