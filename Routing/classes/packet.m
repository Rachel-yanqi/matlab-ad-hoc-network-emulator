classdef packet < handle
    %packet object 
    %   Detailed explanation goes here
    
    properties 
        destination %receivers
        start_time
        end_time
        packet_number
        TTL
    end
    
    methods
        function obj = packet(membership,start_time,packet_number)
            %initialize packet
            if nargin<2
                obj.start_time=0;
            else
                obj.destination = membership;
                obj.start_time = start_time;
                obj.end_time = 0;
                obj.packet_number = packet_number;  
                obj.TTL=5; 
            end
        end
%         function next_hop(obj)
%             obj.path_index = obj.path_index+1;
%             relay = obj.path.optpath(obj.path_index);
%         end
        function set_start_time(obj,timestamp)
            obj.start_time = timestamp;
        end
    end
end

