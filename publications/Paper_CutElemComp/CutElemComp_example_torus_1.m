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

clear
clc
close all

% set number of refinements 
n_refs_min = 0;
n_refs_max = 5;
% n_refs_max = 1;

% set up integrators
reparam_degree = 2;     % Degree of the reparametrisation of cut elements; torus 
% is a quadratic NURBS
SpaceTreeDepth = 3;
problem_dimension = 3;  % Spatial dimension of the background mesh

%% additional settings (plot and integrand)
add_settings = {'PlotError','off','PlotPoints','off'};

%% run actual example
n_quad_pts_mem = [];

% all Integrators with linear boundary approximation
n_quad_pts = 1;
objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
    'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth)
objInt = selectIntegrator(objInt,["GridapIntegrator","NutilsIntegrator", ...
    "QuesoIntegrator"])
[out_vol{1},out_objQuadData{1},names{1}] = example_torus_1(...
    n_refs_min,n_refs_max,objInt,add_settings{:});
n_quad_pts_mem = [n_quad_pts_mem; ones(length(objInt),1)*n_quad_pts];

% all Integrators with pure octree
n_quad_pts = 2;
objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
    'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth)
objInt = selectIntegrator(objInt,["FcmlabIntegrator","MlhpIntegrator"])
[out_vol{2},out_objQuadData{2},names{2}] = example_torus_1(...
    n_refs_min,n_refs_max,objInt,add_settings{:});
n_quad_pts_mem = [n_quad_pts_mem; ones(length(objInt),1)*n_quad_pts];

% all Integrators with higher-order boundary approximation
n_quad_pts = ceil((reparam_degree+1)/2);
objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
    'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth)
if ispc
    objInt = selectIntegrator(objInt,"BoSSSIntegrator","NgsxfemIntegrator")
elseif isunix
    objInt = selectIntegrator(objInt,["AlgoimIntegrator","BoSSSIntegrator"])
end
[out_vol{3},out_objQuadData{3},names{3}] = example_torus_1(...
    n_refs_min,n_refs_max,objInt,add_settings{:});
n_quad_pts_mem = [n_quad_pts_mem; ones(length(objInt),1)*n_quad_pts];

%% Store results separately
% save results for publication
dt = datestr(now,getDateStrFormat); %#ok<TNOW1,DATST>
name_logfile = [names{1}.path 'example_torus_1_' dt '_'];
names_cols = {'n_ele','nQP','relError','nbQuadptsTrimmedElems','nbQuadptsNonTrimmedElems', ...
    'IntegrationTime_sec_'};
count = 0;
for i = 1:length(names)
    for iInt = 1:length(names{i}.integrators)
        count = count + 1;
        file = strcat(names{i}.file, names{i}.integrators{iInt});
        results(count,:,1) = 2.^(n_refs_min:n_refs_max);
        results(count,:,2) = ones(n_refs_max+1,1)*n_quad_pts_mem(count);
        out = getDataFromFile(names{i}.path,file,'relError');
        results(count,:,3) = out{:};
        out = getDataFromFile(names{i}.path,file,'nbQuadptsTrimmedElems');
        results(count,:,4) = out{:};
        out = getDataFromFile(names{i}.path,file,'nbQuadptsNonTrimmedElems');
        results(iInt,:,5) = out{:};
        out = getDataFromFile(names{i}.path,file,'IntegrationTime_sec_');
        results(iInt,:,6) = out{:};

        name_logfile_iInt = join([name_logfile names{i}.integrators{iInt} '.csv'],'');
        T = array2table(squeeze(results(count,:,:)), 'VariableNames', names_cols);
        writetable(T,name_logfile_iInt)
    end
end