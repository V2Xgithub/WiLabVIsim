function [simParams,simValues,positionManagement] = initiatePositionInScenarioPPP(simParams)
    % Scenario
    positionManagement.Xmin = 0;                           % Min X coordinate
    positionManagement.Xmax = simParams.roadLength;        % Max X coordinate
    positionManagement.Ymin = 0;                           % Min Y coordinate
    % Max Y coordinate
    positionManagement.Ymax = 2*simParams.NLanes*simParams.roadWidth;
    
    vMeanMs = simParams.vMean/3.6;                % Mean vehicle speed (m/s)
    vStDevMs = simParams.vStDev/3.6;              % Speed standard deviation (m/s)
    simParams.vehicleDensityM = simParams.vehicleDensity/1e3;           % Average vehicle density (vehicles/m)
    
    Nvehicles = round(simParams.vehicleDensityM*positionManagement.Xmax);   % Number of vehicles
    % Throw an error if there are no vehicles in the scenario
    if ~Nvehicles
        error('Error: no vehicles in the simulation.');
    end

    simValues.IDvehicle(:,1) = 1:Nvehicles;             % Vector of IDs
    simValues.maxID = Nvehicles;                        % Maximum vehicle's ID
    
    if simParams.randomXPosition
        % Generate X coordinates of vehicles (uniform distribution)
        positionManagement.XvehicleReal = positionManagement.Xmax.*rand(Nvehicles,1);
    else
        % Uniformly positioned
        positionManagement.XvehicleReal = (1:Nvehicles)*floor(positionManagement.Xmax/(Nvehicles));
    end

    % Generate driving direction
    %  1 -> from left to right, theta = 0
    % -1 -> from right to left, theta = pi
    positionManagement.direction = 2*(rand(Nvehicles,1)>0.5) - 1;
    left = positionManagement.direction==-1;
    
    % Generate Y coordinates of vehicles (distributed among Nlanes)
    positionManagement.YvehicleReal = randi(simParams.NLanes, Nvehicles, 1);
    % add additional 3 lanes for the left-move vehicles
    positionManagement.YvehicleReal(left) = positionManagement.YvehicleReal(left) + simParams.NLanes;
    positionManagement.YvehicleReal = positionManagement.YvehicleReal * simParams.roadWidth;

    % Assign speed to vehicles
    positionManagement.v = max((vMeanMs + vStDevMs.*randn(Nvehicles,1)), 0);

end
