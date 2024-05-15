function logVehicleLocation(time, Vpoints, XvehicleReal, YvehicleReal, velocity, outParams)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

tableName = "vLocation";

for vid = 1:size(Vpoints, 3)
    Str.time = time;
    Str.Vid = vid;
    Str.V_x = XvehicleReal(vid);
    Str.V_y = YvehicleReal(vid);
    Str.V_speed = velocity(vid);
    for cornerID = 1:4
        Str.(sprintf("corner_p%d_x", cornerID)) = Vpoints(cornerID, 1, vid);
        Str.(sprintf("corner_p%d_y", cornerID)) = Vpoints(cornerID, 2, vid);
    end
    T = struct2table(Str);
    sqlwrite(outParams.conn,tableName,T);
end


end

