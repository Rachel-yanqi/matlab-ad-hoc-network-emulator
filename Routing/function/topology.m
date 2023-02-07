function [A,searching_delay] = topology(node_array,X_Coord,Y_Coord,...
    Signal_strength)
%Topology Function
%   build link layer connection between real nodes
idxs=nchoosek(node_array,2);  %initialize

%calculate the distance
dist=hypot(X_Coord(idxs(:,1))-X_Coord(idxs(:,2)),Y_Coord(idxs(:,1))-Y_Coord(idxs(:,2)));
dist=round(dist);
TF1=(dist<=Signal_strength & dist~=0);
% fprintf('total searching time is: %d\n',length(TF1));
inRangIdxs=idxs(TF1,:);
searching_delay=length(TF1)*10e-3;

%one extra step to achieve 1/3 duplex: delete all edges to 1 except (1,2)
% TF2=and(idxs(:,1)==1, idxs(:,2)~=2);
% inRangIdxs(TF2,:)=[];


%build adjacency matrix A
% temp=max(inRangIdxs(:));
A=sparse(inRangIdxs(:,1),inRangIdxs(:,2),1,length(X_Coord),length(Y_Coord));
A=full(A);
% searching_delay=0.5;
end

