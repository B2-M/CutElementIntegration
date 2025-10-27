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

function ref_integral = getReferenceIntegral3D(InterfaceId,f)
%
% Input:
%   InterfaceId:    ID of the interface
%   f:              integrand as symbolic function depending on x, y and z

syms x y z

if InterfaceId == 4 % cylinder (elliptic base)
    % This geometry allows an explicit representation because it is
    % oriented in z-direction and, therefore, has an explicit dependance of
    % x and y.
    interface = getInterfaceCase3D( InterfaceId );
    curve = sym(interface.implicit{1}.phi); % this is the curved boundary 
    % for this interface
    eqn = curve == 0;
    curve_explicit = solve(eqn,x); % explicit C(y)=x
    ref_integral = int(int(int(f,z,0,1),x,curve_explicit(1),0),y,-0.25,0.25) + ...
        int(int(int(f,z,0,1),x,0,curve_explicit(2)),y,-0.25,0.25);
else
    error(['There is no reference for an arbitrary integrand provided for this ' ...
        'example.'])
end

% convert symbolic function to double
ref_integral = double(ref_integral);

end % function