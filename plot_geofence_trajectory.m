%--------------------------------------------------------------------------
% Script: plot_geofence_trajectory.m
%
% Description:
% This script visualizes the UAV flight trajectory in relation to:
%   - A predefined geofence (loaded from a KML file)
%   - The four eNodeBs (LW1–LW4) involved in the data collection mission
%   - The UAV's initial starting point
%
% It uses `vehicleOut.csv` for UAV position data and overlays the trajectory,
% eNodeB markers, and geofence boundary on a 2D geographic plot. The plot is
% saved as a high-resolution PNG image in the `/figs` directory.
%
% Inputs:
%   - vehicleOut.csv           : Contains UAV GPS trajectory logs
%   - AERPAW_UAV_Geofence_Phase_1.kml : Contains geofence polygon coordinates
%
% Output:
%   - figs/trajectory.png      : Saved figure showing UAV path and geofence
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


% Load UAV trajectory data (must contain 'Latitude' and 'Longitude')
df = readtable('vehicleOut.csv');

% Parse the KML file
kmlFile = 'AERPAW_UAV_Geofence_Phase_1.kml';
xDoc = xmlread(kmlFile);
coordNode = xDoc.getElementsByTagName('coordinates').item(0);
coordStr = char(coordNode.getTextContent());
coordList = strsplit(strtrim(coordStr));

% Extract geofence coordinates
geofence_coords = zeros(length(coordList), 2);
for i = 1:length(coordList)
    parts = strsplit(coordList{i}, ',');
    geofence_coords(i, 1) = str2double(parts{1}); % Longitude
    geofence_coords(i, 2) = str2double(parts{2}); % Latitude
end

% Ensure the geofence polygon is closed
if any(geofence_coords(1,:) ~= geofence_coords(end,:))
    geofence_coords(end+1,:) = geofence_coords(1,:);
end

% eNodeB coordinates
lat_eNBs = [35.7275, 35.728056, 35.725, 35.733056];
lon_eNBs = [-78.695833, -78.700833, -78.691667, -78.698333];
eNB_labels = {'LW1', 'LW2', 'LW3', 'LW4'};
eNB_colors = {'b', 'g', 'm', 'r'};
eNB_markers = {'^', 's', 'p', 'd'};

% Initial drone position
lat_drone = 35.7271225;
lon_drone = -78.696275;

% Plot

figure('Position', [100 100 600 550]);

% Geofence
plot(geofence_coords(:,1), geofence_coords(:,2), 'Color', [1, 0.5, 0], 'LineWidth', 2, 'DisplayName', 'Geofence'); hold on;

% UAV trajectory
plot(df.Longitude, df.Latitude, 'k--o', 'MarkerSize', 1, 'DisplayName', 'Trajectory');

% eNodeBs
for i = 1:length(lat_eNBs)
    scatter(lon_eNBs(i), lat_eNBs(i), 100, eNB_colors{i}, eNB_markers{i}, 'filled', 'DisplayName', eNB_labels{i});
end

% Drone start position
scatter(lon_drone, lat_drone, 80, 'blue', 'o', 'filled', 'DisplayName', 'Drone');

xlabel('Longitude', 'FontSize', 12);
ylabel('Latitude', 'FontSize', 12);
xtickformat('%.4f'); ytickformat('%.4f');
%xtickangle(45);
set(gca, 'FontSize', 12);
legend('FontSize', 12, 'Location', 'best');
grid on;
axis equal;
%xlim([-78.701, -78.692]);
% ylim([35.723, 35.735]); % Uncomment if needed


% Create the directory if it doesn't exist
if ~exist('figs', 'dir')
    mkdir('figs');
end

% Save the figure in /fig directory
print(fullfile('figs', 'trajectory'), '-dpng', '-r600');

% Close the figure
close(gcf)