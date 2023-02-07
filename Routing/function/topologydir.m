function [A,search_delay] = topologydir(number_of_nodes,start_id,X_Coord,Y_Coord,...
     Signal_strength)
% Topology Function
%   build link connection for directional case
%   BFS

% test-brench
% number_of_nodes=9
% start_id=1;
% Signal_strength=3670;


idxs=nchoosek(1:number_of_nodes,2);
dist=hypot(X_Coord(idxs(:,1))-X_Coord(idxs(:,2)),Y_Coord(idxs(:,1))-Y_Coord(idxs(:,2)));
dist=round(dist);
TF1=(dist<=Signal_strength & dist~=0);
inRangIdxs=idxs(TF1,:);
search_delay=0;

% idxs=zeros(number_of_nodes,2);
% idxs(:,1)=idxs(:,1)+start_id;
% idxs(:,2)=(1:number_of_nodes)';
inRangIdxs=[inRangIdxs;[inRangIdxs(:,2),inRangIdxs(:,1)]];
visited=zeros(1,number_of_nodes);
degree=zeros(length(inRangIdxs),1);
for i=1:length(inRangIdxs)
    deltaY=Y_Coord(inRangIdxs(i,2))-Y_Coord(inRangIdxs(i,1));
    deltaX=X_Coord(inRangIdxs(i,2))-X_Coord(inRangIdxs(i,1));
    rad=atan2(deltaY,deltaX);
    if rad<0
        rad=rad+2*pi;
    end
    degree(i)=floor(rad2deg(rad));
end
weight=dist(TF1);
    
k=1;
visited(start_id)=1; %sender is visted
queue=start_id;
while ~isempty(queue)  %BFS
    v=queue(1);
    queue(1)=[];
    temp=inRangIdxs(inRangIdxs(:,1)==v,2);
    temp=temp(visited(temp)==0); %find possible nodes that non-visited
%         queue=[queue,inRangIdxs(inRangIdxs(:,1)==v,2)];
    if isempty(temp)
        edgeList = edgeList(edgeList(:,1)~=0,:);
        continue;
    end
    n=1;
%     ini_degree=degree(inRangIdxs(:,1)==v & inRangIdxs(:,2)==temp(n)); %the degree of first visted node
    temp_degree=degree(inRangIdxs(:,1)==v & inRangIdxs(:,2)==temp(1));
    while n<=length(temp)
        if ~visited(temp(n)) 
            ini_degree=degree(inRangIdxs(:,1)==v & inRangIdxs(:,2)==temp(n)); %the degree of first visted node
            if abs(temp_degree-ini_degree)<=60
                visited(temp(n))=1;
                queue(end+1)=temp(n); 
                edgeList(k,:)=[v,temp(n)];
                k=k+1;
                search_delay=search_delay+5e-3;
            end
        end
        n=n+1;
    end
end
%build adjacency matrix A
% temp=max(edgeList(:));
ini=ini2struct('config.ini');
A=sparse(edgeList(:,1),edgeList(:,2),1,ini.constants.Node,ini.constants.Node);
A=full(A);
A=A+tril(A,1)'; %A's upprt triangle matrix contains all edges
end

