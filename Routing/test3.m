
clear 

addpath('function');
addpath('classes');
ini=ini2struct('config.ini');
Signal_strength=ini.constants.Signal_strength;
halo_radius=sqrt(2)/2*500;
halo_cutoff=2*halo_radius;
% number_of_nodes=ini.constants.Node;
number_of_nodes=4;
node(1:number_of_nodes)=Node;
node(1)=Node(1,0,0,0,0,'sender');
node(2)=Node(2,10,0,10,0,'receiver');
node(3)=Node(3,20,10,10,0,'receiver');
node(4)=Node(4,30,0,30,0,'receiver');
route.optpath=[];   route.halopath=[];
phantom=Phantom();
%%
for t=0:ini.constants.Sample_frequency:ini.constants.Simulation_time
    %update nodes
    for i=1:number_of_nodes
        [x,y] = mobility(node(i).x,node(i).y,node(i).gaussian.get_speed()*ini.constants.Sample_frequency,node(i).gaussian.get_dir());
        node(i).set_coord(x,y);
        node(i).gaussian.movement();
%         fprintf("node %d speed %4.3f, dir %3.3f\n",i,node(i).gaussian.get_speed(),node(i).gaussian.get_dir());
    end
%     fprintf("\n");
    
    X_Coord=zeros(number_of_nodes,1);
    Y_Coord=zeros(number_of_nodes,1);
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
        case 'userhalo'
            [idxs,mac_delay]=topology(1:number_of_nodes,X_Coord,Y_Coord,Signal_strength);
            user=Userhalo(node,halo_cutoff,ini.constants.Speed);
            
    end
    
    G=graph(idxs,'upper');
    G.Edges.Weight=EdgeWeights(G,node);
     h=plot(G,'XData',X_Coord,'YData',Y_Coord,'EdgeColor',[0,0.7,0.9],...
        'NodeColor','b');
    axis([-10 150 -10 130]);
    txt=sprintf('time = %.3f\n',t);
    text(40,20,txt);
    drawnow;
%     [path,virtual_node]=Routing(G,node,routing_topology,sender_ID);
%     if mod(t,30)==0
%         [route,~]=Routing(G,node,ini,phantom,route);
%     end
%     
%     route_table=zeros(number_of_nodes,number_of_nodes);
%     for i=1:length(route)
%         for k=1:length(route(i).optpath)-1
%             A_start=route(i).optpath(k);
%             A_end=route(i).optpath(k+1);
%             route_table(A_start,A_end)=1;
%         end
%     end
%     clear A_end A_start
%     
%     for i=1:number_of_nodes
%         node(i).routing_table=build_table(route_table,i,number_of_nodes);
%     end
%     
%     %     -------------------QoS part start-----------------------------
%     for i=1:number_of_nodes
%         for j=1:number_of_nodes
%             if i~=j && route_table(i,j)==1
%                 node(i).connectListener(node(j),t);
%             end
%         end
% %         fprintf("\nnode 1 generated %d batch at %2.4f\n",node(1).timer,t)
%     end
%     fprintf("\nnode 1 busy %d, node 2 busy %d, node 3 busy %d, node 4 busy %d\n", ...
%         node(1).link.checkLinkBusy,node(2).link.checkLinkBusy,node(3).link.checkLinkBusy,node(4).link.checkLinkBusy);
end
%% Print Statiscs
S=node(ini.constants.Sender_ID).packets.sent*ini.constants.Packet_size*8/((t)*1e6); %sending rate Mbps
fprintf("Sending rate is: %4.2f Mbps\n",S);
%average three receiver
% T=0;    D=0;
frame_number = node(ini.constants.Receiver_ID(1)).packets.rcvd/ini.constants.Frame_size;
% for i=1:length(ini.constants.Receiver_ID)
%     T=T+node(ini.constants.Receiver_ID(i)).packets.rcvd*ini.constants.Packet_size*8/((t)*1e6); 
%     D=D+node(ini.constants.Receiver_ID(i)).packets.delay;
% end
% T=T/length(ini.constants.Receiver_ID);  D=D/length(ini.constants.Receiver_ID)/frame_number;
% fprintf("Throughput is: %4.2f Mbps\n",T);
% fprintf("Delay is: %4.2f ms \n",D*1000);
T=node(ini.constants.Receiver_ID(1)).packets.rcvd*ini.constants.Packet_size*8/((t)*1e6);
D=node(ini.constants.Receiver_ID(1)).packets.delay/frame_number;
fprintf('First receiver throughput is:  %4.2f Mbps\n',T);
fprintf('First receiver delay is: %4.2f ms\n\n',D*1000);