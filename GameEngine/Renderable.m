classdef Renderable < GameObject
    properties(Access = protected)
        position = [0,0]%position in pixels relative to the center of the screen
        image%image matrix defining the renderable's texture
        texture%pointer to its associated texture
        size
        screenBounded%should this renderer be limited to stay inside the screen
        screenHits
    end
    properties(Access = public)
        renderLayer = 100
    end
    methods (Access = public)
        function [positions,tex] = GetData(obj)
            c = obj.Renderer.Center();
            positions = [obj.position(1)-obj.size(1)/2 ,obj.position(2)-obj.size(2)/2,obj.position(1)+obj.size(1)/2,obj.position(2)+obj.size(2)/2];
           positions = positions + [c,c];
            tex = obj.texture;
        end
        function obj = SetPosition(obj,pos)
            obj.position = pos;
            if obj.screenBounded
                hits = obj.Renderer.CheckSideIntersection(obj);
                obj.screenHits = hits;
            else
                return;
            end
            if sum(abs(hits))
                rect = obj.Renderer.GetRect();
                for i = 1:2
                    if abs(hits(i))
                        index = (hits(i)+3)/2;
                        c = obj.Renderer.Center;
                        rect(4) =0;
                        obj.position(i) = rect(i*index) - hits(i)*(obj.size(i)/2-c(i));
                    end
                end
            end
        end
        function out = GetPosition(obj)
            out = obj.position;
        end
        function img = GenerateImage(obj)
        end
        function obj = SetImage(obj)
            obj.image = obj.GenerateImage();
        end
        function obj = SendImage(obj)
            obj.texture = obj.Renderer.ImageToTexture(obj.image);
        end
        function out = GetScreenHits(obj,index)
            out = obj.screenHits;
            if nargin>1
                out = out(index);
            end
        end
         function out = Distance(obj,other,index)
            pos1 = obj.GetPosition;
            pos2 = other.GetPosition;
            if nargin<3
                for i = 1:2
                    out = sqrt(sum((pos1-pos2).^2));
                end
                return
            end
            out = abs(pos1(index)-pos2(index));
        end
    end
end