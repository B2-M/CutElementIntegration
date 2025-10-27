function [name_path,name_test] = getLogFileNames(testCaseId,folderName)

name_path = ['./examples/' folderName '/results/'];
name_test = ['run' folderName '_tC_' num2str(testCaseId)];

end