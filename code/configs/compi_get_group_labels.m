function [group, group_num] = compi_get_group_labels(fname, IDs)
%--------------------------------------------------------------------------
% Loads group variable from excel file for specific subject IDs.
% 
% IN:
%   fname       -> file name (including path) of .xlsx file
%   IDs         -> cell array with subject identifiers (must also be a
%                  column in the excel file)
%
% OUT: 
%   group       -> cell array with group information for each subject
%   group_num   -> array with numeric group assignment
%--------------------------------------------------------------------------


%% Main
% Read excel file
T = readtable(fname);

% Initialise group variables
group = cell(length(IDs),1);
group_num = NaN(length(IDs),1);

% Get group assignment from table
for idx = 1:length(IDs)
    row = strcmp(T.id, ['COMPI_' IDs{idx}]);
    
    group{idx} = T.group_verb{row};
    
    switch group{idx}
        case 'HC'
            group_num(idx) = 0;
        case 'CHR'
            group_num(idx) = 1;
        case 'FEP'
            group_num(idx) = 2;
        otherwise
            group_num(idx)= NaN;
    end
end
