% Fron low mobility to high

% addpath('function');
% addpath('classes');
%%
clear variables;     clc
%Geometric Setting
ini=ini2struct('config.ini');
% global Signal_strength
Signal_strength = ini.constants.Signal_strength;
halo_radius=sqrt(2)/2*500;
halo_cutoff=2*halo_radius;
number_of_nodes=ini.constants.Node;
X_Coord=[600,400,700,1000,200,600,800,1100,1200,1700,400,1500];
Y_Coord=[3300,2500,2600,2550,1700,1800,2000,1600,1700,1300,800,700];
node(1:number_of_nodes)=Node();
for i=1:number_of_nodes
    if i==ini.constants.Sender_ID
        node(i)=Node(i,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i),'sender');
    elseif ismember(i,ini.constants.Receiver_ID)
        node(i)=Node(i,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i),'receiver');
    else
        node(i)=Node(i,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i));
    end
end

phantom=Phantom();
route.optpath=[];   route.halopath=[];
X_Coord=zeros(number_of_nodes,1);
Y_Coord=zeros(number_of_nodes,1);
%%
%main program
for t=0:ini.constants.Sample_frequency:ini.constants.Simulation_time-1

    for i=1:number_of_nodes
        X_Coord(i)=node(i).x;
        Y_Coord(i)=node(i).y;
    end
        % updating nodes
%     for i=1:number_of_nodes
%         node(i).trail.movement();
%         [X_Coord(i),Y_Coord(i)] = mobility(node(i).x,node(i).y,...
%             (node(i).trail.speed*ini.constants.Sample_frequency),node(i).trail.dir);
%         node(i).setCoord(X_Coord(i),Y_Coord(i));
%     end
    
    switch ini.mac.proto
        case 'omni'  %broadcast
            [idxs,mac_delay]=topology(1:number_of_nodes,X_Coord,Y_Coord,Signal_strength);
        case 'directional' %directional cast
            [idxs,~]=topologydir(number_of_nodes,ini.constants.Sender_ID,X_Coord,Y_Coord,Signal_strength);
        case 'halo'
            [idxs,phantom,mac_delay]=halo(node,halo_cutoff,phantom);   
         case 'adaDir'
            idxs = adaptiveAntenna(ini.constants.Speed,Signal_strength,node);     %updating topology with dir antenna
    end
    
    G=graph(idxs,'upper');
    G.Edges.Weight=EdgeWeights(G,node);

    if mod(t,10)==0      
        [route,virtual_node]=Routing(G,node,ini,phantom,route);
        if virtual_node.id ~= 0
            number_of_nodes=numel(node)+numel(virtual_node);
            node(number_of_nodes)=virtual_node;
        end
    end
%     h=plot(G,'XData',X_Coord,'YData',Y_Coord,'EdgeColor',[0,0.7,0.9],...
%         'NodeColor','b');
%     axis([0 3100 0 4000]);
%     txt=sprintf('time = %2.3f\n',t);
%     text(500,500,txt);
%     for i=1:length(route)
%         highlight(h,route(i).optpath,'EdgeColor',"red","LineWidth",4);
%     end
%     
%%
    route_table=zeros(number_of_nodes,number_of_nodes);
    for i=1:length(route)
        for k=1:length(route(i).optpath)-1
            A_start=route(i).optpath(k);
            A_end=route(i).optpath(k+1);
            route_table(A_start,A_end)=1;
        end
    end
    clear A_end A_start
   %%
    for i=1:number_of_nodes
        node(i).routing_table=build_table(route_table,i,number_of_nodes);
    end
  
    
%     -------------------QoS part start-----------------------------
    for i=1:number_of_nodes
        for j=1:number_of_nodes
            if i~=j && route_table(i,j)==1
                node(i).connectListener(node(j),t);
%                 fprintf("node %d busy %d; node %d busy %d\n",i,node(i).link.checkLinkBusy,...
%                     j,node(j).link.checkLinkBusy);
            end
        end
        
    end
    % -------------------QoS part end-----------------------------
%     fprintf("node 1 has %d packets\n",node(1).queue.getNumber());
%     fprintf("\n");
end
%% Print Statiscs
if ini.vis.showStat == 1
    printStat(node,ini,t);
end