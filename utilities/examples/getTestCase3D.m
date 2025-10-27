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

function obj = getTestCase3D(testCaseId,add_var)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
arguments
    testCaseId
    add_var.integrand = []
end

% set default integrand
syms x y z
syms integrand(x,y,z)
if isempty(add_var.integrand)
    integrand(x,y,z) = 1;
elseif isa(add_var.integrand,'symfun')
    integrand = add_var.integrand;
end

if testCaseId == 1  % ellipsoid

    % define integration domain
    xmin = [-1.1,-1.1,-1.1];
    xmax =  [1.1,1.1,1.1];
    n_refs = 0;
    domain = Domain(xmin, xmax, n_refs);

    % define interface
    InterfaceId = 1;
    interface = getInterfaceCase3D( InterfaceId );

    % reference solution
    ref = get_reference_solution(interface,integrand,domain);

elseif testCaseId == 2  % torus

    % define integration domain
    xmin = [-1.4,-1.4,-1.4];
    xmax =  [1.4,1.4,1.4];
    n_refs = 0;
    domain = Domain(xmin, xmax, n_refs);

    % define interface
    InterfaceId = 3;
    interface = getInterfaceCase3D( InterfaceId );

    % reference solution
    ref = get_reference_solution(interface,integrand,domain);

elseif testCaseId == 3  % elliptic cylinder

    % define integration domain
    xmin = [-0.6,-0.6,0];
    xmax =  [0.65,0.65,1.0];
    n_refs = 0;
    domain = Domain(xmin, xmax, n_refs);

    % define interface
    InterfaceId = 4;
    interface = getInterfaceCase3D( InterfaceId );

    % reference solution
    ref = get_reference_solution(interface,integrand,domain);

elseif testCaseId == 4  % rotated cube

    % define integration domain
    xmin = [-0.51,-0.51,-0.51];
    xmax =  [0.51,0.51,0.51];
    n_refs = 0;
    domain = Domain(xmin, xmax, n_refs);

    % define interface
    InterfaceId = 5;
    interface = getInterfaceCase3D( InterfaceId );

    % reference solution
    ref = get_reference_solution(interface,integrand,domain);

elseif testCaseId == 5 % cylinder with arbitrary integrand

    % define integration domain
    xmin = [-0.6,-0.6,0];
    xmax =  [0.65,0.65,1.0];
    n_refs = 0;
    domain = Domain(xmin, xmax, n_refs);

    % define interface
    InterfaceId = 4;
    interface = getInterfaceCase3D( InterfaceId );

%     % define integrand
%     integrand(x,y,z) = x^2 - 3*x*y + z/3;   % function from Gunderman et al. (2021, 3D)

    % reference solution
    ref = get_reference_solution(interface,integrand,domain);

else
    error("Test case %i is not known.", testCaseId )
end

% generate TestCase object
obj = TestCase(domain, interface, ref, testCaseId, integrand);   

end % function: getTestCase3D

%-------------------------------------
% local helper functions
function ref = get_reference_solution(interface,integrand,domain)

    ref = struct();
    if integrand==1
        ref.exact_inside = interface.domainEnclosed;
        ref.exact_outside = prod(domain.xmax - domain.xmin) - interface.domainEnclosed;
        ref.exact_interface = interface.domainGamma;
    elseif isa(integrand,'symfun') % arbitrary integrand
        ref.exact_inside = double(getReferenceIntegral3D(interface.id,integrand));
        ref.exact_outside = -1;     % not applicable
        ref.exact_interface = -1;   % not applicable
    else
        error(['Format of integrand is not accepted. Please provide a symbolic ' ...
            'function.'])
    end

end