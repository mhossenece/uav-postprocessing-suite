%--------------------------------------------------------------------------
% Script: plot_remaining_data.m
%
% Description:
% This script generates a bar plot of the remaining data (in Mbits) to be
% downloaded from each base station (LW1–LW4). It calculates the difference
% between the initial volume assigned to each base station (from `volume.txt`)
% and the actual amount downloaded (from `download.txt`).
%
% The output visualization highlights how much data was left uncollected
% at the end of the mission, providing insight into coverage or scheduling gaps.
%
% Inputs:
%   - volume.txt    : Initial data volumes for each base station
%   - download.txt  : Final downloaded amounts for each base station
%
% Output:
%   - figs/remaining_data_barplot.png : Remaining data bar chart
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


%clc
clear
close all

% Read total volumes from volume.txt
total_volumes = dlmread('volume.txt', ',');

% Read downloaded data from download.txt
fid = fopen('download.txt', 'r');
download_lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
download_lines = download_lines{1};

% Extract only the numeric part after "BS#:"
downloaded_vals = zeros(size(download_lines));
for i = 1:length(download_lines)
    tokens = regexp(download_lines{i}, '\d+:(\d+\.?\d*)', 'tokens');
    downloaded_vals(i) = str2double(tokens{1}{1});
end

% Compute remaining data
remaining_vals = total_volumes(:) - downloaded_vals;

% Define base station labels
base_stations = {'LW1', 'LW2', 'LW3', 'LW4'};

% Custom colors (same as your reference)
colors = [ ...
    31, 119, 180;   % Blue
    255, 127, 14;   % Orange
    44, 160, 44;    % Green
    214, 39, 40     % Red
] / 255;

% Create the bar plot
figure('Position', [100, 100, 600, 500]);
b = bar(remaining_vals, 'FaceColor', 'flat', 'BarWidth', 0.7);

% Apply custom colors to each bar
for i = 1:numel(remaining_vals)
    b.CData(i, :) = colors(i, :);
end

% Add text annotations (values on top of bars)
for i = 1:numel(remaining_vals)
    text(i, remaining_vals(i) + 10, sprintf('%.2f', remaining_vals(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 10);
end

% Axis labels and appearance
set(gca, 'XTickLabel', base_stations, 'FontSize', 14);
ylabel('Data Remaining (Mbits)', 'FontSize', 14);
xlabel('Base Station', 'FontSize', 14);
ytickformat('%.0f')
grid on
box on




% Save high-quality output
set(gcf, 'PaperPositionMode', 'auto');


% Create the directory if it doesn't exist
if ~exist('figs', 'dir')
    mkdir('figs');
end

% Save the figure in /fig directory
print(fullfile('figs', 'remaining_data_barplot'), '-dpng', '-r600');

% Close the figure
close(gcf)
