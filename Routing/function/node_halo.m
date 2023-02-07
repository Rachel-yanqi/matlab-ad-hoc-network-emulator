function NH_pair = node_halo(node,phantom,boundary)
%find the node and halo pairs: a node links to a (or more) halo if 
%the distance is lesser than RF strength+halo_radius
%eg: {node1: halo1, halo2}

halo_position=zeros(numel(phantom),2);
for i=1:numel(phantom)
    try
        halo_position(i,1)=phantom(i).x;
        halo_position(i,2)=phantom(i).y;
    catch
        fprintf('No halo exist\n')
        NH_pair=NaN;
        return
    end
end
node_position=zeros(length(node),2);
for i=1:numel(node)
    node_position(i,1)=node(i).x;
    node_position(i,2)=node(i).y;
end
NH_pair=containers.Map('KeyType','double','ValueType','any'); %an empty directionary
for i=1:size(node_position,1)
    value=[];
    for j=1:size(halo_position,1)
        if sqrt((node_position(i,1)-halo_position(j,1))^2+...
                (node_position(i,2)-halo_position(j,2))^2)<boundary
            value(end+1)=j;
        end
    end
    NH_pair(i)=value; %key is node id, value is halo id
end
end

