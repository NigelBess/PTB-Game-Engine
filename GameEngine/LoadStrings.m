function varargout = LoadStrings(fileName)
    temp = string(importdata([fileName,'.ignore']));
    n = numel(temp);
    varargout = cell(1,n);
    for i = 1:n
        varargout{i} = string(temp{i});
    end
end