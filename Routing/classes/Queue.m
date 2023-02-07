classdef Queue < handle
    %Queue
    
    properties
        elements
        max
        number
    end
    
    methods
        function obj = Queue()
            obj.max=15;      %buffer size
            obj.elements=struct;
            obj.elements=packet.empty;
            obj.number=0;
        end
        function add(obj,packet)
            obj.elements(end+1)=packet;
            obj.number=obj.number+1;
            if obj.getNumber>obj.max
                obj.remove();
            end
        end
        function copy(obj,packet)
            obj.elements(2:end+1)=obj.elements;
            obj.elements(1)=packet;
            obj.number=obj.number+1;
%             if obj.getNumber>obj.max
%                 obj.remove();
%             end
        end
        function packet = remove(obj)
            if obj.isempty()
                fprintf('Queue is empty\n');
                return
            end
            packet=obj.elements(1);
            obj.elements(1)=[];
            obj.number=obj.number-1;
        end
        function tf = isempty(obj)
            tf=isempty(obj.elements);
        end
        function size = getSize(obj)
            size=obj.max;
        end
        function number=getNumber(obj)
            if ~isempty(obj.elements)
                number=length(obj.elements);
            else
                number=0;
            end
        end
    end
end

