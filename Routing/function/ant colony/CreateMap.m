function map = CreateMap(nVar,idxs)
%if ant can move from node i to j, map(i,j)=1
map=zeros(nVar,nVar);
for i=1:nVar-1
    for j=2:nVar
        if idxs(i,j)~=0
            map(i,j)=1;
            map(j,i)=1;
        end
    end
    
end
end

