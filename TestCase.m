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

classdef TestCase
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess = private)
        dim (1,1)
    end

    properties
        domain
        interface        
        references
        id = -1
    end


    methods
        function obj = TestCase(domain, interface, references, id)

            % check input
            if( isa(domain,"Domain") && isa(interface,"Interface") )
                if domain.dim ~= interface.dim
                    error("TestCase error: domain and interface dimensions do not match.")
                end
            else
                error("TestCase error: The first input (%s) and second input (%s) do not match.", class(domain), class(interface))
            end

            % set properties
            obj.dim = domain.dim;
            obj.domain = domain;
            obj.interface = interface;
            obj.references = references;
            if exist('id','var')
                obj.id = id;
            end

        end
    end
end