function [time,slot_number,packet] = transmission(src,dst,packet)
%Calculate transmit time 
% use emane channel model load snr_PCR

%-------------test---------------
% clc; clear;
% t=0;
% packet=packet(3,t,32);
% 
% Signal_strength=1000;
% number_of_nodes=3;
% node(1:number_of_nodes)=Node();
% node(1)=Node(1,2500,2500,2100,2100,"sender");
% node(2)=Node(2,2000,2000,2300,1800);
% node(3)=Node(3,2000,1500,1800,1800,"receiver");
% src=node(1);  dst=node(2);
%------------test---------------

ini=ini2struct('config.ini');
txPower=ini.phy.txPower; %in dBm
antenna_gain=ini.phy.antenna_gain;
packet_size=ini.constants.Packet_size;
addpath 'Input_data';
load dataset.mat
% load channel model
load channelModel.mat 
n = 2; %path loss exponent
noise = -79; %in dB
distance = sqrt((src.x-dst.x)^2+(src.y-dst.y)^2);
pathloss = 10*n*log10(distance);
rxPower = txPower-30+antenna_gain+antenna_gain-pathloss; %dB
sinr = rxPower-noise;

%find appropriate sending rate
%sinr>requiredSNR && sinr<next(requiredSNR)
[~,idx1]=min(abs(sinr-dataRate.RequiredSNR));
if sinr < dataRate.RequiredSNR(idx1) && idx1~=1
    idx1=idx1-1;
end
sending_rate=dataRate.dataRate(idx1);
row=find(channelModel.datarate==sending_rate);
[~,idx]=min(abs(sinr-channelModel.sinr(row)));
pcr=channelModel.packetReceptionRate(row(1)+idx-1);
reception=pcr/100;
rng('shuffle');
random_variable=rand;
% if random_variable>=reception
if random_variable>=0.99
    reception=0; %drop this frame
    
else
    reception=1;
end
% fprintf("SINR is: %f\n",sinr);
% fprintf('delay is: %ds\n',dst.packets.delay);
% fprintf("sending rate: %dMbps\n", sending_rate/1e6);
% fprintf("packet reception rate: %3.2f%%\n",pcr);
% pause(0.1);
time=packet.packet_number*packet_size*8/sending_rate;
packet.packet_number=packet.packet_number*reception;
slot_number=1;
if time > ini.constants.Sample_frequency
    slot_number = ceil(time/ini.constants.Sample_frequency);
end
%%
%limit packet size if tranmission time is longer than simulator's 
%smple frequency.
% if time > ini.constants.Sample_frequency
%     ratio = round(ini.constants.Sample_frequency/time,2);
% %     time = ini.constants.Sample_frequency;
%     packet.packet_number=round(packet.packet_number*reception*ratio,2);
% %     fprintf("packet number: %d\n\n",packet.packet_number);
% end


end