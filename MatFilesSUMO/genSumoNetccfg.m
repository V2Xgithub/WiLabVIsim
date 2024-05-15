function [outputArg1,outputArg2] = genSumoNetccfg(simParams, path_sumo_cfg)
%GENSUMONETCCFG Summary of this function goes here
%   Detailed explanation goes here
import matlab.io.xml.dom.*

docNode = Document("configuration");
root = getDocumentElement(docNode);
root.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
root.setAttributeNS("http://www.w3.org/2000/xmlns/", "xsi:noNamespaceSchemaLocation", "http://sumo.dlr.de/xsd/netconvertConfiguration.xsd");

% input files
e_input = docNode.createElement("input");
node_file = docNode.createElement("node-files");
node_file.appendChild(docNode.createTextNode("linkSumo.nod.xml"));

edge_file = docNode.createElement("edge-files");
edge_file.appendChild(docNode.createTextNode("linkSumo.edg.xml"));

typ_file = docNode.createElement("type-files");
typ_file.appendChild(docNode.createTextNode("linkSumo.typ.xml"));

xmlAppendChild(e_input, [node_file, edge_file, typ_file]);

% output files
e_output = docNode.createElement("output");
out_file = docNode.createElement("output-file");
out_file.appendChild(docNode.createTextNode("linkSumo.net.xml"));
e_output.appendChild(out_file);

% building defaults
e_bd = docNode.createElement("building_defaults");
d_lane_n = docNode.createElement("default.lanenumber");
d_lane_n.appendChild(docNode.createTextNode(num2str(simParams.NLanes)));
e_bd.appendChild(d_lane_n);
d_lane_w = docNode.createElement("default.lanewidth");
d_lane_w.appendChild(docNode.createTextNode(num2str(simParams.roadWidth)));

% junctions
e_junc = docNode.createElement("junctions");
no_turn = docNode.createElement("no-turnarounds");
no_turn.appendChild(docNode.createTextNode("True"));
e_junc.appendChild(no_turn);

% report
e_report = docNode.createElement("report");
verbose = docNode.createElement("verbose");
verbose.appendChild(docNode.createTextNode("True"));
e_report.appendChild(verbose);

xmlAppendChild(root, [e_input, e_output, e_bd, e_junc, e_report]);

fileFormat = ".netccfg";
xmlFileName = "linkSumo" + fileFormat;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writeToFile(writer,docNode,fullfile(path_sumo_cfg,xmlFileName));

fprintf('"%s" has been generated.\n', fileFormat);
end

