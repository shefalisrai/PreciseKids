%% Test-retest curves for tedana pipeline for each run or motion removed pipeline and original pipeline

% Initialize variables
wbcommand = '/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
task = 'task-YT';

% Load the data, mean-center, parcellate, and apply the temporal mask
for ses = 1:4
    % Load dtseries data
    file_path = sprintf('/Users/shefalirai/Desktop/Tedana_tests_sub26Cdatafiles/sub-1973026C_ses-%d_%s_motion_smoothed_Atlas_s4.dtseries.nii', ses, task);
    dtseries = ciftiopen(file_path, wbcommand);
    dtseries_data = dtseries.cdata;

    % Mean-centering
    mean_dtseries = mean(dtseries_data, 2); % Mean across time
    dtseries_data = bsxfun(@minus, dtseries_data, mean_dtseries); % Subtract mean

    % Save Mean Centered cifti
    dtseries.cdata = dtseries_data;
    ciftisave(dtseries, file_path, wbcommand); 

    % Parcellate
    parcelCIFTIFile = '/Users/shefalirai/Downloads/Parcellations/HCP/fslr32k/cifti/Schaefer2018_200Parcels_17Networks_order.dlabel.nii';
    parcelFile = sprintf('/Users/shefalirai/Desktop/Tedana_tests_sub26Cdatafiles/sub-1973026C_ses-%d_%s_motion_parcelled.ptseries.nii', ses, task);
    system(['! /Applications/workbench/bin_macosx64/wb_command -cifti-parcellate ' file_path ' ' parcelCIFTIFile ' COLUMN ' parcelFile ' -method MEAN']);
    ptseries_C{ses} = ciftiopen(parcelFile, '/Applications/workbench/bin_macosx64/wb_command').cdata;

    % Load temporal mask
    temporal_mask_path = sprintf('/Volumes/Prckids/sub-1973026C/ses-%d/func/mergeruns/sub-1973026C_ses-%d_%s_OCMASK_TEMPORAL.txt', ses, ses, task);
    temporal_mask = logical(load(temporal_mask_path));

    % Apply the temporal mask to the parcellated time series data
    ptseries_C{ses} = ptseries_C{ses}(:, temporal_mask);

    % Open SNR mask computed from Midnight Scan Avg
    snrMask = ciftiopen('/Users/shefalirai/Desktop/MSCavg_SNRmask_200parcelled.ptseries.nii', wbcommand);
    snrMask_data = snrMask.cdata;
    ptseries_C{ses}(snrMask_data > 0, :) = NaN;
end

% Combine session data
first_C = ptseries_C{1};
second_C = ptseries_C{2};
third_C = ptseries_C{3};
fourth_C = ptseries_C{4};

% Assign the halves to the new cell arrays
ptseries_firstfourth_C = [first_C second_C];
ptseries_secondthird_C = [third_C fourth_C];

% Define the increment for the scan length, 1 minute
scan_length_increment = 30;

% Calculate scan_length_max 
scan_length_max_C = max(size(ptseries_firstfourth_C, 2), size(ptseries_secondthird_C, 2));

% Initialize reliability_scanlength for the current subject
reliability_scanlength_C = zeros(1, ceil(scan_length_max_C / scan_length_increment));

% Inner loop through increments for the scan length
for i = scan_length_increment:scan_length_increment:scan_length_max_C
        % Extract the first i columns from the matrix for the current subject
        ptseries_firstfourth_columns_C = ptseries_firstfourth_C(:, 1:min(i, size(ptseries_firstfourth_C, 2)));
        ptseries_secondthird_columns_C = ptseries_secondthird_C(:, 1:min(i, size(ptseries_secondthird_C, 2)));

        % Compute correlations for the current subject
        ptseries_firstfourth_connectome_C = corr(ptseries_firstfourth_columns_C');
        ptseries_secondthird_connectome_C = corr(ptseries_secondthird_columns_C');

        % Initialize array to store correlations for all regions
        ptseries_corr_allses_C = zeros(1, size(ptseries_firstfourth_connectome_C, 1));

        % Remove NaNs
        ptseries_firstfourth_connectome_C(isnan(ptseries_firstfourth_connectome_C)) = 0;
        ptseries_secondthird_connectome_C(isnan(ptseries_secondthird_connectome_C)) = 0;

        % Correlate
        for r = 1:size(ptseries_firstfourth_connectome_C, 1)
            ptseries_corr_allses_C(r) = corr(ptseries_firstfourth_connectome_C(r, :)', ptseries_secondthird_connectome_C(r, :)');
        end

        % Store the mean correlation for the current scan length
        reliability_scanlength_C(i / scan_length_increment) = nanmean(ptseries_corr_allses_C);
end


% Remove trailing zeros for each subject in reliability_scanlength_cell
reliability_scanlength_C = reliability_scanlength_C(reliability_scanlength_C ~= 0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test-retest curve for tedana original/current pipeline
% For 200 parcels
wbcommand = '/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
task = 'task-YT';

% Load the data, parcellate, and apply the temporal mask
for ses = 1:4
    % Load dtseries data
    file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/eachses_dtseries/sub-1973026C_ses-%d_%s_smoothed_Atlas_s4.dtseries.nii', ses, task);
    dtseries_C_orig{ses} = ciftiopen(file_path, wbcommand).cdata;

    % Parcellate
    parcelCIFTIFile = '/Users/shefalirai/Downloads/Parcellations/HCP/fslr32k/cifti/Schaefer2018_200Parcels_17Networks_order.dlabel.nii';
    parcelFile = sprintf('/Users/shefalirai/Desktop/Tedana_tests_sub26Cdatafiles/sub-1973026C_ses-%d_%s_ogtedana_parcelled.ptseries.nii', ses, task);
    system(['! /Applications/workbench/bin_macosx64/wb_command -cifti-parcellate ' file_path ' ' parcelCIFTIFile ' COLUMN ' parcelFile ' -method MEAN']);
    ptseries_C_orig{ses} = ciftiopen(parcelFile, '/Applications/workbench/bin_macosx64/wb_command').cdata;

    % Load temporal mask
    temporal_mask_path_orig = sprintf('/Volumes/Prckids/sub-1973026C/ses-%d/func/mergeruns/sub-1973026C_ses-%d_%s_OCMASK_TEMPORAL.txt', ses, ses, task);
    temporal_mask_orig = logical(load(temporal_mask_path_orig));

    % Apply the temporal mask to the parcellated time series data
    ptseries_C_orig{ses} = ptseries_C_orig{ses}(:, temporal_mask_orig);

   % Open SNR mask computed from Midnight Scan Avg
    snrMask = ciftiopen('/Users/shefalirai/Desktop/MSCavg_SNRmask_200parcelled.ptseries.nii', wbcommand);
    snrMask_data = snrMask.cdata;
    ptseries_C_orig{ses}(snrMask_data > 0, :) = NaN;
end

% Combine session data
first_C_orig = ptseries_C_orig{1};
second_C_orig = ptseries_C_orig{2};
third_C_orig = ptseries_C_orig{3};
fourth_C_orig = ptseries_C_orig{4};

% Assign the halves to the new cell arrays
ptseries_firstfourth_C_orig= [first_C_orig second_C_orig];
ptseries_secondthird_C_orig = [third_C_orig fourth_C_orig];

% Define the increment for the scan length, 1 minute
scan_length_increment_orig = 30;

% Initialize the reliability_scanlength_cell cell array
reliability_scanlength_C_orig = cell(1, numel(ptseries_firstfourth_C_orig));

% Calculate scan_length_max 
scan_length_max_C_orig = max(size(ptseries_firstfourth_C_orig, 2), size(ptseries_secondthird_C_orig, 2));

% Initialize reliability_scanlength for the current subject
reliability_scanlength_C_orig = zeros(1, ceil(scan_length_max_C_orig / scan_length_increment_orig));

% Inner loop through increments for the scan length
for i = scan_length_increment_orig:scan_length_increment_orig:scan_length_max_C_orig
        % Extract the first i columns from the matrix for the current subject
        ptseries_firstfourth_columns_C_orig = ptseries_firstfourth_C_orig(:, 1:min(i, size(ptseries_firstfourth_C_orig, 2)));
        ptseries_secondthird_columns_C_orig = ptseries_secondthird_C_orig(:, 1:min(i, size(ptseries_secondthird_C_orig, 2)));

        % Compute correlations for the current subject
        ptseries_firstfourth_connectome_C_orig = corr(ptseries_firstfourth_columns_C_orig');
        ptseries_secondthird_connectome_C_orig = corr(ptseries_secondthird_columns_C_orig');

        % Initialize array to store correlations for all regions
        ptseries_corr_allses_C_orig = zeros(1, size(ptseries_firstfourth_connectome_C_orig, 1));

        % Remove NaNs
        ptseries_firstfourth_connectome_C_orig(isnan(ptseries_firstfourth_connectome_C_orig)) = 0;
        ptseries_secondthird_connectome_C_orig(isnan(ptseries_secondthird_connectome_C_orig)) = 0;

        % Correlate
        for r = 1:size(ptseries_firstfourth_connectome_C_orig, 1)
            ptseries_corr_allses_C_orig(r) = corr(ptseries_firstfourth_connectome_C_orig(r, :)', ptseries_secondthird_connectome_C_orig(r, :)');
        end

        % Store the mean correlation for the current scan length
        reliability_scanlength_C_orig(i / scan_length_increment) = nanmean(ptseries_corr_allses_C_orig);
end


% Remove trailing zeros for each subject in reliability_scanlength_cell
reliability_scanlength_C_orig = reliability_scanlength_C_orig(reliability_scanlength_C_orig ~= 0);


%% % Plotting both pipelines on the same figure

figure;

x_axis_max_C = scan_length_max_C;

% Define x-axis
x_axis = (scan_length_increment * 6 / 180):(scan_length_increment * 6 / 180):(x_axis_max_C * 6 / 180);

% Plot Pipeline 1
plot(x_axis, reliability_scanlength_C, 'LineStyle', '-', 'LineWidth', 2.5, 'Color', 'blue');

hold on; % Hold on to plot the second line

% Plot Pipeline 2
plot(x_axis, reliability_scanlength_C_orig, 'LineStyle', '--', 'LineWidth', 2.5, 'Color', 'red');

xlabel('Scan Length (minutes)');
ylabel('Mean FC-TRC for Sub 26C');
ylim([0 0.9]);
set(gca, 'FontSize', 18);
set(gca, 'FontName', 'Arial');
ax = gca;
ax.Box = 'off';

legend('Tedana motion removed', 'Tedana original'); % Add legend

hold off; % Release the plot


%% Correlation comparison between tedana pipelines if needed

%Create full scan length ptseries
ptseries_C_full_orig=[ptseries_C_orig{1} ptseries_C_orig{2} ptseries_C_orig{3} ptseries_C_orig{4}];
ptseries_C_full=[ptseries_C{1} ptseries_C{2} ptseries_C{3} ptseries_C{4}];

% Compute Connectomes
connectome_full_orig = corr(ptseries_C_full_orig');
connectome_full_orig(isnan(connectome_full_orig')) = 0;

connectome_full = corr(ptseries_C_full');
connectome_full(isnan(connectome_full)) = 0;

% Visualize connectomes 
connectome_difference = connectome_full - connectome_full_orig;
imagesc(connectome_difference)

% Extract upper triangular parts excluding the diagonal
upper_tri_index_orig = triu(true(size(connectome_full_orig)), 1);
upper_tri_index = triu(true(size(connectome_full)), 1);

flat_connectome_full_orig = connectome_full_orig(upper_tri_index_orig);
flat_connectome_full = connectome_full(upper_tri_index);

%Plot scatter of connectomes
figure;
scatter(flat_connectome_full_orig, flat_connectome_full, 'filled', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'r');
hold off;

% Customize the scatter plot if needed
title('FC connectome scatter plot between Sub26C original and motion removed tedana');
xlabel('Original Connectome');
ylabel('Motion Removed Connectome');

% Show the plot
grid on;

% Find regions where connectome on one pipeline is greater and off diagonal of scatter plot
connectome_full_mean = mean(connectome_full, 2);
connectome_full_orig_mean = mean(connectome_full_orig, 2);
connectome_difference_mean = connectome_full_mean - connectome_full_orig_mean;
%save and visualize difference in connectomes to identify parts of the brain
file_path = sprintf('/Users/shefalirai/Desktop/Tedana_tests_sub26Cdatafiles/sub-1973026C_ses-%d_%s_motion_parcelled.ptseries.nii', ses, task);
dtseries = ciftiopen(file_path, wbcommand);
dtseries.cdata = connectome_difference_mean;
ciftisave(dtseries, '/Users/shefalirai/Desktop/sub26C_originalvsmotiontedana_difference.ptseries.nii', wbcommand); 

% Plot scatter of test and re-test connectomes for both pipelines
figure;
scatter(ptseries_firstfourth_connectome_C_orig, ptseries_secondthird_connectome_C_orig, 'filled', 'MarkerEdgeColor', 'white', 'MarkerFaceColor', 'red');
hold on;
scatter(ptseries_firstfourth_connectome_C, ptseries_secondthird_connectome_C, 'filled', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'blue');

% Customize the scatter plot if needed
title('FC test vs. retest connectomes between Sub26C original and motion removed tedana');
xlabel('First and Fourth Session Connectome');
ylabel('Second and Third Session Connectome');
% Show the plot
grid on;


%% Identify outliers in motion components pipeline based on the figure above plotting test vs retest connectomes

% Find which parcels have a difference between test connectome and retest connectome in the motion removed tedana pipeline
% Calculate mean values along rows for each matrix
mean_firstfourth = mean(ptseries_firstfourth_connectome_C, 2);
mean_secondthird = mean(ptseries_secondthird_connectome_C, 2);

% Calculate the difference between mean values
mean_difference = mean_firstfourth - mean_secondthird;

% Find parcels with significant differences
significant_parcels = find(abs(mean_difference) > 0.03); 

% Display significant parcels
disp('Parcels with significant mean differences:');
disp(significant_parcels);

% Create new matrix identifying significant parcels
total_parcels = size(ptseries_firstfourth_connectome_C, 1);

% Create a binary matrix
binary_significant_parcels = zeros(total_parcels, 1);
% Set elements to 1 for significant parcels
binary_significant_parcels(significant_parcels) = 1;

%save and visualize significant parcels across cortical surface
file_path = sprintf('/Users/shefalirai/Desktop/Tedana_tests_sub26Cdatafiles/sub-1973026C_ses-%d_%s_motion_parcelled.ptseries.nii', ses, task);
dtseries = ciftiopen(file_path, wbcommand);
dtseries.cdata = binary_significant_parcels;
ciftisave(dtseries, '/Users/shefalirai/Desktop/sub26C_motiontedana_significantparcels.ptseries.nii', wbcommand); 


