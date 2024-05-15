function [VehicleLOS, VehicleNLOS, Vpoints, AntennaPoints] = updatePotentialInterfers(positionManagement, simParams, outParams, timeNow, activeIDs)
%UNPDATEANTENNALOS Update the LOS and NLOS between antennas and vehicles
%based on the location of vehicles and antennas
%   according to the position of vehicles and antennas, calculate if there
%   are LOS between antennas or between vehicles. Because the antennas has
%   limit transmission angles, there are situations the vehicles or
%   antennas could not sensing each other. Noting this is not LOS or NLOS
%
%   The following returned parameters share the same index of parameter
%   "positionManagement.direction"
%
%   VehicleLOS: bool, TxId x RxId
%   VehicleNLOS: bool, TxId x RxId
%   VehicleNoSensing: bool, TxId x RxId

% total number of vehicles
Nvehicles = size(activeIDs, 1);

VehicleLOS = zeros(Nvehicles, Nvehicles);
VehicleNLOS = zeros(Nvehicles, Nvehicles);

% If it was NLOS between cars, approximation was used, if other car block
% the line section between the reference points of Car_A and Car_B

% It takes the information of the current vehicles within the scenario
Vlength = simParams.Vlength(activeIDs);
Vwidth = simParams.Vwidth(activeIDs);
XvehicleReal = positionManagement.XvehicleReal(activeIDs);
YvehicleReal = positionManagement.YvehicleReal(activeIDs);
v = positionManagement.v(activeIDs);
% isNLOSv = calculateNLOSv_direct(positionManagement.XvehicleReal, positionManagement.YvehicleReal, ...
%     simParams.Vlength, simParams.Vwidth, 'true');

%% Get real locations of vehicles and antennas
% points of vehicles' vertices
% 4 x 2 x Nvehicles
% 1-D: Four vertices of a rectangle vehicle
% 2-D: [x, y]

% Vpoints = zeros([size(simParams.Vpoints), Nvehicles]);
Vpoints = simParams.Vpoints(:,:,activeIDs);

% points of antennas' vertices
% NAntennaGroups x 4 x Nvehicles
% 2-D: [x, y, FOV_Start, FOV_End]

% AntennaPoints = zeros([size(simParams.Antenna), Nvehicles]);

% It takes antennas information of current vehicles
AntennaPoints = simParams.Antenna(:,:,activeIDs);


% ============= for checking the rotation matrix =============
% plotVehicleAndAntenna(polyshape(Vpoints(:,:,1)),AntennaPoints(:,:,1)); % before rotate
% positionManagement.direction(1) = exp(1i*pi/6);
% ============================================================

% merge the vehicles with same direction to reduce the calculational
% complexity
% directions = unique(positionManagement.direction);
% directions = unique(positionManagement.direction(activeIDs));

% It takes directions of current vehicles
% directions = positionManagement.direction(activeIDs);
directions = positionManagement.direction;
directions(directions==1)=0;
directions(directions==-1)=180;
% rotate vehicles and antennas according to the direction, get relative coordinate
for i_dr = 1:size(activeIDs,1)
    % RAngle = angle(directions(i_dr));             % heading of vehicle, radian
    RAngle = deg2rad(directions(i_dr));             % heading of vehicle, radian

    % get rotation matrix
    Rcos = cos(RAngle);
    Rsin = sin(RAngle);
    R = [Rcos, Rsin;
        -Rsin, Rcos];

    % rotate vehicle point
    % NewVpoints(:, 1:2) = simParams.Vpoints(:,1:2) * R;
    Vpoints(:,:,i_dr) = Vpoints(:,:,i_dr) * R;

    % rotate antenna point
    % NewAntennaPoints(:,1:2) = simParams.Antenna(:,1:2) * R;
    AntennaPoints(:,1:2,i_dr) = AntennaPoints(:,1:2,i_dr) * R;
    % rotate FOV of antenna
    AntennaPoints(:,3:4,i_dr) = AntennaPoints(:,3:4,i_dr) + RAngle;

    % set points and Range angles for related vehicles and antennas
    % index_dir = directions(i_dr) == positionManagement.direction;
    % nSameDirection = sum(index_dir);
    % Vpoints(:,:,index_dir) = repmat(NewVpoints, [1, 1, nSameDirection]);
    % AntennaPoints(:,:,index_dir) = repmat(NewAntennaPoints, [1, 1, nSameDirection]);
end

% ============= for checking the rotation matrix =============
% plotVehicleAndAntenna(polyshape(Vpoints(:,:,1)),AntennaPoints(:,:,1)); % after rotate
% ============================================================

% real locations of vehicles and antennas
refPoints = [XvehicleReal, YvehicleReal]';    % 2 x Nvehicles
refPoints = reshape(refPoints, 1,2,[]);                                             % 1 x 2 x Nvehicles
Vpoints(:,1:2,:) = Vpoints(:,1:2,:) + refPoints;
AntennaPoints(:,1:2,:) = AntennaPoints(:,1:2,:) + refPoints;

% sensorStart is in [-pi, pi], and sensorEnd is larger than sensorStart
AntennaPoints(:, 3, :) = wrapToPi(AntennaPoints(:, 3, :));
AntennaPoints(:, 4, :) = AntennaPoints(:, 3, :) + wrapTo2Pi(angdiff(AntennaPoints(:, 3, :), AntennaPoints(:, 4, :)));

%% Check if the FOVs of each point could cover each other
% Step 1: calculate the angle of the vector "AB->" that is defined by point sensorCarA and sensorCarB;
% Step 2: check if the angle of "AB->" was located between the FOV_start and
%         FOV_end of Tx;
% Step 3: transpose matrix, also check if the angle of "BA->" was located
%         between the FOV_start and FOV_end of Rx
% Step 4: if step 2 and 3 could be satisfied, then it meas the FOVs of that two
%         points could cover (or "see") each other
% Step 5: ensure the points on the same vehicle would not "see" each other

% Step 1: calculate vectors between antennas
% Points ReFormat
% before reformat: AntennaPoints
%   1-D: points of the antenna groups
%   2-D: [x, y, FOV_start, FOV_end]
%   3-D: vehicle id
% after reformat: RF_antenna
%   1-D: index of each point and antenna of each vehicle, ordered as:
%        Car1Sensor1, Car1Sensor2, ..., Car1SensorN, Car2Sensor1, ...
%   2-D: [x, y, FOV_start, FOV_end]
RF_antenna = reshape(permute(AntennaPoints, [1,3,2]), [], size(AntennaPoints,2),1);

% Vectors from sensor of Tx to sensor of Rx
RF_pointXdis = RF_antenna(:,1)' - RF_antenna(:,1);
RF_pointYdis = RF_antenna(:,2)' - RF_antenna(:,2);
RF_pointRelativeAngle = angle(RF_pointXdis + 1i.*RF_pointYdis);      % Tx x Rx

% Step 2: Check if the FOV of Tx points could cover the vector
startAngle = repmat(RF_antenna(:,3), 1, Nvehicles * simParams.NAntennaGroups);
endAngle = repmat(RF_antenna(:,4), 1, Nvehicles * simParams.NAntennaGroups);
RF_withinFOV = wrapTo2Pi(angdiff(startAngle, RF_pointRelativeAngle)) <= wrapTo2Pi(angdiff(startAngle, endAngle));

% Step 3 and 4: If the FOVs of two points on Tx and Rx could cover the
% direction angle, it means they could "see" each other
RF_withinFOV = RF_withinFOV & RF_withinFOV';

% Step 5: ensuring points from the same vehicle do not "see" each other
EnsureNotSee = repelem(ones(Nvehicles) - eye(Nvehicles), simParams.NAntennaGroups, simParams.NAntennaGroups);
RF_withinFOV = RF_withinFOV & EnsureNotSee;

% Reformat Matrix
% Befor reformat: RF_withinFOV, RF_pointRelativeAngle
%   index of 1st-D: points of Tx, as same as 1-D of RF_points_V_antenna
%   index of 2nd-D: points of Rx, samilar as 1-D of RF_points_V_antenna
% After reformat: withinFOV, pointRelativeAngle
%   index of 1st-D: index of Tx sensor, samilar as 1-D of AntennaPoints
%   index of 2nd-D: index of Tx vehicles
%   index of 3rd-D: index of Rx sensor, samilar as 1-D of AntennaPoints
%   index of 4th-D: index of Rx vehicles
withinFOV = reshape(RF_withinFOV, simParams.NAntennaGroups, Nvehicles, simParams.NAntennaGroups, Nvehicles);

xVeh = Vpoints(:, 1, :);
yVeh = Vpoints(:, 2, :);
xVeh = squeeze(xVeh);
yVeh = squeeze(yVeh);
isNLOSv = calculateNLOSv_direct(xVeh, yVeh, XvehicleReal, YvehicleReal, 'true');

%% Detect Interference and Store Data
for indexCarA = 1:(Nvehicles-1)
    for indexCarB = indexCarA+1:Nvehicles
        % skip if distance |CarA,CarB| is larger than the threshold
        if positionManagement.distanceReal(indexCarA, indexCarB) > simParams.antennaDistanceMax
            continue
        end

        for indexSensorCarA = 1:simParams.NAntennaGroups
            for indexSensorCarB = 1:simParams.NAntennaGroups
                if ~isNLOSv(indexCarA,indexCarB)
                    isPresentDirect = withinFOV(indexSensorCarA, indexCarA, indexSensorCarB, indexCarB);
                    if isPresentDirect

                        % if makeplot==true
                        %     plot([XsensorA,XsensorB],[YsensorA,YsensorB],'g');
                        % end
                        VehicleLOS(indexCarA, indexCarB) = 1;
                        VehicleLOS(indexCarB, indexCarA) = 1;

                        distancePath = sqrt((AntennaPoints(indexSensorCarA,1,indexCarA)-AntennaPoints(indexSensorCarB,1,indexCarB))^2+(AntennaPoints(indexSensorCarA,2,indexCarA)-AntennaPoints(indexSensorCarB,2,indexCarB))^2);

                        if outParams.logPotentialInterferers && timeNow>0

                            %Save the interferers informations in the database
                            logPotentialInterferers(outParams,timeNow,...
                                activeIDs(indexCarA), XvehicleReal(indexCarA),...
                                YvehicleReal(indexCarA),...
                                positionManagement.direction(indexCarA), v(indexCarA), ...
                                indexSensorCarA, AntennaPoints(indexSensorCarA,1,indexCarA), AntennaPoints(indexSensorCarA,2,indexCarA),...
                                (AntennaPoints(indexSensorCarA,3,indexCarA)+AntennaPoints(indexSensorCarA,4,indexCarA))/2,...
                                (AntennaPoints(indexSensorCarA,4,indexCarA)-AntennaPoints(indexSensorCarA,3,indexCarA)),...
                                activeIDs(indexCarB), XvehicleReal(indexCarB), YvehicleReal(indexCarB), ...
                                positionManagement.direction(indexCarB), v(indexCarB), ...
                                indexSensorCarB, AntennaPoints(indexSensorCarB,1,indexCarB), AntennaPoints(indexSensorCarB,2,indexCarB),...
                                (AntennaPoints(indexSensorCarB,3,indexCarB)+AntennaPoints(indexSensorCarB,4,indexCarB))/2,...
                                (AntennaPoints(indexSensorCarB,4,indexCarB)-AntennaPoints(indexSensorCarB,3,indexCarB)),...
                                distancePath, -1, -1, -1);

                            logPotentialInterferers(outParams,timeNow,...
                                activeIDs(indexCarB), XvehicleReal(indexCarB), YvehicleReal(indexCarB), ...
                                positionManagement.direction(indexCarB), v(indexCarB), ...
                                indexSensorCarB, AntennaPoints(indexSensorCarB,1,indexCarB), AntennaPoints(indexSensorCarB,2,indexCarB),...
                                (AntennaPoints(indexSensorCarB,3,indexCarB)+AntennaPoints(indexSensorCarB,4,indexCarB))/2,...
                                (AntennaPoints(indexSensorCarB,4,indexCarB)-AntennaPoints(indexSensorCarB,3,indexCarB)),...
                                activeIDs(indexCarA), XvehicleReal(indexCarA),...
                                YvehicleReal(indexCarA),...
                                positionManagement.direction(indexCarA), v(indexCarA), ...
                                indexSensorCarA, AntennaPoints(indexSensorCarA,1,indexCarA), AntennaPoints(indexSensorCarA,2,indexCarA),...
                                (AntennaPoints(indexSensorCarA,3,indexCarA)+AntennaPoints(indexSensorCarA,4,indexCarA))/2,...
                                (AntennaPoints(indexSensorCarA,4,indexCarA)-AntennaPoints(indexSensorCarA,3,indexCarA)),...
                                distancePath, -1, -1, -1);

                        end
                        continue;

                    end
                else
                    VehicleNLOS(indexCarA, indexCarB) = 1;
                    VehicleNLOS(indexCarB, indexCarA) = 1;
                end

                % vehivles that MIGHT be sensed by both CarA and CarB
                indexMaySensingSameTime = ~isNLOSv(:,indexCarA) & ~isNLOSv(:,indexCarB);

                % if there are no cars in LOS of both cars mounting the sensors, exit
                if isempty(find(indexMaySensingSameTime,1))
                    continue;
                end

                % Checks if there is one car in LOS of both the cars mounting the sensors
                % and inside the FOV of both sensors
                [isPresentReflected,XI,YI,dist1,dist2] = isReflectedPath(Vpoints, AntennaPoints, indexCarA, indexSensorCarA, ...
                    indexCarB, indexSensorCarB, indexMaySensingSameTime, ...
                    positionManagement.distanceReal, simParams.antennaDistanceMax,...
                    positionManagement); %positionManagement, simParams.Vlength, simParams.Vwidth added

                if isPresentReflected
                    % if makeplot==true
                    %     plot([XsensorA,XI],[YsensorA,YI],'b');
                    %     plot([XsensorB,XI],[YsensorB,YI],'b');
                    % end
                    if outParams.logPotentialInterferers && timeNow>0

                        %Save the interferers informations in the database
                        logPotentialInterferers(outParams,timeNow,...
                            activeIDs(indexCarA), XvehicleReal(indexCarA),...
                            YvehicleReal(indexCarA),...
                            positionManagement.direction(indexCarA), v(indexCarA), ...
                            indexSensorCarA, AntennaPoints(indexSensorCarA,1,indexCarA), AntennaPoints(indexSensorCarA,2,indexCarA),...
                            (AntennaPoints(indexSensorCarA,3,indexCarA)+AntennaPoints(indexSensorCarA,4,indexCarA))/2,...
                            (AntennaPoints(indexSensorCarA,4,indexCarA)-AntennaPoints(indexSensorCarA,3,indexCarA)),...
                            activeIDs(indexCarB), XvehicleReal(indexCarB), YvehicleReal(indexCarB), ...
                            positionManagement.direction(indexCarB), v(indexCarB), ...
                            indexSensorCarB, AntennaPoints(indexSensorCarB,1,indexCarB), AntennaPoints(indexSensorCarB,2,indexCarB),...
                            (AntennaPoints(indexSensorCarB,3,indexCarB)+AntennaPoints(indexSensorCarB,4,indexCarB))/2,...
                            (AntennaPoints(indexSensorCarB,4,indexCarB)-AntennaPoints(indexSensorCarB,3,indexCarB)),...
                            dist1, dist2, XI, YI);

                        logPotentialInterferers(outParams,timeNow,...
                            activeIDs(indexCarB), XvehicleReal(indexCarB), YvehicleReal(indexCarB), ...
                            positionManagement.direction(indexCarB), v(indexCarB), ...
                            indexSensorCarB, AntennaPoints(indexSensorCarB,1,indexCarB), AntennaPoints(indexSensorCarB,2,indexCarB),...
                            (AntennaPoints(indexSensorCarB,3,indexCarB)+AntennaPoints(indexSensorCarB,4,indexCarB))/2,...
                            (AntennaPoints(indexSensorCarB,4,indexCarB)-AntennaPoints(indexSensorCarB,3,indexCarB)),...
                            activeIDs(indexCarA), XvehicleReal(indexCarA),...
                            YvehicleReal(indexCarA),...
                            positionManagement.direction(indexCarA), v(indexCarA), ...
                            indexSensorCarA, AntennaPoints(indexSensorCarA,1,indexCarA), AntennaPoints(indexSensorCarA,2,indexCarA),...
                            (AntennaPoints(indexSensorCarA,3,indexCarA)+AntennaPoints(indexSensorCarA,4,indexCarA))/2,...
                            (AntennaPoints(indexSensorCarA,4,indexCarA)-AntennaPoints(indexSensorCarA,3,indexCarA)),...
                            dist2, dist1, XI, YI);

                    end
                    continue;
                end
                % end
            end
        end
    end
end


end

