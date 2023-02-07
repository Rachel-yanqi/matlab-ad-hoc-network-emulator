%test case for adaptive antenna
%antenna can change its beamwidth according to velocity
addpath('function')
addpath('classes')
%%
clc;    clear variables;     
%Geometric Setting
ini=ini2struct('config.ini');
halo_radius=350;
halo_cutoff=2*halo_radius;
mean_velocity=50;
%% 
Signal_strength = ini.constants.Signal_strength;
number_of_nodes=ini.constants.Node;
node(1:number_of_nodes)=Node;
phantom=Phantom();
route.optpath=[];
% node(1)=Node(1,10,30,10,0,'sender');
% rng('default')
% X_Coord = 20*rand(1,number_of_nodes);
% rng(5)
% Y_Coord = 30*rand(1,number_of_nodes);
% for i=1:length(X_Coord)
%     if ismember(i+1,ini.constants.Receiver_ID)
%         node(i+1)=Node(i+1,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i),'receiver');
%     else
%         node(i+1)=Node(i+1,X_Coord(i),Y_Coord(i),X_Coord(i),Y_Coord(i));
%     end
% end
% number_of_nodes=number_of_nodes+1;
X_Coord=[1,0.8,0.85,1.1,1.4,0.2,1.8,0.3,0,0.8,0.3,1.3,2.1,1.1,1.5,1]*1000;
Y_Coord=[3,2,1.8,2.3,1.5,1,1,0.9,0.5,0.75,0,0.9,0.75,0.9,0.2,0.3]*1000;
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
%%
for t=0:ini.constants.Sample_frequency:ini.constants.Simulation_time
%update nodes
    for i=1:number_of_nodes
        [x,y] = mobility(node(i).x,node(i).y,node(i).gaussian.get_speed()*ini.constants.Sample_frequency,node(i).gaussian.get_dir());
        node(i).set_coord(x,y);
        node(i).gaussian.movement();
        
    end
   
    switch ini.mac.proto
        case 'omni'  %broadcast
            [idxs,mac_delay]=topology(1:number_of_nodes,X_Coord,Y_Coord,Signal_strength);
        case 'directional' %directional cast
            [idxs,mac_delay]=topologydir(number_of_nodes,sender_ID,X_Coord,Y_Coord,Signal_strength);
        case 'halo'
            [idxs,phantom,mac_delay]=halo(node,halo_cutoff,phantom);   
        case 'adaDir'
%             [idxs,mac_delay]=topology(1:number_of_nodes,X_Coord,Y_Coord,Signal_strength);   %initialize a omni topology
            idxs = adaptiveAntenna(ini.constants.Speed,Signal_strength,node);     %updating topology with dir antenna
    end
    
    G=graph(idxs,'upper');
    G.Edges.Weight=EdgeWeights(G,node);
%     
    h=plot(G,'XData',X_Coord,'YData',Y_Coord,'EdgeColor',[0,0.7,0.9],...
        'NodeColor','b');
    axis([-500 3100 -500 3500]);
    txt=sprintf('time = %.3f\n',t);
    text(2500,2500,txt);

%     [path,virtual_node]=Routing(G,node,routing_topology,sender_ID);
    [route,~]=Routing(G,node,ini,phantom,route);

    
    for i=1:length(route)
        highlight(h,route(i).optpath,'EdgeColor',"red","LineWidth",4);
    end
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
    
    %     -------------------QoS part start-----------------------------
    for i=1:number_of_nodes
        for j=1:number_of_nodes
            if i~=j && route_table(i,j)==1
                node(i).connectListener(node(j),t);
%                 fprintf("node %d busy %d; node %d busy %d\n",i,node(i).link.checkLinkBusy,...
%                 j,node(j).link.checkLinkBusy);
            end
        end
%         fprintf("\nnode 1 generated %d batch at %2.4f\n",node(1).timer,t)
    end
%     fprintf("node 1 has %d packets\n",node(1).queue.getNumber());
%     fprintf("\n");
end
%% Print Statiscs
if ini.vis.showStat == 1
    printStat(node,ini,t);
end