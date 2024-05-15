function [simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,stationManagement] = ...
    mainPositionUpdate(simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,stationManagement)

% Call function to update vehicles positions from SUMO
[stationManagement.activeIDsExit,positionManagement] =...
    updatePosition(stationManagement.activeIDs,positionManagement,simParams);


% Call function to compute the distances
[positionManagement] = computeDistance (positionManagement);


% Calculation of the potential interferers
if timeManagement.timeNow >= timeManagement.samplingTime

    [phyParams.LOS, phyParams.NLOS, Vpoints] = updatePotentialInterfers(positionManagement, simParams, outParams, timeManagement.timeNow, stationManagement.activeIDs);
    timeManagement.samplingTime = timeManagement.samplingTime + simParams.sampleTime;

    %Save the vehicles location in the database
    if isfield(outParams, "log_vLocation") && outParams.log_vLocation
        logVehicleLocation(timeManagement.timeNow, Vpoints, positionManagement.XvehicleReal, positionManagement.YvehicleReal, positionManagement.v, outParams);
    end
end

