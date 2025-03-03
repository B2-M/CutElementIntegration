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

function [out_area,out_objQuadData,names] = example_circle_1_moving(...
    n_refs,dsteps,objInt,varargin)


%% set up integrators
if nargin < 3
    n_quad_pts = 3;         % Number of quadrature point per element in each direction
    reparam_degree = 3;     % Degree of the reparametrisation of cut elements
    problem_dimension = 2;  % Spatial dimension of the background mesh
    objInt = getAccessibleIntegrators(n_quad_pts, reparam_degree, problem_dimension );
    % objInt = {EduFEMIntegrator(n_quad_pts, reparam_degree)};
end


%% set up steps 
if nargin < 1
    n_refs= 3;
    n_points= 51;
    di=1e-2;
    dsteps = linspace(0,di*n_points,n_points+1);
end

%% plot setting
if isempty(varargin)
    varargin = {'PlotError','on','PlotPoints','on'};
end

%% run test case
testCaseId = 4;
[out_area,out_objQuadData,names] = runAreaComputation2D_moving(...
    objInt,testCaseId,n_refs,dsteps,varargin{:});