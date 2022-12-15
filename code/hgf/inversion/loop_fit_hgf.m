function loop_fit_hgf(options)
%--------------------------------------------------------------------------
% Function that fits HGF models for all subjects.
%--------------------------------------------------------------------------


%% Initialize
errors = cell(0);
i_err  = 1;
now = datestr(datetime,'ddmmyy_HHMM');
cd(fullfile(options.roots.log));
diary(['logfile_hgf_inversion_' now '.log'])


%% Get subjects and models
subjects = options.subjects.all;
models   = options.hgf.models;


%% Cycle through subjects
for s = 1:length(subjects)
    
    % Get subject details
    id = subjects{s};
    fprintf('\n\n-------------\nSubject: %s\n-------------\n', id);
    details = compi_get_subject_details(id, options);
    
    % Create results directory
    if ~isequal(exist(details.dirs.results_hgf, 'dir'),7); mkdir(details.dirs.results_hgf); end
    
    % Load data
    load(details.files.hgf_data);
    
    
    %% Cycle through models
    for idx_m = 1:length(models)
        m = models(idx_m);
        
        % Get model names and print some output
        [prc_model, obs_model] = get_obs_and_prc_model(m, options);
        fprintf('\n\n-------------\nModel: %d\n-------------\n', m);
        fprintf('Data file: %s\n', details.files.hgf_data);
        fprintf('Perceptual model: %s\nObservational model: %s\n\n',...
            prc_model,obs_model);
        
        try
            %-------------------
            % Invert
            %-------------------
            [est, perf] = train_hgf(data, prc_model, obs_model,...
                options.hgf.seeds);
            
            % Save
            save(details.files.hgf_models{idx_m},...
                'est','perf');
            
            %-------------------
            % Plot diagnostic
            %-------------------
            [fh_traj, fh_corr] = plot_hgf(est, perf, options.task.vol_struct,'off');
            
            % Save figures
            saveas(fh_traj,...
                fullfile(options.roots.diag_hgf,['m' num2str(m)],'traj',...
                [id '.png']));
            close(fh_traj); clear fh_traj;
            
            saveas(fh_corr,...
                fullfile(options.roots.diag_hgf,['m' num2str(m)],'corr',...
                [id '.png']));
            close(fh_corr); clear fh_corr;
            
        catch err
            errors{i_err} = err;
            i_err = i_err +1;
            warning(sprintf('Error occured for subject %s and model %d.', id, m));
            warning(err.message)
        end
        
    end
end

save(fullfile(options.roots.err,...
    ['errors_hgf_inversion_' now '.mat']),'errors');
fprintf('\n-------------------\nComplete.\n-------------------\n');
diary off
cd(options.roots.code)

