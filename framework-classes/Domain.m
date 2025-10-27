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

classdef Domain
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess=private)
        dim
        xmin (1,:) double {mustBeReal, mustBeFinite}
        xmax (1,:) double {mustBeReal, mustBeFinite}
    end

    properties
        n_refs (1,1) % number of dyadic refinements
    end

    methods
        
        function obj = Domain( xmin, xmax, n_refs )

            % check input
            if size(xmin) ~= size(xmax)
                 error("Error: dimensions of lower and upper domain ends do not match!")
            end
            for i = 1:length(xmin)
                if xmin(i) > xmax(i)
                    error("Error in direction $i: upper bound is higher than the lower on [%f,%f]", i, xmin(1),  xmax(2) )
                end
            end

            % set properties
            obj.dim = length(xmin);
            obj.xmin = xmin;
            obj.xmax = xmax;
            obj.n_refs = n_refs;
        end

        function origin = getOrigin( objDomain )
            origin = objDomain.xmin;
        end

        function domain_lengths = getDomainLengths( objDomain )
            domain_lengths = objDomain.xmax - objDomain.xmin;
        end

        function elem_domains = getElementDomains( objDomain )   
         
            origin = getOrigin( objDomain );
            n_elem = objDomain.getNumberOfElementsPerDirection;
            elem_lengths = objDomain.getElementLengths;
            if objDomain.dim == 2
                elem_domains = objDomain.getElementDomains2D(n_elem, origin, elem_lengths);
            elseif objDomain.dim == 3
                elem_domains = objDomain.getElementDomains3D(n_elem, origin, elem_lengths);
            else
                error("getElementDomains not supported for dim %i", objDomain.dim )
            end

        end

        function elem_lengths = getElementLengths( objDomain )
            n_elem = objDomain.getNumberOfElementsPerDirection;
            domain_lengths = objDomain.xmax - objDomain.xmin;
            elem_lengths = domain_lengths./n_elem;
        end

        function n_elem = getNumberOfElementsPerDirection( objDomain )
            n_elem = 2^objDomain.n_refs;
        end


    end

    methods(Access = private)

        function elem_domains = getElementDomains2D( this, n_elem, origin, elem_lengths) 

            count = 1;
            elem_domains(n_elem) = struct();
            for j = 0 : n_elem-1

                y_min = origin(2) + j * elem_lengths(2);
                y_max = y_min + elem_lengths(2);

                for i = 0 : n_elem-1

                    x_min = origin(1) + i * elem_lengths(1);
                    x_max = x_min + elem_lengths(1);

                    % element domains
                    elem_domains(count).min = [x_min,y_min];
                    elem_domains(count).max = [x_max,y_max];
                    count = count + 1;

                end
            end

        end

        function elem_domains = getElementDomains3D( this, n_elem, origin, elem_lengths) 

            count = 1;
            elem_domains(n_elem) = struct();
            for k = 0 : n_elem-1

                z_min = origin(3) + k * elem_lengths(3);
                z_max = z_min + elem_lengths(3);

                for j = 0 : n_elem-1

                    y_min = origin(2) + j * elem_lengths(2);
                    y_max = y_min + elem_lengths(2);

                    for i = 0 : n_elem-1

                        x_min = origin(1) + i * elem_lengths(1);
                        x_max = x_min + elem_lengths(1);

                        % element domains
                        elem_domains(count).min = [x_min,y_min,z_min];
                        elem_domains(count).max = [x_max,y_max,z_max];
                        count = count + 1;

                    end
                end
            end

        end
    end
end