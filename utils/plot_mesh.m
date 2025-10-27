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

function plot_mesh(domain,varargin)
% plot_mesh(domain,varargin)
%
% Plot the backgroundmesh for 2D or 3D domain.
%
% Input:
%   domain:     Object of class Domain
%   varargin:   further plot settings

n_ele = getNumberOfElementsPerDirection( domain );

x = linspace(domain.xmin(1),domain.xmax(1),n_ele+1);
y = linspace(domain.xmin(2),domain.xmax(2),n_ele+1);
    
if domain.dim==2
    
    % lines in x-direction
    for i = 1:n_ele+1
        plot([x(1),x(end)],[y(i),y(i)],'k',varargin{:})
        hold on
    end

    % lines in y-direction
    for i = 1:n_ele+1
        plot([x(i),x(i)],[y(1),y(end)],'k',varargin{:})
        hold on
    end

elseif domain.dim==3

    z = linspace(domain.xmin(3),domain.xmax(3),n_ele+1);
    
    % lines in x-direction
    for i = 1:n_ele+1
        for j = 1:n_ele+1
            plot3([x(1),x(end)],[y(i),y(i)],[z(j),z(j)],'k',varargin{:})
            hold on
        end
    end
    
    % lines in y-direction
    for i = 1:n_ele+1
        for j = 1:n_ele+1
            plot3([x(i),x(i)],[y(1),y(end)],[z(j),z(j)],'k',varargin{:})
            hold on
        end
    end    
    
    % lines in z-direction
    for i = 1:n_ele+1
        for j = 1:n_ele+1
            plot3([x(i),x(i)],[y(j),y(j)],[z(1),z(end)],'k',varargin{:})
            hold on
        end
    end

end