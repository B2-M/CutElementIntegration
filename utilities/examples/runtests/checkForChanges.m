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

function checkForChanges( testCase, names )
    
% This is the key function of the unit tests for comparing reference
% log-files (in the results_ref folder) with current ones (in the result folder)
%
% INPUTS:
% testCase: object of the matlab.unittest.TestCase
% names: output of the test example with contains e.g. the names of the log
% files
%
% EXAMPLE CALL: see e.g., testExampleChanges_AreaComputation2D, testExampleChanges_VolumeComputation3D

% check if testCase consists of several examples
if iscell(names)
    for i = 1 : length(names)
        checkForChanges( testCase, names{i} );
    end
else
    % extract time stamp of current result
    dateStrFormat = getDateStrFormat;
    date = names.file(end-length(dateStrFormat):end-1);
    % check date string format
    assert( isDateStrCorrect(date) )
    
    % get log files
    base_cur = [names.path names.file];
    file_ref_timeless = replace(names.file,date,'*');
    path_ref = replace(names.path,'results','results_ref');
    base_ref = [path_ref file_ref_timeless];
    
    % compare with reference
    isIdentical = false(length(names.integrators),1);
    if isempty(testCase.col_names) % option for updateExampleTestsResultsRef
        isIdentical(:) = true;
    else 
        for i = 1 : length(names.integrators)
            tail_cur = [names.integrators{i} '.csv'];
            tail_ref = [names.integrators{i} '*.csv']; 
            % Note: *.csv allows optional platform keywords ("Windows"/"Linux") in the reference
            % files, see check for platform-specific reference files below insider "otherwise"
            log_cur = convertStringsToChars(join([base_cur tail_cur],''));
            file_ref = dir(convertStringsToChars(join([base_ref tail_ref],'')));
            switch length(file_ref) 
                % expected case
                case 1
                    log_ref = convertStringsToChars(join([path_ref file_ref.name],''));
                    isIdentical(i) = compare_logfiles(log_cur, log_ref, testCase.col_names);
                % warnings for unexpected cases
                case 0
                    warning("Reference solution for %s does not exist",log_cur)
                otherwise
                    
                    % Check for platform-specific reference files
                    if length(file_ref) == 2
                        hasWindows = contains(file_ref(1).name, 'Windows') || contains(file_ref(2).name, 'Windows');
                        hasLinux = contains(file_ref(1).name, 'Linux') || contains(file_ref(2).name, 'Linux');

                        if hasWindows && hasLinux
                            % Determine current platform
                            if ispc
                                platformKeyword = 'Windows';
                            elseif isunix
                                platformKeyword = 'Linux';
                            else
                                platformKeyword = '';
                            end

                            % Select platform-specific reference file
                            if ~isempty(platformKeyword)
                                platformIdx = find(contains({file_ref.name}, platformKeyword), 1);
                                if ~isempty(platformIdx)
                                    log_ref = convertStringsToChars(join([path_ref file_ref(platformIdx).name],''));
                                    isIdentical(i) = compare_logfiles(log_cur, log_ref, testCase.col_names);
                                    continue;
                                end
                            end
                        end
                    end

                    % Default behavior: warn about multiple reference solutions
                    msg = 'There are more than one reference solutions!';
                    msg = sprintf('%s\n\tKeep only one of the following files: \n', msg);
                    for j = 1 : length(file_ref)
                        msg = sprintf('%s \t\t %s \n', msg, file_ref(j).name);
                    end
                    warning(msg);
            end
        end
    end
    testCase.assertEqual( isIdentical, true(length(names.integrators),1) )
end
end 