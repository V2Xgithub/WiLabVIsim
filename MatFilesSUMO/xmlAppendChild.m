function xmlAppendChild(parent_node, child_nodes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(child_nodes)
    parent_node.appendChild(child_nodes(i));
end


end

