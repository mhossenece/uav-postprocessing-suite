%--------------------------------------------------------------------------
% Script: plot_uav_score.m
%
% Description:
% This script reads the mission evaluation scores from `score.txt`, which
% contains four values:
%   - T1 (Total Mission Time)
%   - S1 and S2 (Subscores for different metrics)
%   - Score (Final combined score)
%
% It visualizes S1, S2, and the total score in a single bar chart with
% annotated values. This visualization helps summarize mission performance
% in UAV-based data collection tasks.
%
% Input:
%   - score.txt : File containing the output of the scoring evaluation
%
% Output:
%   - figs/uav_download_metrics.png : Score bar plot
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
clear all
close all


% Step 1: Read lines from the file
fid = fopen('score.txt', 'r');
lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = lines{1};

% Step 2: Parse values using regular expressions
scores = struct('T1', 0, 'S1', 0, 'S2', 0, 'Score', 0);
for i = 1:length(lines)
    tokens = regexp(lines{i}, '(\w+):\s*([\d.]+)', 'tokens');
    if ~isempty(tokens)
        key = tokens{1}{1};
        val = str2double(tokens{1}{2});
        scores.(key) = val;
    end
end

% Step 3: Prepare data for plotting
bar_labels = {'S1', 'S2', 'Total Score'};
bar_values = [scores.S1, scores.S2, scores.Score];

% Step 4: Create bar plot
figure('Position', [100, 100, 600, 500]);
b = bar(bar_values, 'FaceColor', [0.2 0.4 0.6], 'BarWidth', 0.6);

% Add data labels on top
for i = 1:numel(bar_values)
    text(i, bar_values(i) + 1, sprintf('%.2f', bar_values(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 10);
end

% Customize axes
set(gca, 'XTickLabel', bar_labels, 'FontSize', 14);
ylabel('Score', 'FontSize', 14);
ylim([0, max(bar_values) + 10]);
grid on
box on


% Create the directory if it doesn't exist
if ~exist('figs', 'dir')
    mkdir('figs');
end

% Save the figure in /fig directory
print(fullfile('figs', 'uav_download_metrics'), '-dpng', '-r600');

% Close the figure
close(gcf)