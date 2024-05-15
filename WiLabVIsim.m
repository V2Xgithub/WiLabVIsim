function WiLabVIsim(varargin)
% The function WiLabVIsim() is the main function of the simulator

% ==============
% Copyright (C) Alessandro Bazzi, University of Bologna, and Alberto Zanella, CNR
%
% All rights reserved.
%
% Permission to use, copy, modify, and distribute this software for any
% purpose without fee is hereby granted, provided that this entire notice
% is included in all copies of any software which is or includes a copy or
% modification of this software and in all copies of the supporting
% documentation for such software.
%
% THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
% WARRANTY. IN PARTICULAR, NEITHER OF THE AUTHORS MAKES ANY REPRESENTATION
% OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY OF THIS SOFTWARE
% OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
%
% Project:  WiLabVIsim (extension of the simulator LTEV2Vsim)
% ==============

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%                WiLabVIsim           %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call it as
% WiLabVIsim(fileCfg,paramName1,value1,...paramNameN,valueN)
%
% Parameters are optional.
% If one or more parameters are given in input, the first corresponds to the
% config file (a text file). Use 'default' or '0' to set the default config
% file (i.e., WiLabVIsim.cfg). If a file that does not exist is set, the
% simulation continues without considering the settings from the config
% file.
% In the config file, write couples with i) the parameter name within squared
% brackets and ii) the value of the parameter.
%
% In the command line, couples of parameters follow the config file. Each couple
% must include i) the parameter name and ii) the value.
%
% All parameters can be set in the config file and/or in the command
% line; the priority is: 1) command line; 2) config file; 3) default value.
%
% Example call:
% WiLabVIsim('default','seed',0,'MCS_LTE',2);
% In this example, the seed for random numbers is randomly selected and the
% MCS 2 is set. Then the other parameters take the value from the default
% config file if the file is present and the parameter is set; otherwise
% the default value is used.
%
% Write
% WiLabVIsim('help')
% for a full list of the parameters with their default values.

%% Initialization

% The path of the directory of the simulator is saved in 'fullPath'

fullPath = fileparts(mfilename('fullpath'));
addpath(genpath(fullPath));
% chdir(fullPath);
% Version of the simulator
fprintf('WiLabVIsim %s\n\n',constants.SIM_VERSION);

% 'help' feature:
% "WiLabVIsim('help')" allows to print the full list of parameters
% with default values
if nargin == 1 && strcmp(varargin{1},'help')
    fprintf('Help: list of the parameters with default values\n\n');
    initiateParameters({'help'});
    fprintf('End of the list.\n');
    return
end

% Simulator parameters and initial settings
[simParams,outParams] = initiateParameters(varargin);
phyParams.LOS = 0;

% Delete the database SQLite if it already exists
if exist(fullfile(outParams.outputFolder, sprintf('output_database_%d.db',outParams.simID)), "file")
    delete(fullfile(outParams.outputFolder, sprintf('output_database_%d.db',outParams.simID)));
end
% Create database SQLite for logging results
filename = fullfile(outParams.outputFolder, sprintf('output_database_%d.db',outParams.simID));
outParams.conn = sqlite(filename,"create");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Scenario Description

% Load scenario from Trace File or generate initial positions of vehicles
[simParams,simValues,positionManagement] = initVehiclePositions(simParams);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize SUMO
if simParams.linkSUMO
    [simValues, positionManagement] = initSumo(simParams, simValues,...
        outParams, positionManagement);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start Simulation

% Core function where events are sorted and executed

%% Initialization
outputValues = 0;
[simParams,phyParams,outParams,simValues,outputValues,...
    timeManagement,positionManagement,stationManagement] = mainInit(simParams,phyParams,outParams,simValues,outputValues,positionManagement);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulation Cycle
% The simulation ends when the time exceeds the duration of the simulation
% (not really used, since a break inside the cycle will stop the simulation
% earlier)

% The variable 'timeNextPrint' is used only for printing purposes
timeNextPrint = 0;

fprintf('Simulation ID: %d\nMessage: %s\n',outParams.simID, outParams.message);
fprintf('Simulation Time: ');
reverseStr = '';
while timeManagement.timeNow < simParams.simulationTime

    % If the time instant exceeds or is equal to the duration of the
    % simulation, the simulation is ended
    if round(timeManagement.timeNow, 10) >= round(simParams.simulationTime, 10)
        break;
    end

    % Print time to video
    while timeManagement.timeNow > timeNextPrint  - 1e-9
        reverseStr = printUpdateToVideo(timeManagement.timeNow,simParams.simulationTime,reverseStr);
        timeNextPrint = timeNextPrint + simParams.positionTimeResolution;
    end

    % Update vehicle position and compute the potential interferers
    [simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,stationManagement] = ...
        mainPositionUpdate(simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,stationManagement);

    % Set value of the next position update
    timeManagement.timeNow = timeManagement.timeNow + simParams.positionTimeResolution;

end

%% End SUMO
if simParams.linkSUMO
    traci.close;
end

%% Close all, including database
fclose('all');
close(outParams.conn);
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end