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

function plot_error_h_refinement( error_type, file_name, file_path, pts_name )

if ~strcmp( error_type, 'relError' )  && ~strcmp( error_type, 'absError' )
    error("Error type %s is not supported. Please choose 'relError' or 'absError'. ", error_type)
end

if nargin == 2
    % search for file path if not provided
    if isCurrentFolderCorrect
        file_path = findfile('./examples',file_name);
        if isempty(file_path)
            error("Path of file %s was not found. Please add it to a subfolder within '.examples'.",file_name)
        end
    end
end

% load error log table
T = readtable([file_path '/' file_name]);

% plot error graph
x = T{:,local_get_col(T,'h')};
y = T{:,local_get_col(T,error_type)};
y(all([y<eps;y>0])) = eps;
loglog(x,y,'x-')
grid on
ylabel(error_type)
xlabel('h')

% add number of quad points in trimmed elements
if nargin < 4
    pts_name = 'nbQuadptsTrimmedElems';
else
    pts_name = replace(pts_name,' ',''); % rm white spaces
end
nb = T{:,local_get_col(T,pts_name)};
if sum(nb)==0   % write a ? instead of 0 if number of QP is not known
    nb = repmat('?',length(nb),1);
else
    nb = num2str(nb);
end
text( x, y, nb, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right')

% extract test and integrator data from file name
name_split = strsplit(file_name,'_');
title([name_split{1:end-1}])
hLegend = findobj(gcf, 'Type', 'Legend');
if isempty(hLegend)
    hLegend = legend('Location','southeast');
else
    hLegend.Location = 'southeast';
end
if all(y==0)
    hLegend.String{end} = [name_split{end}(1:end-4),',err=0'];
elseif all(isnan(y(:)))
    hLegend.String{end} = [name_split{end}(1:end-4),'(FAILED)'];
elseif all(y==-1)
    hLegend.String{end} = [name_split{end}(1:end-4),'(NotAvailable)'];
else
    hLegend.String{end} = name_split{end}(1:end-4);
end

end

function col = local_get_col(T,col_name)

col = strcmpi(T.Properties.VariableNames,col_name);
if ~any(col==1)
    error('Table has no columne names %s.',col_name)
end

end