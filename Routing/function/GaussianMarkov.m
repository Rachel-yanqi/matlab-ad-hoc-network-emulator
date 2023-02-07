function  [X_current,Y_current,velocity,theta]= GaussianMarkov(X_previous,Y_previous,Mean_velosity,...
boundary,velocity, theta)
%   Gausian Morkov mobility model
%   bounded by the boundary
% velocity=zeros(number_of_nodes,1)+Mean_velosity;
% theta=2*pi*rand(number_of_nodes,1);
Mean_theta=theta;
alpha=0.99;
alpha2=1-alpha;
alpha3=sqrt(1-alpha.*alpha);
limitation=440; %maximum signal range from center to the corner
MAX_X=boundary(1) + limitation; %a 1000*1000 square boarder
MIN_X=boundary(1) - limitation;
MAX_Y=boundary(2) + limitation;
MIN_Y=boundary(2) - limitation;

t=1; 
Xtrajectory=X_previous; Ytrajectory=Y_previous;

%while t<=Simulation_time
    X_current=X_previous+round(velocity.*cos(theta));
    Y_current=Y_previous+round(velocity.*sin(theta));
    %node bounces at the boundary
    if X_current < MIN_X || X_current > MAX_X
        X_current=X_previous-round(velocity .* cos(theta));
        if pdist([X_current, Y_current; boundary(1),boundary(2)]) > 1.5*limitation
%             fprintf('x exceed on node [%d, %d]\n',boundary(1),boundary(2));
        end    
    end

    if Y_current < MIN_Y || Y_current > MAX_Y
        Y_current=Y_previous-round(velocity .* sin(theta));
        if pdist([X_current, Y_current; boundary(1),boundary(2)]) > 1.5*limitation
%             fprintf('y exceed on node [%d, %d]\n',boundary(1),boundary(2));
        end
    end

    velocity=alpha*velocity+alpha2*Mean_velosity+alpha3*normrnd(0,1);
    theta=alpha*theta+alpha2*Mean_theta+alpha3*(2*pi*normrnd(0,1));
    
%     Xtrajectory=[Xtrajectory X_current]; Ytrajectory=[Ytrajectory Y_current];
%     scatter(X_current,Y_current,'filled');
%     axis([-1000,3000,-1000,3000]);
%     drawnow
%     java.lang.Thread.sleep(0.01*1000)  % in mysec!
%     update
%     t=t+1;
%     X_previous=X_current;
%     Y_previous=Y_current;
% end

end

