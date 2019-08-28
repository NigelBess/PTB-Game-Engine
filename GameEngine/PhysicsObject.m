classdef PhysicsObject < Renderable
    properties(Access = protected)
        velocity = [0,0];
        maxPixelsPerFrame = Inf;
    end
    methods (Access = public)
        function obj = SetVelocity(obj,vel,index)
            if(nargin<3)
                obj.velocity = vel;
            else
                obj.velocity(index) = vel;
            end
        end
        function out = GetVelocity(obj)
            out = obj.velocity;
        end
        function obj = BaseUpdate(obj)
            delta = min(abs(obj.velocity*obj.Game.GetTimeDelta()),obj.maxPixelsPerFrame);
            delta = delta.*sign(obj.velocity);
            obj.SetPosition(obj.rootPosition + delta);
        end
    end
end