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

function plot_level_set(implCell,gridsteps,contourlevels)
%
% The function loops over a cell of LevelSetFunction- or 
% LevelSetFunctionAndGradient- objects to plot a 3D domain.
%
% examples:
% see getInterfaceCase2D.m and getInterfaceCase3D.m

if nargin < 2
    gridsteps = -1.1:0.1:1.1;
end

if nargin < 3
    contourlevels = [0,-0.1];
end

if implCell{1}.dim == 2

    [X,Y]=meshgrid(gridsteps);
    for i=1:length(implCell)
        z=implCell{i}.phi(X,Y);
        contour(X,Y,z,contourlevels)
        alpha(0.3)
        hold on
    end

elseif implCell{1}.dim == 3

    [X,Y,Z]=meshgrid(gridsteps);
    hold on
    for i=1:length(implCell)
        D=implCell{i}.phi(X,Y,Z);
        arrayfun(@(LEVEL) isosurface(X, Y, Z, D, LEVEL), contourlevels);
        alpha(0.3)
    end

else
    warning("Dimension %i is not supported.", implCell{1}.dim)
end


end