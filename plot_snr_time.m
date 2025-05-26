%--------------------------------------------------------------------------
% Script: plot_snr_time.m
%
% Description:
% This script reads a UAV telemetry CSV file containing timestamps, SNR
% measurements from four base stations (LW1–LW4), and GPS coordinates.
% It performs the following:
%   - Converts timestamp to seconds since mission start
%   - Computes cumulative distance traveled using the haversine formula
%   - Plots downlink SNR from all base stations over time
%   - Overlays distance traveled on a secondary Y-axis
%   - Saves the final figure as a high-resolution image
%
% Input:
%   - vehicleOut_snr_merged.csv : UAV telemetry data with SNR and location
%
% Output:
%   - figs/time_snr.png : Time vs SNR and Distance plot
%
% Use Case:
%   This visualization helps evaluate the temporal variation in received 
%   signal quality (SNR) from different base stations and how it evolves 
%   with the UAV's movement across space. Useful for analyzing mobility, 
%   coverage, and link reliability in UAV-enabled networks.
%
% Author: Md Sharif Hossen  
% PhD Student, Department of Electrical and Computer Engineering, NCSU  
%
% Copyright (c) 2025 Md Sharif Hossen  
% All rights reserved. This work is licensed for academic and research use only.
%
% If you use this script or dataset in your research, please cite:
%   Md Sharif Hossen. UAV Post-Processing Suite. Available at:
%   https://github.com/mhossenece/uav-postprocessing-suite
%--------------------------------------------------------------------------


clc
close all
plot_uav_snr_distance('vehicleOut_snr_merged.csv')


function plot_uav_snr_distance(csv_file)
    % Read CSV data
    data = readtable(csv_file);

    % Convert time to datetime
    data.time = datetime(data.time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');

    % Time in seconds from start
    time_in_seconds = seconds(data.time - data.time(1));

    % Compute distance traveled (haversine)
    distances = zeros(height(data), 1);
    for i = 2:height(data)
        distances(i) = distances(i-1) + haversine_km( ...
            data.Longitude(i-1), data.Latitude(i-1), ...
            data.Longitude(i), data.Latitude(i) ...
        ) * 1000; % in meters
    end

    % Colors and markers
    colors = {'b', 'g', 'r', 'm'};
    markers = {'o', 's', '^', 'd'};
    lw_labels = {'LW1', 'LW2', 'LW3', 'LW4'};
    lw_fields = {'snr_lw1', 'snr_lw2', 'snr_lw3', 'snr_lw4'};

    figure('Position', [100, 100, 900, 600]);
    yyaxis left
    hold on
    for i = 1:length(lw_fields)
        if ismember(lw_fields{i}, data.Properties.VariableNames)
            plot(time_in_seconds, data.(lw_fields{i}), ...
                'Color', colors{i}, 'Marker', markers{i}, ...
                'LineStyle', 'none', 'DisplayName', lw_labels{i});
        end
    end
    ylabel('SNR (dB)');
    %ylim([-80, 50]);
    xlim([0, max(time_in_seconds)])

    yyaxis right
    plot(time_in_seconds, distances, 'Color', [0.4 0.26 0.13], 'LineWidth', 1.5, ...
        'DisplayName', 'Distance Traveled');
    ylabel('Distance Traveled (meters)','FontSize', 14);

    xlabel('Time (seconds)');
    %legend('Location', 'northoutside', 'Orientation', 'horizontal');
    xlabel('Time (seconds)');
    %legend('Location', 'northeast', 'FontSize', 12, 'Box', 'on');  % Legend inside
    legend('FontSize', 12, 'Box', 'on');
    legend('Position', [0.4, 0.83, 0.2, 0.1]);  % [x, y, width, height]

    grid on
    
    % Create the directory if it doesn't exist
    if ~exist('figs', 'dir')
        mkdir('figs');
    end
    
    % Save the figure in /fig directory
    print(fullfile('figs', 'time_snr'), '-dpng', '-r600');
    
    % Close the figure
    close(gcf)

end

function d = haversine_km(lon1, lat1, lon2, lat2)
    % Convert to radians
    lon1 = deg2rad(lon1);
    lat1 = deg2rad(lat1);
    lon2 = deg2rad(lon2);
    lat2 = deg2rad(lat2);

    dlon = lon2 - lon1;
    dlat = lat2 - lat1;

    a = sin(dlat/2)^2 + cos(lat1)*cos(lat2)*sin(dlon/2)^2;
    c = 2 * asin(sqrt(a));
    r = 6371; % Earth radius in km
    d = c * r;
end


