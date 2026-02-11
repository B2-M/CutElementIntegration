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

%% set up integrators
problem_dimension = 2;
SpaceTreeDepth = 3;
reparam_degree = [1,2,3,4,5,2,2,2,3,4,5,5,5,3,2,4,5,2,2,3,3,4,5,5,2,2]; % Degree 
% of the reparametrisation of cut elements; curve degrees
n_quad_pts = ceil((reparam_degree+1)/2);    % Number of quadrature point per element 
% in each direction; identical with reparam_degree such that it
% integrates a constant integrand correctly according to Antolin et al.
% (2022)
n_quad_pts_green = n_quad_pts;

%% set number of refinements
n_refs_min = 0;
n_refs_max = 0;
% n_refs_min = 3;
% n_refs_max = 3;

%% plot setting
plot_settings = {'PlotError','off','PlotPoints','off'};

%% run test cases
objInt = cell(26,1);
% The following values are chosen for $\numQuadPointsSetting$: 
% $\numQuadPointsSetting=2$ for FCMLab and mlhp
% $\numQuadPointsSetting=1$ for all codes with a linear boundary approximation
% $\numQuadPointsSetting=\lceil(\curveDegree+1)/2\rceil=2$ for all remaining codes.
for i=1:26
    objInt_temp = getAccessibleIntegrators(n_quad_pts(i),problem_dimension, ...
        'reparam_degree',reparam_degree(i),'n_quad_pts_green',n_quad_pts_green(i), ...
        'SpaceTreeDepth',SpaceTreeDepth);
    objInt{i} = selectIntegrator(objInt_temp,["BoSSSIntegrator","QUGaRIntegrator", ...
        "NgsxfemIntegrator","QuahogIntegrator","QuahogPEIntegrator"]);
    objInt{i} = [objInt{i}(:)',objInt_temp(:)'];
    objInt_temp = getAccessibleIntegrators(1,problem_dimension, ...
        'reparam_degree',reparam_degree(i),'n_quad_pts_green',n_quad_pts_green(i), ...
        'SpaceTreeDepth',SpaceTreeDepth);
    objInt_temp = selectIntegrator(objInt_temp,["GridapIntegrator","NutilsIntegrator"]);
    objInt{i} = [objInt{i}(:)',objInt_temp(:)'];
    objInt_temp = getAccessibleIntegrators(2,problem_dimension, ...
        'reparam_degree',reparam_degree(i),'n_quad_pts_green',n_quad_pts_green(i), ...
        'SpaceTreeDepth',SpaceTreeDepth);
    objInt_temp = selectIntegrator(objInt_temp,["FcmlabIntegrator","MlhpIntegrator"]);
    objInt{i} = [objInt{i}(:)',objInt_temp(:)'];
%     objInt{i} = selectIntegrator(objInt{i},"MlhpIntegrator");
end
[out_area,out_objQuadData,names] =  example_testsuite_unibw(...
    n_refs_min,n_refs_max,objInt,plot_settings);

% store results for publication in variable
for i = 1:length(names)
    for iInt = 1:length(names{1}.integrators)
        file = strcat(names{i}.file, names{i}.integrators{iInt});
        out = getDataFromFile(names{i}.path,file,'h');
        results(iInt,i,1) = out{1}(1);  % take only first refinement
        out = getDataFromFile(names{i}.path,file,'relError');
        results(iInt,i,2) = out{1}(1);  % take only first refinement
        out = getDataFromFile(names{i}.path,file,'nbQuadptsTrimmedElems');
        results(iInt,i,3) = out{1}(1);  % take only first refinement
    end
end

%% plot error over test suite
plot_error_testsuite(names,'testsuite_unibw')

%% save results for publication
dt = datestr(now,getDateStrFormat); %#ok<TNOW1,DATST>
name_logfile = [names{1}.path 'example_testsuite_unibw_' dt '_'];
names_cols = {'h','relError','nbQuadptsTrimmedElems'};
for iInt = 1:length(names{1}.integrators)
    name_logfile_i = join([name_logfile names{1}.integrators{iInt} '.csv'],'');
    T = array2table(squeeze(results(iInt,:,:)), 'VariableNames', names_cols);
    writetable(T,name_logfile_i)
end