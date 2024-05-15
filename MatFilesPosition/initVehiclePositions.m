function [simParams,simValues,positionManagement] = initVehiclePositions(simParams)
% Function to initialize the positions of vehicles

% When roadLength is zero all vehicles are in the same location
if simParams.roadLength==0
    % Scenario
    positionManagement.Xmin = 0;                            % Min X coordinate
    positionManagement.Xmax = 0;                            % Max X coordinate
    positionManagement.Ymin = 0;                            % Min Y coordinate
    positionManagement.Ymax = 0;                            % Max Y coordinate
    
    Nvehicles = simParams.vehicleDensity;   % Number of vehicles
    
    simValues.IDvehicle(:,1) = 1:Nvehicles;             % Vector of IDs
    simValues.maxID = Nvehicles;                        % Maximum vehicle's ID
    
    % Generate X coordinates of vehicles (uniform distribution)
    positionManagement.XvehicleReal = zeros(Nvehicles,1);
    positionManagement.direction = rand(Nvehicles,1) > 0.5;
    positionManagement.YvehicleReal = zeros(Nvehicles,1);
    positionManagement.v=0;
    return
end    

switch simParams.typeOfScenario
    case constants.SCENARIO_PPP  % PPP
        [simParams,simValues,positionManagement] = initiatePositionInScenarioPPP(simParams);
    case constants.SCENARIO_HIGHWAY  % ETSI highway high speed
        [simParams,simValues,positionManagement] = initiatePositionInScenarioETSIhighway(simParams);
        % compute LOS and NLOS based on the vehicles' positions and antennas
        % todo: other type of scenarios should also be considered
    case constants.SCENARIO_URBAN  % ETSI Urban
        [simParams,simValues,positionManagement] = initiatePositionInScenarioETSIurban(simParams);
    otherwise
        error("Scenario do not considered!");
end

end
