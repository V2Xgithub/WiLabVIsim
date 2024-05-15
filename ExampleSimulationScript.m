% init env
close all    % Close all open figures
clear        % Reset variables
clc          % Clear the command window
path(pathdef);  % Reset Matlab path
path_task = fileparts(mfilename("fullpath"));
addpath(path_task);
path_this_task = path_task; %fileparts(fileparts(path_task));
% path_simulator = fullfile(path_this_task,"simulator", "WiLabVIsim_internal", "WiLabVIsim_internal");
% addpath(genpath(path_simulator));
path_out_basic = fullfile(path_this_task, "Output");


%% Parameters
roadLength = 8; % km
NLanes = 3;     % number of lane in one direction
dens_km = [35];  % dens per km
sTime = 20;    %  [s] simulation time
beforeSim = 120; % [s] SUMO simulation time before start to log data
sensorNums = [4];
sampleTime = [10];   %0.1 step of 100ms; 10s is the default parameter
% setSeed = 1; %zero default value
setSeed = [1];
for Nsensor = sensorNums
    % for setSeed = seed
        configFile = fullfile(path_task, sprintf('wp_only_NR_cfg_%d_antenna.cfg', Nsensor));
        for i = 1:length(dens_km)
            % path_out = fullfile(path_out_basic, sprintf("antenna%d",Nsensor), sprintf("dens_%d", dens_km(i)));
            path_out = fullfile(path_out_basic, sprintf("antenna%d",Nsensor), sprintf("dens_%d", dens_km(i)), sprintf("sTime_%d",sTime), ...
                sprintf("sampleTime_%d",sampleTime),sprintf("seed_%d",setSeed));
            if exist(path_out, "dir")
                if ~exist(fullfile(path_out, "MainOut.xls"), "file")
                    % rmdir(path_out, "s");
                else
                    continue
                end
            end
            % vMean = dens2speed(dens_km, 2*NLanes);
            % vStDev = vMean / 10;
            WiLabVIsim(configFile,...
                'simulationTime', sTime, 'vehicleDensity', dens_km(i),  'roadLength', roadLength*1000,...
                'NLanes', NLanes,...% 'vMean', vMean(i), 'vStDev', vStDev(i), ...
                'outputFolder', path_out,...
                'antennaDistanceMax', 1000, ...
                'log_vLocation', true, "logPotentialInterferers", true,...
                'linkSUMO', true, 'initialSUMOTime', beforeSim,...
                'sumoGui', true, ...
                'sampleTime', sampleTime, ...
                'seed', setSeed);
        end
    % end
end