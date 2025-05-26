% volume_bar_plot.m
% Plot data volumes for LW1-LW4 based on volume.txt values

clc
clear

% Read data volume from text file
volumes = dlmread('volume.txt', ',');  

% Base station labels and corresponding colors
base_stations = {'LW1', 'LW2', 'LW3', 'LW4'};
colors = [ ...
    31, 119, 180;   % #1f77b4
    255, 127, 14;   % #ff7f0e
    44, 160, 44;    % #2ca02c
    214, 39, 40     % #d62728
] / 255;

% Create the bar plot
figure('Position', [100, 100, 600, 500]);  % Size in pixels
b = bar(volumes, 'FaceColor', 'flat', 'BarWidth', 0.7);

% Apply custom colors
for i = 1:numel(volumes)
    b.CData(i, :) = colors(i, :);
end

% Add data labels on top of bars
for i = 1:numel(volumes)
    text(i, volumes(i) + 10, sprintf('%.2f', volumes(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 10);
end

% Axis settings
set(gca, 'XTickLabel', base_stations, 'FontSize', 14);
ylabel('Data Volume (Mbits)', 'FontSize', 14);
xlabel('Base Station', 'FontSize', 14);
ytickformat('%.0f')
grid on;
box on;
hold off;

% Create the directory if it doesn't exist
if ~exist('figs', 'dir')
    mkdir('figs');
end

% Save the figure in /fig directory
print(fullfile('figs', 'data_volume_per_base_station'), '-dpng', '-r600');

% Close the figure
close(gcf)