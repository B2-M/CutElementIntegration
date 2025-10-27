%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, University of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guliherme H. Teixeira, Graz University of Technology  
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

function ref_integral = getReferenceIntegral2D(InterfaceId,f)
%
% Input:
%   InterfaceId:    ID of the interface
%   f:              integrand as symbolic function depending on x and y

syms x y

if InterfaceId == 10 % UniBw Munich test case 3
    interface = getInterfaceCase2D( InterfaceId );
    curve = sym(interface.implicit{4}.phi); % this is the curved boundary 
    % for this interface
    eqn = curve == 0;
    curve_explicit = solve(eqn,x); % explicit C(y)=x
    ref_integral = int(int(f,x,curve_explicit,1),y,0,1);
elseif InterfaceId == 11 % UniBw Munich test case 4
    interface = getInterfaceCase2D( InterfaceId );
    curve = sym(interface.implicit{4}.phi); % this is the curved boundary 
    % for this interface
    eqn = curve == 0;
    curve_explicit = solve(eqn,x); % explicit C(y)=x
    ref_integral = int(int(f,x,0,curve_explicit),y,0,1);
elseif InterfaceId == 17 % UniBw Munich test case 10
    % piecewise boundary --> functions are explicitly repeated herein
    % because it is not possible to obtain them from the interface
    x_PI = [0.3,0.808072880326076]; % Point of Intersections: first=curve to 
    % curve, second = 2nd curve to edge
    curve(x,y) = -0.4*x^2+1.2*x-y+0.4;
    eqn = curve == 0;
    curve_explicit_1 = solve(eqn,y); % explicit C(x)=y
    curve(x,y) = 0.4*x^2+0.1*x-y+329/500;
    eqn = curve == 0;
    curve_explicit_2 = solve(eqn,y); % explicit C(x)=y
    ref_integral = int(int(f,y,curve_explicit_1,1),x,0,x_PI(1)) + ...
        int(int(f,y,curve_explicit_2,1),x,x_PI(1),x_PI(2));
elseif InterfaceId == 22 % UniBw Munich test case 16
    interface = getInterfaceCase2D( InterfaceId );
    curve = sym(interface.implicit{5}.phi); % this is the curved boundary 
    % for this interface
    eqn = curve == 0;
    curve_explicit = solve(eqn,y); % explicit C(x)=y
    x_PI = 0.750417596651957; % Point of Intersections
    ref_integral = int(int(f,y,curve_explicit,1),x,0,x_PI) + ...
        int(int(f,y,0,1),x,x_PI,1);
else
    error(['There is no reference for an arbitrary integrand provided for this ' ...
        'example. Currently, references are only availabe for InterfaceId 11, ' ...
        '17 and 22 in 2D.'])
end

% convert symbolic function to double
ref_integral = double(ref_integral);

end % function