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

function updateExampleTestsResultsRefByExistingFile( integrator_name, ...
    testfolder_name, testcase_name, source_folder )

% example call:  
% updateExampleTestsResultsRefByExistingFile('Algoim','AreaComputation2D', ...
% ["example_multiple_connected_curves","example_punched_plate"],'results_ser')

% check input
if ismember(integrator_name, getAllIntegratorNames())
    % ok
else
    error("Integator %s is not known!", integrator_name)
end

[testfolder_names,folder_path] = getTestFolderNames();
if nargin > 1
    match = contains(testfolder_names, testfolder_name);
    if any(match)
        % restrict testsuite_names to testsuite_name
        testfolder_names = {testfolder_name};
    else
        error("Testsuite %s is not known!", testfolder_name)
    end
end

if nargin > 2
    if isempty(testcase_name)
        testcase_name = 'all';
    end
else
    testcase_name = 'all';
end

bTakeAllExamples = false;
if ischar(testcase_name) && strcmp(testcase_name,'all') 
    bTakeAllExamples = true;
end

if nargin < 4
    source_folder = 'results';
end

for i = 1:length(testfolder_names)

    path_ref = fullfile(folder_path, testfolder_names{i}, 'results_ref');
    path_source = fullfile(folder_path, testfolder_names{i}, source_folder);
    if ~isfolder(path_ref) 
         error("Reference folder %s does not exist!", path_ref);
    end
    if ~isfolder(path_source) 
         error("Reference folder %s does not exist!", path_source);
    end

    testsuite_details = queryExampleDetails('Category', testfolder_names{i});       
    for j = 1:size(testsuite_details,1)
      example_name = testsuite_details(j,:).ExampleFile{:};
      example_name = example_name(1:end-2); % remove file ending .m
      if bTakeAllExamples || any(example_name==testcase_name)

          % get original file and potential source files
          TC = testsuite_details(j,:).TestCaseId;
          filepattern = ['*_tC_' num2str(TC) '_*' integrator_name '*'];
          log_ref = dir(fullfile(path_ref,filepattern));
          log_source = dir(fullfile(path_source,filepattern));   

          % match the source file that shall replace the original one
          match = local_find_matching_file(log_ref,log_source);

          % replace original file
          % fullfile(path_ref,log_ref.name)
          % fullfile(path_source,match)
          delete(fullfile(path_ref,log_ref.name));
          copyfile(fullfile(path_source,match), fullfile(path_ref,match))

      end
    end

end

end


function match = local_find_matching_file(log_ref,log_source)
  
  % check assumtion: only a single reference file shall be replaced
  assert(length(log_ref)==1)
  name_ref_timeless = local_get_timeless_name(log_ref.name);

  match = [];
  if length(log_source) == 1
      name_timeless = local_get_timeless_name(log_source.name);
      if strcmp(name_timeless,name_ref_timeless)
          match = log_source.name;
      end
  else
      for k = 1:length(log_source)
        name_timeless = local_get_timeless_name(log_source(k).name);
        if strcmp(name_timeless,name_ref_timeless)
            if isempty(match)
                match = log_source(k).name;
            else
                dipsl("Reference: %s \n",name_ref_timeless )
                dipsl("1. match: %s \n",match )
                dipsl("2. match: %s \n",log_source(k).name )                        
                error("Ambiguous replacement: Multiple files matche!")
            end
        end
      end
  end

  if isempty(match)
      error('No match to %s found.\n',name_ref_timeless)
  end

end

function name_timeless = local_get_timeless_name(name)
    namesplits = strfind(name,'_');
    name_timeless = [name(1:namesplits(2)) '*' name(namesplits(4):end)];
end