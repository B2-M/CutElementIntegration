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

function interface = getInterfaceCase2D( InterfaceId,d )
% negative values of the implicit function mean inside

% plot options
gridsteps_level_set = -2:0.1:2;

if InterfaceId == 1

    R=0.20;      % circle radius
    C=[0.5 0.5]; % position of the circle center
    sizeInterface = pi()*R*2;
    sizeInsideDomain =  pi()*R.^2;
    [phi,gradPhi,loops] = geo_circle(R,C);
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};
    
elseif InterfaceId == 2

    R=0.25;      % circle radius
    C=[0.5 0.5]; % position of the circle center
    [phi,gradPhi,loops] = geo_circle(R,C);
    sizeInterface = pi()*R*2;
    sizeInsideDomain =  pi()*R.^2;
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};

elseif InterfaceId == 3

    % P1 = [0,1]; % point 1
    % P2 = [1,1]; % point 2
    % P3 = [1,0]; % point 3
    P1 = [0,0.9]; % point 1
    P2 = [0.9,0.9]; % point 2
    P3 = [0.9,0]; % point 3
    [implCell,loops] = geo_line_through_pointarray({P1,P3,P2,P1});
    sizeInterface = (2+sqrt(2))*0.9;
    sizeInsideDomain = 0.9*0.9/2;

elseif InterfaceId == 4

    % Folium loop - implicit
    a = 1;
    folium = @(x,y) x.^3+y.^3-3*x.*y.*a; %Implicity functions of the curve
    gradFolium = { ...
        @(x,y) 3*(x.^2-y.*a), ...
        @(x,y) 3*(y.^2-x.*a)
        };
    P1 = [0,0]; % point 1
    P2 = [-1,1]; % point 2
    [line,gradLine,~] = geo_line_through_points(P2,P1);
    implCell = {...
        LevelSetFunctionAndGradient(folium,gradFolium),...
        LevelSetFunctionAndGradient(line,gradLine),...
        };

    % Folium loop - parametric
    % Jean-Paul Becar, Laurent Fuchs, Lionel Garnier. Modéliser un demi-cercle et autres questions de
    % poids nuls. JFIG 18, Université de Poitiers, Nov 2018, POITIERS, France. hal-02508960
    pnts = [0.0 2.0 4.0 6.0 2.0 0.0 0.0;
            0.0 0.0 2.0 6.0 4.0 2.0 0.0;
            0.0 0.0 0.0 0.0 0.0 0.0 0.0;
            1.0 1.0 1.0 2.0 1.0 1.0 1.0];
    crv = nrbmak(pnts,[0 0 0 0 0.5 0.5 0.5 1 1 1 1]);
    c0 = nrbtform(crv, vecscale([0.5 0.5]));
    % parametric definition of the circle
    loop_0 = struct();
    loop_0(1).curve = c0;  %Counter-clock wise -> outside normal -> get inside area
    loop_0(1).label = 1; % This is optional;
    loops = {loop_0};

    % https://mathworld.wolfram.com/FoliumofDescartes.html
    % see getFoliumLoopLenghtReferenceValue.nb
    sizeInterface = 4.917488721680027 * a;
    sizeInsideDomain = 3*a^2/2;

%Moving interfaces
elseif InterfaceId == 5
    %Moving circle
    R=0.20;      % circle radius
    C=[0.25+d 0.5]; % position of the circle center
    sizeInterface = pi()*R*2;
    sizeInsideDomain =  pi()*R.^2;
    [phi,gradPhi,loops] = geo_circle(R,C);
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};

elseif InterfaceId == 6
    %Moving line
    P1 = [0.0,0.0]; % point 1
    P2 = [0.5+d,0.0]; % point 2
    P3 = [0.5+d,1.0];
    P4 = [0.0,1.0];
    [implCell,loops] = geo_line_through_pointarray({P1,P2,P3,P4,P1});
    sizeInterface = (2+sqrt(2))*0.9;
    sizeInsideDomain = (P4(2)-P1(2))*(P2(1)-P1(1));

 elseif InterfaceId == 7
    %Moving line
    R=0.5;
    P1 = [0.0,0.0]; % point 1
    P2 = [R,0.0]; % point 2
    P3 = [R*cos((pi/2)-d),R*sin((pi/2)-d)];
    [implCell,loops] = geo_line_through_pointarray({P1,P2,P3,P1});
    sizeInterface = (2+sqrt(2))*0.9;
    sizeInsideDomain = (1/2)*abs(P1(1)*(P2(2)-P3(2))+P2(1)*(P3(2)-P1(2))+P3(1)*(P1(2)-P2(2)));

 elseif InterfaceId == 8
    %Moving line
    R=0.5;
    P1 = [0.0+d,0.1]; % point 1
    P2 = [2*R-d,0.1]; % point 2
    P3 = [R,R];
    [implCell,loops] = geo_line_through_pointarray({P1,P2,P3,P1});
    sizeInterface = (2+sqrt(2))*0.9;
    sizeInsideDomain = (1/2)*abs(P1(1)*(P2(2)-P3(2))+P2(1)*(P3(2)-P1(2))+P3(1)*(P1(2)-P2(2)));

 elseif InterfaceId == 9
    %Semi-circle
    %Parametric
    R=0.25;
    cntrl=[R*1 R*cos(pi/4) 0 -R*cos(pi/4) -R*1;0 R*cos(pi/4) R R*cos(pi/4) 0;0 0 0 0 0;1 cos(pi/4) 1 cos(pi/4) 1];
    knt=[0 0 0 1/2 1/2 1 1 1];
    rotation=[cos(2*pi-(pi/4)) -sin(2*pi-(pi/4)) 0 0; sin(2*pi-(pi/4)) cos(2*pi-(pi/4)) 0 0;0 0 1 0;0 0 0 1];
    translation=[1 0 0 0.1768;0 1 0 0.1768; 0 0 1 0;0 0 0 1];
    transformation_matrix=translation*rotation; %Rotation and then translation
    cntrl_transform=[transformation_matrix*cntrl(:,1) transformation_matrix*cntrl(:,2) transformation_matrix*cntrl(:,3) transformation_matrix*cntrl(:,4) transformation_matrix*cntrl(:,5)];
    loop_0 = struct();
    loop_0(1).curve = nrbmak(cntrl_transform, knt);  %Counter-clock wise -> outside normal -> get inside area
    loop_0(1).label = 1; % This is optional;
    loop_0(2).curve = nrbline([cntrl_transform(1,5) cntrl_transform(2,5)],[cntrl_transform(1,1) cntrl_transform(2,1)]);  %Counter-clock wise -> outside normal -> get inside area
    loop_0(2).label = 2; % This is optional;
    loops = {loop_0};
    %Implicit
    C=[0.1768 0.1768];
    P1=[cntrl_transform(1,1) cntrl_transform(2,1)];
    P2=[cntrl_transform(1,5) cntrl_transform(2,5)];
    [circle,gradCircle,~] = geo_circle(R,C);
    [line,gradLine,~] = geo_line_through_points(P2, P1);
    implCell = {...
        LevelSetFunctionAndGradient(circle,gradCircle),...
        LevelSetFunctionAndGradient(line,gradLine),...
        };
    sizeInterface = pi*R;
    sizeInsideDomain = (pi*R.^2)/2;

elseif InterfaceId == 10 % UniBw Munich test case 3

    scaling = 1;
    moving = 0;
    P1 = [0.2,0]*scaling+moving;
    P2 = [1,0]*scaling+moving;
    P3 = [1,1]*scaling+moving;
    P4 = [0.4,1]*scaling+moving;
    [implCell,loops] = geo_line_through_pointarray({P1,P2,P3,P4,P1});
    sizeInterface = scaling*(0.8+1+0.6+sqrt(0.2^2+1));
    sizeInsideDomain = scaling^2*(0.5*0.2+0.6);

elseif InterfaceId == 11 % UniBw Munich test case 4

    P1 = [0.8,0]; P2 = [0.95,0.5]; P3 = [0.5,1]; P4 = [0,1]; P5 = [0,0];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P3,P4,P5,P1});

    phi = @(x,y) 0.6*y^2-0.3*y+x-0.8;   % polynomial p=2
    grad = {@(x,y) 1, @(x,y) 1.2*y-0.3};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)], [0 0 0 1 1 1]);
    loop_curve = struct('curve',curve,'label',4);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 3.395239726133398;
    sizeInsideDomain = 0.75;

elseif InterfaceId == 12 % UniBw Munich test case 5

    P1 = [1,0.7]; P2 = [0.666666666666667,-0.8]; 
    P3 = [0.333333333333333,0.566666666666666]; P4 = [0,0.9];
    P5 = [0,0]; P6 = [1,0];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P4,P5,P6,P1});

    phi = @(x,y) -3.9*x^3+3.1*x^2+x+y-0.9;   % polynomial p=3
    grad = {@(x,y) -11.7*x^2+6.2*x+1, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',4);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.933765198515698+P4(2)+P6(1)+P1(2);
    sizeInsideDomain = 0.341666666666667;

elseif InterfaceId == 13 % UniBw Munich test case 6

    P1 = [0,0.7]; P2 = [0.25;0.774999999999999];
    P3 = [0.5,0.600000000000001]; P4 = [0.75,-0.675]; P5 = [1,0.6];
    P6 = [1,1]; P7 = [0,1];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P5,P6,P7,P1});

    phi = @(x,y) 4.5*x^4-3.4*x^3-1.5*x^2+0.3*x-y+0.7;   % polynomial p=4
    grad = {@(x,y) 18*x^3-10.2*x^2-3*x+0.3, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2)],[0 0 0 0 0 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',4);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.658028370945444 + 1 - P1(2) + P5(1) + 1 - P5(2);
    sizeInsideDomain = 1 - 0.4;

elseif InterfaceId == 14 % UniBw Munich test case 7

    P1 = [0.750417596651957,0]; P2 = [0.600334077321566;0.702728479923862];
    P3 = [0.450250557991174;0.705445663889469]; P4 = [0.300167038660783;0.625647941657809];
    P5 = [0.150083519330391;0.605058463531276]; P6 = [0,0.5]; P7 = [0,0];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P6,P7,P1});

    phi = @(x,y) 0.8*x^5+4.5*x^4-3.4*x^3+1.5*x^2-0.7*x+y-0.5;   % polynomial p=5
    grad = {@(x,y) 4*x^4+18*x^3-10.2*x^2+3*x-0.7, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',4);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.193146136031298 + P1(1) + P6(2);
    sizeInsideDomain = 0.392578532959995;

elseif InterfaceId == 15 % UniBw Munich test case 8

    P1 = [1,0.45]; P2 = [0.625,0]; P3 = [0.25,0]; P4 = [1,0];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P3,P4,P1});

    phi = @(x,y) -0.8*x^2+0.4*x+y-0.05;   % polynomial p=2
    grad = {@(x,y) -1.6*x+0.4, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve = struct('curve',curve,'label',4);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.903260330124153 + 1 - P3(1) + P1(2);
    sizeInsideDomain = 0.1125;

elseif InterfaceId == 16 % UniBw Munich test case 9

    P1 = [0.6,1]; P2 = [0.290231732002078,0.612789665002598];
    P3 = [1,0.225579330005195]; P4 = [1,1];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P3,P4,P1});

    phi = @(x,y) -x+1.7*y^2-2.6*y+1.5;   % polynomial p=2
    grad = {@(x,y) -1, @(x,y) 3.4*y-2.6};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve = struct('curve',curve,'label',4);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.022208500257135 + 1 - P3(2) + 1 - P1(1);
    sizeInsideDomain = 0.286475828547308;

elseif InterfaceId == 17 % UniBw Munich test case 10

    P1 = [0,0.4]; P2 = [0.15,0.58]; P3 = [0.3,0.724];
    P4 = [0.554036440163038,0.810372389655433]; P5 = [0.808072880326076,1];
    P6 = [0,1];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P5,P6,P1});

    syms x y
    f_1(x,y) = -0.4*x^2+1.2*x-y+0.4;
    f_2(x,y) = 0.4*x^2+0.1*x-y+329/500;
    x_range = [-inf,P3(1);P3(1),inf];
    y_range = [-inf,inf;-inf,inf];
    phi = @(x,y)geo_implicit_piecewise(x,y,{f_1,f_2},x_range,y_range);   % polynomial p=2
    df_1 = {diff(f_1,x),diff(f_1,y)};
    df_2 = {diff(f_2,x),diff(f_2,y)};
    grad = {@(x,y)geo_implicit_piecewise(x,y,{df_1{1},df_2{1}},x_range,y_range), ...
        @(x,y)geo_implicit_piecewise(x,y,{df_1{2},df_2{2}},x_range,y_range)};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve1 = struct('curve',curve,'label',3);
    curve = nrbmak([P3(1),P4(1),P5(1);P3(2),P4(2),P5(2)],[0 0 0 1 1 1]);
    loop_curve2 = struct('curve',curve,'label',4);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve1,loop_curve2]};

    sizeInterface = 1.022360435661060 + 1 - P5(1) + 1 - P1(2);
    sizeInsideDomain = P5(1)-0.599615293277039;

elseif InterfaceId == 18 % UniBw Munich test case 11

    P1 = [0,0.160117935966358];
    P2 = [0.336989868708836,0.398950110474918];
    P3 = [0.753859180080102,0.637782284983478];
    P4 = [0,0.876614459492038];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P4,P1});

    phi = @(x,y) 3.4*y^3-2.1*y^2-y+x+0.2;   % polynomial p=3
    grad = {@(x,y) 1, @(x,y) 10.2*y^2-4.2*y-1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',2);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.157394015938070 + P4(2) - P1(2);
    sizeInsideDomain = P4(2) - P1(2) - 0.521099135738537;

elseif InterfaceId == 19 % UniBw Munich test case 12

    P5 = [1.000000000000000,   0.155077180778728];
    P4 = [0.855319301347602,   0.300746758377517];
    P3 = [0.814306680543472,   0.446416335976305];
    P2 = [0.854613742937773,   0.592085913575093];
    P1 = [1.000000000000000,   0.737755491173882];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P5,P1});

    phi = @(x,y) 0.4*y^4-0.7*y^3+2.1*y^2-1.6*y-x+1.2;   % polynomial p=4
    grad = {@(x,y) 1.6*y^3-2.1*y^2+4.2*y-1.6, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2)],[0 0 0 0 0 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',2);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.665551939192485 + P1(2) - P5(2);
    sizeInsideDomain = 0.055443038657972;

elseif InterfaceId == 20 % UniBw Munich test case 13

    P1 = [0.306731923805770,   1.000000000000000];
    P2 = [0.414182114440665,   0.878347428226277];
    P3 = [0.521632305075560,   0.757960140785942];
    P4 = [0.629082495710455,   0.675254987128686];
    P5 = [0.736532686345350,   0.703090013976239];
    P6 = [0.843982876980245,   1.000000000000000];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P6,P1});

    phi = @(x,y) 1.1*x^5+0.5*x^4+0.7*x^3-1.2*x^2-0.7*x-y+1.3;   % polynomial p=5
    grad = {@(x,y) 5.5*x^4+2*x^3+2.1*x^2-4.2*x-0.7, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',2);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.773184490806806 + P6(1) - P1(1);
    sizeInsideDomain = P6(1) - P1(1) - 0.449021145522378;

elseif InterfaceId == 21 % UniBw Munich test case 14

    P6 = [0.306731923805770,                   0];
    P5 = [0.414182114440665,   0.121652571773723];
    P4 = [0.521632305075560,   0.242039859214056];
    P3 = [0.629082495710455,   0.324745012871316];
    P2 = [0.736532686345350,   0.296909986023760];
    P1 = [0.843982876980245,                   0];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P6,P1});

    phi = @(x,y) 1.1*x^5+0.5*x^4+0.7*x^3-1.2*x^2-0.7*x+y+0.3;   % polynomial p=5
    grad = {@(x,y) 5.5*x^4+2*x^3+2.1*x^2-4.2*x-0.7, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',2);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.773184490806806 + P1(1) - P6(1);
    sizeInsideDomain = 0.088229807652097;

elseif InterfaceId == 22 % UniBw Munich test case 16 (case 15 does not exist in this counting)

    P6 = [0.750417596651957,0]; P5 = [0.600334077321566;0.702728479923862];
    P4 = [0.450250557991174;0.705445663889469]; P3 = [0.300167038660783;0.625647941657809];
    P2 = [0.150083519330391;0.605058463531276]; P1 = [0,0.5]; P7 = [1,0];
    P8 = [1,1]; P9 = [0,1];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P6,P7,P8,P9,P1});

    phi = @(x,y) -0.8*x^5-4.5*x^4+3.4*x^3-1.5*x^2+0.7*x-y+0.5;   % polynomial p=5
    grad = {@(x,y) -4*x^4-18*x^3+10.2*x^2-3*x+0.7, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.193146136031298 + 4 - P1(2) - P6(1);
    sizeInsideDomain = 1 - 0.392578532959995;

elseif InterfaceId == 23 % UniBw Munich test case 17

    P1 = [0.398040146044218,                   0 ];
    P2 = [0.598693430696145,   0.409719015390489];
    P3 = [0.799346715348073,   0.761175912373469];
    P4 = [1.000000000000000,   0.400000000000000];
    P5 = [1,1]; P6 = [0,1]; P7 = [0,0];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P4,P5,P6,P7,P1});

    phi = @(x,y) -3*x^3+3.1*x^2+x-y-0.7;   % polynomial p=3
    grad = {@(x,y) -9*x^2+6.2*x+1, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1); ...
        P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.961716751981047 + 4 - P1(1) - P4(2);
    sizeInsideDomain = 1 - 0.236403920324168;

elseif InterfaceId == 24 % UniBw Munich test case 18

    P3 = [0.177182214461453,   1.000000000000000];
    P2 = [0.588591107230727  -0.399395117707764];
    P1 = [1.000000000000000   0.300000000000000];
    P4 = [0,1]; P5 = [0,0]; P6 = [1,0];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P3,P4,P5,P6,P1});

    phi = @(x,y) -3.1*x^2+4.5*x+y-1.7;   % polynomial p=2
    grad = {@(x,y) -6.2*x+4.5, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.504167570790096 + 2 + P1(2) + P3(1);
    sizeInsideDomain = 0.247011238297634 + P3(1);

elseif InterfaceId == 25 % UniBw Munich test case 19

    P5 = [0,   0.700000000000000];
    P4 = [0.234240400007958,   0.395487479989655];
    P3 = [0.468480800015916,   0.544555097278651];
    P2 = [0.702721200023874,   0.653669362747010];
    P1 = [0.936961600031832,   1.000000000000000];
    P6 = [0,0]; P7 = [1,0]; P8 = [1,1];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P5,P6,P7,P8,P1});

    phi = @(x,y) -x^4+2.4*x^3-3.1*x^2+1.3*x+y-0.7;   % polynomial p=4
    grad = {@(x,y) -4*x^3+7.2*x^2-6.2*x+1.3, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2)],[0 0 0 0 0 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.173972560282842 + 4 - P5(2) - P1(1);
    sizeInsideDomain = 0.617216321872140 + 1 - P1(1);

elseif InterfaceId == 26 % UniBw Munich test case 20

    P6 = [0.300000000000000,                   0];
    P5 = [0.516695892043935,   0.166689147726106];
    P4 = [0.587519106247189,   0.333378295452212];
    P3 = [0.668782879118383,   0.500067443178319];
    P2 = [0.820297779862730,   0.666756590904425];
    P1 = [0,   0.833445738630531];
    P7 = [1,0]; P8 = [1,1]; P9 = [0,1];
    
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P6,P7,P8,P9,P1});

    phi = @(x,y) -2.5*y^5-y^4+2.7*y^3-2.1*y^2+1.3*y-x+0.3;   % polynomial p=5
    grad = {@(x,y) -12.5*y^4-4*y^3+8.1*y^2-4.2*y+1.3, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.358550492807783 + 4 - P6(1) - P1(2);
    sizeInsideDomain = 1 - P1(2) + 0.431544915938570;

elseif InterfaceId == 27 % UniBw Munich test case 21

    P5 = [0.917094319995597, 0.446898534823996, 0,  0.917094319995597];
    P4 = [0.529962390645461, 0.310284400159196, 0, 0.757089129493515];
    P3 = [0.700000000000000, 0.100000000000000, 0, 1.000000000000000];
    P2 = [0.665012356185123, 0.046734539904529, 0, 0.950017651693032];
    P1 = [0.653614649170721, -0.000000000000000, 0, 0.917094319995597];
    P8 = [0,0]; P7 = [0,1]; P6 = [1,1];
    U = [0, 0, 0, 0.829349588531096, 0.829349588531096, 1.000000000000000, ...
        1.000000000000000, 1.000000000000000];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P5(1:2)./P5(4),P6,P7,P8,P1(1:2)./P1(4)});

    R=0.40;      % circle radius
    C=[1.1 0.1]; % position of the circle center
    [phi,gradPhi,~] = geo_circle(R,C);
    phi = @(x,y)-phi(x,y);
    gradPhi = {@(x,y)-gradPhi{1}(x,y),@(x,y)-gradPhi{2}(x,y)};
    implCell_circle = {LevelSetFunctionAndGradient(phi,gradPhi)};
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2); P1(3),P2(3),P3(3),P4(3),P5(3); ...
        P1(4),P2(4),P3(4),P4(4),P5(4)],U);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines implCell_circle];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 2*pi()*R/4 + 3 + P1(1)/P1(4) - P5(2)/P5(4);
    sizeInsideDomain = 1 - ( pi()*R^2/4 + 0.5 * (C(1)-P1(1)/P1(4)-0.1)^2 * 1 * 0.1/0.4 - ...
        0.5 * 0.1 * (P5(2)/P5(4)-(C(1)-P1(1)/P1(4)-0.1)*(0.1/0.4)) );

elseif InterfaceId == 28 % UniBw Munich test case 22

    P3 = [0.6,1]; P2 = [0.290231732002078,0.612789665002598];
    P1 = [1,0.225579330005195]; P4 = [0,1]; P5 = [0,0]; P6 = [1,0];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P3,P4,P5,P6,P1});

    phi = @(x,y) x-1.7*y^2+2.6*y-1.5;   % polynomial p=2
    grad = {@(x,y) 1, @(x,y) -3.4*y+2.6};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.022208500257135 + 2 + P1(2) + P3(1);
    sizeInsideDomain = 1 - 0.286475828547308;

elseif InterfaceId == 29 % UniBw Munich test case 23

    P4 = [0,   0.059970106441517];
    P3 = [0.511525859975488,   0.373313404294345];
    P2 = [0.838680616993959,   0.686656702147172];
    P1 = [0.400000000000000,   1.000000000000000];
    P5 = [0,0]; P6 = [1,0]; P7 = [1,1];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P4,P5,P6,P7,P1});

    phi = @(x,y) -0.7*y^3-0.5*y^2+1.7*y-x-0.1;   % polynomial p=3
    grad = {@(x,y) -1, @(x,y) -2.1*y^2-y+1.7};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)], ...
        [0 0 0 0 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',5);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.290448544433002 + 2 + P4(2) + 1 - P1(1);
    sizeInsideDomain = 0.528718291495744 + P4(2);

elseif InterfaceId == 30 % UniBw Munich test case 24

    P1 = [0,   0.876614459492038];
    P2 = [0.753859180080102,   0.637782284983478];
    P3 = [0.336989868708836,   0.398950110474918];
    P4 = [0,   0.160117935966358];
    P5 = [0,0]; P6 = [1,0]; P7 = [1,1]; P8 = [0,1];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P4,P5,P6,P7,P8,P1});

    phi = @(x,y) -3.4*y^3+2.1*y^2+y-x-0.2;   % polynomial p=3
    grad = {@(x,y) -1, @(x,y) -10.2*y^2+4.2*y+1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',6);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 1.157394015938070 + P4(2) + 1 - P1(2) + 3;
    sizeInsideDomain = P4(2) + 1 - P1(2) + 0.521099135738537;

elseif InterfaceId == 31 % UniBw Munich test case 25

    P1 = [1.000000000000000,   0.155077180778728];
    P2 = [0.855319301347602,   0.300746758377517];
    P3 = [0.814306680543472,   0.446416335976305];
    P4 = [0.854613742937773,   0.592085913575093];
    P5 = [1.000000000000000,   0.737755491173882];
    P6 = [1,1]; P7 = [0,1]; P8 = [0,0]; P9 = [1,0];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P5,P6,P7,P8,P9,P1});

    phi = @(x,y) -0.4*y^4+0.7*y^3-2.1*y^2+1.6*y+x-1.2;   % polynomial p=4
    grad = {@(x,y) -1.6*y^3+2.1*y^2-4.2*y+1.6, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2)],[0 0 0 0 0 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',6);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.665551939192485 + 3 + P1(2) + 1 - P5(2);
    sizeInsideDomain = 1 - 0.055443038657972;

elseif InterfaceId == 32 % UniBw Munich test case 26

    P6 = [0.306731923805770,   1.000000000000000];
    P5 = [0.414182114440665,   0.878347428226277];
    P4 = [0.521632305075560,   0.757960140785942];
    P3 = [0.629082495710455,   0.675254987128686];
    P2 = [0.736532686345350,   0.703090013976239];
    P1 = [0.843982876980245,   1.000000000000000];
    P7 = [0,1]; P8 = [0,0]; P9 = [1,0]; P10 = [1,1];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P6,P7,P8,P9,P10,P1});

    phi = @(x,y) -1.1*x^5-0.5*x^4-0.7*x^3+1.2*x^2+0.7*x+y-1.3;   % polynomial p=5
    grad = {@(x,y) -5.5*x^4-2*x^3-2.1*x^2+4.2*x+0.7, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',6);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.773184490806806 + 3 + P6(1) + 1 - P1(1);
    sizeInsideDomain = P6(1) + 1 - P1(1) + 0.449021145522378 ;

elseif InterfaceId == 33 % UniBw Munich test case 27

    P1 = [0.306731923805770,                   0];
    P2 = [0.414182114440665,   0.121652571773723];
    P3 = [0.521632305075560,   0.242039859214056];
    P4 = [0.629082495710455,   0.324745012871316];
    P5 = [0.736532686345350,   0.296909986023760];
    P6 = [0.843982876980245,                   0];
    P7 = [1,0]; P8 = [1,1]; P9 = [0,1]; P10 = [0,0];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P6,P7,P8,P9,P10,P1});

    phi = @(x,y) -1.1*x^5-0.5*x^4-0.7*x^3+1.2*x^2+0.7*x-y-0.3;   % polynomial p=5
    grad = {@(x,y) -5.5*x^4-2*x^3-2.1*x^2+4.2*x+0.7, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1); ...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve = struct('curve',curve,'label',6);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.773184490806806 + 3 + P1(1) + 1 - P6(1);
    sizeInsideDomain = 1 - 0.088229807652097;

elseif InterfaceId == 34 % UniBw Munich test case 105

    P1 = [0.718710845439301   1.000000000000000];
    P2 = [0.850000000000000   0.934500000000000];
    P3 = [0.981289154560699   1.000000000000000];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P3,P1});

    phi = @(x,y) 1.9*x^2-3.23*x-y+2.34;   % polynomial p=2
    grad = {@(x,y) 3.8*x-3.23, @(x,y) -1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve = struct('curve',curve,'label',2);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 2.730965723820564e-01 + P3(1) - P1(1);
    sizeInsideDomain = P3(1) - P1(1) - 2.568453493722478e-01;

elseif InterfaceId == 35 % UniBw Munich test case 106

    P3 = [0.718710845439301   1.000000000000000];
    P2 = [0.850000000000000   0.934500000000000];
    P1 = [0.981289154560699   1.000000000000000];
    P4 = [0,1]; P5 = [0,0]; P6 = [1,0]; P7 = [1,1];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P3,P4,P5,P6,P7,P1});

    phi = @(x,y) -1.9*x^2+3.23*x+y-2.34;   % polynomial p=2
    grad = {@(x,y) -3.8*x+3.23, @(x,y) 1};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    curve = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve = struct('curve',curve,'label',6);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 2.730965723820564e-01 + 4 - P1(1) + P3(1);
    sizeInsideDomain = 1 - (P1(1) - P3(1) - 2.568453493722478e-01);

elseif InterfaceId == 36 % ellipse

    a = 0.2;    % first semi-axis
    b = 0.35;    % second semi-axis
    C = [0.4,0.6];
    angle = pi()/3; % 60°
    [phi,gradPhi,loops] = geo_ellipse(a,b,C,angle);
    implCell = {LevelSetFunctionAndGradient(phi,gradPhi)};

    sizeInterface = 1.760158109864327;	% generated with Mathematica by B. Marussig
    sizeInsideDomain =  pi()*a*b;

elseif InterfaceId == 37 % moving, cusp

    % Moving line
    P1 = [1,1];
    P2 = [0.6+d,1];
    P3 = [0.6,0.6];
    P4 = [1,0.6+d];
    [implCell,loops] = geo_line_through_pointarray({P1,P2,P3,P4,P1});

    sizeInterface = P1(1) - P2(1) + sqrt((P2(1)-P3(1))^2+(P2(2)-P3(2))^2) + ...
        sqrt((P4(1)-P3(1))^2+(P4(2)-P3(2))^2) + P1(2) - P4(2);
    b = sqrt((P2(1)-P4(1))^2+(P2(2)-P4(2))^2);
    sizeInsideDomain = 0.5 * (P1(2)-P4(2))*(P1(1)-P2(1)) + ...
        0.5 * b * sqrt((P2(1)-P3(1))^2+(P2(2)-P3(2))^2-(b/2)^2);

elseif InterfaceId == 38 % two parabolas with multiple intersections of one element

    P3 = [0.451656188679616,   0.500000000000000-d];
    P2 = [0.625000000000000,   1.125000000000000-d];
    P1 = [0.798343811320384,   0.500000000000000-d];
    P4 = [0.625, -0.125-d];

    phi1 = @(x,y) -13*x + (52*x^2)/5 + (y+d) + 13/4;   % polynomial p=2
    grad1 = {@(x,y) -13*x+104/5*x, @(x,y) 1};
    implCell_curve1 = LevelSetFunctionAndGradient(phi1,grad1);
    phi2 = @(x,y) -13*x + (52*x^2)/5 - (y+d) + 17/4;   % polynomial p=2
    grad2 = {@(x,y) -13*x+104/5*x, @(x,y) -1};
    implCell_curve2 = LevelSetFunctionAndGradient(phi2,grad2);
    curve1 = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2)],[0 0 0 1 1 1]);
    loop_curve1 = struct('curve',curve1,'label',1);
    curve2 = nrbmak([P3(1),P4(1),P1(1);P3(2),P4(2),P1(2)],[0 0 0 1 1 1]);
    loop_curve2 = struct('curve',curve2,'label',2);
    implCell = [{implCell_curve1} {implCell_curve2}];
    loops = {[loop_curve1,loop_curve2]};

    sizeInterface = 2*2.977895775092165/4;  % 2*parabola, scaled form 1 to 0.25
    sizeInsideDomain = 2*1.155625408802561/16;

elseif InterfaceId == 39 % shrinking square

    % Moving line
    P1 = [0.51,0.51];
    P2 = [0.8-d,0.51];
    P3 = [0.8-d,0.8-d];
    P4 = [0.51,0.8-d];
    [implCell,loops] = geo_line_through_pointarray({P1,P2,P3,P4,P1});

    sizeInterface = P2(1)-P1(1)+P3(2)-P2(2)+P3(1)-P4(1)+P4(2)-P4(2);
    sizeInsideDomain = (P2(1)-P1(1)) * (P4(2)-P1(2));

elseif InterfaceId == 40    % two squares

    P1 = [0.5,0.5];
    P2 = [0,0.5];
    P3 = [0,0];
    P4 = [0.5,0];
    P5 = [1,0.5];
    P6 = [1,1];
    P7 = [0.5,1];
    [~,loops1] = geo_line_through_pointarray({P1,P2,P3,P4,P1});
    [~,loops2] = geo_line_through_pointarray({P1,P5,P6,P7,P1});
    loops = [loops1,loops2];

%     % interesting alternative parametric description (Ginkgo does also not run with this one)
%     P2 = [0,0.5];
%     P3 = [0,0];
%     P4 = [0.5,0];
%     P5 = [1,0.5];
%     P6 = [1,1];
%     P7 = [0.5,1];
%     [~,loops1] = geo_line_through_pointarray({P2,P3,P4,P7,P6,P5,P2});
%     loops = [loops1,loops2];

    % outer lines
    [implCell_square,~] = geo_line_through_pointarray({[0,0],[1,0],[1,1],[0,1]});
    % vertical middle line
    syms x y
    f_1(x,y) = x-0.5;
    f_2(x,y) = 0.5-x;
    x_range = [-inf,inf;-inf,inf];
    y_range = [-inf,0.5;0.5,inf];
    phi = @(x,y)geo_implicit_piecewise(x,y,{f_1,f_2},x_range,y_range);
    df_1 = {diff(f_1,x),diff(f_1,y)};
    df_2 = {diff(f_2,x),diff(f_2,y)};
    grad = {@(x,y)geo_implicit_piecewise(x,y,{df_1{1},df_2{1}},x_range,y_range), ...
        @(x,y)geo_implicit_piecewise(x,y,{df_1{2},df_2{2}},x_range,y_range)};
    implCell1 = LevelSetFunctionAndGradient(phi,grad);
    % horizontal middle line
    f_1(x,y) = y-0.5;
    f_2(x,y) = 0.5-y;
    x_range = [-inf,0.5;0.5,inf];
    y_range = [-inf,inf;-inf,inf];
    phi = @(x,y)geo_implicit_piecewise(x,y,{f_1,f_2},x_range,y_range);
    df_1 = {diff(f_1,x),diff(f_1,y)};
    df_2 = {diff(f_2,x),diff(f_2,y)};
    grad = {@(x,y)geo_implicit_piecewise(x,y,{df_1{1},df_2{1}},x_range,y_range), ...
        @(x,y)geo_implicit_piecewise(x,y,{df_1{2},df_2{2}},x_range,y_range)};
    implCell2 = LevelSetFunctionAndGradient(phi,grad);
    implCell = [implCell_square,{implCell1},{implCell2}];

    sizeInterface = 2*4*0.5;
    sizeInsideDomain = 2*0.5^2;

elseif InterfaceId == 41   % two squares slightly curved, almost touching
    % maximum approximation error of implicit curve by parametric curve = 9.814740166425029e-17

    P5 = [0,0.499800000000000,0,0.693027668720244];
    P4 = [0.438590879625572,0.499624563648150,0,1.088190404583880];
    P3 = [0.490963924656038,0.498890040861911,0,0.982648889144339];
    P2 = [0.499602430616139,0.493923459651649,0,0.418946273035616];
    P1 = [0.499800000000000,0,0,0.010763600576563];
    % homogenous coordinates (x = x/w)
    P1(1:3) = P1(1:3).*P1(4);
    P2(1:3) = P2(1:3).*P2(4);
    P3(1:3) = P3(1:3).*P3(4);
    P4(1:3) = P4(1:3).*P4(4);
    P5(1:3) = P5(1:3).*P5(4);
    P6 = [0,0];
    P7 = geo_rotate(P1,[0.5,0.5],pi());
    P8 = geo_rotate(P2,[0.5,0.5],pi());
    P9 = geo_rotate(P3,[0.5,0.5],pi());
    P10 = geo_rotate(P4,[0.5,0.5],pi());
    P11 = geo_rotate(P5,[0.5,0.5],pi());
    P12 = [1,1];
    [implCell1,loops1] = geo_line_through_pointarray({P5(1:2)./P5(4),P6,P1(1:2)./P1(4)});
    curve1 = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1);...
        P1(2),P2(2),P3(2),P4(2),P5(2);P1(3),P2(3),P3(3),P4(3),P5(3); ...
        P1(4),P2(4),P3(4),P4(4),P5(4)],[0 0 0 0 0 1 1 1 1 1]);  % p=4
    loop_curve1 = struct('curve',curve1,'label',1);
    [implCell2,loops2] = geo_line_through_pointarray({P11(1:2)./P11(4),P12,P7(1:2)./P7(4)});
    curve2 = nrbmak([P7(1),P8(1),P9(1),P10(1),P11(1);...
        P7(2),P8(2),P9(2),P10(2),P11(2);P7(3),P8(3),P9(3),P10(3),P11(3);...
        P7(4),P8(4),P9(4),P10(4),P11(4)],[0 0 0 0 0 1 1 1 1 1]);
    loop_curve2 = struct('curve',curve2,'label',1);

    % complex implicit curves
    epsilon = 0.01;
    phi = @(x,y) -((x-0.5).*(y-0.5)-epsilon^2);
    grad = {@(x,y) 0.5-y,@(x,y) 0.5-x};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    
    loops = {[loops1{:},loop_curve1],[loops2{:},loop_curve2]};
    implCell = [implCell1,implCell2,{implCell_curve}];

    sizeInterface = 2*0.983055711637454 + 4*P5(1)./P5(4);
    sizeInsideDomain = 2*0.249117595398914;

elseif InterfaceId == 42   % two squares more curved
    % maximum approximation error of implicit curve by parametric curve = 7.684824998577255e-16
                   
    P6 = [0,0.480000000000000,0,0.569305522212731];
    P5 = [0.386499576308231,0.464540016947658,0,0.969591631066725];
    P4 = [0.357211745396365,0.409009847344064,0,0.870090469484957];
    P3 = [0.452846506715033,0.419662845282020,0,1.617676506977997];
    P2 = [0.472483771686428,0.187905707838772,0,1.274914216232570];
    P1 = [0.480000000000000,0,0,0.684428288359960];
    % homogenous coordinates (x = x/w)
    P1(1:3) = P1(1:3).*P1(4);
    P2(1:3) = P2(1:3).*P2(4);
    P3(1:3) = P3(1:3).*P3(4);
    P4(1:3) = P4(1:3).*P4(4);
    P5(1:3) = P5(1:3).*P5(4);
    P6(1:3) = P6(1:3).*P6(4);
    P7 = [0,0];
    P8 = geo_rotate(P1,[0.5,0.5],pi());
    P9 = geo_rotate(P2,[0.5,0.5],pi());
    P10 = geo_rotate(P3,[0.5,0.5],pi());
    P11 = geo_rotate(P4,[0.5,0.5],pi());
    P12 = geo_rotate(P5,[0.5,0.5],pi());
    P13 = geo_rotate(P6,[0.5,0.5],pi());
    P14 = [1,1];
    [implCell1,loops1] = geo_line_through_pointarray({P6(1:2)./P6(4),P7,P1(1:2)./P1(4)});
    curve1 = nrbmak([P1(1),P2(1),P3(1),P4(1),P5(1),P6(1);...
        P1(2),P2(2),P3(2),P4(2),P5(2),P6(2);P1(3),P2(3),P3(3),P4(3),P5(3),P6(3); ...
        P1(4),P2(4),P3(4),P4(4),P5(4),P6(4)],[0 0 0 0 0 0 1 1 1 1 1 1]);    % p=5
    loop_curve1 = struct('curve',curve1,'label',1);
    [implCell2,loops2] = geo_line_through_pointarray({P13(1:2)./P13(4),P14,P8(1:2)./P8(4)});
    curve2 = nrbmak([P8(1),P9(1),P10(1),P11(1),P12(1),P13(1);...
        P8(2),P9(2),P10(2),P11(2),P12(2),P13(2);P8(3),P9(3),P10(3),P11(3),P12(3),P13(3);...
        P8(4),P9(4),P10(4),P11(4),P12(4),P13(4)],[0 0 0 0 0 0 1 1 1 1 1 1]);
    loop_curve2 = struct('curve',curve2,'label',1);

    % complex implicit curves
    epsilon = 0.1;
    phi = @(x,y) -((x-0.5).*(y-0.5)-epsilon^2);
    grad = {@(x,y) 0.5-y,@(x,y) 0.5-x};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);
    
    loops = {[loops1{:},loop_curve1],[loops2{:},loop_curve2]};
    implCell = [implCell1,implCell2,{implCell_curve}];

    sizeInterface = 2*0.830290762065568 + 4*P6(1)./P6(4);
    sizeInsideDomain = 2*0.207811241751318;

elseif InterfaceId == 43 % trimming curve with inner knot

    P4 = [0.325693909432999,0];
    P3 = [0.494270432074749,0.121562259244849];
    P2 = [0.831423477358250,0.546562259244849];
    P1 = [1.000000000000000,0.645390083300911];
    P5 = [1,0];

    [implCell_lines,loops_lines] = geo_line_through_pointarray({P4,P5,P1});
    
    syms x y
    f_1(x,y) = -(4*x^2)/5 - x/5 + 3/20 + y;
    f_2(x,y) = x^2 - (5823715099613857*x)/2251799813685248 + 4237252033194623/4503599627370496 + y;
    SP = [2985197298264893/4503599627370496,8469484468906624215351501884553/25353012004564588029934064107520];
    x_range = [-inf,SP(1);SP(1),inf];
    y_range = [-inf,inf;-inf,inf];
    phi = @(x,y)geo_implicit_piecewise(x,y,{f_1,f_2},x_range,y_range);
    df_1 = {diff(f_1,x),diff(f_1,y)};
    df_2 = {diff(f_2,x),diff(f_2,y)};
    grad = {@(x,y)geo_implicit_piecewise(x,y,{df_1{1},df_2{1}},x_range,y_range), ...
        @(x,y)geo_implicit_piecewise(x,y,{df_1{2},df_2{2}},x_range,y_range)};
    implCell_curve = LevelSetFunctionAndGradient(phi,grad);

    curve = nrbmak([P1(1),P2(1),P3(1),P4(1); ...
        P1(2),P2(2),P3(2),P4(2)],[0 0 0 0.5 1 1 1]);
    loop_curve = struct('curve',curve,'label',3);
    implCell = [implCell_lines {implCell_curve}];
    loops = {[loops_lines{:},loop_curve]};

    sizeInterface = 0.937574578391202 + 1 - P4(1) + P1(2);
    sizeInsideDomain = 0.222705221351808;

elseif InterfaceId == 44 % punched plate

    % outer boundary
    P1 = [0,0]; P2 = [13,0]; P3 = [13,9]; P4 = [0,9];
    [implCell_lines,loops_lines] = geo_line_through_pointarray({P1,P2,P3,P4,P1});

    % 1st curve
    R=0.5;      % circle radius
    C=[2.5 2.5]; % position of the circle center
    [phi,gradPhi,loops_curve1] = geo_circle(R,C);
    phi = @(x,y)-phi(x,y);
    gradPhi = {@(x,y)-gradPhi{1}(x,y),@(x,y)-gradPhi{2}(x,y)};
    implCell_curve1 = {LevelSetFunctionAndGradient(phi,gradPhi)};
    loops_curve1{1}.curve = change_curve_orientation(loops_curve1{1}.curve);

    % 2nd curve
    CP2=[2.5,8,0,1;3.5,8,0,1;4.5,8,0,1;5,8,0,1/sqrt(2);5,7.5,0,1;5,7,0,1/sqrt(2); ...
        4.5,7,0,1;4,7,0,1;3.5,7,0,1;3,7,0,1/sqrt(2);3,6.5,0,1;3,6,0,1;3,5.5,0,1; ...
        3,5,0,1/sqrt(2);2.5,5,0,1;2,5,0,1/sqrt(2);2,5.5,0,1;2,6.5,0,1;2,7.5,0,1; ...
        2,8,0,1/sqrt(2);2.5,8,0,1];
    CP2(:,1) = CP2(:,1).*CP2(:,4);
    CP2(:,2) = CP2(:,2).*CP2(:,4);
    curve = nrbmak(CP2',[0, 0, 0, 0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, ...
        0.5, 0.5, 0.6, 0.6, 0.7, 0.7, 0.8, 0.8, 0.9, 0.9, 1, 1, 1]);    % p=2
    loops_curve2 = struct('curve',curve,'label',6);
    
    syms x y
    f_1(x,y) = 8-y;
    C=[4.5 7.5]; % position of the circle center
    f_2(x,y) = -((x-C(1)).^2 + (y-C(2)).^2 - R.^2);
    f_3(x,y) = y-7;
    C=[3.5 6.5]; % position of the circle center
    f_4(x,y) = (x-C(1)).^2 + (y-C(2)).^2 - R.^2;
    f_5(x,y) = 3-x;
    C=[2.5 5.5]; % position of the circle center
    f_6(x,y) = -((x-C(1)).^2 + (y-C(2)).^2 - R.^2);
    f_7(x,y) = x-2;
    C=[2.5 7.5]; % position of the circle center
    f_8(x,y) = -((x-C(1)).^2 + (y-C(2)).^2 - R.^2);
    x_range = [2.5,4.5;4.5,inf;3,4.5;2,3.5;2,inf;-inf,inf;-inf,3;-inf,2.5];
    y_range = [7,inf;7,8;-inf,8;6.5,7;5.5,6.5;-inf,5.5;5.5,7.5;7.5,inf];
    phi = @(x,y)geo_implicit_piecewise(x,y,{f_1,f_2,f_3,f_4,f_5,f_6,f_7,f_8}, ...
        x_range,y_range);
    df_1 = {diff(f_1,x),diff(f_1,y)}; df_2 = {diff(f_2,x),diff(f_2,y)};
    df_3 = {diff(f_3,x),diff(f_3,y)}; df_4 = {diff(f_4,x),diff(f_4,y)};
    df_5 = {diff(f_5,x),diff(f_5,y)}; df_6 = {diff(f_6,x),diff(f_6,y)};
    df_7 = {diff(f_7,x),diff(f_7,y)}; df_8 = {diff(f_8,x),diff(f_8,y)};
    grad = {@(x,y)geo_implicit_piecewise(x,y,{df_1{1},df_2{1},df_3{1}, ...
        df_4{1},df_5{1},df_6{1},df_7{1},df_8{1}},x_range,y_range), ...
        @(x,y)geo_implicit_piecewise(x,y,{df_1{2},df_2{2},df_3{2}, ...
        df_4{2},df_5{2},df_6{2},df_7{2},df_8{2}},x_range,y_range)};
    implCell_curve2 = {LevelSetFunctionAndGradient(phi,grad)};

    % 3rd curve
    CP3=[8,8,0,1;9,8,0,1;10,8,0,1;10.5,8,0,1/sqrt(2);10.5,7.5,0,1;10.5,7,0,1/sqrt(2); ...
        10,7,0,1;9,7,0,1;8,7,0,1;7.5,7,0,1/sqrt(2);7.5,7.5,0,1;7.5,8,0,1/sqrt(2); ...
        8,8,0,1];
    CP3(:,1) = CP3(:,1).*CP3(:,4);
    CP3(:,2) = CP3(:,2).*CP3(:,4);
    curve = nrbmak(CP3',[0, 0, 0, 0.25, 0.25, 0.375, 0.375, 0.5, 0.5, 0.75, ...
        0.75, 0.875, 0.875, 1, 1, 1]);    % p=2
    loops_curve3 = struct('curve',curve,'label',7);
    
    syms x y
    f_1(x,y) = 8-y;
    C=[10 7.5]; % position of the circle center
    f_2(x,y) = -((x-C(1)).^2 + (y-C(2)).^2 - R.^2);
    f_3(x,y) = y-7;
    C=[8 7.5]; % position of the circle center
    f_4(x,y) = -((x-C(1)).^2 + (y-C(2)).^2 - R.^2);
    x_range = [8,10;10,inf;8,10;-inf,8];
    y_range = [7,8;7,8;7,8;7,8];
    phi = @(x,y)geo_implicit_piecewise(x,y,{f_1,f_2,f_3,f_4}, ...
        x_range,y_range);
    df_1 = {diff(f_1,x),diff(f_1,y)}; df_2 = {diff(f_2,x),diff(f_2,y)};
    df_3 = {diff(f_3,x),diff(f_3,y)}; df_4 = {diff(f_4,x),diff(f_4,y)};
    grad = {@(x,y)geo_implicit_piecewise(x,y,{df_1{1},df_2{1},df_3{1}, ...
        df_4{1}},x_range,y_range), ...
        @(x,y)geo_implicit_piecewise(x,y,{df_1{2},df_2{2},df_3{2}, ...
        df_4{2}},x_range,y_range)};
    implCell_curve3 = {LevelSetFunctionAndGradient(phi,grad)};

    % collect all curves
    implCell = [implCell_lines,implCell_curve1,implCell_curve2,implCell_curve3];
    loops = {[loops_lines{:}],[loops_curve1{:}],loops_curve2,loops_curve3};

    sizeInterface = 2*9 + 2*13 + 2*pi*R + (2*pi*R + pi*R + 2 + 1 + 1 + 2) + ...
        (2*pi*R + 2 + 2);
    sizeInsideDomain = 9*13 - pi*R^2 - (2.5*1 + pi*R^2 + 1.5*1) - (pi*R^2 + 2*1);

    % plot option
    gridsteps_level_set = -2:0.5:14;

elseif InterfaceId == 45 % multiple connected curves

    syms x y
    % 1st curve
    P1 = [0.100000000000000,0.677200000000000];
	P2 = [0.166666666666667,0.660933333333333];
	P3 = [0.233333333333333,0.644133333333334];
    P4 = [0.300000000000000,0.636400000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve1 = struct('curve',curve,'label',1);
    phi1(x,y) = 1.2*x^3-0.4*x^2-0.2*x-y+0.7;   % polynomial p=3
    
    % 2nd curve
    P1 = [0.300000000000000,0.636400000000000];
	P2 = [0.433333333333333,0.612933333333333];
	P3 = [0.566666666666667,0.519066666666667];
    P4 = [0.700000000000000,0.303600000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve2 = struct('curve',curve,'label',2);
    phi2(x,y) = -0.8*x^3-0.6*x^2+0.4*x-y+0.592;   % polynomial p=3

    % 3rd curve
    P1 = [0.700000000000000,0.303600000000000];
	P2 = [0.766666666666667,0.311866666666667];
	P3 = [0.833333333333333,0.304400000000000];
    P4 = [0.900000000000000,0.274800000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve3 = struct('curve',curve,'label',3);
    phi3(x,y) = -0.8*x^3+0.5*x^2+0.6*x-y-0.087;   % polynomial p=3

    % 4th curve
    P1 = [0.900000000000000,0.274800000000000];
	P2 = [0.881555419146667,0.316533333333333];
	P3 = [0.860179605813333,0.358266666666667];
    P4 = [0.830966272480000,0.400000000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve4 = struct('curve',curve,'label',4);
    phi4(x,y) = (5*y^3)/2 - (3*y^2)/2 + (7*y)/10 + x - 18572237282289909/18014398509481984;   % polynomial p=3

    % 5th curve
    P1 = [0.830966272480000,0.400000000000000];
	P2 = [0.841566272480000,0.450000000000000];
    P3 = [0.856516272480000,0.500000000000000];
    P4 = [0.875478772480000,0.550000000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve5 = struct('curve',curve,'label',5);
    phi5(x,y) = y^3/10 - (7*y^2)/10 + (3*y)/10 + x - 30457529837860107/36028797018963968;   % polynomial p=3

    % 6th curve
    P1 = [0.875478772480000,0.550000000000000];
    P2 = [0.788124605813333,0.633333333333333];
    P3 = [0.694207939146667,0.716666666666667];
    P4 = [0.576541272480000,0.800000000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve6 = struct('curve',curve,'label',6);
    phi6(x,y) = (11*y^3)/10 - (3*y^2)/2 + (17*y)/10 + x - 13868756441975803/9007199254740992;   % polynomial p=3

    % 7th curve
    P1 = [0.576541272480000,0.800000000000000];
	P2 = [0.484360848320000,0.865835569803148];
	P3 = [0.392180424160000,0.838390726696527];
    P4 = [0.300000000000000,0.759962500000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve7 = struct('curve',curve,'label',7);
    phi7(x,y) = 2*x^3 + x^2/5 - (6804093125127299*x)/4503599627370496 + y - 6822392269792147/18014398509481984;   % polynomial p=3

    % 8th curve
    P1 = [0.300000000000000,0.759962500000000];
	P2 = [0.283333333333333,0.764312500000000];
	P3 = [0.266666666666667,0.771020833333334];
    P4 = [0.250000000000000,0.779875000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve8 = struct('curve',curve,'label',8);
    phi8(x,y) = -(17*x^3)/10 - (13*x^2)/10 + (3*x)/2 + y - 16753/16000;   % polynomial p=3

    % 9th curve
    P1 = [0.250000000000000,0.779875000000000];
    P2 = [0.200000000000000,0.749250000000000];
    P3 = [0.150000000000000,0.717500000000000];
    P4 = [0.100000000000000,0.677200000000000];
    curve = nrbmak([P1(1),P2(1),P3(1),P4(1);P1(2),P2(2),P3(2),P4(2)],[0 0 0 0 1 1 1 1]);
    loop_curve9 = struct('curve',curve,'label',9);
    phi9(x,y) = -(11*x^3)/5 + (9*x^2)/5 - (11*x)/10 + y - 583/1000;   % polynomial p=3
    
    x_range = [0,0.3;0.3,0.7;0.7,1;-inf,inf;-inf,inf;-inf,inf; ...
        0.3,0.576541272480000;0.25,0.3;0,0.25];
    y_range = [-inf,inf;-inf,inf;-inf,inf;-inf,0.4;0.4,0.55;0.55,1; ...
        -inf,inf;-inf,inf;-inf,inf];
    phi = @(x,y)geo_implicit_piecewise(x,y,{phi1,phi2,phi3,phi4,phi5,phi6, ...
        phi7,phi8,phi9}, ...
        x_range,y_range);
    dphi1 = {diff(phi1,x),diff(phi1,y)}; dphi2 = {diff(phi2,x),diff(phi2,y)};
    dphi3 = {diff(phi3,x),diff(phi3,y)}; dphi4 = {diff(phi4,x),diff(phi4,y)};
    dphi5 = {diff(phi5,x),diff(phi5,y)}; dphi6 = {diff(phi6,x),diff(phi6,y)};
    dphi7 = {diff(phi7,x),diff(phi7,y)}; dphi8 = {diff(phi8,x),diff(phi8,y)};
    dphi9 = {diff(phi9,x),diff(phi9,y)};
    grad = {@(x,y)geo_implicit_piecewise(x,y,{dphi1{1},dphi2{1},dphi3{1}, ...
        dphi4{1},dphi5{1},dphi6{1},dphi7{1},dphi8{1},dphi9{1}},x_range,y_range), ...
        @(x,y)geo_implicit_piecewise(x,y,{dphi1{2},dphi2{2},dphi3{2}, ...
        dphi4{2},dphi5{2},dphi6{2},dphi7{2},dphi8{2},dphi9{2}},x_range,y_range)};

    implCell = {LevelSetFunctionAndGradient(phi,grad)};
    loops = {[loop_curve1,loop_curve2,loop_curve3,loop_curve4,loop_curve5, ...
        loop_curve6,loop_curve7,loop_curve8,loop_curve9]};

    sizeInterface = 0.945114826075540 + 0.689887117824107 + 0.541069374353550;
    sizeInsideDomain = 0.373753803766412 + (1-0.576541272480000) * 0.8 - ...
        0.397866666666667 - 0.105437627898128 - (1-0.9) * 0.274800000000000;

elseif InterfaceId == 46    % two intersected circles

    C1 = [0.2,0.3];
    C2 = [0.2+d,0.3];
    R = 0.15;      % circle radius
    alpha = acos(d/(2*R));
    beta = pi/2-alpha;
    
    [phi1,gradPhi1,loop_curve1] = geo_circle(R,C1);
    implCell1 = {LevelSetFunctionAndGradient(phi1,gradPhi1)};
    
    if d~=0
        [phi2,gradPhi2,~] = geo_circle(R,C2);
        implCell2 = {LevelSetFunctionAndGradient(phi2,gradPhi2)};

        P1 = zeros(4,1); P2 = zeros(4,1); P3 = zeros(4,1); P4 = zeros(4,1);
        P1(1:2) = C1 + [d/2,R*sin(alpha)];
        P2(1:2) = C1 + [d/2-R*sin(alpha)/tan(beta),0];
        P3(1:2) = C1 + [d/2,-R*sin(alpha)];
        P4(1:2) = C1 + [d/2+R*sin(alpha)/tan(beta),0];
        P1(4) = 1; P2(4) = cos(alpha); P3(4) = 1; P4(4) = cos(alpha);
        % homogenous coordinates (x = x/w)
        P1(1:3) = P1(1:3).*P1(4);
        P2(1:3) = P2(1:3).*P2(4);
        P3(1:3) = P3(1:3).*P3(4);
        P4(1:3) = P4(1:3).*P4(4);
        curve1 = nrbmak([P1(1),P2(1),P3(1);P1(2),P2(2),P3(2);P1(3),P2(3),P3(3); ...
            P1(4),P2(4),P3(4)],[0 0 0 1 1 1]);    % p=2
        curve2 = nrbmak([P3(1),P4(1),P1(1);P3(2),P4(2),P1(2);P3(3),P4(3),P1(3); ...
            P3(4),P4(4),P1(4)],[0 0 0 1 1 1]);    % p=2
        loop_curve1 = struct('curve',curve1,'label',1);
        loop_curve2 = struct('curve',curve2,'label',2);
    end

    if d==0
        implCell = implCell1;
        loops = loop_curve1;
    else
        implCell = [implCell1,implCell2];
        loops = {[loop_curve1,loop_curve2]};
    end

    sizeInterface = 2*pi*2*alpha;
    sizeInsideDomain =  2*R^2/2*(2*alpha-sin(2*alpha)); % twice the area of the circular segment

else
    error("getInterfaceCase2D Interface case %i not known!", InterfaceId )
end

% define output
interface = Interface( implCell, loops, sizeInterface, sizeInsideDomain);

%% plot situation
% % plot parametric interfaces
% if ~exist('d','var')    % only new figure if it is not a moving example
%     figure()	% such it creates a new figure even if this function is not called as first function
% end
% hold on
% for i = 1 : length(loops)
%     plot_domain(loops{i},50)
% end
% 
% % plot implicit interfaces
% plot_level_set( implCell, gridsteps_level_set, [0,-0.1] );

end