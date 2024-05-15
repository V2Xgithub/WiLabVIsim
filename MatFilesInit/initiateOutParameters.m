function [outParams,varargin] = initiateOutParameters(fileCfg,varargin)
% function [outParams,varargin] = initiateOutParameters(fileCfg,varargin)
%
% Settings of the outputs
% It takes in input the name of the (possible) file config and the inputs
% of the main function
% It returns the structure "outParams"

fprintf('Output settings\n');

% [outputFolder]
% Folder where the output files are recorded
% If the folder is not present, the simulator creates it
[outParams,varargin]= addNewParam([],'outputFolder','Output','Folder for the output files','string',fileCfg,varargin{1});
if exist(outParams.outputFolder,'dir')~=7
    mkdir(outParams.outputFolder);
end
% change the path as absolute path
s = what(outParams.outputFolder);
outParams.outputFolder = s.path;
fprintf('Full path of the output folder = %s\n',outParams.outputFolder);

% Name of the file that summarizes the inputs and outputs of the simulation
% Each simulation adds a line in append
% The file is a xls file
% The name of the file cannot be changed
outParams.outMainFile = 'MainOut.xls';
fprintf('Main output file = %s/%s\n',outParams.outputFolder,outParams.outMainFile);

% Simulation ID
mainFileName = sprintf('%s/%s',outParams.outputFolder,outParams.outMainFile);
fid = fopen(mainFileName);
if fid==-1
    simID = 0;
else
    % use recommended function textscan
    C = textscan(fid,'%s %*[^\n]');
    simID = str2double(C{1}{end});
    fclose(fid);
end
outParams.simID = simID+1;
fprintf('Simulation ID = %.0f\n',outParams.simID);


% [message]
[outParams,varargin]= addNewParam(outParams,'message', 'None', 'Message during simulation','string',fileCfg,varargin{1});
fprintf('\n');

% if simParams.debugMode
    % [log_mBestCandidates]
    % If log MBest candidates for C-V2X
    [outParams,varargin] = addNewParam(outParams,'log_mBestCandidates',false,'If log MBest candidates, only for C-V2X','bool',fileCfg,varargin{1});
    
    % [log_BRid]
    % If log BRid used by vehicles, only for MCO scenario
    [outParams,varargin] = addNewParam(outParams,'log_BRid',false,'If log BRid used by vehicles, only for MCO','bool',fileCfg,varargin{1});   
    
    % [log_vLocation]
    % If log vehicle's location
    [outParams,varargin] = addNewParam(outParams,'log_vLocation',false,'If log the locations of vehicles, only for MCO','bool',fileCfg,varargin{1});   
    
    % [log_knownUsedMatrixCV2X]
    % If log BRids used by neighbors
    [outParams,varargin] = addNewParam(outParams,'log_knownUsedMatrixCV2X',false,'If log BRid used by neighbors, only for MCO','bool',fileCfg,varargin{1});   
    
    % [logLOSNeighbor]
    % If log the number of LOS neighbor
    [outParams,varargin] = addNewParam(outParams,'logLOSNeighbor',false,'If log the number of LOS neighbor','bool',fileCfg,varargin{1});   
    
    % [logNLOSNeighbor]
    [outParams,varargin] = addNewParam(outParams,'logNLOSNeighbor',false,'If log the number of LOS neighbor','bool',fileCfg,varargin{1});   
    
    % [logNoSensingNeighbor]
    [outParams,varargin] = addNewParam(outParams,'logNoSensingNeighbor',false,'If log the number of LOS neighbor','bool',fileCfg,varargin{1});   
    
    % [logLOSNeighborDetailsV]
    % If log neighbor IDs of the this vehicle ID, for plotting the links after
    % simulation
    [outParams,varargin] = addNewParam(outParams,'logLOSNeighborDetailsV',0,'If log LOS neighbor IDs of the this vehicle ID','integer',fileCfg,varargin{1});   
    if outParams.logLOSNeighborDetailsV < 0
        error("The vehicle id is %d, it mush be greater than 0", outParams.logLOSNeighborIDsofTaggedV);
    end
    
    % [logNLOSNeighborDetailsV]
    % If log NLOS neighbor IDs of the this vehicle ID, for plotting the links after
    % simulation
    [outParams,varargin] = addNewParam(outParams,'logNLOSNeighborDetailsV',0,'If log NLOS neighbor IDs of the this vehicle ID','integer',fileCfg,varargin{1});   
    if outParams.logNLOSNeighborDetailsV < 0
        error("The vehicle id is %d, it mush be greater than 0", outParams.logNLOSNeighborDetailsV);
    end
    
    % [logNoSensingNeighborDetailsV]
    % If log neighbor IDs of the this vehicle ID, for plotting the links after
    % simulation
    [outParams,varargin] = addNewParam(outParams,'logNoSensingNeighborDetailsV',0,'If log NoSensing neighbor IDs of the this vehicle ID','integer',fileCfg,varargin{1});   
    if outParams.logNoSensingNeighborDetailsV < 0
        error("The vehicle id is %d, it mush be greater than 0", outParams.logNoSensingNeighborDetailsV);
    end

    % [logPotentialInterferers]
    [outParams,varargin] = addNewParam(outParams,'logPotentialInterferers',false,'If log LOS and NLOS results into database','bool',fileCfg,varargin{1});   
% end

% % [PRRstep]
% % Print PRR results every "PRRstep" seconds, "inf" means output results at
% % the end of simulation
% [outParams,varargin] = addNewParam(outParams,'PRRstep',inf,'Print PRR every this time duration','double',fileCfg,varargin{1});

