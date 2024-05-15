function NLOSv = calculateNLOSv_direct(xVeh, yVeh, X, Y, onlyYesNo)

% function calculateNLOSv_direct
%
% Inputs
% xVeh: matrix [4 x number of Vehicle] with the  x-coordinates of the 
%       vertices for each vehicle
% yVeh: matrix [4 x number of Vehicle] with the  y-coordinates of the 
%       vertices for each vehicle
% X: column vector with the x-position of the vehicles
% Y: column vector with the y-position of the vehicles
% (the number of vehicles is inferred from the length of X)
%
% Outputs
% NLOSv: squared matrix of size equal to the number of vehicels, indicating 
% how many vehicles obstruct the line of sight of the vehicles
% correpsonding to the given row and column
% (the matrix is always symmetric to the main diagonal, with zeros on the
% main diagonal)
%

%% INIT
% The number of vehicles is derived from the length of X
% Nvehicles = length(X);
Nvehicles = size(xVeh,2);

% % For debug
% figure
% plot(X,Y,'p');
% axis([min(X)-100 max(X)+100 min(Y)-100 max(Y)+100]);


%% CALCULATION OF NLOSv
% Per each vehicle, if it obstructs the possible connection is calculated
% and then NLOSv updated accordingly
NLOSv = zeros(Nvehicles,Nvehicles); % initialization of NLOSv
for CarA = 1:(Nvehicles-1)   
    for CarB=(CarA+1):Nvehicles
        for i = 1:Nvehicles   
            
            if i==CarA || i==CarB
                continue
            end


            % It defines the vertices of the current obstacle vehicle
            xOb = [xVeh(3,i) xVeh(4,i) xVeh(1,i) xVeh(2,i)];
            yOb = [yVeh(3,i) yVeh(4,i) yVeh(1,i) yVeh(2,i)];

            % Xa,Ya are the coordinates of the first vehicle and Xb,Yb those of the
            % second vehicle which are communicating to each other
            Xa = X(CarA);
            Ya = Y(CarA);
            Xb = X(CarB);
            Yb = Y(CarB);           
   
            % % m, q define the rect connecting the two vehicles that are communicating
            m = (Yb-Ya)/(Xb-Xa);
            q = Yb-m*Xb;
            % 
            % % m_perp defines the angle of the rect perpendicular to the one connecting
            % % the two vehciles that are communicating
            m_perp = -1/m;
            % 
            % % q_perp defines the rect perpendicular to the segment that is possibly
            % % obstructed and that goes through X_obstructing,Y_obstructing
            q_perp = yOb - m_perp * xOb;
             
            % if m is infinite, it means the segment is vertical
            % x_projected,y_projected are the coordinates of the projection of the point 
            % xOb,yOb over the segment
            % They are needed to check that they are inside the segment
            if m==0
                x_projected = xOb;
            else
                x_projected = (q_perp-q)./(m+1./m);
            end
            %x_projected(m(a,b)==0) = X_obstructing;
            if isinf(m)
                y_projected = yOb;
            else
                y_projected = m.*x_projected + q;
            end

            % outOfSegment defines if the projection of xOb, yOb
            % is out of the segment; in such a case, in fact, it will not obstruct
            % the communication, no matter dist
            outOfSegment = ((x_projected<Xa & x_projected<Xb) | (x_projected>Xa & x_projected>Xb)) | ...
                ((y_projected<Ya & y_projected<Yb) | (y_projected>Ya & y_projected>Yb));
            outOfSegment = prod(outOfSegment);

            if outOfSegment
                continue
            end

            newY = rotoTranslate_obstacleCheck(xOb,yOb,Xa,Ya,Xb,Yb);
            test_sign = sign(newY);
            check = unique(test_sign);
            if length(check)~=1
                % NLOSv is updated to include all the cases when vehicle
                % 'i' obstructs the communication, with values that are either 0 (it does not obstruct) or 1 (it obstructs)
                NLOSv(CarA,CarB) = NLOSv(CarA,CarB) + 1;
                NLOSv(CarB,CarA) = NLOSv(CarB,CarA) + 1;
                % isLOS_reflectedPath = 0;
                % return;
                if onlyYesNo
                    break;
                end
            end
        end
    end
end
