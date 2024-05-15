function [simValues, positionManagement] = genSumoRoute(simParams, simValues, path_sumo_cfg, positionManagement)
%GENSUMOROUTE setting vehicle's position and speed. 
%   tothink: 
%   1st way is copy the position and speed from WiLabV2Xsim,
%   which may have some problem, maybe need to move to the 2nd way.
%
%   2nd way is generate position and speed here and do not use the
%   setting in the WiLabV2Xsim. After running for a while, if all of the
%   vehicles were set in the net, the WiLabV2Xsim could be start and copy
%   the settings from here

import matlab.io.xml.dom.*

%% other parameters
minGap = 2.5;  % minimum gap between vehicles

%% set xml
docNode = Document("routes");
routes = getDocumentElement(docNode);

% vtype, in 2nd way, set speedFactor and speedDev in vtype
e_vtype = docNode.createElement("vType");
% https://copradar.com/chapts/references/acceleration.html#:~:text=Maximum%20vehicle%20acceleration%20depends%20on%20tires%20and%20horsepower.,mph%20per%20second%20and%20equates%20to%20%2B0.55%20g%27s.
attrName = ["id", "accel", "decel", "length", "width", "minGap", "maxSpeed", "speedFactor", "sigma"];
attrVal = ["carA", "5.4", "9.8", num2str(simParams.Vlength(1)), num2str(simParams.Vwidth(1)), num2str(minGap), num2str(simParams.carMaxSpeed/3.6), "normc(1, 0.1, 0.2, 2)", "0.5"];  % maxspeed: [m/s]
xmlSetAttr(e_vtype, attrName, attrVal);

% route
attrName = ["id", "edges"];
attrVal_L = ["left", "road_to_left Lb_to_left"];
attrVal_R = ["right", "road_to_right Rb_to_right"];
e_route_L = docNode.createElement("route");
xmlSetAttr(e_route_L, attrName, attrVal_L);
e_route_R = docNode.createElement("route");
xmlSetAttr(e_route_R, attrName, attrVal_R);

xmlAppendChild(routes, [e_vtype, e_route_L, e_route_R]);

%% add vehicles
routeName = ["right", "left"];  

% direction
%-1: <--
% 1: -->
% numToRight = floor(simValues.maxID/2);
% numToLeft = simValues.maxID - numToRight;
%%% NEW %%%
% numToLeft = floor(simValues.maxID * (simParams.RightToLeft_rate/100));
% numToRight = simValues.maxID - numToLeft;
%%% NEW 3 %%%
numToLeft = simParams.RightToLeft_Vehicles * (simParams.roadLength/1000);
numToRight = simValues.maxID - numToLeft;

tempDirection = [0*ones(numToRight,1); ones(numToLeft,1)];  
tempDirection = tempDirection(randperm(length(tempDirection)));

attr_route = routeName(tempDirection+1);
positionManagement.direction = 1 - 2*tempDirection;

% right most of each direction is 0 lane
attr_lane_id = randi([0, simParams.NLanes-1], [simValues.maxID, 1]);

% position
positionManagement.YvehicleReal = simParams.roadWidth*((attr_lane_id+1).*(positionManagement.direction == 1) + (2*simParams.NLanes - attr_lane_id).*(positionManagement.direction==-1));

d_pos = zeros(simValues.maxID, 1);
% d_pos = rand(1, simValues.maxID) .* simParams.roadLength;  % the real road length in the SUMO may be shoter
% d_pos = sort(d_pos);
for i_direc = [-1, 1]
    for L_id = 0:simParams.NLanes-1
        v_index = (positionManagement.direction==i_direc) & (attr_lane_id==L_id);  % index in one lane
        v_num = nnz(v_index);
        lenth_must = v_num * (minGap + simParams.Vlength(1));
        if lenth_must > simParams.roadLength
            error("Too much vehicles located on one lane!");
        end
        length_remain = simParams.roadLength - lenth_must;
        rand_ratio = rand(v_num+1, 1);
        rand_ratio = rand_ratio ./ sum(rand_ratio);
        rand_length = length_remain .* rand_ratio;
        % temp_pos = rand_length(1:end-1) + (minGap + simParams.Vlength);   
        % temp_pos(1) = temp_pos(1) - (minGap + simParams.Vlength)/2;
        temp_pos = rand_length(1:end-1) + (minGap + simParams.Vlength(1));
        temp_pos(1) = temp_pos(1) - (minGap + simParams.Vlength(1))/2;
        d_pos(v_index) = cumsum(temp_pos);
    end
end

attrName = ["id", "type", "route", "depart", "departLane", "departPos", "departSpeed"];
for id = 1:simValues.maxID
    e_vehicle = docNode.createElement("vehicle");
    attrVal = [string(id), "carA", attr_route(id), "0", string(attr_lane_id(id)), string(d_pos(id)), "0"];   % num2str(positionManagement.v(id))
    xmlSetAttr(e_vehicle, attrName, attrVal);
    routes.appendChild(e_vehicle);
end

fileFormat = ".rou.xml";
xmlFileName = "linkSumo" + fileFormat;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writeToFile(writer,docNode,fullfile(path_sumo_cfg,xmlFileName));

fprintf('"%s" has been generated.\n', fileFormat);

end

