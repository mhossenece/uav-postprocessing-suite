% Script: main.m
%
% Description:
% This master script orchestrates the entire post-processing pipeline for 
% UAV-assisted wireless data collection experiments. It automates:
%
%   1. Parsing raw telemetry logs (vehicle position, SNR, and downloads)
%   2. Converting logs into structured CSV files
%   3. Merging data into unified time-aligned tables
%   4. Calculating key metrics:
%       - Total data volume assigned per base station
%       - Cumulative data downloaded
%       - Mission score and duration
%   5. Generating plots for:
%       - UAV trajectory with geofence and eNodeBs
%       - Cumulative download vs. time with distance
%       - Data volume, remaining data, and final score
%
% The purpose is to assess mission performance in terms of throughput,
% fairness, and coverage across a multi-cell wireless setup.
%
% Author: Md Sharif Hossen  
% PhD Student, Department of Electrical and Computer Engineering, NCSU  
% Date: May 4, 2025
%
% Copyright (c) 2025 Md Sharif Hossen  
% All rights reserved. This work is licensed for academic and research use only.
%
% If you use this suite in your research, please cite:
%   Md Sharif Hossen. UAV Post-Processing Suite. Available at:
%   https://github.com/mhossenece/uav-postprocessing-suite
%--------------------------------------------------------------------------


clc
clear all
close all

disp('Please wait...')

%generate csv
run('txt_to_csv_vehicle_snr.m');
run('txt_to_csv_download.m');

%merge csv
run('csv_merge.m');

%calculate data volume, total download, and score
run('volume.m')
run('score.m')
run('extract_last_download.m')

%plot
run('plot_geofence_trajectory.m')
run('uav_cumulative_download_plot.m')
run('volume_bar_plot.m')
run('plot_remaining_data.m')
run('plot_uav_score.m')

disp('Done.')

