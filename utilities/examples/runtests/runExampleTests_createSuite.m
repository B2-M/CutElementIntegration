function suite = runExampleTests_createSuite(suiteConfigs)
% Convert configurations to actual MATLAB TestSuite objects
% This is the only function that touches MATLAB's unittest framework

import matlab.unittest.TestSuite
import matlab.unittest.parameters.Parameter

suite = [];
for i = 1:length(suiteConfigs)
    config = suiteConfigs{i};
    testObj = meta.class.fromName(config.testClass);
    
    if strcmp(config.testType, 'unitTest')
        para = Parameter.fromData( ...
            'eTestType', {config.testType}, ...
            'eIntegrator', {config.integrator}, ...
            'ePlots', {config.plots});
        newSuite = TestSuite.fromClass(testObj, 'ExternalParameters', para);
    else
        para = Parameter.fromData( ...
            'eTestType', {config.testType}, ...
            'eIntegrator', config.integrators, ...
            'ePlots', {config.plots});
        newSuite = TestSuite.fromClass(testObj, 'ExternalParameters', para);
    end
    
    suite = [suite, newSuite]; %#ok<AGROW>
end

end