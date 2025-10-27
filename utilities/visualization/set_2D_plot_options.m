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

function [flag_plot_error,flag_plot_points] = set_2D_plot_options(varargin)

%% varargin options:
    % plot options:
    %   PlotError = 'on','off'
    %   PlotPoints = 'on','off'

flag_plot_error = true;
flag_plot_points = true;
if nargin > 0
    for i = 1:2:length(varargin)
        if ischar(varargin{i})
            if strcmpi(varargin{i},'PlotPoints')
                if strcmp(varargin{i+1},'off')
                    flag_plot_points = false;
                end            
            elseif strcmpi(varargin{i},'PlotError')
                if strcmp(varargin{i+1},'off')
                    flag_plot_error = false;
                end
            end
        end 
    end
end


end