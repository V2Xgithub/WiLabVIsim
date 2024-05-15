function genSumoTyp(simParams, path_sumo_cfg)
%GENSUMOTYP generate the type of edge

import matlab.io.xml.dom.*

docNode = Document("types");
types = getDocumentElement(docNode);

type = docNode.createElement("type");
attrName = ["id", "priority", "numlanes", "speed"];
% the average speed is set as the maximum speed of the edge (or road). 
% speedFactor*edge_speed is the vehicle's speed. In this case, the speed of
% each vehicle could be set with a proper speedFactor 
attrVal = ["highway", "3", simParams.NLanes, num2str(simParams.highwaySpeedLim/3.6)];  % [m/s]

% for i = 1:length(attrName)
%     type.setAttribute(attrName(i), attrVal(i)); 
% end
xmlSetAttr(type, attrName, attrVal);
types.appendChild(type);

fileFormat = ".typ.xml";
xmlFileName = "linkSumo" + fileFormat;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writeToFile(writer,docNode,fullfile(path_sumo_cfg,xmlFileName));

fprintf('"%s" has been generated.\n', fileFormat);
end

