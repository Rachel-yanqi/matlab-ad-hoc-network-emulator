function weight = EdgeWeights(G,node)
%Assign weight on graph
%   weight = packet delivery rate
%input: grpah object, node object, Signal_strength, phantom
%output: weight length(G.Edges)*1
%test
% G=graph(idxs,'upper');
% Signal_strength=1200;


XCoord=zeros(numel(node),1);
YCoord=zeros(numel(node),1);
for i=1:numel(node)
    XCoord(i)=node(i).x;    YCoord(i)=node(i).y;
end
%calculate node's distance
detX=XCoord(G.Edges.EndNodes(:,1))-XCoord(G.Edges.EndNodes(:,2));
detY=YCoord(G.Edges.EndNodes(:,1))-YCoord(G.Edges.EndNodes(:,2));
distance=hypot(detX,detY);
% % normDist=(distance-min(distance))/(max(distance)-min(distance));
% %calculate node's relative stability
% stable=zeros(size(detX));
% for i=1:size(detX,1)
%     j=G.Edges.EndNodes(i,2);
%     stable(i)=node(G.Edges.EndNodes(i,1)).calLET(node(j),Signal_strength);
% end
% normStable=(stable-min(stable))/(max(stable)-min(stable));

%pdr for weight 
ini=ini2struct('config.ini');
load '.\Input_data\channelModel.mat'
load dataset.mat

txPower=ini.phy.txPower; %in dBm
antenna_gain=ini.phy.antenna_gain;

% load '.\Input_data\dataset.mat'
n = 2; %path loss exponent
noise = -79; %in dB
pathloss = 10*n*log10(distance);
rxPower = txPower-30+antenna_gain+antenna_gain-pathloss; %dB
sinr = rxPower-noise;
sending_rate=zeros(size(sinr));
expect_count=zeros(size(sinr));
batch_size=ini.constants.Packet_size*8*ini.constants.Frame_size;
for i=1:length(sinr)
    [~,idx1]=min(abs(sinr(i)-dataRate.RequiredSNR));
    if sinr(i) < dataRate.RequiredSNR(idx1) && idx1~=1
        idx1=idx1-1;
    end
    sending_rate(i)=dataRate.dataRate(idx1);
    row=find(channelModel.datarate==sending_rate(i));
    [~,idx]=min(abs(sinr(i)-channelModel.sinr(row)));
    pcr=channelModel.packetReceptionRate(row(1)+idx-1);
    pcr=pcr/100;
    if pcr==0
        expect_count(i)=100;    %avoid inf result
    else
        expect_count(i)=batch_size/sending_rate(i)*1/pcr;
%         expect_count(i)=batch_size/sending_rate(i);
    end
end 

% sending_rate = 24e6;
% row=find(channelModel.datarate==sending_rate);
% expect_count=zeros(size(sinr));
% for i=1:length(sinr)    
%     [~,idx]=min(abs(sinr(i)-channelModel.sinr(row)));
%     pcr=channelModel.packetReceptionRate(row(1)+idx-1);
%     pcr=pcr/100;
%     if pcr==0
%         expect_count(i)=100;    %avoid inf result
%     else
%         expect_count(i)=1/pcr;
%     end
% end

%calculate weight
weight=expect_count;

%----------need update------------
% a node located near the center of halo should lower its weight
end

