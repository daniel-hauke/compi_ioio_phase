function details = compi_get_subject_details(id, options)
% -------------------------------------------------------------------------
% Function that provides additional subject details like subject-specific 
% file paths.
% -------------------------------------------------------------------------


%% Individual paths and directories
% Subject identifier
details.id = sprintf('COMPI_%s', id);

% Data files
details.files.hgf_data = fullfile(options.roots.data_hgf, [details.id '_data.mat']);

% Results directories
root = fullfile(options.roots.results,'subjects',details.id);
details.dirs.results_hgf = fullfile(root,'hgf');
details.dirs.sim_hgf_data = fullfile(root,'sim_hgf_data');
details.dirs.sim_hgf_results = fullfile(root,'sim_hgf_results');

% Model files
for idx_m = 1:length(options.hgf.models)
    details.files.hgf_models{idx_m} = fullfile(details.dirs.results_hgf,...
        sprintf('ms%d_%s_m%d.mat',...
        options.hgf.model_space,...
        id, ...
        options.hgf.models(idx_m)));
end
end

