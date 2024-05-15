function [outputArg1,outputArg2] = genSumoEdge(simParams, path_sumo_cfg)
%GENSUMOEDGE Summary of this function goes here
%   Detailed explanation goes here
import matlab.io.xml.dom.*

docNode = Document("edges");
edges = getDocumentElement(docNode);
edges.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
edges.setAttributeNS("http://www.w3.org/2000/xmlns/", "xsi:noNamespaceSchemaLocation", "http://sumo.dlr.de/xsd/edges_file.xsd");

Lb_to_right = docNode.createElement("edge");
xmlSetAttr(Lb_to_right, ["id", "from", "to", "type"], ["Lb_to_right", "nod_1", "nod_2", "highway"]);
Lb_to_left = docNode.createElement("edge");
xmlSetAttr(Lb_to_left, ["id", "from", "to", "type"], ["Lb_to_left", "nod_2", "nod_1", "highway"]);

road_to_right = docNode.createElement("edge");
xmlSetAttr(road_to_right, ["id", "from", "to", "type"], ["road_to_right", "nod_2", "nod_3", "highway"]);
road_to_left = docNode.createElement("edge");
xmlSetAttr(road_to_left, ["id", "from", "to", "type"], ["road_to_left", "nod_3", "nod_2", "highway"]);

Rb_to_left = docNode.createElement("edge");
xmlSetAttr(Rb_to_left, ["id", "from", "to", "type"], ["Rb_to_left", "nod_4", "nod_3", "highway"]);
Rb_to_right = docNode.createElement("edge");
xmlSetAttr(Rb_to_right, ["id", "from", "to", "type"], ["Rb_to_right", "nod_3", "nod_4", "highway"]);

xmlAppendChild(edges, [Lb_to_right,Lb_to_left,road_to_right,road_to_left,Rb_to_left,Rb_to_right]);

fileFormat = ".edg.xml";
xmlFileName = "linkSumo" + fileFormat;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writeToFile(writer,docNode,fullfile(path_sumo_cfg,xmlFileName));

fprintf('"%s" has been generated.\n', fileFormat);
end

