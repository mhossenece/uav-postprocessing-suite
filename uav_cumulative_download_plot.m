%--------------------------------------------------------------------------
% Script: uav_cumulative_download_plot.m
%
% Description:
% This script simulates and visualizes UAV-assisted data collection over time.
% It computes:
%   - Cumulative downloaded data per base station (LW1–LW4)
%   - Cumulative distance traveled by the UAV
%
% The simulation uses SNR-based scheduling to determine which base station
% the UAV downloads from at each timestep. It uses a lookup-based spectral
% efficiency model to compute throughput and logs how much data is received
% from each cell. The final figure plots:
%   - Download progress for each base station (left Y-axis)
%   - Distance traveled by the UAV (right Y-axis)
%
% Inputs:
%   - vehicleOut_snr_merged.csv : Merged file containing time, SNR, and GPS logs
%
% Output:
%   - figs/cumulative_download_vs_time.png : Time vs download & distance plot
%
% Author: Md Sharif Hossen  
% PhD Student, Department of Electrical and Computer Engineering, NCSU  
% Advisors: Dr. Ismail Guvenc and Dr. Vijay K. Shah  
% Date: May 4, 2025
%
% Copyright (c) 2025 Md Sharif Hossen  
% All rights reserved. This work is licensed for academic and research use only.
%
% If you use this script or dataset in your research, please cite:
%   Md Sharif Hossen. UAV Post-Processing Suite. Available at:
%   https://github.com/mhossenece/uav-postprocessing-suite
%--------------------------------------------------------------------------


% Clear workspace and command window
clear; close all;
%clc

%% Load Data
% Read the CSV file containing time, SNRs, and positional data
data = readtable('vehicleOut_snr_merged.csv');

% Convert 'time' column to datetime format
data.time = datetime(data.time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');

% Set 'time' as the row times for a timetable
dataTT = table2timetable(data);

%% Define Base Stations and Initial Data Volumes
BS_names = {'snr_lw1', 'snr_lw2', 'snr_lw3', 'snr_lw4'};
BS_labels = {'LW1', 'LW2', 'LW3', 'LW4'};
initial_volume = 1000; % Initial data volume in Mbits for each BS
data_remaining = containers.Map(BS_names, repmat({initial_volume}, 1, numel(BS_names)));
data_downloaded = containers.Map(BS_names, repmat({zeros(height(dataTT), 1)}, 1, numel(BS_names)));
bs_completed = false(numel(BS_names), 1);

%% Compute Cumulative Distance Traveled
% Initialize distance array
distance = zeros(height(dataTT), 1);

% Earth's radius in meters
R = 6371000;

% Convert degrees to radians for latitude and longitude
lat_rad = deg2rad(dataTT.Latitude);
lon_rad = deg2rad(dataTT.Longitude);

% Compute distance between consecutive points
for i = 2:height(dataTT)
    dlat = lat_rad(i) - lat_rad(i-1);
    dlon = lon_rad(i) - lon_rad(i-1);
    a = sin(dlat/2)^2 + cos(lat_rad(i-1)) * cos(lat_rad(i)) * sin(dlon/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1 - a));
    distance(i) = R * c;
end

% Compute cumulative distance
cumulative_distance = cumsum(distance);

%% Define Spectral Efficiency Function
get_spectral_efficiency = @(snr) ...
    (snr >= 22.7) * 5.55 + ...
    (snr >= 21.0 & snr < 22.7) * 5.12 + ...
    (snr >= 18.7 & snr < 21.0) * 4.52 + ...
    (snr >= 16.3 & snr < 18.7) * 3.90 + ...
    (snr >= 14.1 & snr < 16.3) * 3.32 + ...
    (snr >= 11.7 & snr < 14.1) * 2.73 + ...
    (snr >= 10.3 & snr < 11.7) * 2.41 + ...
    (snr >= 8.1 & snr < 10.3) * 1.91 + ...
    (snr >= 5.9 & snr < 8.1) * 1.48 + ...
    (snr >= 4.3 & snr < 5.9) * 1.18 + ...
    (snr >= 2.4 & snr < 4.3) * 0.88 + ...
    (snr >= 0.2 & snr < 2.4) * 0.60 + ...
    (snr >= -2.3 & snr < 0.2) * 0.38 + ...
    (snr >= -4.7 & snr < -2.3) * 0.23 + ...
    (snr >= -6.7 & snr < -4.7) * 0.15 + ...
    (snr < -6.7) * 0.0;

%% Simulate Data Download
time_log = dataTT.time;
time_sec = seconds(time_log - time_log(1));
num_samples = height(dataTT);

% Initialize download matrices
download_matrix = zeros(num_samples, numel(BS_names));

for i = 1:num_samples
    if all(bs_completed)
        break;
    end

    % Get current SNRs for incomplete BSs
    current_snrs = zeros(1, numel(BS_names));
    for j = 1:numel(BS_names)
        if ~bs_completed(j)
            current_snrs(j) = dataTT.(BS_names{j})(i);
        else
            current_snrs(j) = -Inf; % Exclude completed BSs
        end
    end

    % Find the BS with the highest SNR
    [~, best_bs_idx] = max(current_snrs);
    best_bs = BS_names{best_bs_idx};

    % Calculate throughput
    snr_value = dataTT.(best_bs)(i);
    spectral_efficiency = get_spectral_efficiency(snr_value);
    throughput = spectral_efficiency * 1.4; % bits/sec/Hz

    % Calculate actual download amount (limited by remaining volume)
    download_amt = min(throughput, data_remaining(best_bs));

    % Update downloaded data
    prev_download = data_downloaded(best_bs);
    if i == 1
        prev_download(i) = download_amt;
    else
        prev_download(i) = prev_download(i-1) + download_amt;
    end
    data_downloaded(best_bs) = prev_download;
    data_remaining(best_bs) = data_remaining(best_bs) - download_amt;

    % Check if BS is completed
    if data_remaining(best_bs) <= 0
        bs_completed(best_bs_idx) = true;
    end
    
   % Update download matrix
    for j = 1:numel(BS_names)
        bs_key = BS_names{j};
        prev = data_downloaded(bs_key);
        
        if j ~= best_bs_idx
            if i == 1
                prev(i) = 0;
            else
                prev(i) = prev(i-1);
            end
            data_downloaded(bs_key) = prev;
        end
        
        download_matrix(i, j) = prev(i);
    end

end

%% Plotting
figure('Visible', 'off', 'Position', [100, 100, 600, 500]);
colors = {'#1f77b4', '#ff7f0e', '#2ca02c', '#d62728'};
markers = {'o', 's', '^', 'D'};
fontSize = 12;

% Plot cumulative downloads
yyaxis left;
hold on;
% for j = 1:numel(BS_names)
%     plot(time_sec, download_matrix(:, j), 'Color', colors{j}, ...
%         'Marker', markers{j}, 'LineWidth', 1.5, 'DisplayName', BS_labels{j});
% end
skip = 10; % Plot every 10th point

for j = 1:numel(BS_names)
    plot(time_sec(1:skip:end), download_matrix(1:skip:end, j), ...
        'Color', colors{j}, 'Marker', markers{j}, ...
        'LineWidth', 1.5, 'DisplayName', BS_labels{j});
end

ylabel('Cumulative Downloaded Data (Mbits)', 'FontSize', fontSize);
%ylim([0, initial_volume + 50]);
xlim([0, max(time_sec)])


% Plot cumulative distance
yyaxis right;
plot(time_sec, cumulative_distance, 'Color', '#654321', 'LineWidth', 2, ...
    'DisplayName', 'Distance');
ylabel('Distance Traveled (meters)', 'FontSize', fontSize);
%ylim([0, max(cumulative_distance) + 50]);

% Customize plot
xlabel('Time (seconds)', 'FontSize', fontSize);
%title('UAV Data Download Progress', 'FontSize', fontSize + 2);
legend('Location', 'northwest', 'FontSize', fontSize - 2);
grid on;
set(gca, 'FontSize', fontSize);
box on;
hold off;

% Create the directory if it doesn't exist
if ~exist('figs', 'dir')
    mkdir('figs');
end

% Save the figure in /fig directory
print(fullfile('figs', 'cumulative_download_vs_time'), '-dpng', '-r600');

% Close the figure
close(gcf)