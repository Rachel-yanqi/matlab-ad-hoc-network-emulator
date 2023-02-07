classdef Neighbor < handle
    properties
        id 
        period
        timer
        result
    end
    methods
        
        function obj=Neighbor(id)
            obj.id = id;
            obj.period = 300;       %need to be changed according to sending rate
            obj.timer = obj.period;
            obj.result = 0;
        end
        function [obj,pkt]=timeout(obj,timestamp)
            pkt=[];
            if timestamp >= obj.timer*sending_slot
                pkt=packet(dest,timestamp);
                obj.result=1;
            else 
                obj.result=0;
            end
        end
    end
end