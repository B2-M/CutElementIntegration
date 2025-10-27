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

function [ellipsoid,gradEllipsoid,loops] = geo_ellipsoid(a, b, c)

    %% implicit definition of the ellipsoid with the semi-axis a, b, and c
    ellipsoid = @(x,y,z) x.*x./(a*a) + y.*y./(b*b) + z.*z./(c*c) - 1.0;

    gradEllipsoid = { ...
        @(x,y,z) 2.*x./(a*a), ...
        @(x,y,z) 2.*y./(b*b), ...
        @(x,y,z) 2.*z./(c*c), ...
        };

    %% parametric definition of the ellipsoid
    
    % 1: set up volleyball sphere parametrization
    tiling = nrbspheretiling('cube');
    % 2: affine transformation to semi-axis
    transMat = diag([a,b,c,1]);    
    for ii = 1:length(tiling)
        for jj = 1:size(tiling(ii).coefs,3)
            tiling(ii).coefs(:,:,jj) = transMat * tiling(ii).coefs(:,:,jj);
        end
    end
    % store loop
    loop_0 = struct();
    for ii = 1:length(tiling)
        loop_0(ii).surf = tiling(ii);
        loop_0(ii).label = ii;
    end
    loops = {loop_0};

end