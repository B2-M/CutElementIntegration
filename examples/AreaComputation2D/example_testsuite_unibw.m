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


function [out_area,out_objQuadData,names] =  example_testsuite_unibw(...
    n_refs_min,n_refs_max,objInt,varargin)

%% set up integrators
problem_dimension = 2;  % Spatial dimension of the background mesh
if nargin < 3
    n_quad_pts = ones(26,1)*3;         % Number of quadrature point per element in each direction
    reparam_degree = ones(26,1)*5;     % Degree of the reparametrisation of cut elements
    n_quad_pts_green = ones(26,1)*5;
    objInt = cell(26,1);
    for i=1:26
        objInt{i} = getAccessibleIntegrators(n_quad_pts(i),problem_dimension, ...
            'reparam_degree',reparam_degree(i),'n_quad_pts_green',n_quad_pts_green(i));
    end
end

%% set number of refinements 
if nargin < 1
    n_refs_min = 0;
    n_refs_max = 0;
end

%% plot setting
bDefaultPlotSettings = false;
if isempty(varargin)
    bDefaultPlotSettings = true;
    varargin = {'PlotError','off','PlotPoints','on'};
end

%% run test cases
test_cases = (9:34);
n_cases = length(test_cases);
out_area = cell(n_cases,1);
out_objQuadData = cell(n_cases,1);
names = cell(n_cases,1);
count = 0;
for testCaseId = test_cases
    count = count + 1;
    [out_area{count},out_objQuadData{count},names{count}] = runAreaComputation2D_h_refinement( ...
        objInt{count},testCaseId,n_refs_min,n_refs_max,varargin{:});
end

%% plot error over test suite
if bDefaultPlotSettings
    varargin = {'PlotError','on'};
end
[flag_plot_error,~] = set_2D_plot_options(varargin{:});
if flag_plot_error
    plot_error_testsuite(names,'testsuite_unibw')
end


end