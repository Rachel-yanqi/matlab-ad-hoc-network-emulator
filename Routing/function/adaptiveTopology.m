function idxs = adaptiveTopology(node,range,beamwidth,X_Coord,Y_Coord,root)
%MAC connection for different beamwidth antenna 
% use greedy BFS search to determine the link layer
n=factorial(numel(node))/factorial(numel(node)-2);
number_of_nodes=numel(node);
edges=zeros(n,2);
k=1;        
for i=1:numel(node)
    for j=1:numel(node)
        if i~=j
            edges(k,:)=[i,j];
            k=k+1;
        end
    end
end
dist=hypot(X_Coord(edges(:,1))-X_Coord(edges(:,2)),Y_Coord(edges(:,1))-Y_Coord(edges(:,2)));
dist=round(dist);
TF1=(dist<=range & dist~=0);
edges=edges(TF1,:);
degree=zeros(size(edges,1),1);
%build degree table for each links on each node
for i=1:length(edges)
    deltaY=Y_Coord(edges(i,2))-Y_Coord(edges(i,1));
    deltaX=X_Coord(edges(i,2))-X_Coord(edges(i,1));
    rad=atan2(deltaY,deltaX);
    if rad<0
        rad=rad+2*pi;
    end
    degree(i)=floor(rad2deg(rad));
end
edges(:,3)=degree;
%%
% root=1;     %start at sender aim to receiver
visited = zeros(1,number_of_nodes);     %a visted indicator
visited(root)=1;
queue=root;
idxs=[];
while ~isempty(queue)
    i=queue(1);
    queue(1)=[];
    TF=edges(:,1)==i;
    temp=edges(TF,2:3);
    temp=temp(visited(temp(:,1))==0,:);
    if isempty(temp)        %
        continue;
    end
    temp_nodes=zeros(size(temp));
    [temp_nodes(:,2),I]=sort(temp(:,2),1);
    temp=temp(:,1);
    temp_nodes(:,1)=temp(I);
    %find the antenna direction that can cover most unvisited nodes
    C=0;
    coverage=zeros(size(temp_nodes,1),1);
    for j=1:size(coverage,1)
        temp_queue=[];
        for k=1:size(coverage,1)
            if abs(temp_nodes(j,2)-temp_nodes(k,2)) < beamwidth/2
                coverage(j)=coverage(j)+1;
                temp_queue(2:end+1)=temp_queue;
                temp_queue(1)=temp_nodes(k,1);

            end
        end
        if coverage(j) > C
            final_queue=temp_queue;
            C=coverage(j); 

        end

    end
%             idxs=zeros(C,2);
    idxs(end+1:end+C,:)=[i*ones(C,1),final_queue'];        
%     visited(final_queue)=1;       %assigned visted nodes
    visited(i)=1;       
    queue=[queue,final_queue];
   % queue=sort(queue);
    queue=unique(queue);
    [~,direction]=max(coverage);
    node(i).direction=temp_nodes(direction,2);      %assign antenna's direction to each node
end
end

