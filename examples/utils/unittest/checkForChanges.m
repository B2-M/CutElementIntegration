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

function checkForChanges( testCase, names )
    
% This is the key function of the unit tests for comparing reference
% log-files (in the results_ref folder) with current ones (in the result folder)
%
% INPUTS:
% testCase: object of the matlab.unittest.TestCase
% names: output of the test example with contains e.g. the names of the log
% files
%
% EXAMPLE CALL: see e.g., testExampleChanges_AreaComputation2D, testExampleChanges_AreaComputation3D



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
for i = 1 : length(names.integrators)
    tail = [names.integrators{i} '.csv'];
    log_cur = convertStringsToChars(join([base_cur tail],''));
    file_ref = dir(convertStringsToChars(join([base_ref tail],'')));
    log_ref = convertStringsToChars(join([path_ref file_ref.name],''));
    if ~isfile( log_ref )
        warning("Reference solution %s does not exist",log_ref)
        if ~isempty(testCase.col_names) % option for updateExampleTestsResultsRef
            continue
        end
    end
    isIdentical(i) = compare_logfiles(log_cur, log_ref, testCase.col_names);
end

testCase.assertEqual( isIdentical, true(length(names.integrators),1) )

end 