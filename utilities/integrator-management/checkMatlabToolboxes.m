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
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function missingToolboxes = checkMatlabToolboxes()
% CHECKMATLABTOOLBOXES Check for required MATLAB toolboxes
%
% Checks if required MATLAB toolboxes are installed and displays
% warnings for any missing toolboxes.
%
% Output:
%   missingToolboxes - Cell array of missing toolbox names
%
% Required toolboxes:
%   - Symbolic Math Toolbox: Required for reference solution computation
%     in certain test cases (e.g., UniBw Munich examples)

    fprintf('Checking MATLAB toolbox availability...\n');

    % Define required toolboxes with their display names and usage
    requiredToolboxes = {
        'Symbolic Math Toolbox', 'Reference solution computation for certain test cases'
    };

    missingToolboxes = {};

    for i = 1:size(requiredToolboxes, 1)
        toolboxName = requiredToolboxes{i, 1};
        usage = requiredToolboxes{i, 2};

        % Check if toolbox is actually installed (not just licensed)
        hasToolbox = isToolboxInstalled(toolboxName);

        if hasToolbox
            fprintf('  ✓ %s: Available\n', toolboxName);
        else
            fprintf('  ✗ %s: Not installed\n', toolboxName);
            missingToolboxes{end+1} = toolboxName;
            fprintf('    Usage: %s\n', usage);
        end
    end

    % Summary
    if isempty(missingToolboxes)
        fprintf('All required MATLAB toolboxes are installed.\n');
    else
        fprintf('\n=== MATLAB Toolbox Warning ===\n');
        fprintf('Missing %d required toolbox(es):\n', length(missingToolboxes));
        for i = 1:length(missingToolboxes)
            fprintf('  - %s\n', missingToolboxes{i});
        end
        fprintf('\nNote: Some test cases and examples may fail without these toolboxes.\n');
        fprintf('      Install missing toolboxes via MATLAB Add-On Explorer.\n');
        fprintf('==============================\n');
    end

end

function hasToolbox = isToolboxInstalled(toolboxName)
% ISTOOLBOXINSTALLED Check if a MATLAB toolbox is actually installed
%
% Uses 'ver' command to verify installation rather than just license
% availability.
%
% Input:
%   toolboxName - Toolbox display name (e.g., 'Symbolic Math Toolbox')
%
% Output:
%   hasToolbox - Boolean indicating if toolbox is installed

    % Get information about all installed products
    v = ver;

    % Extract product names from the version structure
    installedProducts = {v.Name};

    % Check if the toolbox is in the installed products list
    hasToolbox = any(strcmpi(installedProducts, toolboxName));

end
