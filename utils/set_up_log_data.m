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

function [error_log, names] = set_up_log_data( ...
    objIntegrators, n_rows, name_path, name_test, name_cols)


names.path = name_path;
if exist(names.path,'dir') ~= 7
    warning("set_up_log_data: Path %s does not exist yet.", names.path)
    mkdir(names.path)
    warning("set_up_log_data: Path %s has been added.", names.path)
end

dt = datestr(now,getDateStrFormat); %#ok<TNOW1,DATST> 
names.file = [name_test '_' dt '_'];

if nargin < 5
    names.cols = {'relError','absError','h','nbQuadptsTrimmedElems',...
        'nbQuadptsNonTrimmedElems','IntegrationTime_sec_'};
else
    names.cols = name_cols;
end

error_log( length(objIntegrators) ) = struct();
names.integrators = cell( length(objIntegrators), 1);
n_cols = length(names.cols);
for i = 1 : length(objIntegrators)
    error_log( i ).data = zeros(n_rows,n_cols);
    names.integrators{i} = join([objIntegrators{i}.Name '-' objIntegrators{i}.PropertyString],'');
end

end