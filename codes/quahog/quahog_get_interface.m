function [CPWmat,n_quad_rational] = quahog_get_interface(objTest,integrand_degree)
% Function contains parts from "extract_my_format_from_NURBS.m"
% which is part of the Quahog code. However, the function from
% the Quahog code cannot be used directly because the function
% "Extract_Basis_1D.m", which is used therein, is missing.

n_bounds = length(objTest.interface.parametric);
interface_parametric = objTest.interface.parametric;    % not a handle
CP = cell(n_bounds,1);
W = cell(n_bounds,1);
Xi = cell(n_bounds,1);  % knot vector
n_quad_rational = 0;
for ibound = 1:n_bounds
    
    n_curves = length(interface_parametric{ibound});
    degree_temp = zeros(n_curves,1);
    % check for degree and inner knots
    for icurve = 1:n_curves
        curve = interface_parametric{ibound}(icurve).curve;
        degree_temp(icurve) = curve.order-1; % in nurbs-1.4.3, the order is defined to be p+1
        % check for inner knots
        if length(curve.knots)~=2*(curve.order)
            m = 1;
            R = [];
            for iu = curve.order+1:length(curve.knots)-curve.order
                if curve.knots(iu)==curve.knots(iu+1)
                    m = m+1;
                else
                    R = [R;ones(curve.order-m-1)*curve.knots(iu)]; %#ok<AGROW>
                    m = 1;
                end
            end
            interface_parametric{ibound}(icurve).curve = nrbkntins(curve,R);
        end
    end
    % check whether order elevation is needed for one of the
    % curves
    degree_max = max(degree_temp);
    for icurve = 1:n_curves
        if degree_temp(icurve)~=degree_max
            interface_parametric{ibound}(icurve).curve = nrbdegelev(interface_parametric{ibound}(icurve).curve,degree_max-degree_temp(icurve));
        end
    end

    % connect curves if multiple
    if n_curves==1
        CP{ibound} = interface_parametric{ibound}(icurve).curve.coefs(1:2,:);
        W{ibound} = interface_parametric{ibound}(icurve).curve.coefs(4,:);
        Xi{ibound} = interface_parametric{ibound}(icurve).curve.knots;
    else
        for icurve = 1:n_curves
            if icurve==1
                CP_temp = interface_parametric{ibound}(icurve).curve.coefs;
                Xi_temp = interface_parametric{ibound}(icurve).curve.knots(1:end);
            elseif icurve==n_curves
                CP_temp = interface_parametric{ibound}(icurve).curve.coefs(:,1:end);
                Xi_temp = interface_parametric{ibound}(icurve).curve.knots(degree_max+2:end) + icurve; % this is assuming that all knot spans go from 0 to 1
            else
                CP_temp = interface_parametric{ibound}(icurve).curve.coefs(:,1:end);
                Xi_temp = interface_parametric{ibound}(icurve).curve.knots(degree_max+2:end) + icurve; % this is assuming that all knot spans go from 0 to 1
            end
            CP{ibound} = [CP{ibound} CP_temp(1:2,:)];
            W{ibound} = [W{ibound} CP_temp(4,:)];
            Xi{ibound} = [Xi{ibound} Xi_temp];
        end
    end

    % determine number of quadrature points for rational quadrature rule
    % for intermediate quadrature (only used in case of SPECTRALPE)
    if integrand_degree~=-1 % input of -1 if it should not be computed
        n_quad_rational = n_quad_rational + n_curves*(degree_max*(integrand_degree+3)+1);
    end

end % bounds

% obtain proper format for interface description
CPWmat=cell(1,length(CP));
for segment=1:length(CP)    % segment refers in the Quahog code to bounds
    p=length(Xi{segment})-length(W{segment})-1;
    [n_el,IEN2] = quahog_extract_basis_1D(p,Xi{segment});
    CPWmat{segment}=zeros(n_el*3,p+1);
    for i=1:n_el
        CPWmat{segment}(3*i,:)=W{segment}(:,IEN2(:,i));
        CPWmat{segment}(((i-1)*3+1):(3*i-1),:)=CP{segment}(:,IEN2(:,i)); % homogenous coordinates, the same as the "nurbs-1.4.3 curve" CP
    end
end

end