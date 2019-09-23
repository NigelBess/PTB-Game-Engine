classdef Renderable < GameObject
    properties(Access = protected)
        rootPosition = [0,0];
        position = [0,0]%position in pixels relative to the center of the screen
        image%image matrix defining the renderable's texture
        texture%pointer to its associated texture
        size = [0,0]
        screenBounded%should this renderer be limited to stay inside the screen
        screenHits = [0,0]
        parent
        children = {};
        globalAlpha = 1;
    end
    properties(Access = public)
        renderLayer = 100
    end
    methods (Access = public)
        function obj = InstantiateNew(obj,position,size)
            if nargin<2
                position = [0,0];
            end
            if nargin<3
                size = obj.size(1,:);
            end
            obj.position(end+1,:) = position;
            obj.size(end+1,:) = size;
            obj.screenHits(end+1,:) = zeros(1,2);
        end
          function obj = Remove(obj,instance)
            obj.position(instance,:) = [];
            obj.size(instance,:) = [];
            obj.screenHits(instance,:) = [];
        end
        function [positions,tex,alpha] = GetData(obj)
            globalPos = obj.Renderer.Center()+obj.GetGlobalPosition();
            positions = [obj.position(:,1)-obj.size(:,1)/2 ,obj.position(:,2)-obj.size(:,2)/2,obj.position(:,1)+obj.size(:,1)/2,obj.position(:,2)+obj.size(:,2)/2];
           positions = positions + [globalPos,globalPos];
            tex = obj.texture;
            alpha = obj.globalAlpha;
        end
        function obj =  SetRootPosition(obj,pos)
            obj.rootPosition = pos;
        end
        function obj = SetPosition(obj,pos,instance)
             if nargin<3
                obj.rootPosition = pos;
             else
                 obj.position(instance,:) = pos;
             end
             for j = 1:size(obj.position,1)
                if obj.screenBounded
                    hits = obj.Renderer.CheckSideIntersection(obj,j);
                    obj.screenHits(j,:) = hits;
                else
                    return;
                end
                if sum(abs(hits))
                    rect = obj.Renderer.GetRect();
                    for i = 1:2
                        if abs(hits(i))
                            index = (hits(i)+3)/2;%0, 1 or -1
                            c = obj.Renderer.Center;
                            rect(4) =0;
                            pos = rect(i*index) - hits(i)*(obj.size(j,i)/2-c(i));
                            if  size(obj.position,1) == 1
                                obj.rootPosition(i) = pos;
                            else
                            obj.position(j,i) = pos-obj.GetGlobalPosition(i);
                            end
                        end
                    end
                end
             end
        end
        function out = GetPosition(obj,instance)
            out = obj.GetGlobalPosition();
            if nargin<2
                return;
            end
            out = out + obj.position(instance,:);
        end
        function img = GenerateImage(obj)
        end
        function obj = SetImage(obj)
            obj.image = obj.GenerateImage();
        end
        function obj = SendImage(obj)
            obj.texture = obj.Renderer.ImageToTexture(obj.image);
        end
        function out = GetScreenHits(obj,index,instance)
             if nargin<3
                instance = 1;
            end
            out = obj.screenHits(instance,:);
            if nargin>1
                out = out(index);
            end
        end
         function out = Distance(obj,other,index)
            pos1 = obj.GetPosition();
            pos2 = other.GetPosition();
            if nargin<3
                for i = 1:2
                    out = sqrt(sum((pos1-pos2).^2));
                end
                return
            end
            out = abs(pos1(index)-pos2(index));
         end
         function out = GetGlobalPosition(obj, index)
             out = obj.rootPosition;
             if ~isempty(obj.parent)
                out = out + obj.parent.GetGlobalPosition();
             end
             if nargin>1
                 out = out(index);
             end
         end
         function obj = SetParent(obj,parent)
             obj.parent = parent;
             obj.parent.AddChild(obj);
         end
         function obj = AddChild(obj,child)
            obj.children{end+1} = child;
         end
         function obj = RenderAfter(obj,other)
            obj.renderLayer = other.renderLayer+1;
         end
         function out = PngToImg(obj,pngFileName)
             [out,~,alpha] = imread(pngFileName,'png');
             out(:,:,4) = alpha;
         end
         function out = SelfDistance(obj,instance1,instance2)
             pos1 = obj.position(instance1,:);
             pos2 = obj.position(instance2,:);
            out = sqrt(sum((pos1-pos2).^2));
         end
         function obj = SetAlpha(obj,value)
             obj.globalAlpha = value;
         end
    end
end