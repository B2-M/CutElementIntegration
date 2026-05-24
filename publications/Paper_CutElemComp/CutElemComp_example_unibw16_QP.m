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


% This script determines the quadrature points for the example_unibw3 for
% the mlhp code.

clear
clc
close all

% set number of refinements 
n_refs_min = 1;
n_refs_max = 1;
% n_refs_min = 0;
% n_refs_max = 0;

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
n_quad_pts = 3; % all with the same setting because of visualization purposes
n_quad_pts_green = n_quad_pts;
objInt = getAccessibleIntegrators(n_quad_pts,problem_dimension, ...
    'reparam_degree',reparam_degree,'SpaceTreeDepth',SpaceTreeDepth, ...
    'n_quad_pts_green',n_quad_pts_green);
objInt = selectIntegrator(objInt,"QuahogIntegrator")
[out_area,out_objQuadData,names] = example_unibw16(...
    n_refs_min,n_refs_max,objInt,add_settings{:});

%% plot quadrature points
folder = [pwd,filesep,'publications',filesep,'Paper_CutElemComp',filesep,'plot_QP',filesep];
if exist(folder,'dir') ~= 7
    warning("plot_geometries: Path %s does not exist yet.", folder)
    mkdir(folder)
    warning("plot_geometries: Path %s has been added.", folder)
end

file_format = 'pdf';
is_quality_high = false;

PaperSize = [8 8];  % Text width of CMAME paper is 19cm
FigureWidth = 7.5;
text_fontsize = 7;

markers = dictionary(["Algoim","BoSSS","Fcmlab","QUGaR","Gridap","Mlhp","Ngsxfem","Nutils","Quahog", ...
    "QuahogPE"],["x","+","o","square","*","o","^","diamond",">","*"]);
colors = dictionary(["Algoim","BoSSS","Fcmlab","QUGaR","Gridap","Mlhp","Ngsxfem","Nutils","Quahog", ...
    "QuahogPE"],{[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250], ...
    [0.4940 0.1840 0.5560],[0.47,0.67,0.19],[0.49,0.18,0.56],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330], ...
    [0.6350 0.0780 0.1840],[0 0.4470 0.7410]});

objTest = getTestCase2D(48);
objTest.domain.n_refs = n_refs_min;

% plot points
% w_max = max(abs(out_objQuadData{1}.trimmed_elem_pts.quad_data(3,:)));
% color_pos = [217,83,25]/255;
% color_neg = [237,177,32]/255;
for iInt = 1:length(out_objQuadData)
    if ~isempty(out_objQuadData{iInt})
        name = strsplit(names.integrators{iInt},'_');
        name = strsplit(name{end},'-');
        name = name{1};
        color = colors(name);
        marker = markers(name);
    
        % Manipulate data for BoSSS to exclude single QP with zero weight
        % in uncut element
        if n_refs_min==1 && strcmp(name,'BoSSS')
            out_objQuadData{iInt}.trimmed_elem_pts(1) = [];
        end

        fig=figure('Units','centimeters');
        ax = axes('Parent',fig);
    
        for iel = 1:length(out_objQuadData{iInt}.trimmed_elem_pts)
            scatter(out_objQuadData{iInt}.trimmed_elem_pts(iel).quad_data(1,:), ...
                out_objQuadData{iInt}.trimmed_elem_pts(iel).quad_data(2,:), ...
                [],color{1},'Marker',marker{1});
            hold on
        end
        plot_mesh(objTest.domain);
        hold on
        % plot domain
        resolution = 50;
        newcolors = [0 0.4470 0.7410; 0 0.4470 0.7410; 0 0.4470 0.7410; 0 0.4470 0.7410; ...
            0 0.4470 0.7410];
        colororder(newcolors)
        set(0, 'DefaultLineLineWidth', 1);  % default is 0.5
        for c = 1 : length(objTest.interface.parametric)
            plot_domain(objTest.interface.parametric{c},resolution,'colormap',[0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1])
        end
        hold on
        xlabel('x');
        ylabel('y');
        L_max = max(objTest.domain.xmax-objTest.domain.xmin);
        addon_domain = 0.05 * L_max;
        axis([objTest.domain.xmin(1)-addon_domain,objTest.domain.xmax(1)+addon_domain, ...
            objTest.domain.xmin(2)-addon_domain,objTest.domain.xmax(2)+addon_domain])
        xl = xlabel('x');
        yl = ylabel('y');
        ticks_val = linspace(min(objTest.domain.xmin),max(objTest.domain.xmax),6);
        xticks(ticks_val)
        yticks(ticks_val)
        set(xl,'FontSize',text_fontsize)
        set(yl,'FontSize',text_fontsize)
        set(ax,'FontName','Times New Roman','FontSize',text_fontsize)
        box off
        fig.Position = [10 10 FigureWidth FigureWidth];
        set(gcf,'PaperSize',PaperSize);   % setting only for printing
        
        % save figure
        figname = string(folder)+'example_unibw16_QP_'+names.integrators{iInt}+'.'+file_format;
        print_figure(figname,file_format,is_quality_high)
    %     print(fig,'-dpdf',figname);
    end
end