function [simParams,phyParams,outParams,simValues,outputValues,...
    timeManagement,positionManagement,stationManagement] = mainInit(simParams,phyParams,outParams,simValues,outputValues,positionManagement)
% Initialization function

%% Init of active vehicles and states
% Move IDvehicle from simValues to station Management
stationManagement.activeIDs = simValues.IDvehicle;
simValues = rmfield(simValues,'IDvehicle');

% The simulation starts at time '0'
timeManagement.timeNow = 0;
timeManagement.samplingTime = simParams.sampleTime;


% Call function to compute distances
% computeDistance(i,j): computeDistance from vehicle with index i to vehicle with index j
% positionManagement.distance matrix has dimensions equal to simValues.IDvehicle x simValues.IDvehicle in order to
% speed up the computation (only vehicles present at the considered instant)
% positionManagement.distance(i,j): positionManagement.distance from vehicle with index i to vehicle with index j
[positionManagement] = computeDistance (positionManagement);

% Save positionManagement.distance matrix
positionManagement.XvehicleRealOld = positionManagement.XvehicleReal;
positionManagement.YvehicleRealOld =  positionManagement.YvehicleReal;
positionManagement.distanceRealOld = positionManagement.distanceReal;
positionManagement.angleOld = zeros(length(positionManagement.XvehicleRealOld),1);


% update vehicle and antenna positions if they were logged
% compute channel gain
% [sinrManagement,~, ~,phyParams.LOS, phyParams.NLOS, ~, ~] = ...
%     computeChannelGain(0,stationManagement,positionManagement,phyParams,simParams,outParams,0,timeManagement.timeNow);
[phyParams.LOS, phyParams.NLOS] = updatePotentialInterfers(positionManagement, simParams, outParams, timeManagement.timeNow, stationManagement.activeIDs);

% The variable 'timeManagement.timeNextPosUpdate' is used for updating the positions
timeManagement.timeNextPosUpdate = round(simParams.positionTimeResolution, 10);
positionManagement.NposUpdates = 1;

%% Initialization of time variables
% Stores the instant of the next event among all possible events;
% initially set to the first packet generation
timeManagement.timeNextEvent = Inf * ones(simValues.maxID,1);

%% Create output tables 
[outParams] = outputDB_init(outParams);