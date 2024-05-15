function [simValues, positionManagement] = initSumo(simParams, simValues, outParams, positionManagement)
%Generate config files for SUMO
%   current version only for highway scenario

%% init SUMO environment
path_TraCI4Matlab = fullfile(getenv("SUMO_HOME"), "tools", "contributed", "traci4matlab");
addpath(path_TraCI4Matlab);

%%
outParams.sumo = fullfile(outParams.outputFolder, sprintf("sumoCfg_%d", outParams.simID));
if exist(outParams.sumo,'dir')~=7
    mkdir(outParams.sumo);
end

fprintf('Generating SUMO files ("%s")......\n', outParams.sumo);
genSumoNode(simParams, outParams.sumo);
genSumoTyp(simParams, outParams.sumo);  % edge type
genSumoEdge(simParams, outParams.sumo);
genSumoCon(simParams, outParams.sumo)
genSumoViewSettings(simParams, outParams.sumo) %Set the real world scheme in SUMO

genSumoNetccfg(simParams, outParams.sumo);
[simValues, positionManagement] = genSumoRoute(simParams, simValues, outParams.sumo, positionManagement);
buildSumoNet(outParams.sumo);
genSumoCfg(simParams, outParams.sumo);





%% start sumo
if simParams.linkSUMO
    % run
    fprintf("start running SUMO...\n");
    if simParams.sumoGui
        sumoBin = 'sumo-gui';
    else
        sumoBin = 'sumo';
    end
    scenarioPath = char(fullfile(outParams.sumo, "linkSumo.sumocfg"));
    % traci.start([sumoBin ' -c ' '"' scenarioPath '"']); %SUMO starts if
    % you press the play buttom
    traci.start([sumoBin ' -c ' '"' scenarioPath '"' ' --start' ' --quit-on-end']); %SUMO starts automatically and quits when the simulation stops

    while traci.simulation.getMinExpectedNumber > 0
        traci.simulation.step();  % each step equals to the simParams.positionTimeResolution
        teleportOutsideVehicles();  % call function teleport vehicle if it run out of the lane

        num_v = traci.vehicle.getIDList;
        if length(num_v) == simValues.maxID
            % if vehicle number in the net is equal to the designered, set
            % parameters according to sumo positionManagement.v, positionManagement.XvehicleReal
            %old_speed_distribute = zeros(length(num_v), 1);
            new_speed_distribute = zeros(length(num_v), 1);
            same_distribute_times = 0;

            startTime = simParams.initialSUMOTime;    % [0.1 s], run until a specific time to get a stable traffic
            for i = 1:startTime
                traci.simulation.step();
                teleportOutsideVehicles();
                % every 1 s, check if the two samples of speeds are
                % from the same distribution
                if mod(i,10)==0
                    old_speed_distribute = new_speed_distribute;
                    new_speed_distribute = getSpeedDistribute(num_v);
                    h = kstest2(old_speed_distribute, new_speed_distribute);
                    % fprintf("i = %d, h = %f\n", i,h);
                    if h == 0  % stands for they are from same distribution
                        same_distribute_times = same_distribute_times + 1;
                        % if same_distribute_times >= 3
                        if same_distribute_times >= 10
                            % fprintf("The trafic flow is stable with vMean=%.2f m/s and vStDev=%.2f m/s \n", mean(new_speed_distribute), std(new_speed_distribute));
                            fprintf("The trafic flow is stable");
                            break
                        end
                    else
                        same_distribute_times = 0;
                    end
                end
                if i == startTime
                    fprintf("The traffic do not reach a stable status after %.2f seconds simulation\n", startTime/10);
                end
            end
            positionManagement = setParamsSumo2sim(simParams, positionManagement);
            break;
        end
    end
end

end

