classdef GaussianM < handle
    %generate Gaussian markov random movement trial
    
    properties
        x
        y
        speed
        dir
    end
    properties (Access = private)
       maxspeed
       simtime
    end
    methods
        function obj = GaussianM(x,y,simtime,speed)
            obj.x=x;
            obj.y=y;
            obj.speed=speed;
            obj.dir=2*pi*rand;
            obj.maxspeed=speed;
            obj.simtime = simtime;
        end
        
        function obj=movement(obj)
            alpha=0.99;
            alpha2=1-alpha;
            alpha3=sqrt(1-alpha.*alpha);
            g_speed=round(alpha*obj.speed+alpha2*obj.maxspeed+alpha3*normrnd(0,1),2);
            obj.dir=round(alpha*obj.dir+alpha2*pi/4+alpha3*(2*pi*normrnd(0,1)),2);
            obj.set_speed(g_speed);
        end
        function obj = set_speed(obj,speed)
            obj.speed = speed;
        end
        
        function s = get_speed(obj)
            s = obj.speed;
        end
        function d = get_dir( obj )
            d = obj.dir;
        end 
    end
end

