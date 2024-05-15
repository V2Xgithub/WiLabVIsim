function [outputArg1,outputArg2] = xmlCreateElementWithText(docNode, e_parent, e_child_names, c_texts)
%XMLCREATEELEMENTWITHTEXT Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(e_child_names)
    e_child = docNode.createElement(e_child_names(i));
    e_child.appendChild(docNode.createTextNode(c_texts(i)));
    e_parent.appendChild(e_child);
end

end

