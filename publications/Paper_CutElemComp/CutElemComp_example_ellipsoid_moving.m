%% Contributers: 
%    Florian Kummer, Technische Universität Darmstadt
%    Michael Loibl, University of the Bundeswehr Munich
%    Benjamin Marussig, Graz University of Technology  
%    Guilherme H. Teixeira, Graz University of Technology  
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

%% purpose
% robustness test 3D

close all
clear
clc

%% set up integrators
reparam_degree = 2;     % Degree of the reparametrisation of cut elements
problem_dimension = 3;  % Spatial dimension of the background mesh
SpaceTreeDepth = 3;

%% set up steps
% n_refs = 4;
% dsteps = linspace(0,0.125,5);
n_refs = 3;
dsteps = linspace(0,2*2.2/8,1000);
% dsteps = dsteps(1:3);

%% plot setting
plotting_settings = {'PlotError','off','PlotPoints','off','PlotInterface','off'};

%% run test case

% % integrators with linear boundary approximation
% if ispc
%     n_quad_pts = 1;         % Number of quadrature point per element in each direction
%     objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
%         'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth);
%     % objInt = selectIntegrator(objInt,["GridapIntegrator","NgsxfemIntegrator", ...
%     %     "NutilsIntegrator"])
%     % objInt = selectIntegrator(objInt,["GridapIntegrator","NgsxfemIntegrator"])
%     objInt = selectIntegrator(objInt,"GridapIntegrator")
%     [out_volume,out_objQuadData,names] = example_ellipsoid_moving(...
%         n_refs,dsteps,objInt,plotting_settings{:});
% end

% % remaining integrators
% n_quad_pts = 2;         % Number of quadrature point per element in each direction
% objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
%     'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth);
% % objInt = selectIntegrator(objInt,"FcmlabIntegrator")
% if ispc
%     % objInt = selectIntegrator(objInt,["BoSSSIntegrator","FcmlabIntegrator", ...
%     %     "MlhpIntegrator"])
%     objInt = selectIntegrator(objInt,["BoSSSIntegrator","MlhpIntegrator"])
% elseif isunix
%     objInt = selectIntegrator(objInt,"AlgoimIntegrator")
% end
% [out_volume,out_objQuadData,names] = example_ellipsoid_moving(...
%     n_refs,dsteps,objInt,plotting_settings{:});

% Nutils with different ndivisions setting
if ispc
    n_quad_pts = 1;         % Number of quadrature point per element in each direction
    ndivisions = 32;
    objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
        'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth, ...
        'ndivisions',ndivisions);
    objInt = selectIntegrator(objInt,"NutilsIntegrator")
    [out_volume,out_objQuadData,names] = example_ellipsoid_moving(...
        n_refs,dsteps,objInt,plotting_settings{:});
end