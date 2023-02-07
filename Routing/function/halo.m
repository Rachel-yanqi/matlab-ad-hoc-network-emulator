 function  [idxs,phantom,mac_delay]= halo(node,halo_cutoff,phantom)
%this function is used to create halos 
%Halo is determined by relays
%each halo must contain at least two relays
%output: phantom halo object array

%input 

% Output 
%halo_idxs and phantom node

global Signal_strength

%find relay nodes
relay_X=[];
relay_Y=[];
relay_ID=[];
receiver_ID=[];
X_Coord=zeros(numel(node),1);
Y_Coord=zeros(numel(node),1);
user_flag=0; %initial flag
j=1;    k=1;
for i=1:numel(node)
    if node(i).properity=="relay" && strcmp(node(i).haloinfo.user,'')
        relay_ID(j)=node(i).id;
        relay_X(j)=node(i).x;
        relay_Y(j)=node(i).y;
        j=j+1;
    elseif node(i).properity=="receiver"
        receiver_ID=[receiver_ID,node(i).id];
        
    else
        sender_ID=node(i).id;
    end
    X_Coord(i)=node(i).x;
    Y_Coord(i)=node(i).y;
end
Positions=[relay_X,relay_Y];
Positions=reshape(Positions,[size(relay_ID,2),2]);
index=[];
%check if old phantom contains at least two relys
for i=1:numel(phantom)
    phantom(i).members=[]; %empty membership
    count=0;
    for j=1:numel(relay_ID)
        if inCircle(phantom(i),node(relay_ID(j)))
            phantom(i).members(end+1)=relay_ID(j); 
            count=count+1;
        end
    end
    if count<2 && strcmp(phantom(i).properity,'phantom')
%         phantom(i)=Node(); %empty phantom
        phantom(i).id=0;
    else 
        index=[index,phantom(i).members]; %avaliable nodes in phantom
%         idxs=halo_topology(phantom,node);
%         return;
    end
    if strcmp(phantom(i).properity,'user')
        user_flag=1; %set flag
        phantom(i).x=X_Coord(receiver_ID(k));
        phantom(i).y=Y_Coord(receiver_ID(k));
        phantom(i).members=receiver_ID(k);
        k=k+1;
    end
end
for i=numel(phantom):-1:1
    if phantom(i).id==0
        phantom(i)=[];
    end
end
%find outside relay
index=unique(index);
TF=~ismember(relay_ID,index);
Positions=Positions(TF,:);
relay_ID=relay_ID(TF);

if size(Positions,1)<=2
      NH_pair=node_halo(node,phantom,Signal_strength+halo_cutoff);
%     idxs=halo_topology(phantom,node);
    index=sort([sender_ID,index,receiver_ID]);
%     [idxs,~]=topology(index,XCoord,YCoord,Signal_strength);
    [idxs,mac_delay]=halo_topology(node,phantom,Signal_strength);
%     [idxs,~]=topologydir(length(index),sender_ID,XCoord,YCoord,Signal_strength);
    
%     [~,mac_delay]=halo_topology(node,phantom,NH_pair,Signal_strength);
    return;
end
clear index TF count
%%   Clustering the relays and define halos
Pairwise_distance=linkage(Positions,'complete');
Clusters=cluster(Pairwise_distance,'cutoff',halo_cutoff,'criterion','distance');
%gscatter(Positions(:,1),Positions(:,2),Clusters);
%   Create halo node
halo_X=zeros(max(Clusters),1);
halo_Y=zeros(max(Clusters),1);
% halo_member=zeros(max(Clusters),1);
temp=numel(phantom);
% temp(1,max(Clusters))=Node();
for i=1:max(Clusters)
    X=mean(Positions(Clusters==i,1));
    Y=mean(Positions(Clusters==i,2));
    halo_member=sum(Clusters==i);
%     X=mean(relay_X(Clusters==i));
%     Y=mean(relay_Y(Clusters==i));
%     halo_member=numel(relay_X(Clusters==i));
    if halo_member<2
        temp=temp-1;
        continue;
    else
        halo_X(i)=X;
        halo_Y(i)=Y;
        phantom(i+temp)=Phantom(i+temp,X,Y,halo_cutoff/2);
        phantom(i+temp).assignMembership(relay_ID(Clusters==i));
        phantom(i+temp).set_properity('phantom');
%         temp(i)=Node(i,X,Y,"phantom");
%         temp(i).assignMembership(relay_ID(Clusters==i))
    end
    %find the control center for each halo
    member_position=Positions(Clusters==i,:);
    [k,~]=dsearchn(member_position,[X,Y]);
    center_id=Positions==member_position(k,:);
    center_id=and(center_id(:,1),center_id(:,2));
    phantom(i+temp).set_center(relay_ID(center_id));
end
%add user halo
% if user_flag==0
%     for i=1:length(receiver_ID)
%         phantom(length(phantom)+1)=Phantom(length(phantom)+1,X_Coord(receiver_ID(i)),...
%             Y_Coord(receiver_ID(i)),halo_cutoff/2);
%         phantom(end).assignMembership(receiver_ID(i));
%         phantom(end).set_properity('user');
%         halo_X(length(halo_X)+1)=node(i).x;
%         halo_Y(length(halo_Y)+1)=node(i).y;
%     end
% end
%% find node-halo pairs
%build link for halo structure, RF_strength = Signal_strength + halo_cutoff
NH_pair=node_halo(node,phantom,Signal_strength+halo_cutoff);
%% call halo_topology at here: get link map and searching time
[idxs,mac_delay]=halo_topology(node,phantom,Signal_strength);
% idxs=topology(1:numel(node),XCoord,YCoord,Signal_strength);
return;
 end