function integratorNames = getAllIntegratorNames()
% GETALLINTEGRATORNAMES Auto-detect all integrator names
%
% Automatically discovers integrator names by scanning the codes directory
% for files matching the *Integrator.m pattern and extracting the base names.
% This eliminates the need to manually maintain a hardcoded list.
%
% Usage:
%   integratorNames = getAllIntegratorNames();
%   % Returns: {'Algoim', 'BoSSS', 'Fcmlab', ...}
%
% Output:
%   integratorNames - Cell array of integrator names (auto-detected)

    % Scan codes directory for integrator files
    integratorFiles = dir('./codes/*Integrator.m');
    
    % Extract integrator names from file names (remove 'Integrator' suffix)
    integratorNames = cell(length(integratorFiles), 1);
    for i = 1:length(integratorFiles)
        [~, fileName, ~] = fileparts(integratorFiles(i).name);
        % Remove 'Integrator' suffix to get the name
        integratorNames{i} = fileName(1:end-10);  % Remove 'Integrator' (10 chars)
    end
    
    % Sort for consistent ordering
    integratorNames = sort(integratorNames);
    
end