function drawCircle(xCenter,yCenter,r)

% %test case
% r=300;
% xCenter=1600;
% yCenter=1000;
angle=0:0.01:2*pi;
radius=r;
X=radius*cos(angle)+xCenter.*ones(1,629);
Y=radius*sin(angle)+yCenter.*ones(1,629);
plot(X,Y,'k');
% axis([0 500 0 500]);
end