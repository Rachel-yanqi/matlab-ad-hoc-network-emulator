function [low_path,virtual_node]=Routing(G,node,ini,phantom,~)
% Routing Protocol for Mobility ad-hoc Network
% Find route

% reply dest request

% Path repair

%------------------test start-----------------
%G=graph(idxs,'upper');
% topology_name='tree_opm';
% sender_ID=1;
%------------------test end--------------------

XYCoord = zeros(1,1);  
receiver_ID = zeros(1,1);
virtual_node=Node();
j=1;
for i=1:numel(node)
    if node(i).properity=="receiver"
        receiver_ID(j)=node(i).id;
        XYCoord(j,1)=node(i).x;
        XYCoord(j,2)=node(i).y;
        j=j+1;
    end
end

%% Prerequist
maxcost=realmax;
link_map=sparse(G.Edges.EndNodes(:,1),G.Edges.EndNodes(:,2),1,numel(node),numel(node));

switch lower(ini.routing.proto)
    case 'benchmark'
        %build new route if old route is not avaliable
%         if ~isconnected(link_map,old_path.optpath)
            low_path= repmat(struct('optpath',1),length(receiver_ID),1);
            for i=1:length(receiver_ID)
                [low_path(i).optpath,cost1]=shortestpath(G,ini.constants.Sender_ID,receiver_ID(i));
            
%                 G_rm=rmedge(G,low_path(i).optpath(end-1),low_path(i).optpath(end));
%                 [path2,cost2]=shortestpath(G_rm,ini.constants.Sender_ID,receiver_ID(i));
%                 try 
%                     if length(path2) < length(low_path(i).optpath)
%                         if abs(cost1-cost2) < 0.01
%                             low_path(i).optpath=path2;
%                         end
%                     end
%                 catch
%                     warning("no alternative route");
%                 end
            end
%         else
%             low_path=old_path;
%         end
    case 'tsp'  %(tsp for receiver nodes, more than two)
        LowConfig=struct('XY',XYCoord,'SHOWPROG',0,'SHOWRESULT',0); 
        tsp = tspo_ga(LowConfig);
       %if distance between nodes exceed RF range, add a virtual node
        for i=1:numel(tsp.optRoute)-1
            distance=hypot(XYCoord(tsp.optRoute(i),1)-XYCoord(tsp.optRoute(i+1),1),...
                XYCoord(tsp.optRoute(i),2)-XYCoord(tsp.optRoute(i+1),2));
            if distance<ini.constants.Signal_strength
                continue;
            else
                %1. generate a virtual new node
                 virtual_node=Node(numel(node)+1,...
                     (XYCoord(tsp.optRoute(i),1)+XYCoord(tsp.optRoute(i+1),1))/2,...
                     (XYCoord(tsp.optRoute(i),2)-XYCoord(tsp.optRoute(i+1),2))/2,...
                     0,0);
                %2. mark the virtual node inserting position
                virtual_position=i; 
            end
        end
        if virtual_node.id==0
            low_path(1).optpath = receiver_ID(tsp.optRoute(:));
        else %insert the virtual node
            low_path(1).optpath = [receiver_ID(tsp.optRoute(1:virtual_position)),...
                virtual_node.id,receiver_ID(tsp.optRoute(virtual_position+1:end))];
        end
        for i=1:numel(receiver_ID)
            [path,cost1]=shortestpath(G,ini.constants.Sender_ID,receiver_ID(i));
            if cost1 < maxcost
                maxcost=cost1;
                shortest_path = path;
            end
            
%             
%             [path2,cost2]=shortestpath(G_rm,ini.constants.Sender_ID,receiver_ID(i));
%             try 
%                 if length(path2) < length(low_path(i).optpath)
%                 end
%             catch
%                 warning("no route");
%             end
        end
        G_rm=rmedge(G,shortest_path(end-1),shortest_path(end));
        [path2,cost2]=shortestpath(G_rm,ini.constants.Sender_ID,shortest_path(end));
        if length(path2) < length(shortest_path)
            if abs(cost1-cost2) < 100
                 shortest_path = path2;
            end
        end
        low_path(2).optpath = shortest_path;
        
        %correct the start and terminal on each route 
        index=find(low_path(1).optpath==shortest_path(end));
        low_path(3).optpath = low_path(1).optpath(index:end);
        low_path(1).optpath = flip(low_path(1).optpath(1:index));
    case 'tree_opm'
        %build route: shortest path
        low_path= repmat(struct('optpath',1),length(receiver_ID),1);
        hops = 0;      cost=zeros(1,2);
        for i=1:length(receiver_ID)
            [low_path(i).optpath,cost(i)]=shortestpath(G,ini.constants.Sender_ID,receiver_ID(i));
            hops=hops + length(low_path(i).optpath);      %number of hops
        end
        path_cost=sum(cost);        %total cost 
        %optimize tree 
        %parent node from the shortest branch
        [~,index]=min(cost);
        parent=low_path(index).optpath(end-1);
%         for i=1:length(receiver_ID)-1
%             parent=low_path(i).optpath(end-1);
        for j=1:length(receiver_ID)
            if j ~= index
                [branch,branch_cost]=shortestpath(G,parent,receiver_ID(j));
                if ~isempty(branch)
                    apath_cost=path_cost-cost(j)+branch_cost;
                    if apath_cost < path_cost
                        low_path(j).optpath=branch;   %next receiver updates its route
                        path_cost = apath_cost;       %update total cost
                    end
                end
            end
        end
%         end
%         [~,pred] = minspantree(G);
%         %build route: minimum spanning tree
%         low_path= repmat(struct('optpath',1),length(receiver_ID),1);
%         for i=1:length(receiver_ID)
%             route = receiver_ID(i);
%             k = receiver_ID(i);
%             while pred(k) ~= 0
%                 route(2:end+1)=route;
%                 route(1)=pred(k);
%                 k = pred(k);
%             end
%             low_path(i).optpath = route;
%         end
        
    case 'halo'  % halo multicast //naive way: shortest path to each receiver node//
        low_path= repmat(struct('optpath',1),length(receiver_ID),1);
        for i=1:length(receiver_ID)
            [low_path(i).optpath,~]=shortestpath(G,ini.constants.Sender_ID,receiver_ID(i));
            halo_path=zeros(size(low_path(i).optpath));
            for j=1:length(low_path(i).optpath)
                node_id=low_path(i).optpath(j);     %pick up one point
                for k=1:numel(phantom)
                    if ismember(node_id,phantom(k).members)
                        halo_path(j)=phantom(k).id;        %create halo_route
                        break;
                    end
                end
            end
            low_path(i).halopath=halo_path;
        end
        %maintain old route
%         if ~isempty(old_path.halopath)
%             for i=1:length(low_path)
%                 if ismember(low_path(i).halopath,old_path(i).halopath)
%                     %choose halo's member, better remain same route
%                     if isconnected(link_map,old_path.optpath)
%                         low_path(i).optpath=old_path(i).optpath;
%                     end
%                 end
%             end
%         end
%         A=minspantree(G);
        
%         [A,D]=shortestpathtree(graph_object,sender_ID,receiver_ID);
%         fprintf("path distance %1.1f", d);
%         fprintf("tree distance %1.1f", D);
    %build route to user halo, receiver is gateway
    case 'userhalo'
        user = phantom;     gateway=zeros(1,numel(user));
        low_path= repmat(struct('optpath',1),length(receiver_ID),1);
        for i=1:numel(user)
            gateway(i)=user(i).get_gateway;
        end
        for i=1:length(gateway)
            %path from sender to gateway
            [low_path(i).optpath,cost1]=shortestpath(G,ini.constants.Sender_ID,gateway(i));          
            %path from gateway to receiver (naive first, direct to receiver
            if gateway(i) ~= receiver_ID(i) 
                if ~ismember(receiver_ID(i),low_path(i).optpath)
                    low_path(i).optpath(end+1)=receiver_ID(i);
                else
                    [low_path(i).optpath,~]=shortestpath(G,ini.constants.Sender_ID,receiver_ID(i));
                end
            end
            
%             hop_count = length(low_path(i).optpath);
            %find the second shortest path (avoid too many hops)
            G_rm=rmedge(G,low_path(i).optpath(end-1),low_path(i).optpath(end));
            [path2,cost2]=shortestpath(G_rm,ini.constants.Sender_ID,receiver_ID(i));
            try 
                if length(path2) < length(low_path(i).optpath)
                    if abs(cost1-cost2) < 100
                        low_path(i).optpath=path2;
                    end
                end
            catch
                warning("no route");
            end
            
        end
        
end
end
% %% output
% h=plot(G,'XData',X_Coord,'YData',Y_Coord);
% axis([-1000,3000,-1000,3000]);
% grid on
% for i=1:length(low_path)
%     highlight(h,low_path(i).optpath,'EdgeColor',"red","LineWidth",2);
% end
% highlight(h,low_path,'EdgeColor',"red","LineWidth",2);
% end