function [post,out] = compi_hgf_gbmc(options, load_F)
%--------------------------------------------------------------------------
% Function that computes Bayesian model selection for HGF model space
% specified in compi_ioio_hgf_options and groups specified in
% compi_ioio_subject_options.
%--------------------------------------------------------------------------


%% Defaults
if nargin < 2
    load_F  = 0;  % Load F (1) or compute F from scratch (0)
end


%% Paths
% Adds VBA toolbox to path only now to avoid function conflicts with HGF
% functions.
addpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));


%% Get free energy
subjects   = options.subjects.all;
models     = options.hgf.models;
n_models   = length(options.hgf.models);
n_subjects = length(subjects);

if load_F
    load(fullfile(options.roots.results_hgf, 'F_hgf.mat'));
else
    % Write cell array with model files
    files = cell(n_subjects, n_models);
    for idx_s = 1:n_subjects
        % Get subject details
        details = compi_get_subject_details(subjects{idx_s},options);
        % Write out model file path
        files(idx_s,:) = details.files.hgf_models;
    end
    
    % Get F
    F = compi_get_F_hgf(files);
    
    % Save F
    save(fullfile(options.roots.results_hgf, 'F_hgf.mat'),'F');
end


%% Get group indices
n_groups = length(options.subjects.IDs);
g_idx   = cell(n_groups,1);
F_split = cell(n_groups,1);

for i_group = 1:n_groups
    g_idx{i_group} = ismember(subjects, options.subjects.IDs{i_group});
    F_split{i_group} = F(g_idx{i_group},:)';
end


%% Between-group BMS
model_names = options.hgf.model_names(models);
[results, fh, out, post] = compi_VBA_groupBMC_btwGroups(F_split, options);

save_name = fullfile(options.roots.results_hgf,...
    'hgf_results_btw_groups_bmc');
save([save_name '.png'], 'out', 'post');


% Save
for i_group = 1:n_groups
    fprintf('\n-------------------\nGroup: %s\n-------------------\n',options.subjects.group_labels{i_group});
    
    % Summary figure
    fh_temp = plot_bms(out{i_group}, model_names);
    save_name = fullfile(options.roots.results_hgf,...
        ['hgf_summary_bms_' options.subjects.group_labels{i_group}]);
    saveas(fh_temp,[save_name '.png']);
    
    % Separate figures
    fh_temp = plot_bms_exceedance_probabilities(out{i_group}, model_names);
    save_name = fullfile(options.roots.results_hgf,...
        ['hgf_summary_bms_exceedance_probabilities_' options.subjects.group_labels{i_group}]);
    saveas(fh_temp,[save_name '.png']);
    if options.hgf.model_space==1
        save_name = fullfile(options.roots.figures,...
            ['hgf_summary_bms_exceedance_probabilities_' options.subjects.group_labels{i_group}]);
        saveas(fh_temp,[save_name '.png']);
    end
    
    fh_temp = plot_model_attributions(post{i_group}, model_names);
    save_name = fullfile(options.roots.results_hgf,...
        ['hgf_summary_model_attributions_' options.subjects.group_labels{i_group}]);
    saveas(fh_temp,[save_name '.png']);
    if options.hgf.model_space==1
        save_name = fullfile(options.roots.figures,...
            ['hgf_summary_model_attributions_' options.subjects.group_labels{i_group}]);
        saveas(fh_temp,[save_name '.png']);
    end
end

save_name = fullfile(options.roots.results_hgf,...
    'hgf_summary_btw_groups_bmc');
saveas(fh(n_groups + 1),[save_name '.png']);

% Remove VBA toolbox from path
rmpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));

fprintf('\n-------------------\nComplete.\n-------------------\n');
end

