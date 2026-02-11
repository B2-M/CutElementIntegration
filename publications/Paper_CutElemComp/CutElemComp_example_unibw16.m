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
% n_refs_max = 5;
n_refs_max = 0;

% set up integrators
reparam_degree = 5;     % Degree of the reparametrisation of cut elements
SpaceTreeDepth = 3;
problem_dimension = 2;  % Spatial dimension of the background mesh

%% define integrand
syms x y
syms integrand(x,y)
integrand(x,y) = 1+x*0;

%% additional settings (plot and integrand)
add_settings = {'PlotError','off','PlotPoints','off','integrand',integrand};

%% run test case
% n_quad_pts = 1:2;         % Number of quadrature point per element in each direction
n_quad_pts = 1:4;         % Number of quadrature point per element in each direction
n = length(n_quad_pts);
out_area = cell(n,1);
out_objQuadData = cell(n,1);
names = cell(n,1);
for i = 1:n
    objInt = getAccessibleIntegrators(n_quad_pts(i),problem_dimension, ...
        'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth, ...
        'n_quad_pts_green',n_quad_pts(i));
%    objInt = selectIntegrator(objInt,"MlhpIntegrator")
    [out_area{i},out_objQuadData{i},names{i}] = example_unibw16(...
        n_refs_min,n_refs_max,objInt,add_settings{:});

    % store results for publication in variable
    for iInt = 1:length(objInt)
        file = strcat(names{i}.file, names{i}.integrators{iInt});
        results(iInt,i,1) = i;
        out = getDataFromFile(names{i}.path,file,'relError');
        results(iInt,i,2) = out{1}(1);  % take only first refinement
        out = getDataFromFile(names{i}.path,file,'nbQuadptsTrimmedElems');
        results(iInt,i,3) = out{1}(1);  % take only first refinement
    end
end

% save results for publication
dt = datestr(now,getDateStrFormat); %#ok<TNOW1,DATST>
name_logfile = [names{1}.path 'example_unibw16_nQP_' dt '_'];
names_cols = {'nQP','relError','nbQuadptsTrimmedElems'};
for iInt = 1:length(objInt)
    name_logfile_i = join([name_logfile names{1}.integrators{iInt} '.csv'],'');
    T = array2table(squeeze(results(iInt,:,:)), 'VariableNames', names_cols);
    writetable(T,name_logfile_i)
end

% % store names
% CIbenchenv4libs_example_circle_1_names = names;
% save('examples/AreaComputation2D/results/CIbenchenv4libs_example_circle_1_names.mat', ...
%     'CIbenchenv4libs_example_circle_1_names');