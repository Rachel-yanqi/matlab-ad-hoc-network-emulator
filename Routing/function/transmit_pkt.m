function transmit_pkt(scheduler,node,time_slot,t)
%transmit pkt according to scheduler
%   if 
% node(1).timer=0;    %clear sending intervals every time
for i=1:size(scheduler)
    dst=scheduler.dst{i};
    for j=1:length(dst)
        time=scheduler.act_start(i);
        while time<scheduler.act_end(i)
                delay=node(scheduler.src(i)).connectListener(node(dst(j)),t+time-scheduler.act_start(1));
                time=time+delay;
%             if delay~=0
%                 highlight(h,scheduler.src(i),dst(j),'EdgeColor','g','LineWidth',2)
%                 pause(0.2);
%                 drawnow;
%             end
            if delay==0
                time=time+time_slot;
            end
        end
    end
end
end

