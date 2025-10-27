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

function out = getAccessibleIntegrators( n_quad_pts, problem_dim , add_var )
% INPUT
% n_quad_pts      % Number of quadrature point per element in each direction
% reparam_degree  % Degree of the reparametrisation of cut elements
% 
% optional:
% problem_dim     % Spatial dimension of the problem's background mesh

% OUTPUT
% out... cell of all Integrators (*.m files in ./codes) that are accessible
%        (i.e., with a present implementation) and compatible with the current
%        platform (i.e., Linux or Windows) 
%
% optional: return only those integrators suited for the problem's dimension
%
%---------------------------------------------------------
arguments
    n_quad_pts
    problem_dim = []
    add_var.n_quad_pts_green = 3
    add_var.reparam_degree = 3
    add_var.SpaceTreeDepth = 3
end
%---------------------------------------------------------

out = {};
if isCurrentFolderCorrect

    % Get all known integrator names
    allIntegratorNames = getAllIntegratorNames();

    % loop over integrators
    j = 0;
    objAllInt = cell(1, length(allIntegratorNames));
    for i = 1:length(allIntegratorNames)
        
        % set up integrator
        i_name = allIntegratorNames{i};  % Now i_name is the integrator name (e.g., "BoSSS")
        i_filename = [i_name 'Integrator.m'];  % Corresponding file name            

            % Load pre-built list of available integrators from StartUpCall
            global FOUND_INTEGRATORS
            if isempty(FOUND_INTEGRATORS)
                fprintf('Framework not initialized. Use StartUpCall()...\n');
                fprintf('Press Enter to continue or Ctrl+C to cancel: ');
                pause;
                StartUpCall();
            end

            % Skip integrators not found during StartUpCall
            if ~ismember(i_name, FOUND_INTEGRATORS)
                continue
            end

            try
                
                % call class constructor with integrator name
                objIntegrator = callIntegratorConstructor(i_name, n_quad_pts, add_var);                    
                   
            catch
                % This shouldn't happen if StartUpCall was run, but handle gracefully
                warning("%s: unexpected error during set-up.", i_name);
                continue
            end

        % check compatibility
        if isCompatibleWithPlatform( objIntegrator )
            
            bAdd = true;
            if ~isempty(problem_dim)
                % optional: check problem dimensions
                if ~isCompatibleWithProblemDim( objIntegrator, problem_dim )
                    bAdd = false;
                end
            end

            % check availability
            if ~objIntegrator.IsAccessible
                bAdd = false;
            end

            if bAdd
                j = j+1;
                objAllInt{j} = objIntegrator;
            end
            
        end

    end

    out = objAllInt(1:j);

    % disp("The following integrators are accessible:")
    % for i = 1 : length(out)
    %     fprintf('* %s\n', out{i}.Name)
    % end

end

end