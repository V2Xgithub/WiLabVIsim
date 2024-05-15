function newY = rotoTranslate_obstacleCheck(X,Y,X1,Y1,X2,Y2)
%ROTOTRANSLATE Summary of this function goes here
%   Detailed explanation goes here

for j = 1:length(X)

    alpha=atan((Y2-Y1)/(X2-X1));
    if X1>X2
        alpha=alpha+pi;
    end

    cosaminus = cos(-alpha);
    sinaminus = sin(-alpha);

    R = [ cosaminus sinaminus;
        -sinaminus cosaminus];

    % X = [x1 x2];
    % Y = [y1 y2];

    newC = [X(j)-X1 Y(j)-Y1];
    newC = newC*R;
    % %
    % newX(i) = newC(1);
    newY(j) = newC(2);
end

end

