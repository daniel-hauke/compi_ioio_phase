function [fh_traj, fh_corr] = plot_hgf(est, perf, vol_struct, visibility)
%--------------------------------------------------------------------------
% Function that generates trajectory and correlation plots for the HGF.
%
% IN:
%   est        -> model strutcture obtained from running the tapas 
%                  function: tapas_fitModel.m
%   perf       -> structure with model predictions
%   vol_struct -> volatility schedule of the task to overlay over plot
%   visibility -> Flag indicating whether figure should be created with
%                 visibility option set to 'on' or in the background
%  
% OUT:
%   fh_traj    -> Figure handle to trajectory plot
%   fh_corr    -> Figure handle to correlation plot
% 
% Note: Some changes have been made to tapas functions that plot 
% trajectories and correlation to overlay predicted responses and the 
% volatility schedule and include the option to generate plots in the
% background to accelerate the pipeline.
%--------------------------------------------------------------------------


%% Defaults
if nargin < 4
    visibility = 'on';    
elseif nargin < 3
    plot_vol = 0;
    visibility = 'on';  
else
    plot_vol = 1;
end


%% Create Plots
% Plot trajectory
fh_traj = plot_hgf_binary_traj(est, perf, visibility);
if plot_vol; hold on; plot(vol_struct,'k:'); hold off; end

% Correlation plot
fh_corr = plot_corr(est, visibility);


