function ploting(G,X_Coord,Y_Coord,t,user,ini)
    h=plot(G,'XData',X_Coord,'YData',Y_Coord,'EdgeColor',[0,0.7,0.9],...
        'NodeColor','b');
    axis([-500 3100 -500 3500]);
    txt=sprintf('time = %.3f\n',t);
    text(2500,2500,txt);
    hold on
    for i=1:numel(user)
        if ini.constants.Speed > 60
            drawCircle(user(i).x,user(i).y,user(i).radius);
            drawCircle(user(i).x,user(i).y,user(i).radius/2);
        else
            drawCircle(user(i).x,user(i).y,user(i).radius);
        end
    end
    drawnow;
    hold off
end