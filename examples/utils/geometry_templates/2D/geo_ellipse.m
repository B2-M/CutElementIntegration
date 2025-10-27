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

function [ellipse,gradEllipse,loops] = geo_ellipse(a,b,C,angle)

    %% implicit definition of the ellipse with the semi-axis a and b
    % This implementation causes an error in passing level-set to BoSSS
    % integrator
    % ellipse = @(x,y) x.*x./(a*a) + y.*y./(b*b) - 1.0;
    % ellipse = @(x,y) subs(ellipse,struct('x',-sin(angle)*x+cos(angle)*y,'y',cos(angle)*x+sin(angle)*y));
    % ellipse = @(x,y) subs(ellipse,struct('x',x-C(1),'y',y-C(2)));
    ellipse2 = @(x,y) x.*x./(a*a) + y.*y./(b*b) - 1.0;
    ellipse1 = @(x,y) ellipse2(-sin(angle)*x+cos(angle)*y,cos(angle)*x+sin(angle)*y);
    ellipse = @(x,y) ellipse1(x-C(1),y-C(2));

    syms x y
    dfdx = diff(ellipse,x);
    dfdy = diff(ellipse,y);
    gradEllipse = { ...
        @(x,y) dfdx, ...
        @(x,y) dfdy
        };

    %% parametric definition of the ellipse
    
    % 1: set up circle parametrization
    tiling = nrbcirc();
    % 2: affine transformation to semi-axis
    scaleMat = diag([a,b,1,1]);
    transMat = [1,0,0,C(1);0,1,0,C(2);0,0,1,0;0,0,0,1];
    rotMat = [cos(angle),sin(angle),0,0;-sin(angle),cos(angle),0,0;0,0,1,0;0,0,0,1];
    affineMat = transMat * rotMat * scaleMat;
    for jj = 1:size(tiling.coefs,2)
        tiling.coefs(:,jj) = affineMat * tiling.coefs(:,jj);
    end
    % store loop
    loops = struct('curve',tiling,'label',1);
    loops = {loops};

end