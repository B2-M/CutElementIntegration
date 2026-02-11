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

close all
clear
clc

resolution = 50;
[Px,Py] = meshgrid(linspace(0,1,resolution),linspace(0,1,resolution));

% Plot integrands
syms x y

integrand(x,y) = 2*x^2 + x*y - y + 2;   % first polynomial from Gunderman
% et al. (2021)
figure()
surf(Px,Py,eval(integrand(Px,Py)))

integrand(x,y) = 2*x^2*y^2 + 3/10*x^2*y - y^4 + 3*x + 2;   % third polynomial 
% from Gunderman et al. (2021)
figure()
surf(Px,Py,eval(integrand(Px,Py)))

integrand(x,y) = x^5 - 5*y^3*x^3 + 2*y*x^2 + 1/5*x^2 + 3;   % third polynomial 
% from Gunderman et al. (2021)
figure()
surf(Px,Py,eval(integrand(Px,Py)))
xlabel('x')
ylabel('y')

integrand(x,y) = x^5 + 2 * y^5 - 5*y^3*x^3 + 2*y*(x-1.5)^2 + 5*x^2 + 3;   % third polynomial 
figure()
surf(Px,Py,eval(integrand(Px,Py)))
xlabel('x')
ylabel('y')

% integrand(x,y) = 10*x.^5.*y.^5 ...
%     - 8*x.^4.*y.^3 ...
%     + 6*x.^3.*y.^4 ...
%     - 4*x.^2.*y.^5 ...
%     + 5*x.^5.*y.^2 ...
%     + 7*x.^4.*y.^4 ...
%     - 9*x.^3.*y.^3 ...
%     + 3*x.^2.*y.^2 ...
%     - 2*x.*y ...
%     + x.^5 ...
%     + y.^5 ...
%     - 12*x.^2.*y.^3 ...
%     + 11*x.^3.*y.^2 ...
%     + 13*x.^4.*y ...
%     - 14*x.*y.^4 ...
%     + 6*x.^2 ...
%     - 5*y.^2;
% figure()
% surf(Px,Py,eval(integrand(Px,Py)))
% xlabel('x')
% ylabel('y')