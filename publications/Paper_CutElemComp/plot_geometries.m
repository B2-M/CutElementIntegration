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

%% User Input

dim = 3;

file_format = 'pdf';    % pdf or svg
is_quality_high = true; % makes it slower, but increases plot quality if poor 
% (in particular for 3D plots)

% testCaseIds = (9:10);
% testCaseIds = (9:34);
% testCaseIds = (1:49);
testCaseIds = 2;

PaperSize = [6 6];  % Text width of CMAME paper is 19cm
FigureWidth = 5.5;
text_fontsize = 7;
resolution = 40;

%% Fixed Code
folder = [pwd,filesep,'publications',filesep,'Paper_CutElemComp',filesep,'geometries',filesep];
if exist(folder,'dir') ~= 7
    warning("plot_geometries: Path %s does not exist yet.", folder)
    mkdir(folder)
    warning("plot_geometries: Path %s has been added.", folder)
end

for testCaseId = testCaseIds

    % get Test object
    if dim == 2
        objTest = getTestCase2D(testCaseId);
    elseif dim == 3
        objTest = getTestCase3D(testCaseId);
    else
        error('Invalid dimension "dim" chosen.')
    end
    
    % plot domain
    fig=figure('Units','centimeters');
    ax = axes('Parent',fig);
    if dim == 2
        rectangle('Position',[objTest.domain.xmin,objTest.domain.xmax])
    elseif dim == 3
        X = [objTest.domain.xmin(1);objTest.domain.xmax(1);objTest.domain.xmax(1); ...
            objTest.domain.xmin(1);objTest.domain.xmin(1);nan; ...
            objTest.domain.xmin(1);objTest.domain.xmax(1);objTest.domain.xmax(1); ...
            objTest.domain.xmin(1);objTest.domain.xmin(1);nan; ...
            objTest.domain.xmin(1);objTest.domain.xmin(1);nan; ...
            objTest.domain.xmin(1);objTest.domain.xmin(1);nan; ...
            objTest.domain.xmax(1);objTest.domain.xmax(1);nan; ...
            objTest.domain.xmax(1);objTest.domain.xmax(1)];
        Y = [ones(5,1).*objTest.domain.xmin(2);nan; ...
            ones(5,1).*objTest.domain.xmax(2);nan; ...
            objTest.domain.xmin(2);objTest.domain.xmax(2);nan; ...
            objTest.domain.xmin(2);objTest.domain.xmax(2);nan; ...
            objTest.domain.xmin(2);objTest.domain.xmax(2);nan; ...
            objTest.domain.xmin(2);objTest.domain.xmax(2)];
        Z = [objTest.domain.xmin(3);objTest.domain.xmin(3);objTest.domain.xmax(3); ...
            objTest.domain.xmax(3);objTest.domain.xmin(3);nan; ...
            objTest.domain.xmin(3);objTest.domain.xmin(3);objTest.domain.xmax(3); ...
            objTest.domain.xmax(3);objTest.domain.xmin(3);nan; ...
            objTest.domain.xmin(3);objTest.domain.xmin(3);nan; ...
            objTest.domain.xmax(3);objTest.domain.xmax(3);nan; ...
            objTest.domain.xmin(3);objTest.domain.xmin(3);nan; ...
            objTest.domain.xmax(3);objTest.domain.xmax(3)];
        plot3(X,Y,Z,'Color',[0,0,0],'LineWidth',0.5);
        resolution = [resolution,resolution];
    end
    hold on
    newcolors = [0 0.4470 0.7410; 0 0.4470 0.7410; 0 0.4470 0.7410; 0 0.4470 0.7410; ...
        0 0.4470 0.7410];
    colororder(newcolors)
    set(0, 'DefaultLineLineWidth', 1);  % default is 0.5
    for c = 1 : length(objTest.interface.parametric)
        plot_domain(objTest.interface.parametric{c},resolution,'colormap', ...
            [0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1])
    end
    hold on
    if dim==3 && testCaseId==3    % plot also lid for elliptic cylinder which is not 
        % parametricly defined because it is implicitly given by the domain boundaries
        a=0.5; b=0.25; c=0;
        [phi,gradPhi,loops] = geo_ellipsoid(a,b,c);
        % plot bottom lid
        plot_domain(loops{1},[50,50],'colormap', ...
            [0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1])
        hold on
        % plot top lid
        for c = 1:length(loops{1})
            loops{1}(c).surf.coefs(3,:) = 1.*loops{1}(c).surf.coefs(4,:);
        end
        plot_domain(loops{1},resolution./5,'colormap', ...
            [0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1])
        hold on
    end
    % plot([0.4,0],[1,1])
    % plot([0.4;0;0;0.2],[1;1;0;0])
    % hold on
    
    % formatting
    title('')
    L = objTest.domain.xmax-objTest.domain.xmin;
    addon_domain = 0.05 * L;
    if dim == 2
        axis([objTest.domain.xmin(1)-addon_domain(1),objTest.domain.xmax(1)+addon_domain(1), ...
            objTest.domain.xmin(2)-addon_domain(2),objTest.domain.xmax(2)+addon_domain(2)])
    elseif dim == 3
        axis([objTest.domain.xmin(1)-addon_domain(1),objTest.domain.xmax(1)+addon_domain(1), ...
            objTest.domain.xmin(2)-addon_domain(2),objTest.domain.xmax(2)+addon_domain(2), ...
            objTest.domain.xmin(3)-addon_domain(3),objTest.domain.xmax(3)+addon_domain(3)])
    end
    xl = xlabel('x');
    yl = ylabel('y');
    xticks(linspace(objTest.domain.xmin(1),objTest.domain.xmax(1),6))
    yticks(linspace(objTest.domain.xmin(2),objTest.domain.xmax(2),6))
    set(xl,'FontSize',text_fontsize)
    set(yl,'FontSize',text_fontsize)
    if dim == 3
        zl = zlabel('z');
        zticks(linspace(objTest.domain.xmin(3),objTest.domain.xmax(3),6))
        set(zl,'FontSize',text_fontsize)
    end
    set(ax,'FontName','Times New Roman','FontSize',text_fontsize)
    box off
    fig.Position = [10 10 FigureWidth FigureWidth];
    set(gcf,'PaperSize',PaperSize);   % setting only for printing
    
    %------------------------------------
    % save figure
    figname = [folder,'dim',num2str(dim),'_testCaseId',num2str(testCaseId),'.',file_format];
    print_figure(figname,file_format,is_quality_high)

    %------------------------------------
    % create also top view for 3D geometries
    view(0,90); xlabel('x');    % X-Y plane
    % save figure
    figname = [folder,'dim',num2str(dim),'_testCaseId',num2str(testCaseId),'_top.',file_format];
    print_figure(figname,file_format,is_quality_high)
    % create also side view for 3D geometries
    view(0,0); zlabel('z'); % X-Z plane
    % save figure
    figname = [folder,'dim',num2str(dim),'_testCaseId',num2str(testCaseId),'_side.',file_format];
    print_figure(figname,file_format,is_quality_high)
end