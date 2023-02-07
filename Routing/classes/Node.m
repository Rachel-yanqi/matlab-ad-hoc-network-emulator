classdef Node < handle
    properties
        id
        x
        y
        next_x
        next_y
        theta
        properity  %sender,receiver,relay
        direction %eg: 0 means one edge of antenna is on x-axis
        antenna
        members %for phantom node: node id inside phantom
        haloinfo %for node locates its phantom
        routing_table
        buffer %buffer pool, can be divided into multiple small buffer
        queue 
        packets %used for statistic
        timer
        link
        gaussian     %gaussian markov movement   

    end
    
    events
        packetStart
        packetSent
    end
    methods
        function obj=Node(id,x,y,properity)
            if nargin>0
                if nargin<4
                    obj.properity="relay";
                    %disp 'default properity: relay';
                else
                    obj.properity=char(properity);
                end
                obj.id=id;
                obj.x=x;
                obj.y=y;
                obj.next_x=x;
                obj.next_y=y;
                obj.theta=2*pi*rand;
                obj.direction=0;
                obj.antenna=struct('beamwidth','','strength',0);
                obj.members=0; %no members at initial
                obj.haloinfo=struct('phantom','','user','');    %belong to which halo
                obj.routing_table=[];
                obj.buffer=packet.empty;
                obj.queue=Queue();
                obj.packets=struct('sent',0,'rcvd',0,'dropped',0,'relayed',0,'delay',0,'throuP',0);
                obj.timer=0;
                obj.link=LinkModel(id);
                obj.gaussian=GaussianM(x,y,5e-3,10);
            else
                obj.id=0;
                obj.properity=char.empty; %for initial an empty phantom
            end
     
        end
        function sector(obj,radius)
            if nargin < 2
                disp '----------------------------';
                disp 'default radius: 1400'
                disp '----------------------------';
                radius=1400;
            end
            
            %obj.direction=direction;
            s1=obj.direction-1/2*deg2rad(obj.bandwidth);
            s2=deg2rad(obj.direction)+1/2*deg2rad(obj.bandwidth);
            t=linspace(s1,s2);
            Xsector=obj.x+radius.*cos(t);
            Ysector=obj.y+radius.*sin(t);
            Xsector=[Xsector obj.x Xsector(1)];
            Ysector=[Ysector obj.y Ysector(1)];
            a=fill(Xsector,Ysector,'g');
            a.FaceAlpha=0.1;
        end
        function assignMembership(obj,member)
            obj.members=member;
        end

        function push(obj,packet)
            obj.buffer(end+1)=packet; 
        end
        function packet_to_transmit = pop(obj)
            packet_to_transmit=obj.buffer(1);
            obj.buffer(1)=[];
        end
        function copypacket(obj,p,dest)
            p_copy=packet(dest,p.start_time,p.packet_number); %create new packet object
%             obj.push(p_copy);
            obj.queue.copy(p_copy);
        end
        
        function send_pkt(obj,pkt)
             obj.queue.add(pkt);

        end
%         function rcv_pkt(obj,src)
%         end
        %multicast flag
        function multicast = multicasting(obj, next_hop,rcv_id)
            degree=zeros(size(next_hop));
            for i=1:length(degree)
                degree(i)=obj.routing_table(next_hop(i),3);
            end
            Z=linkage(degree,'complete');
            C=cluster(Z,'cutoff',deg2rad(obj.antenna.beamwidth),'criterion','distance'); %1=deg2rad(60)
            
            degree_diff=nan(2,1);
            degree_diff(1)=max(degree)-degree(next_hop==rcv_id);
            degree_diff(2)=min(degree)-degree(next_hop==rcv_id);
            degree_diff=rad2deg(degree_diff);
            if max(degree_diff) < obj.antenna.beamwidth
                multicast = 1; 
            else
                multicast = 0;      %antenna has to swap among receivers
            end
        end
        function [pkt,flag] = generate_pkt(obj,timestamp)
            pkt=[];
            ini=ini2struct('config.ini');
            F=ini.constants.Frame_size;
            P=ini.constants.Packet_size;
            S=ini.constants.Sending_rate;
            sending_slot=F*P*8/S;
            dest=ini.constants.Receiver_ID;
            n=floor(timestamp/sending_slot);
            
            if timestamp >= obj.timer*sending_slot
%                 if obj.id ==1
%                     fprintf("node 1 generated packets %d\n",obj.timer);
%                 end
                pkt=packet(dest,timestamp,F);
                obj.timer=obj.timer+1;
                
                flag=1;
            else
                flag=0;
            end
            
        end
        
        %transmit pkt if timeout of Tx link; or medium is free
        function tt = connectListener(obj,rcv,time)
            tt=0;               %transmission time
            if strcmp(obj.properity,'sender')
                [p,flag] = obj.generate_pkt(time);      
                if flag>0
                    obj.send_pkt(p);
                end
            end
            %transmit if Tx has pkt and link is not busy
            if obj.queue.getNumber() <= 0
                if obj.link.checkLinkBusy > 0 && rcv.link.checkLinkBusy > 0 
%                     if numel(obj.link.src) < 2      % unicasting 
%                         obj.link.releaseLink(time,rcv.id); rcv.link.releaseLink(time,obj.id);
%                     else
                        % Multicasting
                        if obj.link.src(end) ~= rcv.id
                            rcv.link.releaseLink(time,obj.id);
                        else
                            obj.link.releaseLink(time,rcv.id); rcv.link.releaseLink(time,obj.id);
                        end
%                     end
                end
                return
            end
            if obj.link.checkLinkBusy == 0 && rcv.link.checkLinkBusy == 0 
                p=obj.queue.remove();
                dest=p.destination;
                temp=p.packet_number;
                next_hop=obj.routing_table(dest,2);          
                %when next_hop contains 0 (no avaliable route) but has nonzero 
                %elements (some pkt have route): save the packets, change packet's dest
%                 late_dest=(dest(next_hop==0));
%                 if ~isempty(late_dest) && sum(next_hop)~=0
%                     copypacket(obj,p,late_dest);
%                     p.destination=p.destination(next_hop~=0); 
%                     next_hop(next_hop==0)=[];
%                 end
                %when next_hop~=0 unique(next_hop)
                next_hop=unique(next_hop);
                if numel(next_hop)>1 %packet should go to two different interface
%                     obj.link.releaseLink(); %release sender link
                    multicast = obj.multicasting(next_hop,rcv.id);
%                     for i=1:numel(next_hop)-1
                    dest_cur=obj.routing_table(obj.routing_table(:,2)==rcv.id);
                    if strcmp(rcv.properity,'relay')
                        dest_cur=dest_cur(dest_cur~=rcv.id);
                    end
                    copy_dest=dest(~ismember(dest,dest_cur));
                    dest=dest(ismember(dest,dest_cur));
                    copypacket(obj,p,copy_dest);
%                     end
                    p.destination=p.destination(~ismember(p.destination,copy_dest));
                else 
                    multicast=0;
                end
                if isempty(next_hop) || ~ismember(rcv.id, next_hop)
                    %transmit to wrong link, terminate transmission
                    obj.queue.add(p);
                    return
                end
                %transmit to next hop
                if strcmp(obj.properity,'sender')
%                     p.set_start_time(time); %tx time
                end
                obj.packets.sent=obj.packets.sent+p.packet_number;
                rcv.send_pkt(p);
                [tt,slot_number,p]=transmission(obj,rcv,p);
                for k=1:slot_number
                    if multicast == 0
                        obj.link.holdLink(tt,rcv.id);  rcv.link.holdLink(tt,obj.id);
                    else
                        obj.link.holdLink(tt,next_hop);  rcv.link.holdLink(tt,obj.id);
                    end
                end
%                 fprintf('node %d send packet to node %d at time %2.3f\n',obj.id,rcv.id,time);
%                 fprintf('node %d busy: %d to node %d busy: %d\n\n',obj.id,obj.link.busy,rcv.id,rcv.link.busy);

                rcv.packets.rcvd=rcv.packets.rcvd+p.packet_number;
                obj.packets.dropped=temp - p.packet_number;
                p.TTL=p.TTL-1;
                obj.link.releaseLink(time,rcv.id); rcv.link.releaseLink(time,obj.id); %packet sending
                if multicast == 1
                    obj.link.multiLinkRelease();
                else
                    if obj.link.multicast.max_busy > obj.link.checkLinkBusy
                        obj.link.setBusy(obj.link.multicast.max_busy);
                    end
                end
                if ~ismember(rcv.id,dest) %packet arrive relays
                    rcv.packets.relayed=rcv.packets.relayed+p.packet_number;
                else
                    p=rcv.queue.remove();
                    dest=p.destination;
                    new_dest=dest(dest~=rcv.id); %if one receiver is also a relay
                    if ~isempty(new_dest)
                        copypacket(rcv,p,new_dest);
                    end
                    p.end_time=p.end_time+time+tt;
%                     n=ceil(rcv.packets.rcvd/p.packet_number);
                    rcv.packets.delay=rcv.packets.delay + p.end_time-p.start_time;
%                     fprintf('node %d delay at time %1.4f is %.3f ms\n\n',rcv.id,time,(p.end_time-p.start_time)*1000);
%                     rcv.packets.throuP=(T+(n-1)*rcv.packets.throuP)/(n);
                end 
            else
                if obj.link.checkLinkBusy > 0 && rcv.link.checkLinkBusy > 0 
                    if numel(obj.link.src) < 2      % unicasting 
                        obj.link.releaseLink(time,rcv.id); rcv.link.releaseLink(time,obj.id);
                    else
                        % Multicasting
                        if obj.link.src(end) ~= rcv.id
                            rcv.link.releaseLink(time,obj.id);
                        else
                            obj.link.releaseLink(time,rcv.id); rcv.link.releaseLink(time,obj.id);
                        end
                    end
                else
%                     warning("risking frozen link");
%                     fprintf("node %d to %d\n",obj.id,rcv.id);
                end
             end
        end
        
        function obj = set_coord(obj,x,y)
            obj.x=x;
            obj.y=y;
            obj.next_x=x;
            obj.next_y=y;
        end
        
        function obj = set_velocity(obj,speed)
            obj.gaussian.set_speed(speed);
        end
        
        function obj = set_antenna(obj,beamwidth,RF)
            obj.antenna.beamwidth=beamwidth;
            obj.antenna.RF=RF;
        end
        
        function obj = set_phantom(obj,halo_id)
            obj.haloinfo.phantom=halo_id;
        end
        function obj = set_user(obj,halo_id)
            obj.haloinfo.user=halo_id;
        end

    end
end
