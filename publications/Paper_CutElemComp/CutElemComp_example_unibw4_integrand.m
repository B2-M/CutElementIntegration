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
is_h_refinement = false;
n_refs_min = 0;
n_refs_max = 0;
% n_refs_max = 1;

% set up integrators
reparam_degree = 2;     % Degree of the reparametrisation of cut elements
SpaceTreeDepth = 3;
problem_dimension = 2;  % Spatial dimension of the background mesh

%% define integrand
% bounding_box: [x1,x2;y1,y2] = [0,0.95;0,1]
syms x y
x_shift = 0;
x_scale = 1/0.95;
p_max = 6;
integrand_list = cell(p_max,1);
for p = 1:p_max
    integrand(x,y) = ((x+x_shift)*x_scale)^p*y^p;
    integrand_list{p} = integrand;
end

%% run test case
if is_h_refinement
else
    n_quad_pts_max = zeros(p_max,1);
    n_quad_pts_list = cell(p_max,1);
    for i = 1:p_max
        n_quad_pts_max(i) = 2*(i+1)+1;    % q*(p+1); +1 to check that it has converged
        n_quad_pts_list{i} = 1:n_quad_pts_max(i);
        % n_quad_pts_list{i} = 1:15;
    end
end
for i = 1:p_max
    count = 0;
    for n_quad_pts = n_quad_pts_list{i}
        count = count + 1;
        add_settings = {'PlotError','off','PlotPoints','off','integrand',integrand_list{i}};
        objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
            'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth, ...
            'n_quad_pts_green',n_quad_pts);
        [out_area,out_objQuadData,names] = example_unibw4(...
            n_refs_min,n_refs_max,objInt,add_settings{:});
    
        % store results for publication in variable
        for iInt = 1:length(objInt)
            file = strcat(names.file, names.integrators{iInt});
            if is_h_refinement
            else
                results(iInt,i,count,1) = n_quad_pts;
                out = getDataFromFile(names.path,file,'relError');
                results(iInt,i,count,2) = out{1};
                out = getDataFromFile(names.path,file,'nbQuadptsTrimmedElems');
                results(iInt,i,count,3) = out{1};
            end
        end
    end
end

% save results for publication
dt = datestr(now,getDateStrFormat); %#ok<TNOW1,DATST>
name_logfile = [names.path 'example_unibw4_integrand_' dt '_'];
if is_h_refinement
else
    names_cols = {'nQP','relError','nbQuadptsTrimmedElems'};
end
for i = 1:p_max
    name_logfile_i = [name_logfile 'p' num2str(i) '_'];
    for iInt = 1:length(objInt)
        name_logfile_iiInt = join([name_logfile_i names.integrators{iInt} '.csv'],'');
        if is_h_refinement
        else
            T = array2table(squeeze(results(iInt,i,:,:)), 'VariableNames', names_cols);
            writetable(T,name_logfile_iiInt)
        end
    end
end

% % store names
% CIbenchenv4libs_example_circle_1_names = names;
% save('examples/AreaComputation2D/results/CIbenchenv4libs_example_circle_1_names.mat', ...
%     'CIbenchenv4libs_example_circle_1_names');