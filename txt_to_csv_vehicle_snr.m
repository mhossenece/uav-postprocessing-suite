%--------------------------------------------------------------------------
% Script: txt_to_csv_vehicle_snr.m
%
% Description:
% This script processes UAV telemetry data from two log files:
%   1. 'vehicleOut.txt' – containing UAV geolocation, orientation, and velocity
%   2. 'controller_log.txt' – containing timestamped SNR values from four base stations
%
% It parses, normalizes, and converts each log file into structured CSV format:
%   - Outputs: 'vehicleOut.csv', 'snr_log.csv'
%
% These outputs are used for evaluating UAV trajectories, base station
% coverage, and SNR-aware throughput modeling in wireless communication experiments.
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



%clc;
clear all;

% -------- USER CONFIGURATION --------
inputFiles = {'vehicleOut.txt', 'controller_log.txt'};
modes = {'vehicleOut', 'controller_log'};
outputFiles = {'vehicleOut.csv', 'snr_log.csv'};
% ------------------------------------

for idx = 1:length(inputFiles)
    logFile = inputFiles{idx};
    mode = modes{idx};
    outputFile = outputFiles{idx};

    fid = fopen(logFile, 'r');
    if fid == -1
        warning('File %s could not be opened. Skipping...', logFile);
        continue;
    end
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    lines = lines{1};
    fclose(fid);

    switch mode
        case 'vehicleOut'
            data = parse_vehicleOut(lines);
        case 'controller_log'
            data = parse_controllerData(lines);
        otherwise
            error('Unsupported mode: %s', mode);
    end

    % Normalize all fields to have equal number of rows
    fnames = fieldnames(data);
    lens = structfun(@(f) numel(f), data);
    maxLen = max(lens);

    for i = 1:numel(fnames)
        f = data.(fnames{i});

        % Convert row vector to column vector
        if isrow(f)
            f = f';
        end

        % Pad numeric arrays
        if isnumeric(f)
            f(end+1:maxLen, 1) = 0;

        % Pad cell arrays (e.g., timestamps)
        elseif iscell(f)
            f(end+1:maxLen, 1) = {''};
            % If datetime stored as cell, replace '' with NaT
            if isa(f{1}, 'datetime')
                for k = find(cellfun(@isempty, f))'
                    f{k} = NaT;
                end
            end
        end

        data.(fnames{i}) = f;
    end

    T = struct2table(data);
    writetable(T, outputFile);
    %fprintf('Saved %d rows to %s\n', height(T), outputFile);
end

%% -------------- Functions ----------------

function data = parse_vehicleOut(lines)
    headers = {
        "num", "Longitude", "Latitude", "Altitude", ...
        "Pitch", "Yaw", "Roll", "VelocityX", "VelocityY", "VelocityZ", ...
        "BatteryVolts", "time", "GPSFix", "NumberOfSatellites"
    };

    for i = 1:length(headers)
        data.(headers{i}) = {};
    end

    for i = 1:length(lines)
        line = lines{i};
        line = strrep(line, '"(', '');
        line = strrep(line, ')"', '');
        tokens = strsplit(strtrim(line), ',');
        if length(tokens) ~= length(headers)
            warning("Skipping line %d: unexpected number of fields", i);
            continue;
        end
        for j = 1:length(headers)
            data.(headers{j}){end+1,1} = tokens{j};
        end
    end
end

function data = parse_controllerData(lines)
    % Initialize data structure
    data.time = {};

    data.snr_lw1 = [];
    data.snr_lw2 = [];
    data.snr_lw3 = [];
    data.snr_lw4 = [];

    for i = 1:length(lines)
        line = strtrim(lines{i});

        % Extract timestamp
        ts = extractTimestamp(line);

        % ----------------- SNR ----------------
        %elseif contains(line, 'SNR:')
        if contains(line, 'SNR:')
            [snr1, snr2, snr3, snr4] = extractFourValues(lines, i+1);
            data.snr_lw1(end+1,1) = snr1;
            data.snr_lw2(end+1,1) = snr2;
            data.snr_lw3(end+1,1) = snr3;
            data.snr_lw4(end+1,1) = snr4;
            data.time{end+1,1} = ts;
        end
    end
end

function ts = extractTimestamp(line)
    try
        timeStr = extractBetween(line, '[', ']');
        %ts = datetime(timeStr{1}, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
        ts = datetime(timeStr{1}, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
        ts.Format = 'yyyy-MM-dd HH:mm:ss.SSSSSS';  % Set display format
    catch
        ts = NaT;
    end
end

function val = getVol(tokens, key)
    for i = 1:length(tokens)
        if strcmp(tokens{i}{1}, key)
            val = tokens{i}{2};
            return;
        end
    end
    val = '0';
end

function [v1, v2, v3, v4] = extractFourValues(lines, iStart)
    v1 = 0; v2 = 0; v3 = 0; v4 = 0;
    for j = 0:3
        if iStart + j <= length(lines)
            line = lines{iStart + j};
            
            % Remove the timestamp enclosed in square brackets
            line = regexprep(line, '^\[[^\]]+\]\s*', '');
            % Extract the identifier and value
            tokens = regexp(line, '(\d):([-]?\d+\.\d+)', 'tokens');

            if ~isempty(tokens)
                idx = str2double(tokens{1}{1});
                %idx
                val = str2double(tokens{1}{2});
                %val
                switch idx
                    case 1, v1 = val;
                    case 2, v2 = val;
                    case 3, v3 = val;
                    case 4, v4 = val;
                end
            end
        end
    end
end

