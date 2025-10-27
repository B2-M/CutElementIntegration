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

classdef QuadratureData
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        trimmed_elem_pts        % trimmed elements
        non_trimmed_elem_pts    % active, untrimmed elements
        interface_pts
    end

    properties(SetAccess=private)
        dim  (1,1)
        nb_trimmed_elems (1,1)
        nb_trimmed_elems_pts (1,1)
        nb_non_trimmed_elems (1,1)
        nb_non_trimmed_elems_pts (1,1)
        nb_interfaces (1,1)
        nb_interfaces_pts (1,1)
    end


    methods

        %------------------------------------
        function obj = QuadratureData( dim )           
            % set properties
            obj.dim = dim;

            % initialize empty data structs
            obj.nb_trimmed_elems = 0;
            obj.nb_non_trimmed_elems = 0;
            obj.nb_trimmed_elems_pts = 0;
            obj.nb_non_trimmed_elems_pts = 0;
            obj.trimmed_elem_pts = struct([]);
            obj.non_trimmed_elem_pts = struct([]);
            obj.nb_interfaces = 0;
            obj.nb_interfaces_pts = 0;
            obj.interface_pts = struct([]);            
        end

        %------------------------------------
        function obj = appendQuadratureData(obj, quad_data, elem_id, elem_type )
            
            % check input
            sz = size(quad_data);
            if ( length(sz) ~= 2 || sz(1) ~= obj.dim + 1 )
                error("Quad_data must be a matrix ( dim+1 x nb_pts ).")
            end

            if strcmpi( elem_type, 'trimmed' )
                
                obj.nb_trimmed_elems = obj.nb_trimmed_elems + 1;
                obj.nb_trimmed_elems_pts = obj.nb_trimmed_elems_pts + sz(2);
                obj.trimmed_elem_pts( obj.nb_trimmed_elems ).elem_id = elem_id;
                obj.trimmed_elem_pts( obj.nb_trimmed_elems ).quad_data = quad_data;

            elseif strcmpi( elem_type, 'non_trimmed' )

                obj.nb_non_trimmed_elems = obj.nb_non_trimmed_elems + 1;
                obj.nb_non_trimmed_elems_pts = obj.nb_non_trimmed_elems_pts + sz(2);
                obj.non_trimmed_elem_pts( obj.nb_non_trimmed_elems ).elem_id = elem_id;
                obj.non_trimmed_elem_pts( obj.nb_non_trimmed_elems ).quad_data = quad_data;

            elseif strcmpi( elem_type, 'interface' )

                obj.nb_interfaces = obj.nb_interfaces + 1;
                obj.nb_interfaces_pts = obj.nb_interfaces_pts + sz(2);
                obj.interface_pts( obj.nb_interfaces ).elem_id = elem_id;
                obj.interface_pts( obj.nb_interfaces ).quad_data = quad_data;

            else

                error('Element type %s is not known. Please set it to "trimmed", "non_trimmed" or "interface". ',elem_type);

            end

        end % appendQuadratureData

        %------------------------------------
        function result = compute_integral(obj,integrand)
            result = 0;
            if integrand == 1
                index = obj.dim+1;
                for iel = 1:obj.nb_trimmed_elems
                    QP = obj.trimmed_elem_pts(iel).quad_data;
                    result = result + sum(QP(index,:));
                end
                for iel = 1:obj.nb_non_trimmed_elems
                    QP = obj.non_trimmed_elem_pts(iel).quad_data;
                    result = result + sum(QP(index,:));
                end
            elseif obj.dim==2
                for iel = 1:obj.nb_trimmed_elems
                    QP = obj.trimmed_elem_pts(iel).quad_data;
                    for iQP = 1:size(QP,2)
                        result = result + integrand(QP(1,iQP),QP(2,iQP)) * QP(3,iQP);
                    end
                end
                for iel = 1:obj.nb_non_trimmed_elems
                    QP = obj.non_trimmed_elem_pts(iel).quad_data;
                    for iQP = 1:size(QP,2)
                        result = result + integrand(QP(1,iQP),QP(2,iQP)) * QP(3,iQP);
                    end                
                end
            elseif obj.dim==3
                for iel = 1:obj.nb_trimmed_elems
                    QP = obj.trimmed_elem_pts(iel).quad_data;
                    for iQP = 1:size(QP,2)
                        result = result + integrand(QP(1,iQP),QP(2,iQP),QP(3,iQP)) * QP(4,iQP);
                    end
                end
                for iel = 1:obj.nb_non_trimmed_elems
                    QP = obj.non_trimmed_elem_pts(iel).quad_data;
                    for iQP = 1:size(QP,2)
                        result = result + integrand(QP(1,iQP),QP(2,iQP),QP(3,iQP)) * QP(4,iQP);
                    end                
                end
            end
        end
    end
end