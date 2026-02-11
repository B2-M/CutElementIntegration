clear all
close all
clc

% this is a trivial script to test if bosss-matlab interface works
% it supplies the 2d circle case explicitly. For more details, take a look
% at BoSSSIntegrator.m or .\experimental\public\src\L4-application\MatlabCutCellQuadInterface

%% Test BoSSS External Binding
dotnetenv("core"); %change the .NET environment to the core (which is cross platform)

pstr = fullfile(pwd + "\codes\bosss\repository\src\L4-application\MatlabCutCellQuadInterface\bin\Release\net6.0\BoSSS.Application.MatlabCutCellQuadInterface.dll");
pstr2 = fullfile(pwd + "\codes\bosss\repository\src\L4-application\MatlabCutCellQuadInterface\bin\Release\net6.0\BoSSS.Foundation.XDG.dll");

NET.addAssembly(pstr);

% Create an instance of class
caller = BoSSS.Application.ExternalBinding.MatlabCutCellQuadInterface.MatlabCutCellQuadInterface;

%Initialize
caller.BoSSSInitialize;

% define level set functions
R=0.2;      % circle radius
C=[0.5 0.49]; % position of the circle center
sizeInterface = pi()*R*2;
sizeInsideDomain =  pi()*R.^2;
[phi,gradPhi,loops] = geo_circle(R,C);
phi = @(x, y) phi(x,y) ;
R=0.20;      % circle radius
% C=[0.3 0.5]; % position of the circle center
% [phi2,gradPhi2,loops2] = geo_circle(R,C);

% set domain
dim =int32(2); 
nodes =[ 0, 0.25, 0.5, 0.75, 1]; %[ 0, 0.5, 1 ];  %  %nodes = [ 0, 0.25, 0.5, 0.75, 1];
caller.SetDomain(dim,nodes,nodes)

% set level set (can be called multiple times with different functions)
caller.Submit2DLevelSet(phi)
%caller.Submit2DLevelSet(phi2)

% project level set
caller.ProjectLevelSetWithGaussAndStokes(3)

% plot the case for debugging
%caller.PlotCurrentState(3)

% compile the quadrature rule
caller.CompileQuadRules(3, 1); %% (degree, phaseIndicator)
a=0;
ret=[];
for e =1 : (length(nodes)-1) * (length(nodes)-1)
    quadData = caller.GetQuadRules(e-1, 1); %% (element number, phaseIndicator) : element number is in c index (starting from 0)
    if isempty (quadData) 
        continue
    end
    % transfer data into the matlab format
    numberOfNodes = quadData.Lengths(1);
    dArray = quadData.Storage;
    quadMtx = zeros(numberOfNodes,3);
    

    for n= 1:numberOfNodes
        quadMtx(n,:) = [dArray(3*n-2) dArray(3*n-1) dArray(3*n)];
        a= a + dArray(3*n);
    end
ret = [ret; quadMtx];
end



tquadMtx = quadMtx';

% ret = N×3: [x y w], phi = @(x,y) …   % level‐set φ=0

% 1) Extract and scale
x     = ret(:,1);
y     = ret(:,2);
w     = ret(:,3);
Smax  = 100;
sizes = (abs(w) ./ max(abs(w))) * Smax;

% 2) Logical indices
pos = w>0;
neg = ~pos;

% 3) Plot
% Define 1D nodes
nodes = [0, 0.5, 1];

% Create 2D grid
[X,Y] = meshgrid(nodes, nodes);

figure; hold on
lw = 2;   % line width for all lines

% Draw all grid lines (including borders) with the same bold line
for k = nodes
    % horizontal lines
    plot([nodes(1), nodes(end)], [k, k], 'k-', 'LineWidth', lw);
    % vertical lines
    plot([k, k], [nodes(1), nodes(end)], 'k-', 'LineWidth', lw);
end


scatter(x, y, Smax*1.01, 'o', ...
    'MarkerEdgeColor','k', ...    % black outline
    'LineWidth',1.5);             % thicker lines

h1 = scatter(x(pos), y(pos), sizes(pos), 'r', 'filled');
h2 = scatter(x(neg), y(neg), sizes(neg), 'b', 'filled');
fimplicit(phi, 'k', 'LineWidth', 1.5);

% xlim([0 1])
% ylim([0 1])

% 4) Formatting
axis equal; grid on
xlabel('x'); ylabel('y')
title('Quadrature nodes (size ∝ |w|, color by sign)', 'FontSize', 18, 'FontWeight', 'bold');
legend([h1 h2], {'w>=0','w<0'}, 'Location','best')




fprintf ("Analytical Result=%f, BoSSS Result=%f, Rel Err=%f\n",sizeInsideDomain,a,abs((sizeInsideDomain-a)/sizeInsideDomain))



%% functions

function result = myMatlabFunc(x, y)
    result = x + y; % Just an example operation
    disp(['MATLAB function called with values: ', num2str(x), ', ', num2str(y)]);
end

function result = myMatlabFunc3D(x, y,z)
    result = x + y + z; % Just an example operation
    disp(['MATLAB function called with values: ', num2str(x), ', ', num2str(y)]);
end

function [circle,gradCircle,loops] = geo_circle(R, C)

    % implicit definition of the circle
    % % circle= @(x,y) sqrt((x-C(1)).^2 + (y-C(2)).^2) - R.^2;
    % % gradCircle = {...
    % %     @(x,y) (x-C(1)) ./ sqrt( (x-C(1)).^2 + (y-C(2)).^2), ...
    % %     @(x,y) (y-C(2)) ./ sqrt( (x-C(1)).^2 + (y-C(2)).^2)
    % %     };    
    circle= @(x,y) -((x-C(1)).^2 + (y-C(2)).^2 - R.^2);
    gradCircle = { ...
        @(x,y) 2 * ( x - C(1) ), ...
        @(x,y) 2 * ( y - C(2) ) 
        };

    % parametric definition of the circle
    loop_0 = struct();
    loops = {loop_0};

end