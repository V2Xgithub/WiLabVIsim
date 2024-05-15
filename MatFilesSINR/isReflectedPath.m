function [isPresent,XI,YI,dist1,dist2] = isReflectedPath(Vpoints, AntennaPoints, ...
    indexCarA, indexSensorCarA, indexCarB, indexSensorCarB, indexMaySensingSameTime, distance, distanceMax, positionManagement)

% init
isPresent = false;
XI=0;YI=0;dist1=0;dist2=0;

% sensorStartCarA and sensorStartCarB are in -pi, pi
% sensorEndCarA and sensorEndCarB are larger than sensorStartCarA and sensorStartCarB, respectively,
% and lower than 2*pi
% ( the assumption is that the sensor FOV is not more than pi)



sensorXCarA = AntennaPoints(indexSensorCarA, 1, indexCarA);
sensorYCarA = AntennaPoints(indexSensorCarA, 2, indexCarA);
sensorStartCarA = AntennaPoints(indexSensorCarA, 3, indexCarA);
sensorEndCarA = AntennaPoints(indexSensorCarA, 4, indexCarA);

sensorXCarB = AntennaPoints(indexSensorCarB, 1, indexCarB);
sensorYCarB = AntennaPoints(indexSensorCarB, 2, indexCarB);
sensorStartCarB = AntennaPoints(indexSensorCarB, 3, indexCarB);
sensorEndCarB = AntennaPoints(indexSensorCarB, 4, indexCarB);

% the cars around the two sensors are sorted in distance
distanceCar = distance(indexMaySensingSameTime, indexCarA) + distance(indexMaySensingSameTime, indexCarB);
% distanceCarIDs = activeIDs(indexMaySensingSameTime);
distanceCarIDs = find((indexMaySensingSameTime)==1); %not real IDs
[~,near] = sort(distanceCar);

% check one by one the cars (they are surely in LOS of both the cars
% mounting the sensors)
for i=1:length(distanceCar)
    if indexCarA == distanceCarIDs(near(i)) || indexCarB == distanceCarIDs(near(i)) %NEW
        continue;
    end

    if distanceCar(near(i))>distanceMax
        return;
    end
    
    % CAR RECTANGLE
    % Four vertices identitifying the car, represented as a rectangle
    Xvect = Vpoints(:, 1, distanceCarIDs(near(i)));
    Yvect = Vpoints(:, 2, distanceCarIDs(near(i)));
    
    % Calculation of the distance from each vertex to the two sensors
    distance1 = (Xvect-sensorXCarA).^2+(Yvect-sensorYCarA).^2;
    distance2 = (Xvect-sensorXCarB).^2+(Yvect-sensorYCarB).^2;
    dtot = distance1+distance2;
    [~,pos] = sort(dtot);

    % Reflected path detection
    % Firstly, the segment from the nearer vertex to the second vertex is
    % checked
    [isPresent,XI,YI] = reflectedPath( sensorXCarA, sensorYCarA, sensorStartCarA, sensorEndCarA, ...
        sensorXCarB, sensorYCarB, sensorStartCarB, sensorEndCarB, ...
        Xvect(pos(1)), Yvect(pos(1)), Xvect(pos(2)), Yvect(pos(2)));
    % Secondly, the segment from the second vertex to the third vertex is
    % checked 
    if ~isPresent
        [isPresent,XI,YI] = reflectedPath( sensorXCarA, sensorYCarA, sensorStartCarA, sensorEndCarA, ...
            sensorXCarB, sensorYCarB, sensorStartCarB, sensorEndCarB, ...
            Xvect(pos(1)), Yvect(pos(1)), Xvect(pos(3)), Yvect(pos(3)));
    end

    % If not found, the next car is checked
    if isPresent
        %changed for traces

        vehicleReflection_ID = distanceCarIDs(near(i)); % Vehicle on which the reflection point is located

        xVeh = Vpoints(:, 1, :);
        yVeh = Vpoints(:, 2, :);
        xVeh = squeeze(xVeh);
        yVeh = squeeze(yVeh);
        isLOS_reflectedPath = calculateNLOSv_reflected(xVeh, yVeh,...
        XI, YI, vehicleReflection_ID,...
        sensorXCarB, sensorYCarB, sensorXCarA, sensorYCarA, indexCarA,...
        indexCarB);

        if isLOS_reflectedPath == 1
            dist1 = sqrt((sensorXCarA-XI)^2+(sensorYCarA-YI)^2);
            dist2 = sqrt((sensorXCarB-XI)^2+(sensorYCarB-YI)^2);
            return;
        end

    end
    isPresent = false;
end
end