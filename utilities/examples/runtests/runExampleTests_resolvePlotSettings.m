function plots = runExampleTests_resolvePlotSettings(testPlots, testType)
% Pure function for plot resolution logic

if nargin < 1 || isempty(testPlots)
    if strcmp(testType, 'unitTest')
        plots = 'off';
    else
        plots = 'default';
    end
else
    validOptions = {'default', 'on', 'off', 'error'};
    if ~ismember(testPlots, validOptions)
        error('testPlots must be one of: %s', strjoin(validOptions, ', '));
    end
    plots = testPlots;
end

end