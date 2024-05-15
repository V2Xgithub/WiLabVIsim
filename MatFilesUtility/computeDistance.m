function [positionManagement] = computeDistance (positionManagement)
% Function derived dividing previous version in computeDistance and
% computeNeighbors (version 5.6.0)


% Compute distance matrix
positionManagement.distanceReal = sqrt((positionManagement.XvehicleReal - positionManagement.XvehicleReal').^2+(positionManagement.YvehicleReal - positionManagement.YvehicleReal').^2);

end