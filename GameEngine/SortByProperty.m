function out = SortByProperty(cellArray,propertyName,str)
%sorts a cell array containing structs or objects by a common propery
if nargin<3
    str = 'ascend';
end
n = numel(cellArray);
mat = zeros(n,2);
for i = 1:n
    mat(i,1) = i;
    mat(i,2) = cellArray{i}.(propertyName);
end
mat = sortrows(mat,2,str);
out = cell(1,n);
for i = 1:n
    out{i} = cellArray{mat(i,1)};
end
end