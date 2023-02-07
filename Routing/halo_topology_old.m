function halo_idxs=halo_topology_old(phantom,node)
%testbed
% Input
%input: phantom,  node
global Signal_strength
%%  Use halo to create topology
%1. create connected graph with phantom instead of real relays
%2. pick the high priority node (more stable)
%3. connect picked relays with receivers

%prerequists
sender_ID=zeros(1,1);
% receiver(1,1)=Node(); %need upgrade!!! if we don't know number of receivers
% receiver_ID=zeros(numel(receiver),1);
j=1;
XYCoord=zeros(numel(node),2);
for i=1:numel(node)
    if node(i).properity=="receiver"
        receiver_ID(j)=node(i).id;
        j=j+1;
    elseif node(i).properity=="sender"
        sender_ID=node(i).id;
    end
    XYCoord(i,1)=node(i).x;
    XYCoord(i,2)=node(i).y;
end
%% 2.
% %connect between phantoms
% %connect sender with the closet relay
% %connect receiver with the closet relay
% for i=1:numel(phantom)
%     members=phantom(i).members;
%     inside_idx=nchoosek(members,2);  %ok for one phantom
% end
% phantom_G=graph(inRangIdxs(:,1),inRangIdxs(:,2),weight);
% adj=adjacency(phantom_G);  %create adjancy matrix
% connection_matrix=triu(full(adj));
% relay_idxs=zeros(size(inRangIdxs,1),1);
% lines=1;
% for i=1:length(connection_matrix)
%     for j=1:length(connection_matrix)
%         if connection_matrix(i,j)==1
% %             P_id=phantom(i).members;
% %             
% %             PQ_id=phantom(j).members;
%             
% %             relay_idxs(lines,1)=phantom(i).members(1); %pick the member closet to the other phantom
% %             relay_idxs(lines,2)=phantom(j).members(1);
%             lines=lines+1;
%         end
%     end
% end
% %connect inside phantom

% %% 3. connect sender and receiver to phantoms
% dist=squareform(pdist(XYCoord));
% relay_ID=zeros(numel(phantom),1);
% backup=[];
% quality=[];
% for i=1:numel(phantom)
%     member_id=phantom(i).members;
%     for j=1:numel(member_id)
%         TFS = dist(sender_ID,member_id(j)) < Signal_strength; %sender side
%         TFR = dist(receiver_ID,member_id(j)) < Signal_strength; %receiver side multiple receivers
%         if sum(TFR) < numel(TFR)
%             TFR = false;
%         else
%             TFR = true;
%         end
%         if TFS && TFR  %member can connect both sender and receiver
%             backup=[backup;member_id(j)];
%             temp=member_id(j);
%         else 
%             continue;
%         end  
%         %check stability of temp
%         SR=0;
%         SS = node(sender_ID).calLET(node(temp),Signal_strength);
%         for k=1:numel(receiver_ID)
%             SR = SR+node(receiver_ID(k)).calLET(node(temp),Signal_strength);
%         end
%         quality=[quality, SS + SR];
%         
% %         %balanced transmission distance
% %         if abs(dist(sender_ID,member_id(j))-dist(receiver_ID(1),member_id(j)))<mindiff
% %             mindiff=abs(dist(sender_ID,member_id(j))-dist(receiver_ID(1),member_id(j)));
% %             relay_ID(i)=member_id(j);
% %         end
%         
%     end
%     [~,idx]=min(quality);
%     relay_ID=backup(idx);
% end
% % create edge lists
% relay_ID=relay_ID(relay_ID~=0); %delete zeros 
% if isempty(relay_ID) 
%     %choose a member node for sender and receiver
%     relay_ID=phantom.members;
%     relay_ID=relay_ID';
%     inside_sender = dist(sender_ID,relay_ID)<Signal_strength;
%     inside_sender = inside_sender';
%     inside_receiver = dist(receiver_ID,relay_ID)<Signal_strength;  
%     inside_receiver = inside_receiver';
%     T=table(relay_ID,inside_sender,inside_receiver);
%     Squality=zeros(size(relay_ID));
%     Rquality=zeros(size(relay_ID));
%     for i=1:length(T.relay_ID)
%         Squality(i)=node(sender_ID).calLET(node(T.relay_ID(i)),Signal_strength);
%         for j=1:length(receiver_ID)
%             Rquality(i)=Rquality(i)+node(receiver_ID(j)).calLET(node(T.relay_ID(i)),Signal_strength);
%         end
%     end
%     T=addvars(T,Squality,Rquality);
%     clear Squality Rquality TFS TFR
%     %first check if inside sender range, then select min quality value
%     backup=T.relay_ID(inside_sender==1);
%     [~,idx]=min(T.Squality(ismember(T.relay_ID,backup)));
%     relay_ID=T.relay_ID(idx);
%     %receiver side
%     clear idx
%     TF1=and(T.inside_receiver(:,1),T.inside_receiver(:,2));
%     if TF1==0  %no relay can connect both receivers
%         TF2=or(T.inside_receiver(:,1),T.inside_receiver(:,2));
%         backup=T.relay_ID(TF2);
%         [~,idx]=min(T.Rquality(T.relay_ID==backup));
%         relay_ID=[relay_ID,T.relay_ID(idx)];
%         %set connected receiver as relay
%         temp=receiver_ID( T.inside_receiver(idx,:)==1);
%         relay_ID(end+1)=temp;
%         clear temp
%     else
%         backup=T.relay_ID(TF1);
%         [~,idx]=min(T.Rquality(T.relay_ID==backup));
%         relay_ID(end+1)=T.relay_ID(idx);
%     end
%     
% end
% relay_ID=unique(relay_ID);
% relay_ID=reshape(relay_ID,[],1);
% ID1s=vertcat(sender_ID, relay_ID,receiver_ID');
% ID1s=unique(ID1s);
% halo_idxs=nchoosek(ID1s,2);
% clear dist
% dist=hypot(XYCoord(halo_idxs(:,1),1)-XYCoord(halo_idxs(:,2),1),XYCoord(halo_idxs(:,1),2)-XYCoord(halo_idxs(:,2),2));
% TF=dist<=Signal_strength;
% halo_idxs=halo_idxs(TF,:);


%% choose one member in each phantom output is graph link
dist=squareform(pdist(XYCoord));
relay_ID=zeros(1,numel(phantom));
for i=1:numel(phantom)
    Squality=zeros(numel(phantom(i).members),1); 
    Rquality=zeros(numel(phantom(i).members),1);
    for j=1:numel(phantom(i).members)
        %sender side 
        if dist(sender_ID,phantom(i).members(j))<Signal_strength
            Squality(j)=node(sender_ID).calLET(node(phantom(i).members(j)),Signal_strength);
        end
        %receiver side
        for k=1:numel(receiver_ID)
            if dist(receiver_ID(k),phantom(i).members(j))<Signal_strength
                Rquality(j)=Rquality(j)+node(receiver_ID(k)).calLET(node(phantom(i).members(j)),Signal_strength);
            end
        end
        
    end
    if nonzeros(Squality)
        [~,I]=min(Squality);
        relay_ID(i)=phantom(i).members(I);
    end
    if nonzeros(Rquality)
        [~,I]=min(Rquality);
        relay_ID(i)=phantom(i).members(I);
    end
end
relay_ID(relay_ID==0)=[];
relay_ID=horzcat(sender_ID,relay_ID,receiver_ID);
relay_ID=unique(relay_ID);
halo_idxs=topology(relay_ID,XYCoord(:,1),XYCoord(:,2),Signal_strength);
end