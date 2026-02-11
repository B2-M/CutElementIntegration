function text = insert_dot_after_number(text)

count = 1;
text_piece = [];
is_decimal = false;
while count <= length(text)
    if isnan(str2double(text(count))) && ~(text(count)=='.')
        if ~isempty(text_piece)
            if ~is_decimal
                text = [text(1:count-1) '.' text(count:end)];
            end
            text_piece = [];
            is_decimal = false;
        end
    else
        if text(count)=='.'
            is_decimal = true;
        end
        text_piece = [text_piece text(count)]; %#ok<AGROW> 
    end
    count = count + 1;
end

% if last string is a number, add one more point
if ~isempty(text_piece)
    text = [text '.'];
end

end