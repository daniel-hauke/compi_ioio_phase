function fh = plot_bfc(VBA_out, family_names, family_title)
%--------------------------------------------------------------------------
% Function that creates a summary plot showing both protected exceedance 
% probabilities and expected model frequencies based on the posterior 
% output from the VBA toolbox.
%
% IN:
%   VBA_out      -> out structure obtained by running VBA toolbox function: 
%                  [posterior, out] = VBA_groupBMC.m
%   family_names -> Cell array with family names to be used in plot
%   family_title -> Title to be used in plot
%  
% OUT:
%   fh           -> Figure handle
%--------------------------------------------------------------------------


%% Main
% Get exceedance probabilites, model frequencies and variances thereof
ep = VBA_out.families.ep;
ef = VBA_out.families.Ef;
vf = VBA_out.families.Vf;
n_fam = length(ep);

% Plot
fh = figure('name', family_title);
hold on
subplot(1,2,1)
bar(ep, 'FaceColor', [.8 .8 .8]);
line([0,n_fam+1], [.95,.95], 'Color','red', 'LineStyle', ':');
xlabel('Families', 'FontWeight','bold', 'FontSize', 20);
ylabel('Exceedance Probability', 'FontWeight','bold', 'FontSize', 20);
xticks(1:n_fam);
if ~isempty(family_names); xticklabels(family_names); end
ylim([0 1.05])
xlim([0 n_fam+1])
box on;
hold off

subplot(1,2,2)
hold on
bar(ef, 'FaceColor', [.8 .8 .8]);
errorbar(1:n_fam,ef,sqrt(vf),'.k')
line([0, n_fam+1],[1, 1]/n_fam,'Color','red','LineStyle',':');
xlabel('Families', 'FontWeight','bold', 'FontSize', 20);
ylabel('Expected Frequency', 'FontWeight','bold', 'FontSize', 20);
xticks(1:n_fam);
if ~isempty(family_names); xticklabels(family_names); end
ylim([0 1.05])
xlim([0 n_fam+1])
box on;
hold off

%set(findall(gcf,'-property','FontSize'),'FontWeight','bold','FontSize',12)
