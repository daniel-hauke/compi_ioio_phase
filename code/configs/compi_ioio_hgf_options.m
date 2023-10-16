function [options] = compi_ioio_hgf_options(options, ms)
% -------------------------------------------------------------------------
% Function that appends option structure with all options relevant to HGF
% analysis.
% 
% IN: 
%   ms      -> model space you wish to run (e.g., 1)
%   options -> options structure that will be appended
% OUT:
%   options -> appended option structure
% -------------------------------------------------------------------------


%% Analysis options
options.hgf.model_space = ms; % Select HGF model space

% Simulation options
options.hgf.sim_noise = 0; % No(additive) noise for confusion matrix
%options.hgf.sim_noise = [0 1 2]; % (Additive) noise for confusion matrix


% Simulation seed (set to NaN if no seed should be used)
% Note: For estimating model performance only first seed will be used, the
% other seeds are used for the simulation pipeline (e.g. computing
% parameter recoveribility and confusion matrices (averaged across seeds)

options.hgf.seeds = [10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29];
% options.hgf.seeds = NaN; % If you do not want to use seeds


%% Return model space
switch options.hgf.model_space
    case 1
        %------------------------------------------------------------------
        % Runs the main model space presented in the paper
        %------------------------------------------------------------------
        
        % Make sure, that we use the correct HGF version (3.0)
        addpath(genpath(fullfile(options.roots.toolboxes, 'HGF_3.0')));
        
        options.hgf.models = 1:4;
        options.hgf.model_names = {'HI','CI', 'HII', 'CII'};
        
        options.hgf.prc_models = {...
            'ms1_compi_hgf_config',...                      % 1
            'ms1_compi_hgf_bo_config',...                   % 2
            'ms1_compi_hgf_ar1_lvl3_config',...             % 3
            'ms1_compi_hgf_ar1_lvl3_bo_config',...          % 4
            };
        
        options.hgf.obs_models = {...
            'ms1_compi_constant_voltemp_exp_config',...     % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: ms1_compi_hgf_config & ms1_compi_constant_voltemp_exp_config
            2     1    %  2: ms1_compi_hgf_bo_config & ms1_compi_constant_voltemp_exp_config
            3     1    %  3: ms1_compi_hgf_ar1_lvl3_config & ms1_compi_constant_voltemp_exp_config
            4     1    %  4: ms1_compi_hgf_ar1_lvl3_bo_config & ms1_compi_constant_voltemp_exp_config
            ];
end


%% Create folders
% HGF Results
options.roots.results_hgf = fullfile(options.roots.results,'results_hgf',['ms' num2str(ms)]);
if ~isequal(exist(options.roots.results_hgf,'dir'),7); mkdir(options.roots.results_hgf); end

% Diagnostics
options.roots.diag_hgf = fullfile(options.roots.results,'diag_hgf',['ms' num2str(ms)]);
if ~isequal(exist(options.roots.diag_hgf,'dir'),7); mkdir(options.roots.diag_hgf); end

for i_m = 1:length(options.hgf.models)
    if ~isequal(exist(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'traj'),'dir'),7); mkdir(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'traj')); end
    if ~isequal(exist(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'corr'),'dir'),7); mkdir(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'corr')); end
end
if ~isequal(exist(fullfile(options.roots.diag_hgf, 'C'),'dir'),7); mkdir(fullfile(options.roots.diag_hgf, 'C')); end
