function [A,search_delay] = halo_topology(node,phantom,Signal_strength)
%build link pairs between nodes
%a node only search inside its node_halo pair
%return a link map A

% search_delay=0;
% A=zeros(length(node));
% for i=1:numel(node)
%     target = NH_pair(i);    %target is halo id value
%     for j=1:length(target)
%         nlist=phantom(target(j)).members;   %nlist is node id inside this halo
%         for k=1:length(nlist)
%             try
%                 if sqrt((node(i).x-node(nlist(k)).x)^2+(node(i).y-node(nlist(k)).y)^2) < Signal_strength...
%                     && i~=nlist(k)    %distance lesser than RF and not the same node
%                     search_delay=search_delay+1;      %searching frequency
%                     if hypot(X_next-phantom(target(j)).x,Y_next-phantom(target(j)).y) <= phantom(target(j)).radius
%                         A(i,nlist(k))=1;
%                     end
%                     
%                 end
%             catch 
%                 fprintf('node i: %d  to node j: %d\n',i,nlist(k));
%             end
%         end
%     end
% end
% search_delay=search_delay*10e-3;
% fprintf('total searching time is: %d',time);

%select the best relay (won't move out of halo in next time slot) in each halo
nlist=[];   search_delay=0;
for i=1:numel(phantom)
    members=phantom(i).members;
    for j=1:length(members)
        X_next = node(members(j)).next_x;
        Y_next = node(members(j)).next_y;
        dist=hypot(X_next-phantom(i).x,Y_next-phantom(i).y);
        if dist<=phantom(i).radius
            nlist(end+1)=members(j);
        end
        node(members(j)).set_phantom(phantom(i).id);
    end
end
nlist=unique(nlist);
nlist=[1,nlist]; %add sender
%build mac neighbor table (node belong to halo, node will not leave halo in
%next time slot)
A=zeros(numel(node));
for i=1:numel(node)
    for j=1:numel(node)
        if ismember(i,nlist) && ismember(j,nlist)
            dist=hypot(node(i).x-node(j).x,node(i).y-node(j).y);
            if dist<=Signal_strength && i~=j
                A(i,j)=1;
                search_delay=search_delay+10e-3;
            end
        end
    end
end
end  

