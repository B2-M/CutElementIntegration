function objIntegrator = callIntegratorConstructor(name,n_quad_pts,add_settings)
% function objIntegrator = callIntegratorConstructor(name,n_quad_pts,add_settings)
%
% Description:
% General constructor call valid for all Integrators.
%
% Input:
%	name:		name of Integrator (e.g. "Fcmlab") 
%	n_quad_pts:	number of quadrature points
%	add_settings:	additional settings needed to call specific constructors; 
%					differs for each Integrator

n_quad_pts_green = [];
SpaceTreeDepth = [];
reparam_degree = [];
ndivisions = [];

% value assignment
if nargin > 2 && ~isempty(add_settings)
    if isfield(add_settings,'n_quad_pts_green')
        n_quad_pts_green = add_settings.n_quad_pts_green;
    end    
    if isfield(add_settings,'reparam_degree')
        reparam_degree = add_settings.reparam_degree;
    end    
    if isfield(add_settings,'SpaceTreeDepth')
        SpaceTreeDepth = add_settings.SpaceTreeDepth;
    end 
    if isfield(add_settings,'ndivisions')
        ndivisions = add_settings.ndivisions;
    end
end

className = strcat(string(name), "Integrator");  % Convert integrator name to class name (e.g., "Fcmlab" -> "FcmlabIntegrator")
className = char(className);  % Convert back to char for compatibility


if strcmp(className,'FcmlabIntegrator') || strcmp(className,'NutilsIntegrator')
    if isempty(SpaceTreeDepth)
        objIntegrator = feval(className,n_quad_pts);
    elseif isempty(ndivisions) || strcmp(className,'FcmlabIntegrator')
        objIntegrator = feval(className,n_quad_pts,SpaceTreeDepth);
    else
        objIntegrator = feval(className,n_quad_pts,SpaceTreeDepth,ndivisions);
    end
elseif strcmp(className,'QuahogIntegrator')
    if isempty(n_quad_pts_green)
        objIntegrator = feval(className,n_quad_pts);
    else
        objIntegrator = feval(className,n_quad_pts,n_quad_pts_green);
    end
elseif strcmp(className,'QUGaRIntegrator') || strcmp(className,'AlgoimIntegrator') || ...
        strcmp(className,'BoSSSIntegrator') || strcmp(className,'NgsxfemIntegrator')
    if isempty(reparam_degree)
        objIntegrator = feval(className,n_quad_pts);
    else
        objIntegrator = feval(className,n_quad_pts,reparam_degree);
    end
% elseif strcmp(className,'GridapIntegrator') || strcmp(className,'MlhpIntegrator')...
%         || strcmp(className,'NgsxfemIntegrator') ...
%         || strcmp(className,'QuahogPEIntegrator') || strcmp(className,'QuesoIntegrator')
%     objIntegrator = feval(className,n_quad_pts);    
else
    objIntegrator = feval(className,n_quad_pts);
end

end