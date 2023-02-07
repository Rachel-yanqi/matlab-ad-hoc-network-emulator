function A = adaptiveAntenna(velocity,OR,node)
%this function find the RF range and beamwidth according to velocity
%beamwidth: 360, 90, 60,45
%no halo: 360; one halo: cover all halo members; two halo

%-------------test bench---------
% OR = 10;          %OR is omni- RF range
% velocity=40;
%-------------test end-------------

number_of_nodes=numel(node);
X_Coord=zeros(number_of_nodes,1);
Y_Coord=zeros(number_of_nodes,1);
for i=1:number_of_nodes
    X_Coord(i)=node(i).x;
    Y_Coord(i)=node(i).y;
    if strcmp(node(i).properity, 'sender')
        root=i;
    end
end
% if phantom(1).id==0
%     RF_strength=OR;
%     beamwidth=360;
%     return;
% end

%build a minimum spanning tree 
switch velocity
    case num2cell(0:9)
        beamwidth=360;
        [idxs,~]=topology(1:number_of_nodes,X_Coord,Y_Coord,OR); 
        
    case num2cell(10:60)
        %method1: greedy search
        beamwidth=90;
        range= 2*OR;  %90degree
        idxs=adaptiveTopology(node,range,beamwidth,X_Coord,Y_Coord,root);
%         fprintf("90 degrees antenna\n");
    case num2cell(61:110)
        beamwidth=60;
        range= sqrt(6)*OR;  %60degree
        idxs=adaptiveTopology(node,range,beamwidth,X_Coord,Y_Coord,root);
%          fprintf("60 degrees antenna\n");
    case num2cell(111:200)
        beamwidth=45;
        range=sqrt(8)*OR;
        idxs=adaptiveTopology(node,range,beamwidth,X_Coord,Y_Coord,root);
end
A=sparse(idxs(:,1),idxs(:,2),1,numel(node),numel(node));
A=full(A);
A=A+tril(A,1)'; %A's upprt triangle matrix contains all edges
end