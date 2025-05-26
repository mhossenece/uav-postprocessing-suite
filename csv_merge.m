%--------------------------------------------------------------------------
% Script: csv_merge.m
%
% Description:
% This script merges two CSV files containing timestamped UAV telemetry data.
% It supports two modes of merging based on time alignment:
%   - Interpolation ('i'): linearly interpolates values between timestamps
%   - Copy/forward-fill ('c'): carries forward the most recent known value
%
% The script outputs a unified CSV file with synchronized data columns,
% which is used in UAV data analysis pipelines for joint trajectory,
% download, and SNR evaluations.
%
% Usage:
%   csvMergeMatlab(file1, file2, outputFile, mergeMode, noTrim)
%
% Example:
%   csvMergeMatlab('snr_log.csv', 'vehicleOut.csv', ...
%                  'vehicleOut_snr_merged.csv', 'i', false);
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

csvMergeMatlab('snr_log.csv', 'vehicleOut.csv', 'vehicleOut_snr_merged.csv', 'i', false);
csvMergeMatlab('download_log.csv', 'vehicleOut.csv', 'vehicleOut_download_merged.csv', 'i', false);

function csvMergeMatlab(file1, file2, outputFile, mergeMode, noTrim)
    % csvMergeMatlab merges two CSV files on their time columns.
    %
    % Parameters:
    %   file1     - Filename of the first CSV file (e.g., 'vehicleOut.csv')
    %   file2     - Filename of the second CSV file (e.g., 'snr_log.csv')
    %   outputFile - Filename for the output merged CSV file
    %   mergeMode - 'i' for interpolation, 'c' for copy/forward-fill
    %   noTrim    - Boolean flag; if true, does not trim to overlapping time range

    % Read the first CSV file into a timetable
    data1 = readtable(file1);
    data1.time = datetime(data1.time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
    tt1 = table2timetable(data1);

    % Read the second CSV file into a timetable
    data2 = readtable(file2);
    data2.time = datetime(data2.time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
    tt2 = table2timetable(data2);

    % Determine the overlapping time range
    ts_min = max([min(tt1.time), min(tt2.time)]);
    ts_max = min([max(tt1.time), max(tt2.time)]);

    % Synchronize the timetables based on the specified merge mode
    switch mergeMode
        case 'i'
            % Interpolate missing data
            mergedTT = synchronize(tt1, tt2, 'union', 'linear');
        case 'c'
            % Forward-fill missing data
            mergedTT = synchronize(tt1, tt2, 'union', 'previous');
        otherwise
            error('Invalid mergeMode. Use ''i'' for interpolate or ''c'' for copy/forward-fill.');
    end

    % Trim to the overlapping time range unless noTrim is true
    if ~noTrim
        mergedTT = mergedTT(mergedTT.time >= ts_min & mergedTT.time <= ts_max, :);
    end

    % Filter to only include timestamps present in the first file
    mergedTT = mergedTT(ismember(mergedTT.time, tt1.time), :);

    % Write the merged timetable to the output CSV file
    writetimetable(mergedTT, outputFile);
    %disp(['Merged data saved to ', outputFile]);
end


