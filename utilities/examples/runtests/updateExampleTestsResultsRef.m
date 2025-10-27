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

function updateExampleTestsResultsRef( integrator_name, testsuite_name, testcase_name, ...
    bReplaceExistingResultsRef )

% example call:  
% updateExampleTestsResultsRef('Ginkgo','testExampleChanges_InterfaceComputation2D', ...
%     ["checkForChanges_example_triangle_1","checkForChanges_example_testsuite_unibw"],false)

% check input
if strcmp(integrator_name,'Algoim') || ...
        strcmp(integrator_name,'BoSSS') || ...        
        strcmp(integrator_name,'EduFEM') || ...
        strcmp(integrator_name,'Fcmlab') || ...
        strcmp(integrator_name,'Ginkgo') || ...
        strcmp(integrator_name,'Gridap') || ...
        strcmp(integrator_name,'Mlhp') || ...
        strcmp(integrator_name,'Ngsxfem') || ...
        strcmp(integrator_name,'Nutils') || ...
        strcmp(integrator_name,'Quahog') || ...
        strcmp(integrator_name,'QuahogPE')|| ...
        strcmp(integrator_name,'Queso')
    % ok
else
    error("Integator %s is not known!", integrator_name)
end

testsuite_names = getTestSuiteNames();
if nargin > 1
    match = contains(testsuite_names, testsuite_name);
    if any(match)
        % restrict testsuite_names to testsuite_name
        testsuite_names = {testsuite_name};
    else
        error("Testsuite %s is not known!", testsuite_name)
    end
end

if nargin > 2
    if isempty(testcase_name)
        testcase_name = 'all';
    end
else
    testcase_name = 'all';
end

if nargin < 4
    bReplaceExistingResultsRef = true;
end

for i = 1:length(testsuite_names)

    % get test suit and update integrators
    ts = eval(testsuite_names{i});
    ts.integrator_names = {integrator_name};
    ts.testType = 'convergenceStudy';
    ts.col_names = {}; % set to zero to suppress file comparison in checkForChanges/compare_logfiles

    % get example unit tests of test suit
    m = methods(ts);
    ids_examples = find(contains(m, 'checkForChanges_'));    
    for j = 1:length(ids_examples)
        example_name = m{ids_examples(j)};
        if strcmp(testcase_name,'all') || any(example_name==testcase_name)
            names = feval(example_name,ts);
            % check if testCase consists of several examples
            if iscell(names)
                for n = 1 : length(names)
                    local_updateResultsRef( names{n}, bReplaceExistingResultsRef, integrator_name );
                end
            else
                local_updateResultsRef( names, bReplaceExistingResultsRef, integrator_name )
            end
        end
    end   

end

end

function local_updateResultsRef(names,bReplaceExistingResultsRef,integrator_name)
    % get current log file
    log_cur = convertStringsToChars(join(...
        [names.path names.file names.integrators{1} '.csv'],''));
    if isfile( log_cur )

        % define new reference file
        log_ref = replace(log_cur,'results','results_ref');

        % Check if results_ref folder exits
        path_ref = replace(names.path,'results','results_ref');
        bResultsRefExists = false;
        if ~exist(path_ref, 'dir')
            mkdir(path_ref)
        else
            % extract time stamp of current result
            dateStrFormat = getDateStrFormat;
            date = names.file(end-length(dateStrFormat):end-1);

            % Delete old reference solutions 
            log_ref_old = replace(log_ref,date,'*');
            log_ref_old = [log_ref_old(1:(strfind(log_ref_old,integrator_name) ...
                +length(integrator_name)-1)),'*'];    % remove end which 
            % is stating the parameters such that also references with 
            % outdated parameters are deleted             
            log_ref_old = dir(log_ref_old);
            if ~isempty(log_ref_old)
                if bReplaceExistingResultsRef
                    for k = 1 : length(log_ref_old)
                        delete([path_ref log_ref_old(k).name]);
                    end
                else
                    bResultsRefExists = true;
                end
            end
        end

        % Copy file to results_ref/
        if bResultsRefExists == false
            log_ref = replace(log_cur,'results','results_ref');
            copyfile(log_cur, log_ref)
        end
    else
        warning("Reference solution %s does not exist",log_cur)
        % continue
    end
end