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

function interface = getInterfaceCase3D( InterfaceId )

if InterfaceId == 1

    % ellipsoid with semi axis
    a=1;
    b=1/2;
    c=1/3;    
    [phi,gradPhi,loops] = geo_ellipsoid(a, b, c);
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};
    sizeInterface = 4.400809564664971;
    sizeInsideDomain =  pi()*a*b*c*4/3;

elseif InterfaceId == 2

    % sphere with radius 1.2
    r=1.2;
    a=r;
    b=r;
    c=r;    
    [phi,gradPhi,loops] = geo_ellipsoid(a, b, c);
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};
    sizeInterface = pi()*4*r*r;
    sizeInsideDomain =  pi()*a*b*c*4/3;

elseif InterfaceId == 3

    % torus
    rTorus = 1;
    rTube = 0.2;
    [phi,gradPhi,loops] = geo_torus(rTorus, rTube);
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};
    sizeInterface = pi()^2*4*rTorus*rTube;
    sizeInsideDomain =  pi()^2*2*rTorus*rTube^2;

elseif InterfaceId == 4

    % elliptic cylinder
    a=0.5;
    b=0.25;
    h=1.0;
    [phi,gradPhi,loops] = geo_cylinder(a, b, h);
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};

    f=@(t) sqrt(a*a*sin(t).^2+b*b*cos(t).^2);
    lQuater = integral(f,0,pi()/2);
    sizeInterface =4*lQuater;
    sizeInsideDomain = pi()*a*b*h;

elseif InterfaceId == 5

    % rotated cube
    a=0.5;
    [implCell,loops] = geo_cube_rotated(a,[pi()/2,pi()/3,pi()/4]);
    sizeInterface = 6*a*a;
    sizeInsideDomain = a*a*a;    

else

    error("getInterfaceCase3D Interface case %i not known!", InterfaceId )

end

% define output
interface = Interface( implCell, loops, sizeInterface, sizeInsideDomain, InterfaceId);

%% plot situation
% % plot 
% plot_level_set( implCell, -2:0.1:2, [0,-0.02] );
% hold on
% for i = 1:length(loops)
%     plot_domain(loops{i},[40 40],'FaceAlpha',0.2)
% end

end
