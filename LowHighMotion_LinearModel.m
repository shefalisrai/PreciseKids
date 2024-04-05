% Linear model for low/high motion groups for child group and adult group
% Run MeanFD_ChildandParent.m to get the mean FD values for all 48
% particpiants before this script


%Load matched matrix from low/high motion groups (12 participants each)
load('PKdata_matchedmatrix_lowhighmotion_CP.mat');
load('PKdata_meanFD_allparticipants_unordered.mat');
load('PKdata_lowhighmotion_ordered.mat');

% Find the indices where the reliability first meets 0.7 for each row
[~, Timeat7_lowmotion_C_indices] = max(matched_matrix_lowmotion_C >= 0.7, [], 2);
[~, Timeat7_highmotion_C_indices] = max(matched_matrix_highmotion_C >= 0.7, [], 2);
[~, Timeat7_lowmotion_P_indices] = max(matched_matrix_lowmotion_P >= 0.7, [], 2);
[~, Timeat7_highmotion_P_indices] = max(matched_matrix_highmotion_P >= 0.7, [], 2);

%Reorder FD based on correct indices
child_indices=[low_motion_C'; high_motion_C'];
adult_indices=[low_motion_P'; high_motion_P'];
childadult_indices=[child_indices; adult_indices];

% Initialize the reordered matrix
reordered_meanFD_volumes_final = zeros(length(childadult_indices), 2);

% Reorder the rows based on childadult_indices
for i = 1:length(childadult_indices)
    % Find the index of the subject ID in the second column
    idx = find(meanFD_volumes_final(:, 2) == childadult_indices(i), 1);
    
    % Assign the corresponding FD value and subject ID to the reordered matrix
    reordered_meanFD_volumes_final(i, :) = [meanFD_volumes_final(idx, 1), childadult_indices(i)];
end


%% LME model to include family group

% Data preparation
ageGroup = [repmat({'Child'}, 24, 1); repmat({'Adult'}, 24, 1)];
motionValues = reordered_meanFD_volumes_final(:,1);
timeAtReliability = [Timeat7_lowmotion_C_indices; Timeat7_highmotion_C_indices; Timeat7_lowmotion_P_indices; Timeat7_highmotion_P_indices];
model_data_input = table(ageGroup, motionValues, timeAtReliability);
% Create a vector of zeros
familyID = [child_indices; adult_indices];
familymodel_data_input = table(ageGroup, motionValues, timeAtReliability, familyID);

% Fit the mixed-effects model
formula = 'timeAtReliability ~ ageGroup + motionValues + ageGroup*motionValues + (1|familyID)';
mdl_mixed = fitlme(familymodel_data_input, formula);
disp(mdl_mixed);

%% Plot mdl_mixed

% Fixed effects coefficients from your model
intercept = 8.1363;
ageGroup_coef = 1.922;
motionValues_coef = 30.235;
interaction_coef = -34.844;

% Generate data points for the regression lines
motion_values_range = linspace(0, 50, 100);

% Map age group strings to numeric values
age_group_numeric = zeros(size(ageGroup));
age_group_numeric(strcmp(ageGroup, 'Adult')) = 1;
age_group_numeric(strcmp(ageGroup, 'Child')) = 2;

% Calculate predicted values for each age group
predicted_values_adult = intercept + ageGroup_coef + motionValues_coef * motion_values_range + interaction_coef * motion_values_range;
predicted_values_child = intercept + motionValues_coef * motion_values_range;

% Plot the scatter plot with original data points
figure;
hold on;
scatter(motionValues(age_group_numeric == 1), timeAtReliability(age_group_numeric == 1), [], 'b', 'filled');
scatter(motionValues(age_group_numeric == 2), timeAtReliability(age_group_numeric == 2), [], 'r', 'filled');

% Plot the lines of best fit
plot(motion_values_range, predicted_values_adult, 'b', 'LineWidth', 2);
plot(motion_values_range, predicted_values_child, 'r', 'LineWidth', 2);

% Add legend and labels
legend({'Adult', 'Child', 'Adult Regression', 'Child Regression'}, 'Location', 'best');
xlabel('Motion Values');
ylabel('Time at Reliability');

% Add a title
title('Relationship between Motion Values and Time at Reliability by Age Group');

% Set axis limits if needed
xlim([0 1]);
ylim([0 25]);

hold off;

