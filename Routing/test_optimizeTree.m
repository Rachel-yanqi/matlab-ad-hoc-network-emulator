 clear 

% addpath('function');
% addpath('classes');
%%
ini=ini2struct('config.ini');
Signal_strength=ini.constants.Signal_strength;
number_of_nodes=ini.constants.Node;

node(1:number_of_nodes)=Node;
node(1)=Node(1,900,2000,1000,2000,"sender");
node(2)=Node(2,500,1500,500,1500,"relay");
node(3)=Node(3,500,1000,500,1000,"relay");
node(4)=Node(4,500,480,500,480,"receiver");
node(5)=Node(5,1200,1500,1500,1500,"relay");
node(6)=Node(6,1205,1000,1505,1000,"relay");
node(7)=Node(7,1205,480,1505,480,"receiver");
node(8)=Node(8,800,750,1000,750);
node(9)=Node(9,1600,1500,1600,1500);
node(10)=Node(10,1660,1000,1660,1000);
node(11)=Node(11,1670,500,1670,500,'receiver');
route.optpath=[];   route.halopath=[];
phantom=Phantom();

X_Coord=zeros(number_of_nodes,1);
Y_Coord=zeros(number_of_nodes,1);
for t=0:ini.constants.Sample_frequency:ini.constants.Simulation_time
    
    for i=1:number_of_nodes
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
%     [path,virtual_node]=Routing(G,node,routing_topology,sender_ID);
  
    [route,~]=Routing(G,node,ini,phantom,route);
    
    h=plot(G,'XData',X_Coord,'YData',Y_Coord);
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
            end
        end
    end
%     fprintf("\nnode 1 has %d packets\n",node(1).queue.getNumber());
%     fprintf("\nnode 1 busy %d, node 2 busy %d, node 3 busy %d, node 4 busy %d\n", ...
%         node(1).link.checkLinkBusy,node(2).link.checkLinkBusy,node(3).link.checkLinkBusy,node(4).link.checkLinkBusy);
end
%% Print Statiscs
S=node(ini.constants.Sender_ID).packets.sent*ini.constants.Packet_size*8/((t)*1e6); %sending rate Mbps
fprintf("Sending rate is: %4.2f Mbps\n",S);
%average three receiver
T=0;    D=0;
for i=1:length(ini.constants.Receiver_ID)
    T=T+node(ini.constants.Receiver_ID(i)).packets.rcvd*ini.constants.Packet_size*8/((t)*1e6); 
    rcv_frames=ceil(node(ini.constants.Receiver_ID(i)).packets.rcvd/ini.constants.Frame_size);
    D=D+ node(ini.constants.Receiver_ID(i)).packets.delay/rcv_frames;
end
T=T/length(ini.constants.Receiver_ID);  D=D/length(ini.constants.Receiver_ID);
fprintf("Throughput is: %4.4f Mbps\n",T);
fprintf("Delay is: %4.4f ms \n",D*1000);
T=node(ini.constants.Receiver_ID(3)).packets.rcvd*ini.constants.Packet_size*8/((t)*1e6);
rcv_frames=ceil(node(ini.constants.Receiver_ID(3)).packets.rcvd/ini.constants.Frame_size);
D=node(ini.constants.Receiver_ID(3)).packets.delay/rcv_frames;
fprintf('First receiver throughput is:  %4.4f Mbps\n',T);
fprintf('First receiver delay is: %4.4f ms\n\n',D*1000);