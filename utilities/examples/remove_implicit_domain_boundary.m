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

function implicit_new = remove_implicit_domain_boundary(implicit,domain)
% This function is used to remove implicit boundary curves which are
% aligned with the boundary of the domain. The function is called by
% certain integrators. Keeping this curves would result in unfavourable
% results for these integrators because more elements than necessary would 
% be detected as cut. The question whether this special boundaries should 
% be defined or not seems to be a modelling question which has to be
% decided on integrator level. We keep them in the pure interface
% description such that they fit the parametric description where a closed
% loop is definitely favourable.

syms x y z

implicit_new = implicit;
if length(implicit)~=1
    for ic = length(implicit):-1:1
        phi = implicit{ic}.phi;
        % check that x, y and z are used as parameters
        args = getArgNames(phi);
        allowed = {'x','y','z'};
        allOK = all(ismember(args, allowed));
        if ~allOK
            error(['Unexpected parameter names used in definition of implicit ' ...
                'boundary curve.'])
        end

        % Determine whether curve is straight parallel line
        try
            f(x,y,z) = sym(phi);
            deg = polynomialDegree(f,x);
            deg = deg + polynomialDegree(f,y);
            deg = deg + polynomialDegree(f,z);
        catch
            deg = 100; % random number which is not 1
        end
        % Check whether curve is on domain boundary
        if deg == 1
            is_onDomain = false;
            corners = [domain.xmin(:),domain.xmax(:)]; % it is sufficient to test diagonal corners
            for icorner = 1:2
                if domain.dim==2
                    levelset = phi(corners(1,icorner),corners(2,icorner));
                elseif domain.dim==3
                    levelset = phi(corners(1,icorner),corners(2,icorner),corners(3,icorner));
                end
                if levelset==0
                    is_onDomain = true;
                    break
                end
            end
            if is_onDomain
                implicit_new(ic) = [];
            end
        end
    end
end

end

function args = getArgNames(f)
    info = functions(f);
    str = info.function;
    tok = regexp(str, '@\((.*?)\)', 'tokens', 'once');
    if isempty(tok)
        args = {};
    else
        raw = tok{1};
        args = strtrim(strsplit(raw, ','));
    end
end