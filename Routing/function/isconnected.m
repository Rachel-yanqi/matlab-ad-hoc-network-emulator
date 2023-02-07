function bool=isconnected(link_map,route)
%boolean output for test: if route is connected or not
%link_map: contain all existing connections 
%eg., route=[1,2,5]
bool=false;
for i=1:length(route)-1
    if link_map(route(i),route(i+1))==1
        bool=true;
    else
        bool=false;
        break
    end
end
end