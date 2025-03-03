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

function FigH = plot_quad_pts( objQuadData, pts_type, varargin )

if nargin < 3
    varargin{1} = "o";
end

% collect quadrature points
space_dim = objQuadData.dim;
if strcmpi(pts_type,'trimmed')

    quad_pts = local_accumulate_pts( ...
        objQuadData.trimmed_elem_pts, ...
        objQuadData.nb_trimmed_elems_pts, space_dim );

elseif strcmpi(pts_type,'non_trimmed')

    quad_pts = local_accumulate_pts( ...
        objQuadData.non_trimmed_elem_pts, ...
        objQuadData.nb_non_trimmed_elems_pts, space_dim );

elseif strcmpi(pts_type,'interface')

    quad_pts = local_accumulate_pts( ...
        objQuadData.interface_pts, ...
        objQuadData.nb_interfaces_pts, space_dim );    

elseif strcmpi(pts_type,'all')

    % recursive call of this function
    plot_quad_pts( objQuadData, 'trimmed', varargin{:} ); hold on
    PtsH = plot_quad_pts( objQuadData, 'non_trimmed', varargin{:} ); hold off
    FigH = ancestor(PtsH, 'figure');
    return
    
else    
    error("plot2D_quad_pts pts_type %s is not known.", pts_type)
end

% plot
if space_dim == 2
    PtsH = scatter( quad_pts(1,:), quad_pts(2,:), varargin{:} );
elseif space_dim == 3
    PtsH = scatter3( quad_pts(1,:), quad_pts(2,:), quad_pts(3,:), varargin{:} );
else
    error("Plot for %i dimensions is not supported.",space_dim)
end
FigH = ancestor(PtsH, 'figure');

end


function quad_pts = local_accumulate_pts( elem_quad_data, nb_elem_pts, space_dim )

    c = 1;
    quad_pts = zeros( space_dim, nb_elem_pts );
    for i = 1 : length(elem_quad_data)
        cols = size( elem_quad_data(i).quad_data, 2 );
        quad_pts(:,c:c+cols-1) = elem_quad_data(i).quad_data(1:space_dim,:);
        c = c + cols;
    end 

end