function SaveCustomDataAndParamsCSV()
%{
Function to write trial custom data from NosePoke
into a tab separated value file (.tsv)

Author: Greg Knoll
Date: October 13, 2022
%}

global BpodSystem

n_trials = BpodSystem.Data.nTrials;

trial_data = BpodSystem.Data.Custom.TrialData;

%{
---------------------------------------------------------------------------
preprocess the data
- remove last entry in arrays that are n_trials+1 long (from the incomplete
  last trial)
- split any n_trials x 2 array into two n_trials x 1 arrays

then save in the table as a column (requires using .', which inverts the
dimensions)
---------------------------------------------------------------------------
%}
data_table = table();

% ---------------------Sample and Choice variables-------------------- %
data_table.EarlyWithdrawal = trial_data.EarlyWithdrawal(1:n_trials).';
data_table.sample_length = trial_data.sample_length(1:n_trials).';
data_table.ChoiceLeft = trial_data.ChoiceLeft(1:n_trials).';
data_table.move_time = trial_data.move_time(1:n_trials).';
data_table.port_entry_delay = trial_data.port_entry_delay(1:n_trials).';


% -----------------------Reward variables------------------------------ %
data_table.Correct = trial_data.Correct(1:n_trials).';
data_table.Rewarded = trial_data.Rewarded(1:n_trials).';
data_table.RewardAvailable = trial_data.RewardAvailable(1:n_trials).';
data_table.RewardDelay = trial_data.RewardDelay(1:n_trials).';
data_table.LeftRewardMagnitude = trial_data.RewardMagnitude(1, :);
data_table.RightRewardMagnitude = trial_data.RewardMagnitude(2, :);


% -------------------------Misc variables------------------------------ %
data_table.RandomThresholdPassed = trial_data.RandomThresholdPassed(1:n_trials).';
data_table.LightLeft = trial_data.LightLeft(1:n_trials).';


% ----------------------------Params----------------------------------- %
param_names = BpodSystem.GUIData.ParameterGUI.ParamNames;
param_vals = BpodSystem.Data.TrialSettings.';
params_table = cell2table(param_vals, "VariableNames", param_names);


% --------------------------------------------------------------------- %
% Combine the data and params tables and save to .csv
% --------------------------------------------------------------------- %
full_table = [data_table params_table];

[filepath, session_name, ext] = fileparts(BpodSystem.Path.CurrentDataFile);
csv_name = "_trial_custom_data_and_params.csv";
file_name = string(strcat("O:\data\", session_name, csv_name));
writetable(full_table, file_name, "Delimiter", "\t")

end  % save_custom_data_and_params_tsv()