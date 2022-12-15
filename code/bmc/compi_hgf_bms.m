function [post,out] = compi_hgf_bms(options, load_F)
%--------------------------------------------------------------------------
% Function that computes Bayesian model selection for HGF model space
% specified in compi_ioio_hgf_options.
%--------------------------------------------------------------------------


%% Defaults
if nargin < 2
   load_F  = 0;  % Load F (1) or compute F from scratch (0) 
end


%% Paths
addpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));


%% Get free energy
subjects   = options.subjects.all;
models     = options.hgf.models;
n_models   = length(options.hgf.models);
n_subjects = length(subjects);
group = compi_get_group_labels(options.files.groups, subjects);
covars = compi_get_covariates(options.files.covars, subjects);

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
    
    % Save F as table
    IDs = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
    T1 = array2table([IDs' group],'VariableNames', {'subject' 'group'});
    T2 = [covars array2table(F)];
    T  = [T1 T2];
    writetable(T,fullfile(options.roots.results_hgf, 'F_hgf.xlsx'));

end


%% BMS
model_names = options.hgf.model_names(models);
[post,out]= compi_VBA_groupBMC(F');

% Save
save_name = fullfile(options.roots.results_hgf,'hgf_bms');
save([save_name '_results.mat'],'post','out');
saveas(gcf,[save_name '_vba_fig.fig']);
saveas(gcf,[save_name '_vba_fig.png']);

% Summary figure
fh = plot_bms(out, model_names);
save_name = fullfile(options.roots.results_hgf, 'hgf_summary_bms');
saveas(fh,[save_name '.png']);

rmpath(genpath(fullfile(options.roots.toolboxes, 'VBA')));

fprintf('\n-------------------\nComplete.\n-------------------\n');

