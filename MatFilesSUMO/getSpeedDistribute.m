function speeds = getSpeedDistribute(Vids)
%GETSPEEDDISTRIBUTE get all of the vehicles' speed from SUMO
%   speeds is a vertor

speeds = zeros(length(Vids), 1);
for i = 1:length(Vids)
    speeds(i) = traci.vehicle.getSpeed(Vids{i});
end


end

