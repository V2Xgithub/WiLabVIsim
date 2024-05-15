function buildSumoNet(path_sumo_cfg)
%BUILDSUMONET Summary of this function goes here
%   Detailed explanation goes here

fprintf('Building sumo net...\n');

path_netccfg = fullfile(path_sumo_cfg, "linkSumo.netccfg");
netConvertBinary = fullfile(getenv("SUMO_HOME"), "bin", "netconvert.exe");
[status, result] = system(sprintf('"%s" -c "%s"',netConvertBinary, path_netccfg));
if status == 0
    disp(result);
else
    error(result);
end

