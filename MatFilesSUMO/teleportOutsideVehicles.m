function teleportOutsideVehicles()
%TELEPORTOUTSIDEVEHICLES reset vehicle's position at the beginning of the
%road
%   if vehicle go into the buffer edge, then reset its position to the
%   begging of the road with same lane number


vehicleIDs = traci.vehicle.getIDList;

for i = 1:length(vehicleIDs)
    v_id = vehicleIDs{i};
    lane_id = traci.vehicle.getLaneID(v_id);

    if contains(lane_id, "Lb_to_left")  % vehicle go into left buffer edge
        lane_num = traci.vehicle.getLaneIndex(v_id);
        to_lane_id = sprintf('road_to_left_%d', lane_num);
        lane_pos = traci.vehicle.getLanePosition(v_id);

        % get speed of the first vehicle in the other side of the same lane
        traci.vehicle.moveTo(v_id, to_lane_id, lane_pos);
%         leader_id = traci.vehicle.getLeader(v_id);
%         leader_speed = traci.vehicle.getSpeed(leader_id);
%         traci.vehicle.setSpeed(v_id, leader_speed);
    elseif contains(lane_id, "Rb_to_right")  % vehicle go into right buffer edge
        lane_num = traci.vehicle.getLaneIndex(v_id);
        to_lane_id = sprintf('road_to_right_%d', lane_num);
        lane_pos = traci.vehicle.getLanePosition(v_id);

        % get speed of the first vehicle in the other side of the same lane
        traci.vehicle.moveTo(v_id, to_lane_id, lane_pos);
%         leader_id = traci.vehicle.getLeader(v_id);
%         leader_speed = traci.vehicle.getSpeed(leader_id);
%         traci.vehicle.setSpeed(v_id, leader_speed);
    end

end




end

