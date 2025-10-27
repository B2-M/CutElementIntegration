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

function plot_error_testsuit(objInt,test_cases,area,names,name_testsuit)

n_cases = length(test_cases);
count = 0;
err_rel = zeros(n_cases,length(objInt));
for testCaseId = test_cases
    count = count + 1;
    objTest = getTestCase2D( testCaseId );
    area_exact = objTest.references.exact_inside;
    for i = 1:length(objInt)
        err_rel(count,i) = abs(area{count}(i)-area_exact)/area_exact;
        if err_rel(count,i) < eps
            err_rel(count,i) = eps;
        end
    end
end
figure()
names_legend = names.integrators;
for i = 1:length(objInt)
    semilogy(err_rel(:,i),'x-')
    hold on
    if all(isnan(err_rel(:,i)))
        names_legend{i} = strcat(names_legend{i},',all failed');
    elseif any(isnan(err_rel(:,i)))
        names_legend{i} = strcat(names_legend{i},',some failed');
    end
end
grid on
legend(names_legend)
dt = datestr(now,'_yymmdd-HH-MM-SS_'); %#ok<TNOW1,DATST> 
figname = [names.path 'runAreaComputation2D_' name_testsuit dt '_error.fig' ];
savefig(figname)

end