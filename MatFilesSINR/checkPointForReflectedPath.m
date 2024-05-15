function [isPresent,XI,YI] = checkPointForReflectedPath(X1, Y1, angle1A, angle1B, X2, Y2, angle2A, angle2B, Xcheck, Ycheck)

angleCto1 = atan((Y1-Ycheck)/(X1-Xcheck));
if Xcheck<X1
    angleCto1 = angleCto1 +pi;
end
while angleCto1>angle1A
    angleCto1 = angleCto1 - 2*pi;
end
angleCto1 = angleCto1 + 2*pi;

angleCto2 = atan((Y2-Ycheck)/(X2-Xcheck));
if Xcheck<X2
    angleCto2 = angleCto2 +pi;
end
while angleCto2>angle2A
    angleCto2 = angleCto2 - 2*pi;
end
angleCto2 = angleCto2 + 2*pi;


if angleCto1>angle1A && angleCto1<angle1B && angleCto2>angle2A && angleCto2<angle2B
    isPresent = true;
    XI = Xcheck;
    YI = Ycheck;
else
    isPresent = false;
    XI = -1;
    YI = -1;
end
    