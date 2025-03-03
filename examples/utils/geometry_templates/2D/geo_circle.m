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

function [circle,gradCircle,loops] = geo_circle(R, C)

    % implicit definition of the circle
    % % circle= @(x,y) sqrt((x-C(1)).^2 + (y-C(2)).^2) - R.^2;
    % % gradCircle = {...
    % %     @(x,y) (x-C(1)) ./ sqrt( (x-C(1)).^2 + (y-C(2)).^2), ...
    % %     @(x,y) (y-C(2)) ./ sqrt( (x-C(1)).^2 + (y-C(2)).^2)
    % %     };    
    circle= @(x,y) (x-C(1)).^2 + (y-C(2)).^2 - R.^2;
    gradCircle = { ...
        @(x,y) 2 * ( x - C(1) ), ...
        @(x,y) 2 * ( y - C(2) ) 
        };

    % parametric definition of the circle
    loop_0 = struct();
    loop_0(1).curve = nrbcirc(R, [C(1) C(2)]);  %Counter-clock wise -> outside normal -> get inside area
    loop_0(1).label = 5; % This is optional;
    loops = {loop_0};

end