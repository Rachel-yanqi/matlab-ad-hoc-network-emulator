function [ x,y,len, dir ] = mobility( x, y, len, dir )
%UNTITLED3 Summary of this function goes here
%   Function handles mobility of the node
%   x - x coordinate
%   y - y coordinate
%   len - length of the movement
%   dir - degree to move [0..360]

dir=rad2deg(dir);

% alpha=0.99;
% alpha2=1-alpha;
% alpha3=sqrt(1-alpha.*alpha);

x=x+(len*cosd(dir));
y=y+(len*sind(dir));
% len = alpha*len+alpha2*len+alpha3*normrnd(0,1);
% dir = alpha*dir+alpha2*dir+alpha3*(2*pi*normrnd(0,1));
end

