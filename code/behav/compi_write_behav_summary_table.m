function compi_write_behav_summary_table(options)
%--------------------------------------------------------------------------
% Function that saves choices, group and covariates in one table for
% statistical analyses later on.
%--------------------------------------------------------------------------


%% Get important parameters
subjects = options.subjects.all;
nt       = options.task.last_trial;
group    = compi_get_group_labels(options.files.groups, subjects);
covars   = compi_get_covariates(options.files.covars, subjects);


%% Get choices
% Loop through subjects and extract advice taking
choices = NaN(length(subjects), nt);
for idx_subject = 1:length(subjects)
    % Get details
    id = options.subjects.all{idx_subject};
    details = compi_get_subject_details(id, options);
    
    % Load data
    load(details.files.hgf_data);
    
    % Store choices
    choices(idx_subject,:) = data.y(:,1);
end

% Write out table with all choices
IDs = cellfun(@(c)['COMPI_' c], subjects, 'uni', false);
T1 = array2table([IDs' group],'VariableNames', {'IDs' 'group'});
trial_index = cellfun(@(c)['t' num2str(c)], num2cell(1:nt), 'uni', false);
T2 = array2table(choices, 'VariableNames', trial_index);
T  = [T1 covars T2];
writetable(T,fullfile(options.roots.results_behav,'compi_choices.xlsx'));

% Write out input
input = array2table(data.input_u, 'VariableNames', {'advice','piechart'});
writetable(input, fullfile(options.roots.results_behav,'compi_input.xlsx'));

fprintf('\n-------------------\nComplete.\n-------------------\n');


