function compi_write_pred_responses_summary_table(options)
%--------------------------------------------------------------------------
% Function that saves predicted responses, group and covariates in one 
% table for statistical analyses in R later on.
%--------------------------------------------------------------------------


%% Get important parameters
subjects = options.subjects.all;
models   = options.hgf.models;
nt       = options.task.last_trial;
group    = compi_get_group_labels(options.files.groups, subjects);
covars   = compi_get_covariates(options.files.covars, subjects);
IDs      = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
trials   = cellfun(@(c)['t' num2str(c)], num2cell(1:nt), 'uni', false);

% Create first two columns of output table
T1 = array2table([IDs' group],'VariableNames', {'IDs' 'group'});


%% Get choices and predictions
% Loop through models
for idx_model = 1:length(models)   
    % Initialise
    predictions = NaN(length(subjects), nt);
    
    % Loop through subjects
    for idx_subject = 1:length(subjects)
        % Get details
        id = options.subjects.all{idx_subject};
        details = compi_get_subject_details(id, options);
        
        % Load data
        load(details.files.hgf_models{idx_model});
        
        % Store choices
        predictions(idx_subject,:) = perf.prob;
    end
    
    % Write out table with all predictions
    T2 = array2table(predictions, 'VariableNames', trials);
    writetable([T1 covars T2],fullfile(options.roots.diag_hgf,['m' num2str(idx_model)],'pred_responses.xlsx'));
    clear T2
end

fprintf('\n-------------------\nComplete.\n-------------------\n');
