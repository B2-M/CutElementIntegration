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

classdef LevelSetFunctionAndGradient
   properties(SetAccess = private)
      phi 
      grad   
      dim
   end  
   methods
       function obj = LevelSetFunctionAndGradient(phi, gradPhi)
           
           % check input
           if ~isa(phi,"function_handle")
               error("Error: The first input must be a function_handle to the level set function; not a %s.", class(phi))
           end
           if ~isa(gradPhi,"cell")
               error("Error: The second input must be a cell of function_handles defining the gradient of the level set function; not a %s.", class(gradPhi))
           end
           if nargin(phi) ~= length(gradPhi)
               error("Error: the number of input variables of the level set function differs from the number of derivatives of the gradient.")
           else
               for i = 1:nargin(phi)
                   if nargin(phi) ~= nargin(gradPhi{i})
                       error("Error: the number of input variables differs for the level set function and the %i-th component of the gradient.", i)
                   end
               end
           end

           % set properties
           obj.phi = phi;
           obj.grad = gradPhi;
           obj.dim = length(gradPhi);

           % check dimensions
           if obj.dim == 2
               v = obj.phi(0.1,0.1);
               g = {obj.grad{1}(0.1,0.1),obj.grad{2}(0.1,0.1)};
           elseif obj.dim == 3
               v = obj.phi(0.1,0.1,0.1);
               g = {obj.grad{1}(0.1,0.1,0.1),obj.grad{2}(0.1,0.1,0.1),...
                   obj.grad{3}(0.1,0.1,0.1)};
           else
               error("LevelSetFunctionAndGradient with dimension %i is not supported.",obj.dim)
           end

       end     
   end
end