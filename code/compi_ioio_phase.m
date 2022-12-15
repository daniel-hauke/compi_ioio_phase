function compi_ioio_phase
%--------------------------------------------------------------------------
% Runs the computational modelling analysis for the paper:
% "Aberrant perception of environmental volatility in emerging psychosis"
% by
% Hauke, Wobmann, Andreou, Mackintosh, de Bock, Sterzer, Borgwardt, Roth, &
% Diaconescu (2022)
%--------------------------------------------------------------------------


%% Initialise
compi_setup_paths; % set up paths
options = compi_ioio_options; % get analysis options


%% First-level analysis
% Save behavior (choices) for all participants in excel tables for later analyses in R
fprintf('\n===\n\t Writing summary table of behavior:\n\n');
compi_write_behav_summary_table(options);

% Fit HGF models
fprintf('\n===\n\t Running the first level analysis:\n\n');
loop_fit_hgf(options);

% Save model predictions for all participants in excel tables for later analyses in R
fprintf('\n===\n\t Writing summary table of model predictions:\n\n');
compi_write_pred_responses_summary_table(options);


%% Second-level analysis
% Perform Bayesian model selection
fprintf('\n===\n\t Performing Bayesian model selection:\n\n');
compi_hgf_bms(options);

% Perform between group Bayesian model selection
fprintf('\n===\n\t Performing between group Bayesian model selection:\n\n');
compi_hgf_gbmc(options, 1);

% Run HGF diagnostics
fprintf('\n===\n\t Running HGF diagnostic:\n\n');
compi_run_hgf_diagnostics(options);

% Run HGF simulations
tic;
fprintf('\n===\n\t Running HGF simulations:\n\n');
compi_run_hgf_simulations(options)
t = toc;
fprintf('\n===\n\t Simulations done in %s (HH:MM:SS)!\n\n', datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'));



%% Supplementary Analyses
% Supplementary Analysis I:
% Comparing original model space of the paper to model space where mu3 was 
% removed from the response model to decorrelate m3 and decision noise nu.

model_space = 2;
options = compi_ioio_hgf_options(options, model_space);

% Fit HGF models
fprintf('\n===\n\t Running the first level analysis:\n\n');
loop_fit_hgf(options);

% Perform Bayesian family comparison
fprintf('\n===\n\t Performing Bayesian model selection:\n\n');
compi_hgf_bfc(options);


% Supplementary Analysis II:
% Comparing original model space of the paper to model space where decision 
% noise nu was removed from the response model to decorrelate m3 and 
% decision noise nu.

model_space = 3;
options = compi_ioio_hgf_options(options, model_space);

% Fit HGF models
fprintf('\n===\n\t Running the first level analysis:\n\n');
loop_fit_hgf(options);

% Perform Bayesian family comparison
fprintf('\n===\n\t Performing Bayesian model selection:\n\n');
compi_hgf_bfc(options);


