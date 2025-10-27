function suiteConfigs = runExampleTests_buildConfigurations(params)
% Pure function that returns configuration data instead of MATLAB objects
% Much easier to test than TestSuite objects

suiteConfigs = {};
configIndex = 1;

for i = 1:length(params.tests)
    testClassName = params.tests{i};
    
    if strcmp(params.testType, 'unitTest')
        % Get integrators for this test
        integrator_names = runExampleTests_getIntegratorNames(testClassName, params.integratorName);
        
        % Create separate configuration for each integrator
        for j = 1:length(integrator_names)
            suiteConfigs{configIndex} = struct(...
                'testClass', testClassName, ...
                'testType', params.testType, ...
                'integrator', integrator_names{j}, ...
                'plots', params.testPlots ...
            );
            configIndex = configIndex + 1;
        end
    else
        % Convergence study - one config per test class
        integrator_names = runExampleTests_getIntegratorNames(testClassName, params.integratorName);
        if ~isempty(integrator_names)
            suiteConfigs{configIndex} = struct(...
                'testClass', testClassName, ...
                'testType', params.testType, ...
                'integrators', {integrator_names}, ... % Cell of integrators
                'plots', params.testPlots ...
            );
            configIndex = configIndex + 1;
        end
    end
end

end