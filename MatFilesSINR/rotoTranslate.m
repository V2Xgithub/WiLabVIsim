function [newX,newY] = rotoTranslate(X,Y,X1,Y1,X2,Y2)
%ROTOTRANSLATE Summary of this function goes here
%   Detailed explanation goes here

alpha=atan((Y2-Y1)/(X2-X1));
if X1>X2
    alpha=alpha+pi;
end

cosaminus = cos(-alpha);
sinaminus = sin(-alpha);

% R = [ cosaminus sinaminus;
%     -sinaminus cosaminus];
% 
% newC = [X-X1 Y-Y1];
% newC = newC*R;
% 
% newX = newC(1);
% newY = newC(2);

newX = (X-X1)*cosaminus - (Y-Y1)*sinaminus;
newY = (X-X1)*sinaminus + (Y-Y1)*cosaminus;

end

