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

function updateExampleTestsResultsRef( integrator_name )

% example call:  updateExampleTestsResultsRef('Ginkgo')

% check input
if strcmp(integrator_name,'Algoim') || ...
        strcmp(integrator_name,'BoSSS') || ...        
        strcmp(integrator_name,'EduFEM') || ...
        strcmp(integrator_name,'Fcmlab') || ...
        strcmp(integrator_name,'Ginkgo') || ...
        strcmp(integrator_name,'Ngsxfem') || ...
        strcmp(integrator_name,'Nutils') || ...
        strcmp(integrator_name,'Quahog') || ...
        strcmp(integrator_name,'QuahogPE')|| ...
        strcmp(integrator_name,'Queso')
    % ok
else
    error("Integator %s not known!", integrator_name)
end


testsuite_names = {...
    'testExampleChanges_AreaComputation2D',...
    'testExampleChanges_AreaComputation3D',...
    'testExampleChanges_InterfaceComputation2D',...
    'testExampleChanges_InterfaceComputation3D',...
    'testExampleChanges_AreaFluxComputation2D',...
    'testExampleChanges_AreaFluxComputation3D',...
    'testExampleChanges_AreaComputationMoving2D',...
    };

for i = 1:length(testsuite_names)

    % get test suit and update integrators
    ts = eval(testsuite_names{i});
    ts.integrator_names = {integrator_name};
    ts.col_names = {}; % set to zero to supress file comparison in checkForChanges/compare_logfiles

    % get example unit tests of test suit
    m = methods(ts);
    ids_examples = find(contains(m, 'checkForChanges_'));    
    for j = 1:length(ids_examples)
        example_name = m{ids_examples(j)};
        names = feval(example_name,ts);

        % get current log file
        log_cur = convertStringsToChars(join(...
            [names.path names.file names.integrators{1} '.csv'],''));
        if isfile( log_cur )

            % define new reference file
            log_ref = replace(log_cur,'results','results_ref');

            % Check if results_ref folder exits
            path_ref = replace(names.path,'results','results_ref');
            if ~exist(path_ref, 'dir')
                mkdir(path_ref)
            else
                % extract time stamp of current result
                dateStrFormat = getDateStrFormat;
                date = names.file(end-length(dateStrFormat):end-1);

                % Delete old reference solutions 
                log_ref_old = replace(log_ref,date,'*');                
                log_ref_old = dir(log_ref_old);
                for k = 1 : length(log_ref_old)
                    delete([path_ref log_ref_old(k).name]);
                end
            end

            % Copy file to results_ref/
            log_ref = replace(log_cur,'results','results_ref');
            copyfile(log_cur, log_ref)
        else
            warning("Refernce solution %s does not exist",log_cur)
            continue
        end
    end
    

end