function deleteFilesInResultsFolders()
    % Function to find all folders named "results" and delete all files within these folders.

    % Get a list of all "results" folders in the current directory and subdirectories
    resultsFolders = findResultsFolders();

    % Iterate over each "results" folder
    for i = 1:length(resultsFolders)
        % Get the current "results" folder
        folderPath = resultsFolders{i};
        
        % Get all files within this folder
        files = dir(fullfile(folderPath, '*'));

        % exclude '.' and '..'
        isFile = ~ismember({files.name}, {'.', '..'});

        % Get the names of the subfolders
        files = files(isFile);
        fprintf('There are %i files in folder %s.\n', length(files), folderPath);

        if ~isempty(files)
            % Ask the user for confirmation
            userResponse = input('Do you want to delete all these files? (y/n): ', 's');

            % Check user response
            if strcmpi(userResponse, 'y')
                % Iterate over each file and delete it
                for j = 1:length(files)
                    % Skip '.' and '..' entries
                    if ~files(j).isdir
                        % Get the full path of the file
                        filePath = fullfile(folderPath, files(j).name);

                        % Delete the file
                        try
                            delete(filePath);
                            % fprintf('Deleted: %s\n', filePath);
                        catch ME
                            fprintf('Failed to delete: %s (%s)\n', filePath, ME.message);
                        end
                    end
                end
            end
        end
    end

    fprintf('Finished deleting files in all "results" folders.\n');
end

% Helper function to find all folders named "results" in the examples directory
function resultsFolders = findResultsFolders()

    % Get the names of the subfolders
    [subFolderNames,folderPath] = getTestFolderNames();

    % Get paths to result folders
    resultsFolders = cell(size(subFolderNames));
    for i = 1 : length(resultsFolders)
        resultsFolders{i} = [folderPath subFolderNames{i} '/results/'];
    end

end