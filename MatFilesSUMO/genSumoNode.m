function genSumoNode(simParams, path_sumo_cfg)
%GENSUMONODE only for highway scenario at current
%   generate 4 points, 2 for real road, 2 for buffer. If a vehicle went out
%   of the road, it would go into the road at the other end.
import matlab.io.xml.dom.*

docNode = Document("nodes");
nodes = getDocumentElement(docNode);
nodes.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
nodes.setAttributeNS("http://www.w3.org/2000/xmlns/", "xsi:noNamespaceSchemaLocation", "http://sumo.dlr.de/xsd/nodes_file.xsd");
node_attr = ["id", "x", "y", "type"];
x = [0, 10, 10+simParams.roadLength, 20+simParams.roadLength];
for i=1:4
    node = docNode.createElement("node");
    node_attr_value = ["nod_"+num2str(i), x(i), "0", "priority"];
    for i_attr = 1:length(node_attr)
        node.setAttribute(node_attr(i_attr), node_attr_value(i_attr));
    end
    nodes.appendChild(node);
end

fileFormat = ".nod.xml";
xmlFileName = "linkSumo" + fileFormat;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writeToFile(writer,docNode,fullfile(path_sumo_cfg,xmlFileName));

fprintf('"%s" has been generated.\n', fileFormat);
end

