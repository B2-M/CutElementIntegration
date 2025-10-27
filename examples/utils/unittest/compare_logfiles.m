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

function isIdentical = compare_logfiles(A_log,B_log,col_names)

isIdentical = true;
if isempty(col_names)
    warning('nothing to compares')
    return
end

A = local_get_logfile(A_log);
B = local_get_logfile(B_log);
if isempty(A) || isempty(B)
    isIdentical = false;       
else
    for j = 1 : length(col_names)
        A_j = A{:,local_get_col(A,col_names(j))};
        B_j = B{:,local_get_col(B,col_names(j))};  
        ni = length(A_j);
        if length(A_j) ~= length(B_j)
            % warning('The number of rows in %s of %s and %s differ.',col_names{j},A_log,B_log)
            % note: this option allows the comparison of unit tests (only a
            % few refinement steps) with reference solutions of convergence
            % studies (using several refinement steps).
            % It is assumed that both start with the same coarse mesh.
            ni = min(length(A_j),length(B_j));
        end        
        if norm(A_j(1:ni) - B_j(1:ni)) > 1.0e-12
	        warning('The colume %s of %s and %s differ.',col_names{j},A_log,B_log)
            isIdentical = false;
        end
    end
end


end


function T = local_get_logfile(name)
T = [];
try
    T = readtable(name);
catch catched_error
    warning('Did not find file %s',name)
    fprintf(1,'There was an error! The message was:\n%s\n',catched_error.message);
end
end

function col = local_get_col(T,col_name)

col = strcmpi(T.Properties.VariableNames,col_name);
if ~any(col==1)
    error('Table has no columne name: %s',col_name{:})
end

end