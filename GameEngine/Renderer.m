classdef Renderer < GameObject
    properties (Access = protected)
        screenNumber%0:single monitor 1:first monitor in dual mode 2:second
        backgroundColor
        defaultBackgroundColor
        renderables%all renderable objects
        displayWindow%pointer to window for rendering
        
        %rect data
        rect;
        width
        height
        xCenter
        yCenter
        
        %for only rendering to a small portion of the screen
        percentRect = [0 0 1 1];%min x, min y, max x, max y
    end
    methods (Access = public)
        function obj = Renderer(screenNum,backgroundColor,percentRect)
            if(nargin<1)
                screenNum = 0;
            end
            if(nargin<2)
                backgroundColor = 0.5;
            end
            if (nargin<3)
                percentRect = [0 0 1 1];
            end
            obj.percentRect = percentRect;
            obj.screenNumber = screenNum;
            obj.backgroundColor = backgroundColor;
            obj.defaultBackgroundColor = backgroundColor;
            
        end
        
        function obj = StartRendering(obj)
             %Initialize PsychToolbox
                obj.renderables = obj.Game.FindObjectsOfType('Renderable');
                obj.SortRenderables;
                PsychDefaultSetup(2);
                Screen('Preference','SkipSyncTests',1);
                Screen('Preference','VisualDebugLevel',0);
                Screen('Preference','SuppressAllWarnings',1);
                try
                 rect = Screen('GlobalRect', obj.screenNumber);
                catch e
                    error(string(obj.screenNumber) + "is an invalid screen number. Make sure you select 0 if you are using a single monitor");
                end
                 [obj.width, obj.height] = Screen('WindowSize', obj.screenNumber);
                 rect = rect + [obj.width,obj.height,0,0].*obj.percentRect;
                 rect = rect - [0,0,obj.width,obj.height].*(1-obj.percentRect);
                [obj.displayWindow, obj.rect] = PsychImaging('OpenWindow', obj.screenNumber, obj.backgroundColor,rect);
                % Enable alpha blending with proper blend-function. We need it for drawing of our alpha-mask (gaussian aperture):
                Screen('BlendFunction', obj.displayWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                 [obj.width, obj.height] = Screen('WindowSize', obj.displayWindow);
                %Get info on window
                [obj.xCenter, obj.yCenter] = RectCenter(obj.rect);
                for i = 1:numel(obj.renderables)
                    obj.renderables{i}.SetImage();
                    obj.renderables{i}.SendImage();
                end
                
                %obj.EmptyFrame();

        end
        function obj = BaseUpdate(obj)
            obj.Frame()
        end
        function [] = Frame(obj)
            obj.ClearFrame();
            for i = 1:numel(obj.renderables)
                if obj.renderables{i}.enabled
                 [positions,tex,alpha] = obj.renderables{i}.GetData();
                 for j = 1:size(positions,1)
                    Screen('DrawTexture', obj.displayWindow, tex, [], positions(j,:), 0, 0, alpha); 
                 end
                end
            end
            Screen('Flip', obj.displayWindow);
        end
        function [] = ClearFrame(obj)
            Screen('FillRect',obj.displayWindow,obj.backgroundColor,[]);
        end
        function obj = SetBackgroundColor(obj,col)
            obj.backgroundColor = col;
        end
        function obj = ResetBackgroundColor(obj)
            obj.backgroundColor = obj.defaultBackgroundColor;
        end
        function out = WindowSize(obj)
            width = obj.width;
            height = obj.height;
            out = [width,height];
        end
        function out = Center(obj)
            out = [obj.xCenter,obj.yCenter];
        end
        function out = ImageToTexture(obj,img)
            out = Screen('MakeTexture', obj.displayWindow, img);
        end
        function obj = SortRenderables(obj)
            obj.renderables = SortByProperty(obj.renderables,'renderLayer','descend');
        end
        function out = CheckSideIntersection(obj,renderable,instance)
            if nargin<3
                instance = 1;
            end
            hits = zeros(2,2);%[xlow, xHigh; yLow, yHigh]
            direction = [1,-1;1,-1];
            pos = renderable.GetData();
            for i = 1:4
                hits(i) =  pos(instance,i)*direction(i)< obj.rect(instance,i)*direction(i);
            end
            out = zeros(2,1);
            for i = 1:2
                out(i) = -hits(i,1)+hits(i,2);
            end
        end
        function out = GetRect(obj)
            out = obj.rect;
        end
    end
end