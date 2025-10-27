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

function write_quaddata_to_table(objQuadData, name_file, name_path )

% check input
if exist(name_path,'dir') ~= 7
    warning("write_quaddata_to_table: %s does not exist yet.", name_path)
    mkdir(name_path)
    warning("write_quaddata_to_table: %s has been added.", name_path)
end

space_dim = objQuadData.dim;
if space_dim == 2
    names_cols = {'elem','x','y','w'};
elseif space_dim == 3
    names_cols = {'elem','x','y','z','w'};
else
    error("Dimension %i is not supported",space_dim)
end


if ~isempty( objQuadData.trimmed_elem_pts )

    name_logfile = join([name_path name_file '_trimmed_elem_pts.csv'],'');
    quad_pts = local_accumulate_pts( ...
        objQuadData.trimmed_elem_pts, ...
        objQuadData.nb_trimmed_elems_pts, space_dim );
    T = array2table(quad_pts, 'VariableNames', names_cols);
    writetable(T,name_logfile)

end


if ~isempty( objQuadData.non_trimmed_elem_pts )

    name_logfile = join([name_path name_file '_non_trimmed_elem_pts.csv'],'');
    quad_pts = local_accumulate_pts( ...
        objQuadData.non_trimmed_elem_pts, ...
        objQuadData.nb_non_trimmed_elems_pts, space_dim );
    T = array2table(quad_pts, 'VariableNames', names_cols);
    writetable(T,name_logfile)

end


if ~isempty( objQuadData.interface_pts )

    name_logfile = join([name_path name_file '_interface_pts.csv'],'');
    quad_pts = local_accumulate_pts( ...
        objQuadData.interface_pts, ...
        objQuadData.nb_interfaces_pts, space_dim );
    T = array2table(quad_pts, 'VariableNames', names_cols);
    writetable(T,name_logfile)

end

end

function quad_pts = local_accumulate_pts( elem_quad_data, nb_elem_pts, space_dim )

    c = 1;
    quad_pts = zeros( space_dim + 2, nb_elem_pts );
    for i = 1 : length(elem_quad_data)
        cols = size( elem_quad_data(i).quad_data, 2 );
        quad_pts(1,c:c+cols-1) = i;
        quad_pts(2:end,c:c+cols-1) = elem_quad_data(i).quad_data(1:space_dim+1,:);
        c = c + cols;
    end 
    quad_pts = quad_pts';
end