%test for tsp (directional)
clear

% addpath('function');
% addpath('classes');
%% Initialization
ini=ini2struct('config.ini');
Signal_strength=ini.constants.Signal_strength;
number_of_nodes=ini.constants.Node;
route.optpath=[];
phantom=Phantom();

node(1:number_of_nodes)=Node;
node(1)=Node(1,2000,3000,2000,3500,'sender');
node(2)=Node(2,2000,1500,1500,3000,'receiver');
node(3)=Node(3,0,500,700,1300,'receiver');
node(4)=Node(4,1200,700,1700,500,'receiver');
node(5)=Node(5,2200,200,2200,0,'receiver');
node(6)=Node(6,3500,500,3500,800,'receiver');
node(7)=Node(7,1200,1000,2000,2000);
node(8)=Node(8,1000,2700,1000,2700);
node(9)=Node(9,2600,2000,3000,1400);
node(10)=Node(10,2700,2700,2500,2700);
for i=1:number_of_nodes
    node(i).set_antenna(ini.phy.beamwidth,ini.constants.Signal_strength);
end
X_Coord=zeros(number_of_nodes,1);
Y_Coord=zeros(number_of_nodes,1);

for t=0:ini.constants.Sample_frequency:ini.constants.Simulation_time
    
    for i=1:number_of_nodes
        if mod(t,1)==0
            [x,y] = mobility(node(i).x,node(i).y,node(i).gaussian.get_speed(),node(i).gaussian.get_dir());
            node(i).set_coord(x,y);
            node(i).gaussian.movement();
        end
        X_Coord(i)=node(i).x;
        Y_Coord(i)=node(i).y;
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
    
    % Build Routing layer
    if mod(t,1)==0
        [route,~]=Routing(G,node,ini,phantom,route);
        h=plot(G,'XData',X_Coord,'YData',Y_Coord);
        txt=sprintf('time = %.3f\n',t);
        text(2500,2500,txt);
        for i=1:length(route)
            highlight(h,route(i).optpath,'EdgeColor',"red","LineWidth",4);
        end
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
        node(i).routing_table=build_table(route_table,i,X_Coord,Y_Coord);
    end
  %%  
   check_busy=zeros(1,number_of_nodes);
    %     -------------------QoS part start-----------------------------
    for i=1:number_of_nodes
%         multicast_table=multicast(node,i);
        for j=1:number_of_nodes
            if i~=j && route_table(i,j)==1
                node(i).connectListener(node(j),t);
                fprintf("node %d busy %d; node %d busy %d\n",i,node(i).link.checkLinkBusy,...
                    j,node(j).link.checkLinkBusy);
            end
        end
        %saftey guard
        if check_busy(i)==node(i).link.checkLinkBusy && check_busy(i)~=0
            node(i).link.setBusy(0);
        end
        check_busy(i)=node(i).link.checkLinkBusy;
    end
    fprintf("node 1 has %d packets\n\n",node(1).queue.getNumber());
  
end
%% Print Statiscs
if ini.vis.showStat == 1
    printStat(node,ini,t);
end