function [outputArg1,outputArg2] = genSumoCfg(simParams, path_sumo_cfg)
%GENSUMOCFG Summary of this function goes here
%   Detailed explanation goes here
import matlab.io.xml.dom.*

docNode = Document("configuration");
configuration = getDocumentElement(docNode);
configuration.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
configuration.setAttributeNS("http://www.w3.org/2000/xmlns/", "xsi:noNamespaceSchemaLocation", "http://sumo.dlr.de/xsd/sumoConfiguration.xsd");


% input
e_input = docNode.createElement("input");
% c_names = ["net-file", "route-files"];
% c_texts = ["linkSumo.net.xml", "linkSumo.rou.xml"];
c_names = ["net-file", "route-files", "gui-settings-file"];
c_texts = ["linkSumo.net.xml", "linkSumo.rou.xml", "viewsettings.xml"];
xmlCreateElementWithText(docNode, e_input, c_names, c_texts)

% time
e_time = docNode.createElement("time");
c_names = ["begin", "end", "step-length"];
c_texts = ["0", string(2*simParams.simulationTime), string(simParams.positionTimeResolution)];
xmlCreateElementWithText(docNode, e_time, c_names, c_texts);

% processing
e_processing = docNode.createElement("processing");
c_names = ["time-to-teleport", "collision.action"];
c_texts = ["-1", "warn"];
xmlCreateElementWithText(docNode, e_processing, c_names, c_texts);

% output
e_output = docNode.createElement("output");
c_names = ["collision-output", "statistic-output", "tripinfo-output", "fcd-output", "fcd-output.acceleration"];
c_texts = ["out.collision.xml", "out.statistic.xml", "out.tripinfo.xml",...
    "out.fcd.xml", "True"];
xmlCreateElementWithText(docNode, e_output, c_names, c_texts);

% random
e_random = docNode.createElement("random_number");
c_names = "seed";
c_texts = string(simParams.seed-2147483649);  % random seed in sumo change mapping with simulator

xmlCreateElementWithText(docNode, e_random, c_names, c_texts);


xmlAppendChild(configuration, [e_input, e_time, e_processing, e_output, e_random]);

fileFormat = ".sumocfg";
xmlFileName = "linkSumo" + fileFormat;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writeToFile(writer,docNode,fullfile(path_sumo_cfg,xmlFileName));

fprintf('"%s" has been generated.\n', fileFormat);

end

