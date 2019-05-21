classdef GameObject < handle
    properties (Access = public)
          enabled = true;%setting this to false preventts update from being called
    end
    properties (Access = protected)
              Game%the game engine
              Renderer%the renderer (if one exists)
              delayedCallTimes;
              delayedCallNames = cell(0);
              delayedParams = cell(0);
              stopDelayCalledThisFrame = false;
    end
    methods (Access = public)
        function obj = DisableFor(obj,time)
            obj.DelayedCall('Enable',time);
            obj.enabled = false; 
        end
        function obj = Enable(obj)
            obj.enabled = true;
        end
        function obj = Update(obj)
            
        end
        function obj = BaseUpdate(obj)
        end
        function obj = Awake(obj)
            
        end
        function obj = Start(obj)
            
        end
        function obj = OnError(obj)
        end
        function obj = OnQuit(obj)
        end
        function obj = SetGameEngine(obj,engine)
            obj.Game = engine;
            obj.Renderer = engine.GetRenderer();
        end
        function obj = CheckDelays(obj)
            obj.stopDelayCalledThisFrame = false;
            n = numel(obj.delayedCallTimes);
            if n<1
                return;
            end
            t = obj.Game.GetTime();
            callThisFrame = obj.delayedCallTimes<=t;
            if ~sum(callThisFrame)
                return;
            end
            for i = 1:n
                if callThisFrame(i)
                    obj.(obj.delayedCallNames{i})(obj.delayedParams{i}{:});
                    if(obj.stopDelayCalledThisFrame)
                        return; 
                    end
                end
            end
            obj.delayedCallTimes(callThisFrame) = [];
            obj.delayedCallNames(callThisFrame) = [];
            obj.delayedParams(callThisFrame) = [];
        end
        function obj = DelayedCall(obj,methodName,delayTime,varargin)
            if isempty(obj.Game())
                warning('Attempting to make a delayed call without game engine running. Call will be ignored.')
                return;
            end
            n = numel(obj.delayedCallTimes);
            obj.delayedCallTimes(n+1)= delayTime+obj.Game.GetTime();
            obj.delayedCallNames{n+1} = methodName;
            obj.delayedParams{n+1} = varargin;
        end
        function [] = DebugFutureCalls(obj)
            obj.delayedCallTimes
            obj.delayedCallNames
        end
        function obj = StopAllDelayedCalls(obj)
            obj.stopDelayCalledThisFrame = true;
            obj.delayedCallTimes = [];
            obj.delayedCallNames = cell(0);
            obj.delayedParams = cell(0);
        end
    end
end