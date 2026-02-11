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
reparam_degree = 5;     % Degree of the reparametrisation of cut elements, 
% example_unibw16 has a quintic boundary
SpaceTreeDepth = 3;
problem_dimension = 2;  % Spatial dimension of the background mesh

%% define integrand
% bounding_box: [x1,x2;y1,y2] = [0,0.95;0,1]
syms x y
x_shift = 0;
x_scale = 1/0.95;
p = 6;
integrand(x,y) = ((x+x_shift)*x_scale)^p*y^p;

%% additional settings (plot and integrand)
add_settings = {'PlotError','off','PlotPoints','off','integrand',integrand};

%% run actual example
nQP_choice = 6;

switch nQP_choice
    case 3
        n_quad_pts = 3; % = best choice from n_QP study on single element for
        % FCMLab and Nutils
    case 4
        n_quad_pts = 4; % = p+1 (FEM-rule) for integrand
    case 5
        n_quad_pts = 5; % = best choice from n_QP study on single element for
        % ngsxfem
    case 6
        n_quad_pts = 6; % = q+1 because of boundary as suggested in Breitenberger 
        % et al. (2015)
    otherwise
        error('Unsupported choice.')
end

objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
    'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth)
objInt = selectIntegrator(objInt,["BoSSSIntegrator","FcmlabIntegrator","NgsxfemIntegrator", ...
    "NutilsIntegrator"])
% objInt = selectIntegrator(objInt,"BoSSSIntegrator")
[out_vol,out_objQuadData,names] = example_unibw16(...
    n_refs_min,n_refs_max,objInt,add_settings{:});

%% Store results separately
% save results for publication
dt = datestr(now,getDateStrFormat); %#ok<TNOW1,DATST>
name_logfile = [names.path 'example_unibw16_href_p' num2str(p) '_' dt '_'];
names_cols = {'n_ele','nQP','relError','nbQuadptsTrimmedElems'};
count = 0;
for iInt = 1:length(names.integrators)
    count = count + 1;
    file = strcat(names.file, names.integrators{iInt});
    results(count,:,1) = 2.^(n_refs_min:n_refs_max);
    results(count,:,2) = ones(length(n_refs_min:n_refs_max),1)*n_quad_pts;
    out = getDataFromFile(names.path,file,'relError');
    results(count,:,3) = out{:};
    out = getDataFromFile(names.path,file,'nbQuadptsTrimmedElems');
    results(count,:,4) = out{1};

    name_logfile_iInt = join([name_logfile names.integrators{iInt} '.csv'],'');
    T = array2table(squeeze(results(count,:,:)), 'VariableNames', names_cols);
    writetable(T,name_logfile_iInt)
end