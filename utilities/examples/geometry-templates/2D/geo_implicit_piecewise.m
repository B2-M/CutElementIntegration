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

function level_set = geo_implicit_piecewise(x,y,f,x_range,y_range)

%% slow version
% level_set = nan(size(x,1),size(x,2));
% for jx = 1:size(x,2)
%     for ix = 1:size(x,1)
%         level_set_f = nan(length(f),1);
%         for i = 1:length(f)
%             % Convert symbolic expressions to numeric values before using in logical conditions
%             x_num = double(x(ix,jx));
%             y_num = double(y(ix,jx));
%             if x_num >= x_range(i,1) && x_num <= x_range(i,2) && ....
%                y_num >= y_range(i,1) && y_num <= y_range(i,2)
%                 level_set_f(i) = double(f{i}(x_num,y_num));
%             end
%         end
%         % level_set(ix,jx) = max(level_set_f);
%         [~, idx] = min(abs(level_set_f), [], 'omitnan');
%         level_set(ix,jx) = level_set_f(idx);
%     end
% end

%% vectorized version
% Convert inputs to double once
x = double(x);
y = double(y);

% Preallocate
level_set = nan(size(x,1),size(x,2));
level_set_all = nan([size(x,1),size(x,2), length(f)]);

% Vectorized evaluation for each piecewise function
for i = 1:length(f)
    % Create mask for valid region (vectorized)
    mask = (x >= x_range(i,1)) & (x <= x_range(i,2)) & ...
            (y >= y_range(i,1)) & (y <= y_range(i,2));
    
    % Evaluate function only where mask is true
    if any(mask(:))
        % Extract only the x,y values within the valid range
        x_valid = x(mask);
        y_valid = y(mask);

        % Evaluate function only on valid points (much faster!)
        values_valid = double(f{i}(x_valid, y_valid));

        % Create full-size array initialized with NaN
        values_full = nan(size(x,1),size(x,2));

        % Place computed values at the valid positions
        values_full(mask) = values_valid;

        % Store in 3D array
        level_set_all(:,:,i) = values_full;
    end
end

% Find closest level set value for each point (vectorized)
[~, idx] = min(abs(level_set_all), [], 3, 'omitnan');

% Extract selected values
for ix = 1:numel(x)
    if ~isnan(idx(ix))
        level_set(ix) = level_set_all(ix + (idx(ix)-1)*numel(x));
    end
end

end