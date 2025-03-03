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

classdef Interface
    % This class provides the interface curve that intersects a 2D domain.
    %
    % Example call: see getInterfaceCase2D.m or getInterfaceCase3D.m
    %
    % Properties:
    % implicit... cell of implicitly defined interface (see LevelSetFunctionAndGradient)
    % parametric... Cells of parametric loops consisting of curves defined by the nurbs tool box
    %               Each cell corresponds to a boundary consisting of a
    %               struct array corresponding to connected curves.
    % domainGamma... size of the interface
    % domainEnclosed... size of the domain enclosed by the interface (independent of its orientation)

    properties(SetAccess = private)
        dim
        implicit
        parametric
        domainGamma (1,1) double {mustBeReal, mustBeFinite}
        domainEnclosed (1,1) double {mustBeReal, mustBeFinite}
    end

    methods
        function obj = Interface(implicit, parametric, domainGamma, domainEnclosed)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here

            % check input
            if ~isa(implicit,"cell")
                error("Error: The first input must be a cell of loop object; not a %s.", class(parametric))
            else
                dim = zeros(length(implicit),1);
                for i = 1 : length(implicit)
                    dim(i) = implicit{i}.dim;
                    if ~isa(implicit{i},"LevelSetFunctionAndGradient")
                        error("Error: The first input cell must contain LevelSetFunctionAndGradient object; not a %s.", class(implicit))
                    end
                end
            end     
            dim = unique(dim);
            if length(dim) > 1
               error("Error: Inconsistent dimension of the LevelSetFunctionAndGradient objects.")
            end
            if dim == 2
                iType = 'curve';
            elseif dim == 3
                iType = 'surf';
            else
                error("Error: Dimension %i is not supported.",dim)
            end
            if ~isa(parametric,"cell")
                error("Error: The second input must be a cell of loop object; not a %s.", class(parametric))
            else
                for i = 1 : length(parametric)
                    names = fieldnames(parametric{i});
                    if ~any(strcmpi(names,iType))
                        error("Error: The second input must contain a %s definition within the loop struct.",iType)
                    end
                end
            end

            % set properties
            obj.dim = dim;
            obj.implicit = implicit;
            obj.parametric = parametric;
            obj.domainGamma = domainGamma;
            obj.domainEnclosed = domainEnclosed;
        end
    end
end