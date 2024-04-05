%% Test-retest curves for GE scans sub-004 3 echo session 1 task-rest *TEST script*
% After running parcellator.py which parcellates voxels in 200 Schaefer parcels and applies a brain and temporal mask

%specify task & TR
sub='sub-me3mm3and5run1';
ses='ses-DEVELOPMENTDEVELOPMENTACH16762';
task='task-vanilla_acq-series';
TR=2.5; %5 echo is TR2 3 echo is 1.75 vanilla is TR2.5


% Specify the file paths for each session
file_path_ses1_run1 = sprintf('/Users/shefalirai/Downloads/bids-files/%s/%s_%s_%s7_parcelled.csv',sub, sub, ses, task);
file_path_ses2_run1 = sprintf('/Users/shefalirai/Downloads/bids-files/%s/%s_%s_%s8_parcelled.csv', sub, sub, ses, task);


% Read the CSV files into tables
data_table_ses1_run1 = readtable(file_path_ses1_run1);
data_table_ses1_run2 = readtable(file_path_ses2_run1);


% Remove columns with all zeros
data_table_ses1_run1 = data_table_ses1_run1(:, any(data_table_ses1_run1{:,:} ~= 0, 1));
data_table_ses1_run2 = data_table_ses1_run2(:, any(data_table_ses1_run2{:,:} ~= 0, 1));


% Remove time label
data_table_ses1_run1 = removevars(data_table_ses1_run1, 'Var1');
data_table_ses1_run2 = removevars(data_table_ses1_run2, 'Var1');


% Convert tables to matrices
ses1_run1_data = table2array(data_table_ses1_run1);
ses1_run2_data = table2array(data_table_ses1_run2);


% Assign tables to variables
first_session = [ses1_run1_data];
second_session = [ses1_run2_data];

% Assign the halves to the new cell arrays and transform to have 200 parcel as rows and columns as time points
gescan_first = first_session';
gescan_second = second_session';

% Define the increment for the scan length, 1 minute
scan_length_increment = 30;

% Calculate scan_length_max 
scan_length_max_C = max(size(gescan_first, 2), size(gescan_second, 2));

% Initialize reliability_scanlength for the current subject
reliability_scanlength = zeros(1, ceil(scan_length_max_C / scan_length_increment));

% Inner loop through increments for the scan length
for i = scan_length_increment:scan_length_increment:scan_length_max_C
        % Extract the first i columns from the matrix for the current subject
        gescan_first_columns = gescan_first(:, 1:min(i, size(gescan_first, 2)));
        gescan_second_columns = gescan_second(:, 1:min(i, size(gescan_second, 2)));

        % Compute correlations for the current subject
        gescan_first_connectome = corr(gescan_first_columns');
        gescan_second_connectome = corr(gescan_second_columns');

        % Initialize array to store correlations for all regions
        gescan_corr_allses = zeros(1, size(gescan_first_connectome, 1));

        % Remove NaNs
        gescan_first_connectome(isnan(gescan_first_connectome)) = 0;
        gescan_second_connectome(isnan(gescan_second_connectome)) = 0;

        % Correlate
        for r = 1:size(gescan_first_connectome, 1)
            gescan_corr_allses(r) = corr(gescan_first_connectome(r, :)', gescan_second_connectome(r, :)');
        end

        % Store the mean correlation for the current scan length
        reliability_scanlength(i / scan_length_increment) = nanmean(gescan_corr_allses);
end


% Remove trailing zeros for each subject in reliability_scanlength_cell
reliability_scanlength_rsfMRI = reliability_scanlength(reliability_scanlength ~= 0);

%% % Plotting single echo dataset

figure;

x_axis_max_C = scan_length_max_C;

% Define x-axis
x_axis = (scan_length_increment * TR / 60):(scan_length_increment * TR / 60):(x_axis_max_C * TR / 60);

% Plot 
plot(x_axis, reliability_scanlength_rsfMRI, 'LineStyle', '-', 'LineWidth', 2.5, 'Color', 'green'); 
xlabel('Scan Length (minutes)');
ylabel('FC-TRC for 2 Vanilla Runs');
ylim([0 1]);
xlim([0 10]);
set(gca, 'FontSize', 18);
set(gca, 'FontName', 'Arial');
ax = gca;
ax.Box = 'off';

