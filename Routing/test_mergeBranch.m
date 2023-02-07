% 0 - 30 mobility
% merge branch to minimize the total path cost 
% originally shotest path, but two different branches
clc; clear;
% addpath('function');
% addpath('classes');
% addpath 'D:\MATLAB\matlab-tsp-ga-master'
% addpath('.\function\ant colony');
ini=ini2struct('config.ini');
%% Initilization
number_of_nodes=ini.constants.Node;
Signal_strength=770;
mean_velocity=5;
sender_ID=1;
receiver_ID=[4,7];
simulation_time = ini.constants.Simulation_time;
node(1:number_of_nodes)=Node();
node(1)=Node(1,1000,2000,"sender");
node(2)=Node(2,500,1500,"relay");
node(3)=Node(3,500,1000,"relay");
node(4)=Node(4,500,480,"receiver");
node(5)=Node(5,1500,1500,"relay");
node(6)=Node(6,1505,1000,"relay");
node(7)=Node(7,1505,480,"receiver");
node(8)=Node(8,1000,750);
for i=1:number_of_nodes
    node(i).set_antenna(ini.phy.beamwidth,ini.constants.Signal_strength);
end
%special prerequists
position=zeros(number_of_nodes,2);
phantom=Phantom();
route.optpath=[];  
%% Main Code
X_Coord=zeros(number_of_nodes,1);
Y_Coord=zeros(number_of_nodes,1);
for t=1:simulation_time
    %current position
     for i=1:number_of_nodes
        X_Coord(i)=node(i).x;
        Y_Coord(i)=node(i).y;
     end 
     position(:,1)=X_Coord;
     position(:,2)=Y_Coord;
    %MAC's links 
    [idxs,~]=topology(1:number_of_nodes,X_Coord,Y_Coord,Signal_strength);
    G=graph(idxs,'upper');
    G.Edges.Weight=EdgeWeights(G,node);
    %Routing path
    [route,~]=Routing(G,node,ini,phantom,route);

    h=plot(G,'XData',X_Coord,'YData',Y_Coord);
    axis([0 2000 0 2500]);
    for i=1:length(route)
        highlight(h,route(i).optpath,'EdgeColor',"red","LineWidth",4);
    end
    grid on
    drawnow;

    %update position
    if mod(t,ini.constants.Movement_freq)==0
        for i=1:number_of_nodes
            move_class=GaussianM(node(i).x,node(i).y,ini.constants.Movement_freq,ini.constants.Speed);
            move_class=move_class.movement();
            [x,y,~,dir]=mobility(node(i).x,node(i).y,move_class.speed*ini.constants.Movement_freq,move_class.get_dir());
            node(i).set_coord(x,y);
        end
    end
end
