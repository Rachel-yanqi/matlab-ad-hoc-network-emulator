%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YOEA103
% Project Title: Ant Colony Optimization for Traveling Salesman Problem
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%
function model=CreateModel(position)
    %Node's position
    x=position(:,1);
    
    y=position(:,2);
    
    n=numel(x);
    
    D=zeros(n,n);
    
    for i=1:n-1
        for j=i+1:n
            
            D(i,j)=sqrt((x(i)-x(j))^2+(y(i)-y(j))^2);
            
            D(j,i)=D(i,j);
            
        end
    end
    
    model.n=n;
    model.x=x;
    model.y=y;
    model.D=D;
end