function isLOS_reflectedPath = calculateNLOSv_reflected(xVeh, yVeh, XI, YI, obstacleID,...
    sensorXCarB, sensorYCarB, sensorXCarA, sensorYCarA, indexCarA, indexCarB)

% function calculateNLOSv_reflected
%
% Inputs
% xVeh: matrix [4 x number of Vehicle] with the  x-coordinates of the 
%       vertices for each vehicle
% yVeh: matrix [4 x number of Vehicle] with the  y-coordinates of the 
%       vertices for each vehicle
% XI: x-coordinate of the reflection point
% YI: y-coordinate of the reflection point
% (the number of vehicles is inferred from the length of X)
%
% Outputs
% isLOS_reflectedPath:
%                      - '1' if there is LOS stutus from sensorCarA to
%                      Reflection Point and from Reflection Point to
%                      sensorCarB
%                      - '0' if there is NLOS stutus from sensorCarA to
%                      Reflection Point and from Reflection Point to
%                      sensorCarB
%

%% INIT
% The number of vehicles is derived from the length of xVeh
Nvehicles = size(xVeh,2);

% % For debug
% figure
% plot(X,Y,'p');
% axis([min(X)-100 max(X)+100 min(Y)-100 max(Y)+100]);

%% CALCULATION OF NLOSv

% by default there is Line of Sight
isLOS_reflectedPath = 1; 
% doubleCheck = 1;
for doubleCheck = 1:2
    %check the second path [Reflection Point - vehicle B]
    if doubleCheck == 1
        xa = XI;
        ya = YI;
        xb = sensorXCarB;
        yb = sensorYCarB;
    else
        %check the first path [Reflection Point - vehicle A]
        xa = XI;
        ya = YI;
        xb = sensorXCarA;
        yb = sensorYCarA;
    end

    for i = 1:Nvehicles

        if doubleCheck == 1
            if i==indexCarB
                continue;
            end
        else
            if i==indexCarA
                continue;
            end
        end

        if i == obstacleID
            continue;
        end

        % xOb, yOb are the coordinates of the possibly obstructing vehicle
        xOb = [xVeh(3,i) xVeh(4,i) xVeh(1,i) xVeh(2,i)];
        yOb = [yVeh(3,i) yVeh(4,i) yVeh(1,i) yVeh(2,i)];

        % % m, q define the rect connecting the two vehicles that are communicating
        m = (yb-ya)/(xb-xa);
        q = yb-m*xb;

        % m_perp defines the angle of the rect perpendicular to the one connecting
        % the two vehciles that are communicating
        m_perp = -1/m;

        % q_perp defines the rect perpendicular to the segment that is possibly
        % obstructed and that goes through xOb, yOb
        q_perp = yOb - m_perp .* xOb;

        % if m is infinite, it means the segment is vertical
        % x_projected,y_projected are the coordinates of the projection of the point
        % xOb, yOb over the segment.
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
        % is out of the segment
        outOfSegment = ((x_projected<xa & x_projected<xb) | (x_projected>xa & x_projected>xb)) | ...
            ((y_projected<ya & y_projected<yb) | (y_projected>ya & y_projected>yb));
        outOfSegment = prod(outOfSegment);

        % For Debug
        % scatter(xa,ya)
        % hold on
        % grid on
        % scatter(xOb,yOb,'filled')
        % % plot(xOb,yOb)
        % scatter(xb,yb,'filled','red','^')
        % plot([xa xb],[ya yb])
        % xlabel('x[m]');
        % ylabel('y[m]');
        %     scatter(x_projected,y_projected,'filled');
        % end

        if outOfSegment
            % los = 1;
            continue;
        end

        %PLOT THE VEHICLES
        % hold on
        % grid on
        % scatter(xOb,yOb,'filled')

        newY = rotoTranslate_obstacleCheck(xOb,yOb,xa,ya,xb,yb);
        test_sign = sign(newY);
        check = unique(test_sign);
        if length(check)~=1
            % If there is no line of sight (LoS), isLos_reflected is updated to 0.
            isLOS_reflectedPath = 0;
            return;
        end
    end
end

end

