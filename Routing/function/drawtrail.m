% test 4
% a node moving into halo while a node moving out of halo
% the halo maintain its location but the routing path
% switch to incoming node

clc;
 % I'm just using dummy values here but my actual program has similar outputs (1800 x 1 double)
for i=1:length(A)
    plot (A(i),B(i), 'd', 'MarkerSize', 5, 'MarkerFaceColor', 'k')
    hold on
    plot(A(1:i),B(1:i),'r')
    hold off
    axis ([0 6000 0 6000])
    pause (0.1)
end