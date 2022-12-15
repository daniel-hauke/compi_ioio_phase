function options = compi_ioio_options
%--------------------------------------------------------------------------
% Defines analysis options.
%--------------------------------------------------------------------------


%% Set up roots
options.roots.project = fileparts(fileparts(fileparts(mfilename('fullpath'))));

% Make sure that this corresponds to the folder where the data is located
options.roots.data_hgf = fullfile(options.roots.project, 'data', 'ioio');
options.roots.data_clinical = fullfile(options.roots.project, 'data', 'clinical');

% Change if you wish to save the results elsewhere
options.roots.results = fullfile(options.roots.project,'results');
options.roots.results_behav = fullfile(options.roots.results,'results_behav');
options.roots.figures = fullfile(options.roots.results,'figures_paper');

% Set up some more roots
options.roots.code = fullfile(options.roots.project,'code');
options.roots.config = fullfile(options.roots.code,'configs');
options.roots.toolboxes = fullfile(options.roots.code,'toolboxes');
options.roots.log = fullfile(options.roots.results,'logfiles');
options.roots.err = fullfile(options.roots.results,'errors');


%% Include important files
% File with task parameters (e.g. volatility schedule)
options.files.config = fullfile(options.roots.config, 'COMPI.txt');
% File with group labels
options.files.groups = fullfile(options.roots.data_clinical, 'clinical.xlsx');
% File with covariates (in this case the same file)
options.files.covars = options.files.groups;


%% Create folders
if ~isequal(exist(options.roots.results,'dir'),7); mkdir(options.roots.results); end
if ~isequal(exist(options.roots.figures,'dir'),7); mkdir(options.roots.figures); end
if ~isequal(exist(options.roots.results_behav,'dir'),7); mkdir(options.roots.results_behav); end
if ~isequal(exist(options.roots.log,'dir'),7); mkdir(options.roots.log); end
if ~isequal(exist(options.roots.err,'dir'),7); mkdir(options.roots.err); end


%% Task options
% Load task configuration file
configs = load(options.files.config);

% Get volatility schedule for plotting
options.task.last_trial = 136;
options.task.vol_struct = configs(1:options.task.last_trial, end); 


%% Specify HGF options
% Model spaces available are:
% 1 -> Model space presented in the paper
% 2 -> Model space comparing original model space of the paper to model
%      space where mu3 was removed from the response model to decorrelate
%      m3 and decision noise nu
% 3 -> Model space comparing original model space of the paper to model
%      space where decision noise nu was removed from the response model to 
%      decorrelate m3 and decision noise nu

model_space = 1;
options = compi_ioio_hgf_options(options, model_space);


%% Get subject options
options = compi_ioio_subject_options(options);



