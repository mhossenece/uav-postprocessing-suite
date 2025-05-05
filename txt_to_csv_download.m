%--------------------------------------------------------------------------
% Script: txt_to_csv_download.m
%
% Description:
% This script processes UAV download telemetry data from:
%   - 'controller_log.txt' – containing timestamped download amounts from
%     four base stations (LW1–LW4)
%
% It extracts per-base-station download data and timestamps, normalizes the
% structure, and saves the result as:
%   - Output: 'download_log.csv'
%
% This output is used for evaluating per-cell data contribution and
% computing cumulative download metrics in UAV-assisted wireless experiments.
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
inputFiles = {'controller_log.txt'};
modes = {'controller_log'};
%outputFiles = {'vehicleOut.csv', 'download_log.csv'};
outputFiles = {'download_log.csv'};
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

    data = parse_controllerData(lines);

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

function data = parse_controllerData(lines)
    % Initialize data structure
    data.time = {};
    data.dl_lw1 = [];
    data.dl_lw2 = [];
    data.dl_lw3 = [];
    data.dl_lw4 = [];

    for i = 1:length(lines)
        line = strtrim(lines{i});

        % Extract timestamp
        ts = extractTimestamp(line);

        if contains(line, 'Download:')
            [dl1, dl2, dl3, dl4] = extractFourValues(lines, i+1);
            data.dl_lw1(end+1,1) = dl1;
            data.dl_lw2(end+1,1) = dl2;
            data.dl_lw3(end+1,1) = dl3;
            data.dl_lw4(end+1,1) = dl4;
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

function [v1, v2, v3, v4] = extractFourValues(lines, iStart)
    v1 = 0; v2 = 0; v3 = 0; v4 = 0;
    for j = 0:3
        if iStart + j <= length(lines)
            line = lines{iStart + j};
            %line
            %tokens = regexp(line, '(\d):([-]?\d+\.\d+)', 'tokens');
            %tokens = regexp(line, '^\[[^\]]+\]\s*(\d):([-]?\d+\.\d+)', 'tokens');

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