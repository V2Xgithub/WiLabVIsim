function genSumoViewSettings(simParams, path_sumo_cfg)
%GENSUMOCFG Summary of this function goes here
%   Detailed explanation goes here
import matlab.io.xml.dom.*

% docNode = Document("configuration");

docNode = Document("viewsettings");
viewsettings = getDocumentElement(docNode);
% edges = getDocumentElement(docNode);
% input

scheme_attr = "name";
scheme = docNode.createElement("scheme");
scheme_attr_value = "real world";
scheme.setAttribute(scheme_attr, scheme_attr_value);
viewsettings.appendChild(scheme);


% e_input = docNode.createElement("viewsettings");
% c_names = "scheme";
% c_texts = "real world";
% xmlCreateElementWithText(docNode, e_input, c_names, c_texts)
% xmlAppendChild(viewsettings, e_input);

fileFormat = ".xml";
xmlFileName = "viewsettings" + fileFormat;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writeToFile(writer,docNode,fullfile(path_sumo_cfg,xmlFileName));

fprintf('"%s" has been generated.\n', fileFormat);

end
