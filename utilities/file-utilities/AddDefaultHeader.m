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

%% example call:
% AddDefaultHeader('utils')

function AddDefaultHeader(folderRelativePath)

% Define the folder path
folderPath = fullfile(pwd,folderRelativePath);
fileExtension = '*.m'; % Change this to match the type of files you want to process
headerFilePath = '.\utils\doc\defaultHeader.txt'; % Path to the header file

% Read header text from file
fid = fopen(headerFilePath, 'r');
if fid == -1
    error('Could not open header file: %s', headerFilePath);
end
headerText = fread(fid, '*char')';
fclose(fid);

% Get a list of all files in the folder
files = dir(fullfile(folderPath, fileExtension));

% Loop through each file and add the header
for i = 1:length(files)
    filePath = fullfile(folderPath, files(i).name);
    
    % Read the existing content of the file
    fid = fopen(filePath, 'r');
    if fid == -1
        warning('Could not open file: %s', filePath);
        continue;
    end
    fileContent = fread(fid, '*char')';
    fclose(fid);    
    
    % Check if the header is already present
    if startsWith(fileContent, '%% Contributers:')
        fprintf('Header already present in: %s\n', files(i).name);
        continue;
    end
    
    % Write the new content with the header
    fid = fopen(filePath, 'w');
    if fid == -1
        warning('Could not write to file: %s', filePath);
        continue;
    end
    fprintf(fid, '%s%s', headerText, fileContent);
    fclose(fid);
    
    fprintf('Header added to: %s\n', files(i).name);
end

fprintf('Header insertion completed.\n');



end