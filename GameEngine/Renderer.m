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
    end
    methods (Access = public)
        function obj = Renderer(screenNum,backgroundColor)
            if(nargin<1)
                screenNum = 0;
            end
            if(nargin<2)
                backgroundColor = 0.5;
            end
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
                [obj.displayWindow, obj.rect] = PsychImaging('OpenWindow', obj.screenNumber, obj.backgroundColor);

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
                 [positions,tex] = obj.renderables{i}.GetData();
                 Screen('DrawTexture', obj.displayWindow, tex, [], positions, 0, 0); 
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
        function out = CheckSideIntersection(obj,renderable,index)
            hits = zeros(2,2);%[xlow, xHigh; yLow, yHigh]
            direction = [1,-1;1,-1];
            pos = renderable.GetData();
            for i = 1:4
                hits(i) =  pos(i)*direction(i)< obj.rect(i)*direction(i);
            end
            out = zeros(2,1);
            for i = 1:2
                out(i) = -hits(i,1)+hits(i,2);
            end
            if nargin>2
               	out = out(index);
            end
        end
        function out = GetRect(obj)
            out = obj.rect;
        end
    end
end