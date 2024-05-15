function outParams = outputDB_init(outParams)
%outpuDB_init Create tables in the database for related simulation
%results
%   Detailed explanation goes here

    % Used in logVehicleLocation.m
    if outParams.log_vLocation
        % Create vLocation table
        sqlquery = "create table vLocation " + ...
            "(" + ...
            "time double not null," + ...
            "Vid double not null," + ...
            "V_x double not null," + ...
            "V_y double not null," + ...
            "V_speed double not null" + ...
            sprintf(", corner_p%d_x double not null, corner_p%d_y double not null", [1:4;1:4]) + ...            
            ");";
        execute(outParams.conn,sqlquery);
    end

   
    if outParams.logPotentialInterferers
        sqlquery = "create table firstReflectLog " + ...
        "(" + ...
        "time double not null," + ...
        "interferedId double not null," + ...
        "interfered_x double not null," + ...
        "interfered_y double not null," + ...
        "interferedDirection double not null," + ...
        "interferedSpeed double not null," + ...
        "interferedSensorId double not null," + ...
        "interferedSensor_x double not null," + ...
        "interferedSensor_y double not null," + ...
        "interferedSensorDir double not null," + ...
        "interferedSensorFOV double not null," + ...
        "interferingId double not null," + ...
        "interfering_x double not null," + ...
        "interfering_y double not null," + ...
        "interferingDirection double not null," + ...
        "interferingSpeed double not null," + ...
        "interferingSensorId double not null," + ...
        "interferingSensor_x double not null," + ...
        "interferingSensor_y double not null," + ...
        "interferingSensorDir double not null," + ...
        "interferingSensorFOV double not null," + ...
        "lengthPathFirst double," + ...
        "lengthPathSecond double," + ...
        "reflectPointX double," + ...
        "reflectPointY double" + ...
        ");";
        execute(outParams.conn,sqlquery);
    end
end