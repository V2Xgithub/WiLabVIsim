classdef constants
    %The WiLabV2Xsim constants

  properties (Constant = true)
    %% ****************************************
	%% SIMULATOR RELATED

    SIM_VERSION = 'V6.2';


    %% ****************************************
	%% SCENARIO TYPE

    % Random speed and direction on multiple parallel roads, all configurable
    SCENARIO_PPP = 1;

    % Traffic traces
    SCENARIO_TRACE = 2;

    % ETSI Highway high speed scenario
    SCENARIO_HIGHWAY = 3;

    % ETSI URBAN scenario
    SCENARIO_URBAN = 4;


	end
end
