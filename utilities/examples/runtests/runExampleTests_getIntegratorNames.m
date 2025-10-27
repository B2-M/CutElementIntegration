function integrator_names = runExampleTests_getIntegratorNames(testClassName, integratorName)
% Extract integrator resolution logic

try
    testObj = meta.class.fromName(testClassName);
    testObjProp = findobj(testObj.PropertyList, 'Name', 'integrator_names');
    all_integrators = testObjProp.DefaultValue;
    
    if strcmp(integratorName, 'default')
        integrator_names = all_integrators;
    else
        index = cellfun(@(x) strcmp(x, integratorName), all_integrators, 'UniformOutput', 1);
        integrator_names = {all_integrators{index}};
        if isempty(integrator_names)
            warning("Integrator %s is not known for %s", integratorName, testClassName)
        end
    end
catch
    integrator_names = {};
    warning("Could not get integrators for test class %s", testClassName);
end

end