function foundIntegrators = checkIntegratorAvailability()
% CHECKINTEGRATORAVAILABILITY Test all integrators and return list of available ones
%
% This function attempts to initialize all known integrators and returns
% a list of those that are successfully available. Used by StartUpCall to
% pre-build the list of accessible integrators.
%
% Usage:
%   foundIntegrators = checkIntegratorAvailability();
%
% Output:
%   foundIntegrators - Cell array of integrator names that are available

    fprintf('Checking integrator availability...\n');
    
    % Get all known integrator names
    allIntegratorNames = getAllIntegratorNames();
    foundIntegrators = {};
    failedIntegrators = {};
    
    for i = 1:length(allIntegratorNames)
        integratorName = allIntegratorNames{i};
        integratorClass = [integratorName 'Integrator'];
        
        try
            % First check if integrator reports itself as accessible
            if exist(integratorClass, 'class') == 8
                isAccessible = feval([integratorClass '.IsAccessible']);
                if ~isAccessible
                    failedIntegrators{end+1} = integratorName;
                    fprintf('  ✗ %s: Not accessible (IsAccessible = false)\n', integratorName);
                    continue
                end
            end
            
            % If accessible, attempt to create integrator instance
            n_quad_pts = 1;
            objIntegrator = callIntegratorConstructor(integratorName,n_quad_pts);            
            if isCompatibleWithPlatform( objIntegrator )
                foundIntegrators{end+1} = integratorName;
                fprintf('  ✓ %s: Available\n', integratorName);
            else
                failedIntegrators{end+1} = integratorName;
                fprintf('  ✗ %s: Available but not compatible with the operating system (IsAccessible = false)\n', integratorName);
                continue
            end

            
        catch ME
            % Integrator failed to initialize
            failedIntegrators{end+1} = integratorName;
            fprintf('  ✗ %s: Failed (%s)\n', integratorName, ME.message);
        end
    end
    
    % Summary
    numTotal = length(allIntegratorNames);
    numFailed = length(failedIntegrators);
    numAvailable = length(foundIntegrators);

    fprintf('\n=== Integrator Availability Summary ===\n');
    fprintf('Available: %d of %d integrators\n', numAvailable, numTotal);
    if numFailed > 0
        fprintf('Note: Missing integrators may require additional dependencies or platform-specific setups.\n');
        fprintf('      See codes/[integrator]/README for setup instructions.\n');
    end
    fprintf('=======================================\n');

end