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

function [cyl,gradCyl,loops] = geo_cylinder(a,b,height)

    %% implicit definition of a torus with the semi-axis a and b 
    cyl = @(x,y,z) x.*x./(a*a) + y.*y./(b*b) - height;

    gradCyl = { ...
        @(x,y,z) 2.*x./(a*a), ...
        @(x,y,z) 2.*y./(b*b), ...
        @(x,y,z) zeros(size(z))
        };

    %% parametric definition of the cylinder
    radius = 1;
    circ = nrbcirc(radius);
    % 2: affine transformation to semi-axis
    transMat = diag([a,b,1,1]);    
    for jj = 1:size(circ.coefs,3)
        circ.coefs(:,:,jj) = transMat * circ.coefs(:,:,jj);
    end
    surf = nrbextrude(circ,[0.0 0.0 height]);
    loop_0 = struct();
    loop_0(1).surf = surf;
    loop_0(1).label = 1;
    loops = {loop_0};

end