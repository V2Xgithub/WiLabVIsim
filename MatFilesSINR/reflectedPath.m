function [isPresent,XI,YI] = reflectedPath( X1, Y1, angle1A, angle1B, X2, Y2, angle2A, angle2B, X3, Y3, X4, Y4)

% Given one segment and the two sensors, it is checked if one extreme is
% inside both FOV, then the middle point, then the other vertex

% Firstly check if the rect including the segment does not pass between the
% two sensors, because in such case the segment cannot be a reflected path

% I set X3, Y3 as the origin and rotate following the segment to X4, Y4
% At that point, if Y1rotoTranslated and Y2rototranslate are one positive
% and the other negative, the straight extending the segment 3-4 intersects 
% the segment 1-2 and this means that the signals sent by the two sensors
% impact on the segment 3-4 on different sides; this cannot create a
% reflection
[~,rotoTranslatedY1] = rotoTranslate(X1,Y1,X3,Y3,X4,Y4);
[~,rotoTranslatedY2] = rotoTranslate(X2,Y2,X3,Y3,X4,Y4);
if rotoTranslatedY1 * rotoTranslatedY2 < 0
    isPresent = false;
    YI=-1;
    XI=-1;
    return;
end

% Operations are used to correctly calculate the angles
[isPresent,XI,YI] = checkPointForReflectedPath(X1, Y1, angle1A, angle1B, X2, Y2, angle2A, angle2B, X3, Y3);

if ~isPresent
    X5 = (X3+X4)/2;
    Y5 = (Y3+Y4)/2;
    [isPresent,XI,YI] = checkPointForReflectedPath(X1, Y1, angle1A, angle1B, X2, Y2, angle2A, angle2B, X5, Y5);
    
    if ~isPresent
        [isPresent,XI,YI] = checkPointForReflectedPath(X1, Y1, angle1A, angle1B, X2, Y2, angle2A, angle2B, X4, Y4);
    end
end