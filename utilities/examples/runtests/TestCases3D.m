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

classdef TestCases3D < matlab.unittest.TestCase

    properties(SetAccess=immutable)
        dim = 3
    end

    properties(ClassSetupParameter)
        eTestType = {'default'}; 
        eIntegrator = {'default'};
        ePlots = {'default'};
    end

    methods(TestClassSetup)
        function setExternalParameterValue( testCase, eTestType, eIntegrator, ePlots )
            setTestExternalParameters(testCase, eTestType, eIntegrator);
            if ~strcmp(ePlots,'default')
                if strcmp(ePlots,'off')
                    testCase.plot_settings = {'PlotError','off','PlotPoints','off','PlotInterface','off'};
                elseif strcmp(ePlots,'on')
                    testCase.plot_settings = {'PlotError','on','PlotPoints','on','PlotInterface','on'};
                elseif strcmp(ePlots,'error')
                    testCase.plot_settings = {'PlotError','on','PlotPoints','off','PlotInterface','off'};
                else
                    error("Plot option %s is not known.", ePlots)
                end
            end
        end
    end

end