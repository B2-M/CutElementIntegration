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

function plot_error_h_refinement_ref_results( testFolderName, testCaseId)
% compares the results of all reference solutions of a specific test
% example

%% example call:
% plot_error_h_refinement_ref_results('AreaComputation2D',1)

% check input
tests = { ...
    'AreaComputation2D',...
    'AreaComputation3D',...
    'InterfaceComputation2D',...
    'InterfaceComputation3D',...
    'AreaFluxComputation2D',...
    'AreaFluxComputation3D',...
    'AreaComputationMoving2D'...
    };
if ~any(strcmp(tests,'AreaComputation2D'))
    error("testFolderName %s is not known!", testFolder);
end

% get all reference solutions of the test case 
file_path = ['./examples/' testFolderName '/results_ref/'];
file_name_timeless = ['run' testFolderName '_tC_' num2str(testCaseId) '_'];
files_in_folder = dir(file_path);
index = find(contains({files_in_folder.name}, file_name_timeless));

% plot convergence curves
error_type = 'relError';
for i = 1 : length(index)
    plot_error_h_refinement( error_type, files_in_folder(index(i)).name, file_path )
    hold on
end
legend('Location','eastoutside')

end