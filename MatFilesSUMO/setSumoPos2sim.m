function [simValues, positionManagement] = setSumoPos2sim(simValues, positionManagement)
%set vehicles' location from sumo to WiLabSimV2X

for id = simValues.IDvehicle'  % IDvehicle is also the num index of sumoIDList
     v_pos = traci.vehicle.getPosition(simValues.sumoIDList{id});
     positionManagement.XvehicleReal(id) = v_pos(1);
     positionManagement.YvehicleReal(id) = v_pos(2);
end

% set the outside-net vehicle's location as -1
outsideIndex = find(simValues.sumoIDListIndex==0);
positionManagement.XvehicleReal(outsideIndex) = -1;
positionManagement.YvehicleReal(outsideIndex) = -1;



