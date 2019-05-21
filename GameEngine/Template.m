classdef Template < GameObject
    %template for a gameobject
    methods (Access = public)
        function obj = Awake(obj)
            %Called at the beginning of the game
        end
        function obj = Update(obj)
            %Called once per frame if this object is enabled
        end
    end
end