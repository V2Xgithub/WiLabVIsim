function [simParams,simValues,positionManagement] = initiatePositionInScenarioETSIurban(simParams)
  simValues.Nblocks = simParams.Nblocks;
  %The dimension x and y of each block
  simValues.XmaxBlock = simParams.XmaxBlock;
  simValues.YmaxBlock = simParams.YmaxBlock;
  
  %Single block definition - n. of horizontal lanes and n. vertical lanes
  simValues.NLanesBlockH = simParams.NLanesBlockH;      % n_lanes_block_horizontal = 4;
  simValues.NLanesBlockV = simParams.NLanesBlockV;      % n_lanes_block_vertical = 4;
  simValues.roadWdt = simParams.roadWdt;                % lane width

  vMeanMs = simParams.vMean / 3.6;              % Mean vehicle speed (m/s)
  vStDevMs = simParams.vStDev / 3.6;            % Speed standard deviation (m/s)
  simValues.vehicleDensityM = simParams.vehicleDensity / 1e3;         % Average vehicle density (vehicles/m)
  
  % number of vehicles per horizontal lanes per block,
  % per vertical lanes per block
  n_veh_h_block = round(simValues.NLanesBlockH.*simValues.vehicleDensityM*simValues.XmaxBlock);
  n_veh_v_block = round(simValues.NLanesBlockV.*simValues.vehicleDensityM*simValues.YmaxBlock);
  
  Nvehicles = simValues.Nblocks*(n_veh_h_block+n_veh_v_block);
  % Throw an error if there are no vehicles in the scenario
  if ~Nvehicles
    error('Error: no vehicles in the simulation.');
  end
  
  % The origins of the blocks in x and y
  X0 = (0:2)'*ones(1,3).*simValues.XmaxBlock;
  Y0 = ones(3,1)*(0:2).*simValues.YmaxBlock;
  % A set with the blocks sorted, in the sense that I might have less blocks
  % but when I define it I follow that order
  order_idx = [1,2,5,4,3,6,9,8,7]; 
  Orig_set = [X0(order_idx)', Y0(order_idx)'];

  % the direction of the lanes sorted
  direction_h_lanes_block = [-1,-1,1,1]';
  direction_v_lanes_block = [1,1,-1,-1]';

  % 0 indica + e 1 indica -
  y_h_lanes_block = [(0:1).*simValues.roadWdt+simValues.roadWdt/2,simValues.YmaxBlock-...
    2.*simValues.roadWdt+(1:-1:0).*simValues.roadWdt+simValues.roadWdt/2]';
  x_v_lanes_block = [(0:1).*simValues.roadWdt+simValues.roadWdt/2,simValues.XmaxBlock-...
    2.*simValues.roadWdt+(1:-1:0).*simValues.roadWdt+simValues.roadWdt/2]';

  h_lane = unidrnd(simValues.NLanesBlockH,simValues.Nblocks*n_veh_h_block,1);
  v_lane = unidrnd(simValues.NLanesBlockV,simValues.Nblocks*n_veh_v_block,1);
  
  % For the horizontal vehicles, a random x position is picked
  % The y position is fixed by the lane
  % The direction is fixed by the lane
  gen_veh_h = [unifrnd(0,simValues.XmaxBlock,simValues.Nblocks*n_veh_h_block,1),y_h_lanes_block(h_lane),direction_h_lanes_block(h_lane)];
  gen_veh_v = [x_v_lanes_block(v_lane),unifrnd(0,simValues.YmaxBlock,simValues.Nblocks*n_veh_v_block,1),direction_v_lanes_block(v_lane)];

  Or_block_pos_x = repmat(Orig_set(1:simValues.Nblocks,1)',n_veh_h_block,1);
  Or_block_pos_y = repmat(Orig_set(1:simValues.Nblocks,2)',n_veh_h_block,1);
  
  pos_veh_h = gen_veh_h(:,1:2)+[Or_block_pos_x(:),Or_block_pos_y(:)];
  
  Or_block_pos_x = repmat(Orig_set(1:simValues.Nblocks,1)',n_veh_v_block,1);
  Or_block_pos_y = repmat(Orig_set(1:simValues.Nblocks,2)',n_veh_v_block,1);
  
  pos_veh_v = gen_veh_v(:,1:2)+[Or_block_pos_x(:),Or_block_pos_y(:)];
  direction_h = gen_veh_h(:,3);
  direction_v = gen_veh_v(:,3);
  Pos = [pos_veh_h; pos_veh_v];
  positionManagement.XvehicleReal = Pos(:,1);
  positionManagement.YvehicleReal = Pos(:,2);
  
  positionManagement.Xmin = 0;              % Min X coordinate
  positionManagement.Xmax = max(X0(order_idx(1:simValues.Nblocks)))+...
    simValues.XmaxBlock+1i.*max(Y0(order_idx(1:simValues.Nblocks)))+1i.*simValues.YmaxBlock;    % Max X coordinate
  positionManagement.Ymin = 0;              % Min Y coordinate
  
  

  simValues.IDvehicle(:,1) = 1:Nvehicles;       % Vector of IDs
  simValues.maxID = Nvehicles;                  % Maximum vehicle's ID
    
  % Generate X coordinates of vehicles (uniform distribution)
  
  % Uniformly positioned,
  %positionManagement.XvehicleReal = (1:Nvehicles)*floor(simValues.Xmax/(Nvehicles));
  
  % Generate driving direction
  directionX =  zeros(Nvehicles,1);
  directionX(1:simValues.Nblocks*n_veh_h_block) = direction_h;
  directionY = zeros(Nvehicles,1);
  directionY((simValues.Nblocks*n_veh_h_block+1):end) = direction_v;
  positionManagement.direction = directionX+1i*directionY;

  % Assign speed to vehicles
  positionManagement.v = max((vMeanMs + vStDevMs.*randn(Nvehicles,1)), 0);
end
