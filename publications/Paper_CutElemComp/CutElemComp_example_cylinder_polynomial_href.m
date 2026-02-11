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


% elliptic cylinder

clear
clc
close all

% set number of refinements 
n_refs_min = 0;
n_refs_max = 5;
% n_refs_max = 1;

% set up integrators
reparam_degree = 2;     % Degree of the reparametrisation of cut elements; cylinder 
% is a quadratic NURBS
SpaceTreeDepth = 3;
problem_dimension = 3;  % Spatial dimension of the background mesh

%% get test case
testCaseId = 3;
objTest = getTestCase3D(testCaseId);

%% define integrand
% bounding_box: [x1,x2;y1,y2;z1,z2]
% shift and scale monomial to a [0,1]x[0,1]x[0,1] domain
% homogenous coordinates (x = x_hom/w)
CP = objTest.interface.parametric{1}.surf.coefs(1:3,:)./objTest.interface.parametric{1}.surf.coefs(4,:);
x1 = min(CP(1,:)); x2 = max(CP(1,:));
y1 = min(CP(2,:)); y2 = max(CP(2,:));
z1 = min(CP(3,:)); z2 = max(CP(3,:));
syms x y z
x_shift = -x1; x_scale = 1/(x2-x1);
y_shift = -y1; y_scale = 1/(y2-y1);
z_shift = -z1; z_scale = 1/(z2-z1);
p = 5;
integrand(x,y,z) = ((x+x_shift)*x_scale)^p*((y+y_shift)*y_scale)^p* ...
    ((z+z_shift)*z_scale)^p;

%% define n_QP
n_quad_pts = ceil((p+1)/2);

%% run actual example
names_cols = {'n_ele','nQP','relError','nbQuadptsTrimmedElems','nbQuadptsNonTrimmedElems', ...
    'IntegrationTime_sec_'};

add_settings = {'PlotError','off','PlotPoints','off','integrand',integrand};
objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
    'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth);
objInt = selectIntegrator(objInt,"QuesoIntegrator")
[out_vol,out_objQuadData,names] = example_cylinder_polynomial(...
    n_refs_min,n_refs_max,objInt,add_settings{:});