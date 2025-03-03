%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, Universtiy of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guliherme H. Teixeira, Graz University of Technology  
%    Muhammed Toprak, Technische Universität Darmstadt
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

function out = getAccessibleIntegrators( n_quad_pts, reparam_degree, problem_dim  )

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
       

out = {};
if isCurrentFolderCorrect

    % get all *.m files in '.codes' folder (i.e., the interfaces to the integrators)
    listAllIntegratorInterfaceFiles = dir('./codes/*.m');

    % loop over interfaces
    j = 0;
    objAllInt = cell(1,length(listAllIntegratorInterfaceFiles));
    for i = 1 : length(listAllIntegratorInterfaceFiles)
        
        % set up integrator
        i_name = listAllIntegratorInterfaceFiles(i).name;
        if strcmp(i_name,'AlgoimIntegrator.m') || ...
                strcmp(i_name,'BoSSSIntegrator.m') || ... 
                strcmp(i_name,'EduFEMIntegrator.m') || ...
                strcmp(i_name,'FcmlabIntegrator.m') || ...
                strcmp(i_name,'GinkgoIntegrator.m') || ...
                strcmp(i_name,'NgsxfemIntegrator.m') || ...
                strcmp(i_name,'NutilsIntegrator.m') || ...
                strcmp(i_name,'QuahogIntegrator.m') || ...
                strcmp(i_name,'QuahogPEIntegrator.m') || ...
                strcmp(i_name,'QuesoIntegrator.m')            

            try
                % call class constructor
                objIntegrator = feval(i_name(1:end-2), n_quad_pts, reparam_degree);
            catch
                warning("%s: error during set-up.", i_name);
                continue
            end

        else
            warning("Integator %s not known!", i_name);
            continue
        end

        % check compatibility
        if isCompatibleWithPlatform( objIntegrator )
            
            bAdd = true;
            if nargin == 3
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

    disp("The following integrators are accessible:")
    for i = 1 : length(out)
        fprintf('* %s\n', out{i}.Name)
    end

end

end