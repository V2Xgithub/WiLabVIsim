function [positionManagement] = setParamsSumo2sim(simParams, positionManagement)
%SETPARAMS2SIM copy parameters from SUMO to simulator
%   updata: simValues.v, positionManagement.XvehicleReal, positionManagement.YvehicleReal
%   not update: simValues.direction
vehicle_ids = traci.vehicle.getIDList;
for i = 1:length(vehicle_ids)
    v_id = vehicle_ids{i};
    v_id_sim = str2double(v_id);
    positionManagement.v(v_id_sim) = traci.vehicle.getSpeed(v_id);
    
    % position global
    v_lane_id = traci.vehicle.getLaneIndex(v_id);
    switch traci.vehicle.getRouteID(v_id)   % move to left: <--
        case "left"
            positionManagement.XvehicleReal(v_id_sim) = simParams.roadLength -traci.vehicle.getLanePosition(v_id);
            positionManagement.YvehicleReal(v_id_sim) = simParams.roadWidth*(2*simParams.NLanes-v_lane_id);
        case "right"    % 1, move to right: -->
            positionManagement.XvehicleReal(v_id_sim) = traci.vehicle.getLanePosition(v_id);
            positionManagement.YvehicleReal(v_id_sim) = simParams.roadWidth*(v_lane_id+1);
        otherwise
            error("something went error")
    end

end
