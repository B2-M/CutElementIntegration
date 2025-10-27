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

function plot_error_testsuite(names,name_testsuite)

% get general test case data
folder_path = names{1}.path;
names_legend = names{1}.integrators;
n_integrators = length(names_legend);
n_cases = length(names);

% extract relativ error from log files
out_err_rel = zeros(n_cases,n_integrators);
for iTC = 1:n_cases  
    for iIntegrator = 1:n_integrators
        file = strcat(names{iTC}.file, names{iTC}.integrators{iIntegrator});
        out = getDataFromFile(folder_path,file,'relError');
        err_rel = out{1};
        if err_rel < eps
            err_rel = eps;
        end
        out_err_rel(iTC,iIntegrator) = err_rel;
    end
end

% plot error
figure()
err_rel = out_err_rel;
for i = 1:n_integrators
    semilogy(err_rel(:,i),'x-')
    hold on
    if all(isnan(err_rel(:,i)))
        names_legend{i} = strcat(names_legend{i},',all failed');
    elseif any(isnan(err_rel(:,i)))
        names_legend{i} = strcat(names_legend{i},',some failed');
    end
end
grid on
legend(names_legend)
dt = datestr(now,getDateStrFormat); %#ok<TNOW1,DATST> 
base_name = local_extract_base_name( names{1}.file );
figname = [folder_path base_name name_testsuite '_' dt '_error.fig' ];
savefig(figname)

end


function example_folder = local_extract_base_name( file_name )

% Define the delimiter
delimiter = '_tC_';

% Find the position of the delimiter
idx = strfind(file_name, delimiter);

% Extract substring if delimiter is found
if ~isempty(idx)
    example_folder = file_name(1:idx(1));
else
    assert(false)
end

end