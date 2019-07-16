function SaveStrings(fileName,varargin)
    file = fopen([fileName,'.ignore'],'wt');
    if numel(varargin)==1
        varargin = varargin{1};
    end
    for i = 1:numel(varargin)
        try
            fprintf(file,string(varargin{i})+"\n");
        catch e
            fprintf(file,string(varargin(i))+"\n");
        end
    end  
    fclose(file);
end