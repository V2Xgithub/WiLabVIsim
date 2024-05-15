function [simParams,varargin] = initiateMainSimulationParameters(fileCfg,varargin)
% function simParams = initiateMainSimulationParameters(fileCfg,varargin)
%
% Main settings of the simulation
% It takes in input the name of the (possible) file config and the inputs
% of the main function
% It returns the structure "simParams"

fprintf('Simulation settings\n');
% [CheckVersion]
% check if the simulation tasks are running on the right simulator verion
[simParams,varargin] = addNewParam([],'CheckVersion',constants.SIM_VERSION,'Simulator version needed','string',fileCfg,varargin{1});
if simParams.CheckVersion ~= constants.SIM_VERSION
    error('You are using a wrong version!');
end

% [debugMode]
% check if the simulator is in the debug mode
[simParams,varargin] = addNewParam(simParams,'debugMode', false,'If simulator is in the debug mode','bool',fileCfg,varargin{1});

% [seed]
% Seed for the random numbers generation
% If seed = 0, the seed is randomly selected (the selected value is saved
% in the main output file)
[simParams,varargin] = addNewParam(simParams,'seed',0,'Seed for random numbers','integer',fileCfg,varargin{1});
if simParams.seed == 0
    simParams.seed = getseed();
    fprintf('Seed used in the simulation: %d\n',simParams.seed);
end
rng(simParams.seed);

% [simulationTime]
% Duration of the simulation in seconds
[simParams,varargin] = addNewParam(simParams,'simulationTime',10,'Simulation duration (s)','double',fileCfg,varargin{1});
if simParams.simulationTime<=0
    error('Error: "simParams.simulationTime" cannot be <= 0');
end

% [calculateInterferenceTime]
% Interval every which interference is calculated
[simParams,varargin] = addNewParam(simParams,'sampleTime',10,'Interference calculation (s)','double',fileCfg,varargin{1});
if simParams.sampleTime<=0
    error('Error: "simParams.sampleTime" cannot be <= 0');
end


%% [typeOfScenario]
% Select if want to use Trace File: true or false
[simParams,varargin] = addNewParam(simParams,'TypeOfScenario','PPP','Type of scenario ("PPP"=random 1-D, "Traces"=traffic trace, "ETSI-Highway"=ETSI highway high speed','string',fileCfg,varargin{1});
% Check string
switch upper(simParams.TypeOfScenario)
    case 'PPP'
        simParams.typeOfScenario = constants.SCENARIO_PPP;       % Random speed and direction on multiple parallel roads, all configurable
    case 'TRACES'
        simParams.typeOfScenario = constants.SCENARIO_TRACE;     % Traffic traces
    case 'ETSI-HIGHWAY'
        simParams.typeOfScenario = constants.SCENARIO_HIGHWAY;   % ETSI Highway high speed scenario
    case 'ETSI-URBAN'
        simParams.typeOfScenario = constants.SCENARIO_URBAN;     % ETSI Highway high speed scenario
    otherwise
        error('"simParams.TypeOfScenario" must be "PPP" or "Traces" or "ETSI-Highway" or "ETSI-Urban"');
end

% [positionTimeResolution]
% Time resolution for the positioning update of the vehicles in the trace file (s)
[simParams,varargin] = addNewParam(simParams,'positionTimeResolution',0.1,'Time resolution for the positioning update of the vehicles in the trace file (s)','double',fileCfg,varargin{1});
if simParams.positionTimeResolution<=0
    error('Error: "simParams.positionTimeResolution" cannot be <= 0');
end

switch simParams.typeOfScenario
    case constants.SCENARIO_PPP  % PPP
        simParams.fileObstaclesMap = false;
        % [roadLength]
        % Length of the road to be simulated (m)
        [simParams,varargin] = addNewParam(simParams,'roadLength',4000,'Road Length (m)','double',fileCfg,varargin{1});
        if simParams.roadLength<=0
            error('Error: "simParams.roadLength" cannot be <= 0');
        end
        
        % [roadWidth]
        % Width of each lane (m)
        [simParams,varargin] = addNewParam(simParams,'roadWidth',3.5,'Road Width (m)','double',fileCfg,varargin{1});
        if simParams.roadWidth<0
            error('Error: "simParams.roadWidth" cannot be < 0');
        end
        
        % [vMean]
        % Mean speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vMean',114.23,'Mean speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vMean<0
            error('Error: "simParams.vMean" cannot be < 0');
        end
        
        % [vStDev]
        % Standard deviation of speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vStDev',12.65,'Standard deviation of speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vStDev<0
            error('Error: "simParams.vStDev" cannot be < 0');
        end
        
        % [vehicleDensity]
        % Density of vehicles (vehicles/km)
        [simParams,varargin] = addNewParam(simParams,'vehicleDensity',100,'Density of vehicles (vehicles/km)','double',fileCfg,varargin{1});
        if simParams.vehicleDensity<=0
            error('Error: "simParams.vehicleDensity" cannot be <= 0');
        end
        
        % [NLanes]
        % Number of lanes per direction
        [simParams,varargin] = addNewParam(simParams,'NLanes',3,'Number of lanes per direction','integer',fileCfg,varargin{1});
        if simParams.NLanes<=0
            error('Error: "simParams.NLanes" cannot be <= 0');
        end
    case constants.SCENARIO_TRACE % Traffic traces
        % [fileObstaclesMap]
        % Select if want to use Obstacles Map File: true or false
        [simParams,varargin] = addNewParam(simParams,'fileObstaclesMap',false,'If using a obstacles map file','bool',fileCfg,varargin{1});
        if simParams.fileObstaclesMap~=false && simParams.fileObstaclesMap~=true
            error('Error: "simParams.fileObstaclesMap" must be equal to false or true');
        end
        
        % [filenameTrace]
        % If the trace file is used, this selects the file
        [simParams,varargin] = addNewParam(simParams,'filenameTrace','null.txt','File trace name','string',fileCfg,varargin{1});
        % Check that the file exists. If the file does not exist, the
        % simulation is aborted.
        fid = fopen(simParams.filenameTrace);
        if fid==-1
            fprintf('File trace "%s" not found. Simulation Aborted.',simParams.filenameTrace);
        else
            fclose(fid);
        end
        
        % [XminTrace]
        % Minimum X coordinate to keep in the traffic trace (m)
        [simParams,varargin] = addNewParam(simParams,'XminTrace',-1,'Minimum X coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
        if simParams.XminTrace~=-1 && simParams.XminTrace<0
            error('Error: the value set for "simParams.XminTrace" is not valid');
        end
        
        % [XmaxTrace]
        % Maximum X coordinate to keep in the traffic trace (m)
        [simParams,varargin] = addNewParam(simParams,'XmaxTrace',-1,'Maximum X coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
        if simParams.XmaxTrace~=-1 && simParams.XmaxTrace<0 && simParams.XmaxTrace<simParams.XminTrace
            error('Error: the value set for "simParams.XmaxTrace" is not valid');
        end
        
        % [YminTrace]
        % Minimum Y coordinate to keep in the traffic trace (m)
        [simParams,varargin] = addNewParam(simParams,'YminTrace',-1,'Minimum Y coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
        if simParams.YminTrace~=-1 && simParams.YminTrace<0
            error('Error: the value set for "simParams.YminTrace" is not valid');
        end
        
        % [YmaxTrace]
        % Maximum Y coordinate to keep in the traffic trace (m)
        [simParams,varargin] = addNewParam(simParams,'YmaxTrace',-1,'Maximum Y coordinate to keep in the traffic trace (m)','double',fileCfg,varargin{1});
        if simParams.YmaxTrace~=-1 && simParams.YmaxTrace<0 && simParams.XmaxTrace<simParams.YminTrace
            error('Error: the value set for "simParams.YmaxTrace" is not valid');
        end
        
        
        % Depending on the setting of "simParams.fileObstaclesMap", other parameters must
        % be set
        if simParams.fileObstaclesMap
            % [filenameObstaclesMap]
            % If the obstacles map file is used, this selects the file
            [simParams,varargin] = addNewParam(simParams,'filenameObstaclesMap','null.txt','File obstacles map name','string',fileCfg,varargin{1});
            % Check that the file exists. If the file does not exist, the
            % simulation is aborted.
            fid = fopen(simParams.filenameObstaclesMap);
            if fid==-1
                fprintf('File obstacles map "%s" not found. Simulation Aborted.',simParams.filenameObstaclesMap);
            else
                fclose(fid);
            end
        end
    case constants.SCENARIO_HIGHWAY  % ETSI Highway high speed
        simParams.fileObstaclesMap = false;
        % [roadLength]
        % Length of the road to be simulated (m)
        [simParams,varargin] = addNewParam(simParams,'roadLength',2000,'Road Length (m)','double',fileCfg,varargin{1});
        if simParams.roadLength<0
            % The length can be zero to simulate all the vehicles in the same position
            error('Error: "simParams.roadLength" cannot be < 0');
        end
        
        % [roadWidth]
        % Width of each lane (m)
        [simParams,varargin] = addNewParam(simParams,'roadWidth',4,'Road Width (m)','double',fileCfg,varargin{1});
        if simParams.roadWidth<0
            error('Error: "simParams.roadWidth" cannot be < 0');
        end
        
        % [vMean]
        % Mean speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vMean',240,'Mean speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vMean<0
            error('Error: "simParams.vMean" cannot be < 0');
        end

        % [vStDev]
        % Standard deviation of speed of vehicles (km/h)
        [simParams,varargin] = addNewParam(simParams,'vStDev',0,'Standard deviation of speed of vehicles (Km/h)','double',fileCfg,varargin{1});
        if simParams.vStDev<0
            error('Error: "simParams.vStDev" cannot be < 0');
        end
        
        % [vehicleDensity]
        % Density of vehicles (vehicles/km)
        [simParams,varargin] = addNewParam(simParams,'vehicleDensity',35,'Density of vehicles (vehicles/km)','double',fileCfg,varargin{1});
        if simParams.vehicleDensity<=0
            error('Error: "simParams.vehicleDensity" cannot be <= 0');
        end

        % [randomXPosition]
        % switch if vehicles are randomly or Uniformly positioned
        [simParams, varargin] = addNewParam(simParams, 'randomXPosition', true, 'Randomly/uniformly position', 'bool',fileCfg,varargin{1});
        
        % [randomXPosition]
        % switch if vehicles are randomly or Uniformly positioned
        [simParams, varargin] = addNewParam(simParams, 'randomXPosition', true, 'Randomly/uniformly position', 'bool',fileCfg,varargin{1});

        % [NLanes]
        % Number of lanes per direction
        [simParams,varargin] = addNewParam(simParams,'NLanes',3,'Number of lanes per direction','integer',fileCfg,varargin{1});
        if simParams.NLanes<=0
            error('Error: "simParams.NLanes" cannot be <= 0');
        end

        % [RightToLeft_Vehicles]
        % Traffic density [veh/km] of vehicles traveling from east to west
        [simParams,varargin] = addNewParam(simParams,'RightToLeft_Vehicles',floor(simParams.vehicleDensity/2),'Number of vehicles going from right to left ','integer',fileCfg,varargin{1});
        if simParams.RightToLeft_Vehicles == 0 || simParams.RightToLeft_Vehicles == simParams.vehicleDensity
            error('Error: Vehicles cannot all go in the same direction');
        end

        % [NAntennaGroups]
        % Number of antenna groups equippted on each vehicle
        [simParams,varargin] = addNewParam(simParams,'NAntennaGroups',0,'Number of antenna groups equippted on each vehicle','integer',fileCfg,varargin{1});
        if simParams.NAntennaGroups<0
            error('Error: "simParams.NAntennaGroups" cannot be < 0');
        end
        % if more than 1 antenna group, the antennas would be placed at
        % different places
        if simParams.NAntennaGroups > 0
            totNumOfVeh = simParams.vehicleDensity * simParams.roadLength/1000;
            % [Vlength]
            % The length of a vehicle
            [simParams,varargin] = addNewParam(simParams,'Vlength',3.58,'The length of a vehicle [m]','double',fileCfg,varargin{1});
            simParams.Vlength = repelem(simParams.Vlength,totNumOfVeh); % each vehicle has the same length
            if simParams.Vlength<=1
                error('Error: "simParams.Vlength" cannot be <= 1');
            end
            % [Vwidth]
            % The width of a vehicle
            [simParams,varargin] = addNewParam(simParams,'Vwidth',1.65,'The width of a vehicle [m]','double',fileCfg,varargin{1});
            simParams.Vwidth = repelem(simParams.Vwidth,totNumOfVeh); % each vehicle has the same width
            if simParams.Vwidth<=1
                error('Error: "simParams.Vwidth" cannot be <= 1');
            end

            % set vertices and midpoints of the vehicle
            % 4 x 2
            % 2-D: [x, y]. 
            % simParams.Vpoints = [-simParams.Vlength/2, -simParams.Vwidth/2;      % vertex:   V1
            %                       simParams.Vlength/2, -simParams.Vwidth/2;      % vertex:   V2
            %                       simParams.Vlength/2, simParams.Vwidth/2;       % vertex:   V3
            %                      -simParams.Vlength/2, simParams.Vwidth/2];      % vertex:   V4

            for i = 1:totNumOfVeh
                % the last dimension is the vehicle ID
                simParams.Vpoints(:,:,i) = [-simParams.Vlength(i)/2, -simParams.Vwidth(i)/2;      % vertex:   V1
                    simParams.Vlength(i)/2, -simParams.Vwidth(i)/2;                    % vertex:   V2
                    simParams.Vlength(i)/2, simParams.Vwidth(i)/2;                     % vertex:   V3
                    -simParams.Vlength(i)/2, simParams.Vwidth(i)/2];                   % vertex:   V4
            end

            % Area occupied by a standard vehicle
            Vpolygon = polyshape(simParams.Vpoints(:,1), simParams.Vpoints(:,2));
            
            % set antenna parameters
            % NAntennaGroups x 4
            % 2-D: [AntennaRelativeX, AntennaRelativeY, TxStartingAngle, TxendAngle]
            simParams.Antenna = zeros(simParams.NAntennaGroups, 4);
            for Ant_id = 1:simParams.NAntennaGroups
                % [AntennaRelativeX]
                pNameTempX = sprintf("AntennaRelativeX%d", Ant_id);
                [simParams,varargin] = addNewParam(simParams,pNameTempX,0,'The relative antenna angle to the reference point of a vehicle [radian]','double',fileCfg,varargin{1});
                % [AntennaRelativeY]
                pNameTempY = sprintf("AntennaRelativeY%d", Ant_id);
                [simParams,varargin] = addNewParam(simParams,pNameTempY,0,'The relative antenna distance to the reference point of a vehicle [m]','double',fileCfg,varargin{1});
                
                % check if antenna is located on the vehicle
                isInside = inpolygon(simParams.(pNameTempX), simParams.(pNameTempY), Vpolygon.Vertices(:,1),Vpolygon.Vertices(:,2));
                if ~isInside
                    error("The antenna is located outside the Vehicle's area");
                end
                
                % [TxStartAngle]
                pNameTempSAngle = sprintf("AntennaRelativeStartAngle%d", Ant_id);
                [simParams,varargin] = addNewParam(simParams,pNameTempSAngle,0,'The antenna relative Tx start angle [radian]','double',fileCfg,varargin{1});
                % [TxEndAngle]
                pNameTempEAngle = sprintf("AntennaRelativeEndAngle%d", Ant_id);
                [simParams,varargin] = addNewParam(simParams,pNameTempEAngle,pi/2,'The antenna relative Tx end angle [radian]','double',fileCfg,varargin{1});
                % [AntennaGain]

                % [antennaDistanceMax]
                [simParams,varargin] = addNewParam(simParams,"antennaDistanceMax",1000,'The maximum antenna impact distance','double',fileCfg,varargin{1});

                if simParams.antennaDistanceMax <= 0
                    error("The maximum antenna impact distance should be positive, now %.2f meters", simParams.antennaDistanceMax);
                end

                % todo later
                % save params
                simParams.Antenna(Ant_id,:) = [simParams.(pNameTempX), simParams.(pNameTempY), simParams.(pNameTempSAngle), simParams.(pNameTempEAngle)];
                
                % remove temporary parmaters
                simParams = rmfield(simParams,[pNameTempX, pNameTempY, pNameTempSAngle, pNameTempEAngle]);
            end
            % === plot the initial position of vehicle and antennas ===
            %             plotVehicleAndAntenna(Vpolygon, simParams.Antenna);
            
            % The Antennas positions are the same for all the vehicles 
            simParams.Antenna = repmat(simParams.Antenna,1,1,totNumOfVeh);
        end
    case constants.SCENARIO_URBAN  % ETSI Urban
        simParams.fileObstaclesMap = false;
        % [roadLength]
        % Length of the road to be simulated (m)
        %         [simParams,varargin] = addNewParam(simParams,'vehicleDensity',35,'Density of vehicles (vehicles/km)','double',fileCfg,varargin{1});
        %         if simParams.vehicleDensity<=0
        %             error('Error: "simParams.vehicleDensity" cannot be <= 0');
        %         end
        [simParams,varargin] = addNewParam(simParams,'Nblocks',4,'Number of blocks','integer',fileCfg,varargin{1});
        if simParams.Nblocks<=0
            error('Error: "simParams.Nblocks" cannot be <= 0');
        end
        
        [simParams,varargin] = addNewParam(simParams,'XmaxBlock',250,'Maximum X coordinate per block','double',fileCfg,varargin{1});
        if simParams.XmaxBlock<=0
            error('Error: "simParams.XmaxBlock" cannot be <= 0');
        end
        
        [simParams,varargin] = addNewParam(simParams,'YmaxBlock',433,'Maximum Y coordinate per block','double',fileCfg,varargin{1});
        if simParams.YmaxBlock<=0
            error('Error: "simParams.YmaxBlock" cannot be <= 0');
        end
        
        [simParams,varargin] = addNewParam(simParams,'roadLength',2732,'Road Length (m)','double',fileCfg,varargin{1});
        if simParams.roadLength<=0
            error('Error: "simParams.roadLength" cannot be <= 0');
        end
        
        [simParams,varargin] = addNewParam(simParams,'NLanesBlockH',4,'Number of horizontal lanes per block','integer',fileCfg,varargin{1});
        if simParams.NLanesBlockH<=0
            error('Error: "simParams.NLanesBlockH" cannot be <= 0');
        end
        
        [simParams,varargin] = addNewParam(simParams,'NLanesBlockV',4,'Number of vertical lanes per block','integer',fileCfg,varargin{1});
        if simParams.NLanesBlockV<=0
            error('Error: "simParams.NLanesBlockV" cannot be <= 0');
        end
        
        
        [simParams,varargin] = addNewParam(simParams,'roadWdt',3.5,'Lane width','double',fileCfg,varargin{1});
        if simParams.roadWdt<=0
            error('Error: "simParams.roadWdt" cannot be <= 0');
        end
     
        % Density in v/km in the case of 60km/h according to the TR
        [simParams,varargin] = addNewParam(simParams,'vehicleDensity',24,'Inter vehicle distance factor in sec (sec * absolute vehicle speed is the density)','double',fileCfg,varargin{1});
        if simParams.vehicleDensity<=0
            error('Error: "simParams.vehicleDensity" cannot be <= 0');
        end
        
        [simParams,varargin] = addNewParam(simParams,'vMean',60,'Number of blocks','double',fileCfg,varargin{1});
        if simParams.vMean<=0
            error('Error: "simParams.vMean" cannot be <= 0');
        end
        
        [simParams,varargin] = addNewParam(simParams,'vStDev',0,'Number of blocks','double',fileCfg,varargin{1});
        if simParams.vStDev<0
            error('Error: "simParams.vStDev" cannot be <= 0');
        end
    otherwise
        error("typeOfScenario not implemented!");
end

% [linkSUMO]
[simParams, varargin] = addNewParam(simParams, 'linkSUMO', false, 'If link SUMO', 'bool', fileCfg, varargin{1});
if simParams.linkSUMO 
    if (simParams.typeOfScenario ~= 3)  % for now, just for highway
        error('Error: "linkSUMO" could only used for "highway" with current version');
    end
    % [sumoGui]
    % if starting SUMO GUI during simulation
    [simParams, varargin] = addNewParam(simParams, 'sumoGui', true, 'Using SUMO GUI', 'bool', fileCfg, varargin{1});
    % [initialSUMOTime]
    % The time duration for running SUMO before starting simulation [s]
    [simParams, varargin] = addNewParam(simParams, 'initialSUMOTime', 60, 'The time duration for running SUMO before starting simulation [s]', 'double', fileCfg, varargin{1});
    simParams.initialSUMOTime = simParams.initialSUMOTime / simParams.positionTimeResolution;

    
    % [highwaySpeedLim]
    % The speed limitation on the highway
    [simParams, varargin] = addNewParam(simParams, 'highwaySpeedLim', 140, 'The speed limitation on the highway [km/h]', 'double', fileCfg, varargin{1});

    % [carMaxSpeed]
    % The maximum speed of a car
    [simParams, varargin] = addNewParam(simParams, 'carMaxSpeed', 200, 'The speed limitation on the highway [km/h]', 'double', fileCfg, varargin{1});
end

fprintf('\n');

end
