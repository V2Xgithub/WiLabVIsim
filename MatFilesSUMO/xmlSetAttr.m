function xmlSetAttr(element, attrName, attrVal)
%XMLSETATTR Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(attrName)
    element.setAttribute(attrName(i), attrVal(i));
end

end

