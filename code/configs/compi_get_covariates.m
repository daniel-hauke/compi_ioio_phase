function [covars] = compi_get_covariates(fname, IDs)
%--------------------------------------------------------------------------
% Loads covariates from excel file for specific subject IDs.
% 
% IN:
%   fname       -> file name (including path) of .xlsx file
%   IDs         -> cell array with subject identifiers (must also be a
%                  column in the excel file)
%
% OUT: 
%   covars      -> table with study-specific covariates
%--------------------------------------------------------------------------


%% Main
% Read excel file
T = readtable(fname);

% Initialise covariates
age = NaN(length(IDs),1);
wm = NaN(length(IDs),1);
antipsych = NaN(length(IDs),1);
antidep = NaN(length(IDs),1);
chlor_eq = NaN(length(IDs),1);
fluox_eq = NaN(length(IDs),1);

% Get covariates from table
for idx = 1:length(IDs)
    row = strcmp(T.id, ['COMPI_' IDs{idx}]);
    
    age(idx) = T.SocDem_age(row);
    wm(idx) = T.DS_backward(row);
    antipsych(idx) = T.medication_antipsych_T0(row);
    antidep(idx) = T.medication_antidep_T0(row);
    chlor_eq(idx) = T.chlor_eq_dose_T0(row);
    fluox_eq(idx) = T.fluox_eq_dose_T0(row);
end

% Summarize covariates in output table
covars = array2table([age wm antipsych antidep chlor_eq fluox_eq]);
covars.Properties.VariableNames = {'age', 'wm', 'antipsych', 'antidep', 'chlor_eq','fluox_eq'};