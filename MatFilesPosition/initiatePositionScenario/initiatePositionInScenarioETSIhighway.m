function [simParams,simValues,positionManagement] = initiatePositionInScenarioETSIhighway(simParams)
    % Scenario
    positionManagement.Xmin = 0;                                        % Min X coordinate
    positionManagement.Xmax = simParams.roadLength;                     % Max X coordinate
    positionManagement.Ymin = 0;                                        % Min Y coordinate
    positionManagement.Ymax = 2*simParams.NLanes*simParams.roadWidth;   % Max Y coordinate
    
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
    %positionManagement.YvehicleReal = zeros(Nvehicles,1);
    laneSelected = simParams.NLanes + 0.5 + ((-1).^(mod(mod(((1:Nvehicles)-1),(2*simParams.NLanes))+1+1,2))) .* (ceil((mod(((1:Nvehicles)-1),2*simParams.NLanes)+1)/2)-0.5);
    % The lane, selected in order, need to be shuffled
    laneSelected = laneSelected(randperm(numel(laneSelected)));
    % and then the Y and direction follow from the selected lane
    positionManagement.YvehicleReal = laneSelected'*simParams.roadWidth;
    positionManagement.direction =  2*(1-ceil(laneSelected'/simParams.NLanes))+1;
    
    positionManagement.v = max((vMeanMs + vStDevMs.*randn(Nvehicles,1)), 0);
end

