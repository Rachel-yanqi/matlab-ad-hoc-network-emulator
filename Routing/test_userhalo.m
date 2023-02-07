%test user halo cases 
%build connection inside user halo

addpath('function')
addpath('classes')
%%
clc; clear 
ini=ini2struct('config.ini');
global Signal_strength
Signal_strength=ini.constants.Signal_strength;
halo_radius=350;
halo_cutoff=2*halo_radius;
route.optpath=[];   route.halopath=[];
node(1:ini.constants.Node)=Node;
number_of_nodes=ini.constants.Node;
% phantom=Phantom();
X_Coord=[1,0.5,0.65,1.5,1.5,0.2,1.8,0.3,0,0.8,0.3,1.3,2.1,1.1,1.5,1]*1000;
Y_Coord=[2.5,2,1.8,2,1.6,1,1,0.9,0.5,0.75,0,0.9,0.75,0.9,0.2,0.3]*1000;
% Initial nodes
for i=1:length(X_Coord)
    if i==ini.constants.Sender_ID
        node(i)=Node(i,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i),'sender');
    elseif ismember(i,ini.constants.Receiver_ID)
        node(i)=Node(i,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i),'receiver');
    else
        node(i)=Node(i,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i));
    end
end
warning_counter=0;
%% Main Program
for t=0:ini.constants.Sample_frequency:ini.constants.Simulation_time
%update nodes
    for i=1:number_of_nodes
        [x,y] = mobility(node(i).x,node(i).y,node(i).gaussian.get_speed()*ini.constants.Sample_frequency,node(i).gaussian.get_dir());
        node(i).set_coord(x,y);
        node(i).gaussian.movement();
        
    end
%     fprintf("node %d speed %4.3f, dir %f\n",1,node(1).gaussian.get_speed(),node(1).gaussian.get_dir());
%     fprintf("node 1 locate at x: %4.2f, y: %4.2f\n",node(1).x,node(1).y);
%     fprintf("\n");
 % Degine MAC layer  
    switch ini.mac.proto
        case 'omni'  %broadcast
            [idxs,mac_delay]=topology(1:number_of_nodes,X_Coord,Y_Coord,Signal_strength);
        case 'directional' %directional cast
            [idxs,mac_delay]=topologydir(number_of_nodes,sender_ID,X_Coord,Y_Coord,Signal_strength);
        case 'halo'
            [idxs,phantom,mac_delay]=halo(node,halo_cutoff,phantom);
        case 'userhalo'
            [idxs,mac_delay]=topology(1:number_of_nodes,X_Coord,Y_Coord,Signal_strength);
            user=Userhalo(node,halo_cutoff,ini.constants.Speed);
            
    end
    
    G=graph(idxs,'upper');
    G.Edges.Weight=EdgeWeights(G,node);

%draw nodes
    X_Coord=zeros(number_of_nodes,1);
    Y_Coord=zeros(number_of_nodes,1);
    for i=1:number_of_nodes
        X_Coord(i)=node(i).x;
        Y_Coord(i)=node(i).y;
    end
    if ini.vis.showPlot==1
        ploting(G,X_Coord,Y_Coord,t,user,ini);
    end
    
    for i=1:numel(user)
        members = user(i).members;
        if length(members)==1
            gateway=members;
        end
        temp_weight = 100;
        for j=1:length(members)
            [path,cost]=shortestpath(G,ini.constants.Sender_ID,members(j));
            if cost < temp_weight
                gateway=members(j);
                temp_weight = cost;
            end
            
%             TF1 = G.Edges.EndNodes(:,1)==members(j);
%             TF2 = G.Edges.EndNodes(:,2)==members(j);
%             TF = TF1 || TF2;
%             edges = G.Edges.EndNodes(TF,:);                     
        end
        user(i).set_gateway(gateway);
    end
    clear members temp_weight
   
    % Build Routing layer
    [route,~]=Routing(G,node,ini,user,route);
    
    route_table=zeros(number_of_nodes,number_of_nodes);
    for i=1:length(route)
        for k=1:length(route(i).optpath)-1
            A_start=route(i).optpath(k);
            A_end=route(i).optpath(k+1);
            route_table(A_start,A_end)=1;
        end
    end
    clear A_end A_start
    
    for i=1:number_of_nodes
        node(i).routing_table=build_table(route_table,i,number_of_nodes);
    end
    %%    -------------------QoS part start-----------------------------
    for i=1:number_of_nodes
        for j=1:number_of_nodes
            if i~=j && route_table(i,j)==1
                node(i).connectListener(node(j),t);
                fprintf("node %d busy %d; node %d busy %d\n",i,node(i).link.checkLinkBusy,...
                    j,node(j).link.checkLinkBusy);
            end
        end
        
    end
    
    if node(ini.constants.Receiver_ID(2)).link.checkLinkBusy == 0       %build a warning
        warning_counter=warning_counter+1;
        warning_route=route;
        if warning_counter > 50
            warning("Frozen?"); 
            for i=1:number_of_nodes
                node(i).link.reset;
            end
            warning_counter=0;
            pause(1);
        end
    else 
        warning_counter=0;
    end
    fprintf("node 1 has %d packets\n",node(1).queue.getNumber());
    fprintf("\n");

end
%% Print Statiscs
if ini.vis.showStat == 1
    printStat(node,ini,t);
end