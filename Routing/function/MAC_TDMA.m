function scheduler=MAC_TDMA(route_map,mac_delay)
%calculate which link should be activated under certain time slot
%----------------test case-----------------%
% route_map=A;
%----------------test case-----------------%

%initial table
sz=[1,4];
variable_type={'int8','cell','double','double'};
variable_name={'src','dst','act_start','act_end'};
scheduler=table('Size',sz,'VariableTypes',variable_type,'VariableNames',variable_name);

[t,s]=find(route_map');
s_unique=unique(s);
max_perd=(1-mac_delay)/length(s_unique);      %maximum duration
if max_perd<0
    fprintf('No time for routing, return an empty table\n');
    return;
end
start=mac_delay;
act_start=zeros(size(s_unique));
act_end=zeros(size(s_unique));
for i=1:size(s_unique,1)
    act_start(i)=start+(i-1)*max_perd;
    act_end(i)=start+i*max_perd;
end
for i=1:length(s_unique)
    dest=t(s==s_unique(i));
    dest=dest';
    scheduler(i,:)={s_unique(i),{dest},act_start(i),act_end(i)};
end
% if ~isempty(s)
%     s=zeros(size(s));   t=zeros(size(t));
%     j=1;    
%     t(j)=find(route_map(1,:),1);
%     s(j)=1;
%     while ~isempty(find(route_map(t                                                                                                                                                                                                                                                   (j),:),1))
%         j=j+1;
%         s(j)=t(j-1);
%         t(j)=find(route_map(s(j),:),1);
%     end
% end
% link_number=sum(route_map,'all');
% % req_time_slot=zeros(size(s));
% act_start=zeros(size(s));
% act_end=zeros(size(s));
% max_perd=floor(1/link_number/time_slot); %maximum link activation period
% t_index=1; %to allocate time slot
% for i = 1:size(s,1)
%     req_time_slot=transmit_time(s(i),t(i),max_perd);
%     if req_time_slot > max_perd
%         req_time_slot = max_perd;
%     end
%     act_start(i)=t_index;
%     act_end(i)=t_index+req_time_slot;
%     t_index=t_index+req_time_slot;
% end
% scheduler_table=table(s,t,act_start,act_end);
% end
end
    