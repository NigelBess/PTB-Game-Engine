function out = LoadStrings(fileName)
    temp = string(importdata([fileName,'.ignore']));
    n = numel(temp);
    out = cell(1,n);
    for i = 1:n
        out{i} = string(temp{i});
    end
end