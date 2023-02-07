function result = inCircle(phantom_object,relay_object)
%inCircle Summary of this function goes here
%  check 
x1=phantom_object.x; 
y1=phantom_object.y;

x2=relay_object.x;
y2=relay_object.y;

radius = phantom_object.get_radius();
if hypot(x1-x2,y1-y2)<radius
    result=true;
else
    result=false;
end

