classdef GameEngine < handle
properties (Access = private)
    workspace %all global variables
    gameObjects %all gameobjects in workspace
    running = true;
    renderer
    timeDelta%time since last frame
    minTimeDelta = 0.01 %set this to something other than zero to force a min time between frames
    numObjects%numel(gameobjects)
    time;
end
properties (Constant)
    tempFileName = "dsfgd21dfg4sdfgd2dfg4s";
end
methods (Access = private)
   
end
methods (Access = public)
    function obj = GameEngine(sceneFileName)
        if nargin>0
            load(sceneFileName);
        end
        obj.LoadWorkspace();
        renderers = obj.FindObjectsOfType('Renderer');
        if numel(renderers)>1
            error('More than one renderer detected. Make sure there is at most one renderer');
        end
        if numel(renderers)==1
            obj.renderer = renderers{1};
        end
        obj.gameObjects = obj.FindObjectsOfType('GameObject');
        obj.numObjects = numel(obj.gameObjects);
        if (obj.numObjects <=0)
           error('No GameObjects found in workspace. Game cancelled.');
        end
        fprintf("found " + num2str(obj.numObjects) + " GameObjects\n");
        %initialize all gameObjects
    end
    function obj = Start(obj)
        try
            obj.time = GetSecs();
            obj.timeDelta = 0;
            
        for i = 1:obj.numObjects
            obj.gameObjects{i}.SetGameEngine(obj);
        end
      
        for i = 1:obj.numObjects
            obj.gameObjects{i}.Awake();
        end
        if ~isempty(obj.renderer)
            obj.renderer.StartRendering();
        end
        for i = 1:obj.numObjects
            obj.gameObjects{i}.Start();
        end
        
        obj.running = true;
        obj.time = GetSecs();
        %Game Loop
        while obj.running
            t = GetSecs();
            obj.timeDelta = t - obj.time();
            obj.time = t;
             for i = 1:obj.numObjects
                 obj.gameObjects{i}.CheckDelays();
                 if obj.gameObjects{i}.enabled
                     obj.gameObjects{i}.BaseUpdate();
                     obj.gameObjects{i}.Update();
                 end
                 if ~obj.running
                    break;
                 end
             end
             pause(obj.minTimeDelta);
        end
             
        catch e
            sca;
            try
                for i = 1:obj.numObjects
                    obj.gameObjects{i}.OnError();
                end
            catch e2
                warning(e2.message);
            end
            rethrow(e);
         end
    end
    function obj = Quit(obj)
        for i = 1:obj.numObjects
            obj.gameObjects{i}.OnQuit();
        end
        fprintf("Game quit.\n");
        obj.running = false;
        sca;
    end
    function out = FindObjectsOfType(obj,typeChar)
        n = numel(obj.workspace);
        isType = zeros(1,n);
        for i = 1:n
              isType(i) = isa(obj.workspace{i},typeChar);
        end
        n = sum(isType);
        out = cell(1,n);
        j = 1;
        for i = 1:numel(isType)
            if(isType(i))
                out{j} = obj.workspace{i};
                j = j+1;
            end
        end
    end
    function obj = LoadWorkspace(obj)
        %creates references to all vars in the workspace
        
        %if you read through this function you will find that I used a very
        %hacky method to do this, but I think this is the only way as of
        %Matlab 2019a
        
        %good luck trying to figure out a better method
        str = "save('"+obj.tempFileName+"')";
        evalin('base',str);
        varsStruct = load(obj.tempFileName);
        delete(char(obj.tempFileName+".mat"));
        fields = fieldnames(varsStruct);
        n = numel(fields);
        vars = cell(1,n);
        for i = 1:n
            vars{i} = varsStruct.(fields{i});
        end 
        obj.workspace = vars;
    end
    function out = GetRenderer(obj)
        out = obj.renderer;
    end
    function out = GetTimeDelta(obj)
        out = obj.timeDelta;
    end
    function out = GetTime(obj)
        out = obj.time;
    end
    function obj = SetMinTimeDelta(obj,val)
        obj.minTimeDelta = val;
    end
end
end