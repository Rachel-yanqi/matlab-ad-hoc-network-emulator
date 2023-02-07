classdef Phantom<handle
    properties
        id 
        x
        y
        radius
        members
        properity
        gateway
        center
    end
    methods
        function obj=Phantom(id,x,y,r)
            if nargin<4
                obj.id=0;
            else
                obj.id=id;
                obj.x=x;
                obj.y=y;
                obj.radius=r;
                obj.members=0; %no members at initial
                obj.properity=char.empty;
                obj.gateway='';     %gateway id
                obj.center='';      %control center
            end
        end
        function assignMembership(obj,member)
            obj.members=member;
        end
        function radius = get_radius(obj)  %set halo radius
            radius=obj.radius;
        end
        function id = get_gateway(obj)
            id = obj.gateway;
        end
        function set_properity(obj,value)
            obj.properity=value;
        end
        function obj = set_gateway(obj,id)
            obj.gateway = id;
        end
        function obj = set_center(obj,id)
            obj.center = id;
        end
    end
end