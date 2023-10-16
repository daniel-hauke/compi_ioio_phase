%--------------------------------------------------------------------------
% Simulates the effect of changing model parameters
%--------------------------------------------------------------------------



%% Defaults
random_seed = 999; % Random seed for simulations
% Sets axis font size (this may depend on your screen size, you can
% increase it to 20, if the font is too small or decrease it).
set(0,'defaultAxesFontSize', 18); 


%% Options
options = compi_ioio_options; 
vol_struct = options.task.vol_struct;
details = compi_get_subject_details('0001', options);


%% Load data
load(details.files.hgf_data);
u = data.input_u;


%% Generate an ideal observer
% Get Bayes optimal parameters given the input
bopars = tapas_fitModel([], u,...           % experimental input
    'ms1_compi_hgf_ar1_lvl3_config',...     % perceptual model function
    'tapas_bayes_optimal_binary_config');   % observational model function

% Simulate how this agent would respond to seeing this input.
sim = tapas_simModel(u,...
    'ms1_compi_hgf_ar1_lvl3', bopars.p_prc.p,...
     'tapas_unitsq_sgm', 5,... 
    random_seed);
sim.c_prc.n_levels = 3;
tapas_hgf_binary_plotTraj(sim)
hold on; plot(vol_struct, 'k:'); hold off; % Plot volatility structure 


%% Investigate parameter changes
% To understand what the parameters do it is helpful to see how changes in
% the parameters affect the belief trajectories. 
% Choose a parameter to vary, possible options are:
% 'ka2'     -> Coupling between hierarchical levels (Phasic learning rate)
% 'om2'     -> Learning rate at second level (Tonic learning rate) 
% 'th'      -> Meta-volatility
% 'm3'      -> Equilibrium/Attractor point for drift at third level
% 'phi3'    -> Drift rate at third level
% 'mu30'    -> Prior mean on expected volatility

parameter = 'm3'; % Change the parameter you want to investigate
parameter = 'om2'; % Change the parameter you want to investigate
parameter = 'ka2'; % Change the parameter you want to investigate
[parameter_idx, parameter_name, parameter_array] = get_hgf_parameter_index(parameter);

% Simulate trajectories for different parameter values, while keeping the
% other parameters fixed to the parameters of the ideal observer.
sims = cell(0);
for idx_sim = 1: length(parameter_array)
    sims{idx_sim} = tapas_simModel(u, ...
        'ms1_compi_hgf_ar1_lvl3',...
        [bopars.p_prc.p(1:parameter_idx-1) parameter_array(idx_sim) bopars.p_prc.p(parameter_idx+1:end)],...
         'tapas_unitsq_sgm', 5,... 
        random_seed);
    sims{idx_sim}.c_prc.n_levels = 3;
end

plot_multiple_hgf_traj(flip(sims), parameter_name, flip(parameter_array));
hold on;  h = plot(vol_struct, 'k:'); h.Annotation.LegendInformation.IconDisplayStyle = 'off'; hold off; % Plot volatility structure 

% Just to make the plot a bit more compact
if strcmp(parameter,'m3')
%     subplot(3,1,1)
%     ylim([-2.3 3.6])
%     subplot(3,1,2)
%     ylim([-2.6 3.6]) 
end
set(findall(gcf,'-property','FontSize'),'FontWeight','bold')
saveas(gcf,fullfile(options.roots.figures,['simulating_changes_in_' parameter '.png']));


