function cfg = checkpoint_setup()
%CHECKPOINT_SETUP Resolve paths from this file, independently of pwd.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'config'),fullfile(root,'lib'));
cfg = simulation_parameters();
folders = {cfg.raw,cfg.processed,cfg.figures,fullfile(root,'models'), ...
    fullfile(root,'docs'),fullfile(root,'data','paper')};
for k=1:numel(folders)
    if ~isfolder(folders{k}), mkdir(folders{k}); end
end
end
