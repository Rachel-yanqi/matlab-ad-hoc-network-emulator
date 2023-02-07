function routing_table = build_table(route_map,node_ID,X_Coord,Y_Coord)
%build routing table for each node
%by using adjacent matrix

%------------test case---------------
% route_map=A;
% node_ID=2;
%------------test case---------------
[s,t]=find(route_map);
edges=[s,t];
number_of_nodes=size(route_map,1);
routing_table=zeros(number_of_nodes,3); %first col is dest, second col is next_hop, third col is the degree
routing_table(:,1)=1:number_of_nodes; 
routing_table(:,3)=NaN;
for i=1:size(routing_table,1)
    if node_ID==i
        routing_table(i,2)=i; %same node
        routing_table(i,3)=0;   %0 degree
        continue;
    end
    index=find(edges(:,2)==i);
    if edges(index,1)==node_ID 
        if ~isempty(index)
            routing_table(i,2)=edges(index,2); %update: dest routing table is not right
            deltaY=Y_Coord(edges(index,2))-Y_Coord(node_ID);
            deltaX=X_Coord(edges(index,2))-X_Coord(node_ID);
            rad=atan2(deltaY,deltaX);
            if rad<0
                rad=rad+2*pi;
            end
            routing_table(i,3)=rad;
        end
        continue;
    end
    while edges(index,1)~=node_ID
        if ~isempty(index)
            routing_table(i,2)=edges(index,1);  %next_hop
%             deltaY=Y_Coord(edge
            index=find(edges(:,2)==routing_table(i,2));
        end
    end
end
end