function printStat(node,ini,t)
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
    T=node(ini.constants.Receiver_ID(1)).packets.rcvd*ini.constants.Packet_size*8/((t)*1e6);
    rcv_frames=ceil(node(ini.constants.Receiver_ID(1)).packets.rcvd/ini.constants.Frame_size);
    D=node(ini.constants.Receiver_ID(1)).packets.delay/rcv_frames;
    fprintf('First receiver throughput is:  %4.4f Mbps\n',T);
    fprintf('First receiver delay is: %4.4f ms\n\n',D*1000);
end