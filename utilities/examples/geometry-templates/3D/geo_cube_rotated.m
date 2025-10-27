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

function [implCell,loops] = geo_cube_rotated(sLength, rotxyz)

    corners = [ ...
        0.0 sLength 0.0    sLength   0.0   sLength   0.0   sLength; ...
        0.0   0.0  sLength sLength   0.0   0.0   sLength   sLength; ... 
        0.0   0.0   0.0     0.0   sLength   sLength   sLength   sLength; ...  
        1.0   1.0   1.0     1.0   1.0   1.0   1.0  1.0 ...      
        ];

    % rotate nodes
    rx = vecrotx(rotxyz(1));
    ry = vecroty(rotxyz(2));
    rz = vecrotz(rotxyz(3)); 
    corners = rx * ry * rz * corners;

    % move center coordinate to axis origin
    cc = 0.5 .* (corners(1:3,1) + corners(1:3,8)); 
    dd = vectrans(-cc);
    corners = dd * corners;

    pts = corners(1:3,:);
    ip = [1 3 2; 1 2 5; 1 5 3; 8 7 6; 8 6 4; 8 4 7];
    
    n_sides = 6;
    loop_0 = struct();
    implCell = cell(1,n_sides);
    % hold off
    for i = 1 : n_sides
        [plane,gradPlane,iloops] = geo_plane(pts(:,ip(i,1)),pts(:,ip(i,2)),pts(:,ip(i,3)));
        implCell{i} = LevelSetFunctionAndGradient(plane,gradPlane);
        loop_0(i).surf = iloops{1}(1).surf; 
        loop_0(i).label = i;
        % plot_domain(iloops{1},[40 40],'FaceAlpha',0.2)
        % hold on
    end
    loops = {loop_0};

end