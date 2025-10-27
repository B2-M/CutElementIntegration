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

function obj = getTestCase3D( testCaseId )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

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
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = prod(xmax-xmin) - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref, testCaseId);

elseif testCaseId == 2

    % define integration domain
    xmin = [-1.4,-1.4,-1.4];
    xmax =  [1.4,1.4,1.4];
    n_refs = 0;
    domain = Domain(xmin, xmax, n_refs);

    % define interface
    InterfaceId = 3;
    interface = getInterfaceCase3D( InterfaceId );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = prod(xmax-xmin) - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref, testCaseId);

elseif testCaseId == 3

    % define integration domain
    xmin = [-0.6,-0.6,0];
    xmax =  [0.65,0.65,1.0];
    n_refs = 0;
    domain = Domain(xmin, xmax, n_refs);

    % define interface
    InterfaceId = 4;
    interface = getInterfaceCase3D( InterfaceId );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = prod(xmax-xmin) - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref, testCaseId);

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
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = prod(xmax-xmin) - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref, testCaseId);    

else
    error("Test case %i is not known.", testCaseId )
end

end