function multicast_table = multicast(node,i)
%for multiplex
%   table structure
% member: next hop of i
% degree: relative degree to i
% cluster: 
TF=and(~isnan(node(i).routing_table(:,3)),node(1).routing_table(:,3) ~=0);
member=node(i).routing_table(TF,2);
degree=(node(i).routing_table(TF,3));
Z=linkage(degree,'complete');
C=cluster(Z,'cutoff',deg2rad(node(i).antenna.beamwidth),'criterion','distance'); %1=deg2rad(60)
multicast_table=table(member,degree,C);
end

