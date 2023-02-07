classdef LinkModel < handle
    %link in mac layer
    %   Detailed explanation goes here
    
    properties
        id
        src
        busy
        info
        multicast
    end
    events
        finshedTransmit
    end
    
    methods
        function obj = LinkModel(id)
            obj.id=id;
            obj.src='';
            obj.busy=0;
            obj.info=struct("start_time",0,"period",0);
            obj.multicast=struct("max_busy",0);
        end

        function holdLink(obj,tt,src)
%             obj.busy=1;
            obj.busy=obj.busy+1;
            obj.info.period = tt;
            obj.src=src;    %lock to the link to src
%             if obj.multicast(1).member~=0
%                 member=[];
%                 for i=1:length(obj.multicast)
%                     member=[member,obj.multicast(i).member];
%                 end
%                 obj.src=member;
%             end
            
        end
%         function releaseLink(obj,current_time)
         function releaseLink(obj,~,src)
%              if obj.src == src
             if ismember(src,obj.src)
                 if obj.busy>0
                    obj.busy = obj.busy - 1;
                 end
                 if obj.busy == 0
                     obj.src = '';
                 end
             end
%             if current_time-obj.info.start_time > obj.info.period
%                 obj.busy=0;
%             end
        end
        function b = checkLinkBusy(obj)
            b=obj.busy;
%             b=obj.busy+rcv.busy;
%             if (b==2)
%                 b=1;
%             else
%                 b=0;
%             end
        end
        function obj=setBusy(obj,count)
            obj.busy=count;
        end
        function obj = multiLinkRelease(obj)
            obj.multicast.max_busy=obj.checkLinkBusy;
            obj.busy = 0;   % multicast sender set busy flag to 0 if it has other children
        end
        function obj = linkLockTx(obj,tt)
            obj.busy=obj.busy+1;
            obj.info.period = tt;
        end
        
        function obj = linkLockRx(obj)
            obj.busy = obj.busy + 1;
        end
        
         function obj = linkReleaseRx(obj)
            if obj.busy > 0
                obj.busy = obj.busy - 1;
            end
        end
        
        function obj = linkReleaseTx(obj)
            if obj.busy > 0
                obj.busy = obj.busy - 1;
            end
        end      
        function obj = reset(obj)
            obj.busy = 0;
        end
        function obj.timeout(obj,sample_frequency)
            if obj.info.period>0
                obj.info.period = obj.info.period - sample_frequency;
                if obj.info.period<=0
                    notify(obj,'finishedSending');   % link is available again
                end
            end
        end
    end
end

