%--------------------------------------------------------------------------
% Script: score.m
%
% Description:
% This script parses the UAV controller log file ('controller_log.txt') to
% extract key mission performance metrics, including:
%   - T1 (mission duration in seconds)
%   - S1 and S2 (individual scores)
%   - Score (final combined score)
%
% It identifies lines matching the format:
%   "T1: <val> seconds, S1:<val>, S2:<val>, Score:<val>"
%
% The extracted values are written to a clean summary file:
%   - Output: 'score.txt'
%
% This output is used for visualization, evaluation, and reporting of
% mission success in UAV-assisted data collection experiments.
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

% Open the log file for reading
fid_in = fopen('controller_log.txt', 'r');
if fid_in == -1
    error('Cannot open log.txt for reading.');
end

% Open the output file for writing
fid_out = fopen('score.txt', 'w');
if fid_out == -1
    fclose(fid_in);
    error('Cannot open score.txt for writing.');
end

% Read the log file line by line
while ~feof(fid_in)
    line = fgetl(fid_in);
    if contains(line, 'T1:')
        % Use regular expressions to extract the values
        tokens = regexp(line, 'T1:\s*([\d.]+)\s*seconds,\s*S1:([\d.]+),\s*S2:([\d.]+),\s*Score:([\d.]+)', 'tokens');
        if ~isempty(tokens)
            values = tokens{1};
            T1 = str2double(values{1});
            S1 = str2double(values{2});
            S2 = str2double(values{3});
            Score = str2double(values{4});
            % Write the extracted values to the output file
            fprintf(fid_out, 'T1: %.2f\nS1: %.2f\nS2: %.2f\nScore: %.2f\n', T1, S1, S2, Score);
        end
    end
end

% Close the files
fclose(fid_in);
fclose(fid_out);
