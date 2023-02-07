function  User = Userhalo(node,halo_cutoff,speed)
%build MAC connections for user halo testing

%----------------test bench-------------
% halo_cutoff=700;
% speed = 100;
%-----------------test end---------------

receiver_ID=0;
j=1;
for i=1:numel(node)
    if strcmp(node(i).properity,'receiver')
        receiver_ID(j)= node(i).id;
        j=j+1;
    elseif strcmp(node(i).properity,'sender')
        sender_ID = node(i).id;
    end
end
%decide user halo radius
User(1:length(receiver_ID))=Phantom();      %preallocate
switch speed
    case num2cell(30:60)
        for i=1:length(receiver_ID)
            User(i) = Phantom(i,node(receiver_ID(i)).x,node(receiver_ID(i)).y,halo_cutoff/2);
            User(i).set_properity('user');
            User(i).assignMembership(receiver_ID(i));       %receiver is also user halo member
            node(receiver_ID(i)).set_user(receiver_ID(i));
        end
    case num2cell(61:120)
        for i=1:length(receiver_ID)
            User(i) = Phantom(i,node(receiver_ID(i)).x,node(receiver_ID(i)).y,halo_cutoff);
            User(i).set_properity('user');
            User(i).assignMembership(receiver_ID(i));
            node(receiver_ID(i)).set_user(receiver_ID(i));
        end
end
%assign user halo member
for i=1:numel(User)
    members = User(i).members;
    for j=1:numel(node)
        if strcmp(node(j).properity,'relay')
            if inCircle(User(i),node(j))
                members(2:end+1) = members;
                members(1)=node(j).id;
                node(j).set_user(i);        %tell node belong to which halo
            end
            %member should inside halo at next time slot
            dist = hypot(node(j).next_x-User(i).x,node(j).next_y-User(i).y);
            if dist > User(i).radius
                members(members==node(j).id)=[];
            end
        end
    end
    members=sort(members);
    User(i).assignMembership(members);
end


end