%--------------------------------------------------------------------------
% Script: extract_last_download.m
%
% Description:
% This script extracts the most recent "Download" entry from the UAV
% controller log file (`controller_log.txt`). It scans the file in reverse
% to locate the last occurrence of a "Download:" line and retrieves the
% subsequent four lines corresponding to download amounts from base
% stations (LW1–LW4).
%
% The extracted values are cleaned using regular expressions and saved to:
%   - Output: 'download.txt'
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
fid = fopen('controller_log.txt', 'r');
lines = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);
lines = lines{1};

% Search backwards for the last "Download:" line
last_idx = -1;
for i = numel(lines):-1:1
    if contains(lines{i}, 'Download:')
        last_idx = i;
        break;
    end
end

if last_idx == -1
    error('No Download section found in the log file.');
end

% Extract next 4 lines after "Download:" that contain the actual values
download_lines = lines(last_idx+1:min(last_idx+4, numel(lines)));

% Extract the part after the timestamp using regular expressions
extracted_values = regexp(download_lines, '\] (.+)', 'tokens');

% Flatten and convert to string array
extracted_values = string(cellfun(@(x) x{1}, extracted_values));

download_lines = extracted_values;

% Write to download.txt
fid_out = fopen('download.txt', 'w');
for i = 1:numel(download_lines)
    fprintf(fid_out, '%s\n', strtrim(download_lines{i}));
end
fclose(fid_out);
