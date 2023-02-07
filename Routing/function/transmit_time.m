function time = transmit_time(node,srcid,dstid,max_allocate_time)
%Calculate transmit time 
% use emane channel model load snr_PCR

%-------------test start-------------
% srcid=1;
% dstid=2;
%-------------test end---------------

global packet_size

addpath 'Input_data';
load dataset.mat
load dataset2.mat 
txPower=2; %in dBm
antenna_gain=8;
% time_slot=1e-3; %1ms
n = 2; %path loss exponent
noise = -90; %in dB
distance = sqrt((node(srcid).x-node(dstid).x)^2+(node(srcid).y-node(dstid).y)^2);
pathloss = 10*n*log10(distance);
rxPower = txPower-30+antenna_gain+antenna_gain-pathloss; %dB
sinr = rxPower-noise;

%find appropriate sending rate
[~,idx1]=min(abs(sinr-dataRate.RequiredSNR));
if sinr < dataRate.RequiredSNR(idx1)
    idx1=idx1-1;
end
sending_rate=dataRate.dataRate(idx1);
if isempty(node(srcid).buffer)
    time=0;
    return 
end
node(srcid).sendbuffer=node(srcid).pop();
time=node(srcid).sendingbuffer.packet_number*packet_size*8/sending_rate;
if time > max_allocate_time
    time = max_allocate_time;
end
% slot_number=ceil(time/time_slot);
% if slot_number > max_slot_number
%     slot_number = max_slot_number;
% end
end