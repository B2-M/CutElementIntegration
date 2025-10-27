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

function obj = getTestCase2D( testCaseId, d )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if~exist('d','var')
    d=0;
end

if testCaseId == 1

    % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 1;
    interface = getInterfaceCase2D( InterfaceId );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;


    obj = TestCase(domain, interface, ref);

elseif testCaseId == 2

    % define integration domain
    x_min = [-0.1,-0.1];
    x_max = [1.6,1.6];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 3;
    interface = getInterfaceCase2D( InterfaceId );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = prod(x_max - x_min) - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif testCaseId == 3

    % define integration domain
    shift = 10^-10; % needed since edufem crashes when node is at zero level set
    x_min = [0.0+shift ,0.0+shift ];
    x_max = [2.0,2.0];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 4;
    interface = getInterfaceCase2D( InterfaceId );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = prod(x_max - x_min) - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);


elseif any(testCaseId==(4:7)) 
%Moving Cases
     % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    if testCaseId==4
        InterfaceId = 5;
    elseif testCaseId==5
        InterfaceId = 6;
    elseif testCaseId==6
        InterfaceId = 7;
    elseif testCaseId==7
        InterfaceId = 8;
    end
    interface = getInterfaceCase2D( InterfaceId,d );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

 elseif testCaseId == 8
 %SemiCircle
     % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 9;
    interface = getInterfaceCase2D( InterfaceId,d );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif any(testCaseId==(9:34))  % basic test suite of UniBw Munich

    % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    if testCaseId == 9  % UniBw Munich test case 3
        InterfaceId = 10;
    elseif testCaseId == 10  % UniBw Munich test case 4
        InterfaceId = 11;
    elseif testCaseId == 11  % UniBw Munich test case 5
        InterfaceId = 12;
    elseif testCaseId == 12  % UniBw Munich test case 6
        InterfaceId = 13;
    elseif testCaseId == 13  % UniBw Munich test case 7
        InterfaceId = 14;
    elseif testCaseId == 14  % UniBw Munich test case 8
        InterfaceId = 15;
    elseif testCaseId == 15  % UniBw Munich test case 9
        InterfaceId = 16;
    elseif testCaseId == 16 % UniBw Munich test case 10
        InterfaceId = 17;
    elseif testCaseId == 17 % UniBw Munich test case 11
        InterfaceId = 18;
    elseif testCaseId == 18 % UniBw Munich test case 12
        InterfaceId = 19;
    elseif testCaseId == 19 % UniBw Munich test case 13
        InterfaceId = 20;
    elseif testCaseId == 20 % UniBw Munich test case 14
        InterfaceId = 21;
    elseif testCaseId == 21 % UniBw Munich test case 16 (case number 15 does not exist in this test suite)
        InterfaceId = 22;
    elseif testCaseId == 22 % UniBw Munich test case 17
        InterfaceId = 23;
    elseif testCaseId == 23 % UniBw Munich test case 18
        InterfaceId = 24;
    elseif testCaseId == 24 % UniBw Munich test case 19
        InterfaceId = 25;
    elseif testCaseId == 25 % UniBw Munich test case 20
        InterfaceId = 26;
    elseif testCaseId == 26 % UniBw Munich test case 21
        InterfaceId = 27;
    elseif testCaseId == 27 % UniBw Munich test case 22
        InterfaceId = 28;
    elseif testCaseId == 28 % UniBw Munich test case 23
        InterfaceId = 29;
    elseif testCaseId == 29 % UniBw Munich test case 24
        InterfaceId = 30;
    elseif testCaseId == 30 % UniBw Munich test case 25
        InterfaceId = 31;
    elseif testCaseId == 31 % UniBw Munich test case 26
        InterfaceId = 32;
    elseif testCaseId == 32 % UniBw Munich test case 27
        InterfaceId = 33;
    elseif testCaseId == 33 % UniBw Munich test case 105
        InterfaceId = 34;
    elseif testCaseId == 34 % UniBw Munich test case 106
        InterfaceId = 35;
    end
    interface = getInterfaceCase2D( InterfaceId );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);
    
elseif testCaseId==35   % ellipse
    
    % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 36;
    interface = getInterfaceCase2D( InterfaceId );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif any(testCaseId==(36:38))

     % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    if testCaseId==36       % moving, cusp
        InterfaceId = 37;
    elseif testCaseId==37   % one element intersected four times by same curve
        InterfaceId = 38;
    elseif testCaseId==38   % shrinking square
        InterfaceId = 39;
    end
    interface = getInterfaceCase2D( InterfaceId,d );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif any(testCaseId==(39:41)) % example from Saye (2022), sec. 4.4

     % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    if testCaseId==39       % two squares
        InterfaceId = 40;
    elseif testCaseId==40   % two squares slightly curved, almost touching
        InterfaceId = 41;
    elseif testCaseId==41   % two squares more curved
        InterfaceId = 42;
    end
    interface = getInterfaceCase2D( InterfaceId);

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif testCaseId==42 % example with inner knot in parametric trimming curve

     % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 43;
    interface = getInterfaceCase2D( InterfaceId);

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif testCaseId==43 % punched plate

     % define integration domain
    x_min = [-1,-1];
    x_max = [14,10];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 44;
    interface = getInterfaceCase2D( InterfaceId);

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif testCaseId==44 % multiple connected curves

     % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 45;
    interface = getInterfaceCase2D( InterfaceId);

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);

elseif testCaseId==45   % moving case

     % define integration domain
    x_min = [0,0];
    x_max = [1,1];
    n_refs = 0;
    domain = Domain(x_min, x_max, n_refs);

    % define interface
    InterfaceId = 46;
    interface = getInterfaceCase2D( InterfaceId,d );

    % reference solution
    ref = struct();
    ref.exact_inside = interface.domainEnclosed;
    ref.exact_outside = 1 - interface.domainEnclosed;
    ref.exact_interface = interface.domainGamma;

    obj = TestCase(domain, interface, ref);
else
    error("Test case %i is not known.", testCaseId )
end

%% plot situation
% hold on
% plot_mesh(domain)

end