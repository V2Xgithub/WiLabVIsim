function [XvehicleReal,YvehicleReal,IDvehicle,indexNewVehicles,indexOldVehicles,indexOldVehiclesToOld,IDvehicleExit,speedNow] = updatePositionFromSUMO(timeNow,oldIdVehicle,simValues,outParams)
% Update position of vehicles from SUMO
traci.simulationStep(timeNow+simValues.sumoTimeOffset);  % todo: end of time


sumoIdVehicle = traci.vehicle.getIDList;
newVehicle = setdiff(sumoIdVehicle, simValues.sumoIDList);
simValues.sumoIDList = [simValues.sumoIDList, newVehicle];  % add new vehicle

% index in simValues.sumoIDList is the IDvehicle (the IDs in simulator)
[~, ~, IDvehicle] = intersect(sumoIdVehicle, simValues.sumoIDList, 'stable'); 
% init
XvehicleReal = zeros(length(sumoIdVehicle),1);YvehicleReal = XvehicleReal;speedNow = XvehicleReal;
for i = 1:length(sumoIdVehicle)
    vehiclePosition = traci.vehicle.getPosition(sumoIdVehicle{i});
    XvehicleReal(i) = vehiclePosition(1);
    YvehicleReal(i) = vehiclePosition(2);
    speedNow(i) = traci.vehicle.getSpeed(sumoIdVehicle{i});
end


% Sort IDvehicle, XvehicleReal and YvehicleReal by IDvehicle
[IDvehicle,indexOrder] = sort(IDvehicle);
XvehicleReal = XvehicleReal(indexOrder);
YvehicleReal = YvehicleReal(indexOrder);
speedNow = speedNow(indexOrder);


[~,indexNewVehicles] = setdiff(IDvehicle,oldIdVehicle,'stable');

% Find IDs of vehicles that are exiting the scenario
IDvehicleExit = setdiff(oldIdVehicle,IDvehicle);

% Find indices of vehicles in IDvehicle that are both in IDvehicle and OldIDvehicle
indexOldVehicles = find(ismember(IDvehicle,oldIdVehicle));

% Find indices of vehicles in OldIDvehicle that are both in IDvehicle and OldIDvehicle
indexOldVehiclesToOld = find(ismember(oldIdVehicle,IDvehicle));


% Print speed (if enabled)
if ~isempty(outParams) && outParams.printSpeed
    printSpeedToFile(timeNow,IDvehicle,speedNow,simValues.maxID,outParams);
end
