function out = getDataFromFile(file_path,file_name,varargin)

% load error log table
T = readtable(strcat(file_path,file_name));

out = cell(length(varargin),1);
for i = 1:length(varargin)
    out{i} = T{:,local_get_col(T,varargin{i})};
end

end

function col = local_get_col(T,col_name)

col = strcmpi(T.Properties.VariableNames,col_name);
if ~any(col==1)
    error('Table has no columne names %s.',col_name)
end

end