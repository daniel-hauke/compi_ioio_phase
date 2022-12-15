function compi_compute_hgf_parameter_recoverability(options)
%--------------------------------------------------------------------------
% Function that computes and plots parameter recoverability for each random
% seed.
%--------------------------------------------------------------------------


%% Get Settings
subjects = options.subjects.all;


%% Cycle through all models
for idx_m = 1: length(options.hgf.models)
    m = options.hgf.models(idx_m);
    
    % Cycle through simulation seeds
    for idx_seed = 1:length(options.hgf.seeds)
        seed = options.hgf.seeds(idx_seed);
        
        %% Write out model files
        fprintf('\n-------------------\nComputing parameter recoverability:');
        fprintf('\n Seed: %d', seed);
        fprintf('\n Writing model files...');
        emp_files = cell(length(subjects),1); % empirical model files
        sim_files = cell(length(subjects),1); % simulated model files
        
        for idx_s = 1:length(subjects)
            % Get subject details
            details = compi_get_subject_details(subjects{idx_s},options);
            % Write out model file path
            [~ , model_file] = fileparts(details.files.hgf_models{idx_m});
            if isnan(seed)
                sim_file_name = [model_file '_sim_n0' ...
                    '_m' num2str(m) '_tm' num2str(m) '_noseed'];
            else
                sim_file_name = [model_file '_sim_n0'...
                    '_m' num2str(m) '_tm' num2str(m) '_s' num2str(seed)];
            end
            emp_files{idx_s, 1} = fullfile(details.dirs.results_hgf, model_file);
            sim_files{idx_s, 1} = fullfile(details.dirs.sim_hgf_results, sim_file_name);
        end
        
        
        %% Collect parameters
        fprintf('\n Collecting estimated parameters from empirical model...');
        params = collect_all_estimated_hgf_params(emp_files);
        
        fprintf('\n Collecting estimated parameters from simulated model...');
        sim_params = collect_all_estimated_hgf_params(sim_files);
        
        
        %% Get parameter names
        load(emp_files{1});
        param_overview = get_hgf_param_overview(est);
        param_names = param_overview.names;
        n_params = length(param_names);
        
        
        %% Plot recoverability
        fprintf('\n Plotting parameter recoverability...');
        % Pretty parameter names for winning model otherwise use names from
        % HGF file
        if m == 3
            param_names = {'\mu_{2}^{(0)}','\mu_{3}^{(0)}','m_3',...
                '\kappa_{2}','\omega_{2}','\zeta','\nu'};
        end
        
        %         figure('name', options.hgf.model_names{idx_m},...
        %             'units', 'normalized', 'outerposition', [0 0 1 1], 'Visible', 'on');
        figure('name', options.hgf.model_names{idx_m},...
            'units', 'normalized', 'outerposition', [0 0 1 1], 'Visible', 'on');
        cmap = colormap('prism');
        
        for i_p = 1:n_params
            [r,p] = corr(params(:,i_p), sim_params(:,i_p));
            if p < 0.001
                p_verb = 'p < 0.001';
            else
                p_verb = ['p = ' num2str(round(p,3))];
            end
            
%             if n_params > 6
%                 subplot(ceil(n_params/3),3,i_p)
%             else
%                 subplot(ceil(n_params/2),2,i_p)
%             end
%             scatter(params(:,i_p), sim_params(:,i_p), 14,...
%                 'MarkerFaceColor', cmap(i_p,:),...
%                 'MarkerEdgeColor', 'k')
            subplot(2,4,i_p)
            scatter(params(:,i_p), sim_params(:,i_p), 14,...
                'MarkerFaceColor', [.2 .2 .2],...
                'MarkerEdgeColor', 'k')
            alpha(.5);
            text(.7,.18,...
                sprintf('r = %.2f\nf^{2} = %.2f\n%s', r, r^2/(1-r^2), p_verb),...
                'FontSize', 12, 'FontWeight', 'bold', 'Units', 'normalized');
            xlabel('simulated', 'FontWeight', 'bold', 'FontSize', 28, 'Color', 'k');
            ylabel('recovered', 'FontWeight', 'bold', 'FontSize', 28, 'Color', 'k');
            xlim([min(params(:,i_p))-.1*range(params(:,i_p)) max(params(:,i_p))+.1*range(params(:,i_p))]);
            ylim([min(sim_params(:,i_p))-.1*range(sim_params(:,i_p)) max(sim_params(:,i_p))]+.1*range(sim_params(:,i_p)));
            lsline;
            title(param_names{i_p}, 'FontWeight', 'bold', 'FontSize', 28, 'Color', 'k')
        end
        
        % Save
        if isnan(seed)
            save_name = ['m' num2str(m) '_noseed_parameter_recoverability.png'];
        else
            save_name = ['m' num2str(m) '_s' num2str(seed) '_parameter_recoverability.png'];
        end
        saveas(gcf, fullfile(options.roots.diag_hgf, ['m' num2str(m)], save_name));
        
        % Save seed displayed in paper
        if options.hgf.model_space==1 && seed==16 && m==3
            saveas(gcf, fullfile(options.roots.figures, save_name));
        end
    end
end
fprintf('\n-------------------\nComplete.\n-------------------\n');


