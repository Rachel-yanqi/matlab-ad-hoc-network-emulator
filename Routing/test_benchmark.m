clear;      
%Geometric Setting
ini=ini2struct('config.ini');

global Signal_strength
Signal_strength=1400;
halo_radius=sqrt(2)/2*500;
halo_cutoff=2*halo_radius;
mean_velocity=50;
simulation_time=50;
number_of_nodes=5;
%% read multiple txt files
addpath('./Movement/halo_movement')
format='%d %d';
reading_size=[2 Inf];
% Specify the folder where the files live.
myFolder = '.\Movement\halo_movement';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.txt'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
theFiles=natsortfiles(theFiles);
trail=cell(1,number_of_nodes,1);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
%     fullFileName = fullfile(theFiles(k).folder, baseFileName);
%     fprintf(1, 'Now reading %s\n', fullFileName);
    fid=fopen(baseFileName,'r');
    trail{k}=fscanf(fid,format,reading_size); fclose(fid);
    trail{k}=trail{k}';
end
clear format reading_size myFolder filePattern theFiles baseFileName fid

node(1:number_of_nodes)=Node();
for i=1:number_of_nodes
    if i==ini.constants.Sender_ID
        node(i)=Node(i,trail{i}(1,1),trail{i}(1,2),trail{i}(2,1),trail{i}(2,2),'sender');
    elseif ismember(i,ini.constants.Receiver_ID)
        node(i)=Node(i,trail{i}(1,1),trail{i}(1,2),trail{i}(2,1),trail{i}(2,2),'receiver');
    else
        node(i)=Node(i,trail{i}(1,1),trail{i}(1,2),trail{i}(2,1),trail{i}(2,2));    
    end
    
end
clear i
%%
X_Coord=zeros(number_of_nodes,1);
Y_Coord=zeros(number_of_nodes,1);
phantom=Phantom();
% phantom=phantom();
% figure(1);
%QoS Setting
time_slot=5e-3; %in ms;
schedule_alg="Uniform";
route.optpath=[];   route.halopath=[];
%%
%main program
for t=0:ini.constants.Sample_frequency:ini.constants.Simulation_time
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
        case 'dirHalo'
            fprintf('Updating...');
    end
    
    G=graph(idxs,'upper');
    G.Edges.Weight=EdgeWeights(G,node);
%     h=plot(G,'XData',X_Coord,'YData',Y_Coord,'EdgeColor',[0,0.7,0.9],...
%         'NodeColor','b');
%     axis([0 3100 0 4000]);
%     txt=sprintf('time = %.3f\n',t);
%     text(500,500,txt);
%     drawnow;
%     pause(0.1);
    if mod(t,30)==0
        [route,~]=Routing(G,node,ini,phantom,route);
    end
%     highlight(h,route.optpath,'EdgeColor','g','LineWidth',2);
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
%     allocate time slot in one second
    for i=1:number_of_nodes
        for j=1:number_of_nodes
            if i~=j && route_table(i,j)==1
                node(i).connectListener(node(j),t);
            end
        end
    end
    % -------------------QoS part end-----------------------------
    % updating nodes
    if mod(t,1)==0
        for i=1:number_of_nodes
            node(i).x=trail{i}(t+1,1);    node(i).y=trail{i}(t+1,2);
            node(i).next_x=trail{i}(t+2,1);     node(i).next_y=trail{i}(t+2,2);
        end
    end
end

%% Print Statiscs
S=node(ini.constants.Sender_ID).packets.sent*ini.constants.Packet_size*8/((t)*1e6); %sending rate Mbps
fprintf("Sending rate is: %4.2f Mbps\n",S);
% %average three receiver
% T=0;    D=0;
% for i=1:length(ini.constants.Receiver_ID)
%     T=T+node(ini.constants.Receiver_ID(i)).packets.rcvd*ini.constants.Packet_size*8/((t)*1e6); 
%     D=D+node(ini.constants.Receiver_ID(i)).packets.delay;
% end
% T=T/length(ini.constants.Receiver_ID);  D=D/length(ini.constants.Receiver_ID);
% fprintf("Throughput is: %4.2f Mbps\n",T);
% fprintf("Delay is: %4.2f second \n",D);
T=node(ini.constants.Receiver_ID(1)).packets.rcvd*ini.constants.Packet_size*8/((t)*1e6);
rcv_frames=ceil(node(ini.constants.Receiver_ID(1)).packets.rcvd/ini.constants.Frame_size);
D=node(ini.constants.Receiver_ID(1)).packets.delay/rcv_frames;
fprintf('First receiver throughput is:  %4.4f Mbps\n',T);
fprintf('First receiver delay is: %4.4f ms\n\n',D*1000);