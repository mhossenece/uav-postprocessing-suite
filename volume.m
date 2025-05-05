%--------------------------------------------------------------------------
% Script: volume.m
%
% Description:
% This script parses a UAV controller log file ('controller_log.txt') to extract
% data volume values assigned to each base station. It uses regular expressions
% to identify download volume entries like `'1': 1000.00`, `'2': 1000.00`, etc.,
% and saves them as a numeric array in:
%   - Output: 'volume.txt'
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

inputFile = 'controller_log.txt';
outputFile = 'volume.txt';

% Read the entire content of the log file
fileContent = fileread(inputFile);

% Define a regular expression pattern to match volume values
pattern = '''\d+'':\s*([\d.]+)';

% Extract all matches of the pattern
matches = regexp(fileContent, pattern, 'tokens');

% Convert the extracted strings to numeric values
volumes = cellfun(@(x) str2double(x{1}), matches);

% Write the volume values to the output file
writematrix(volumes, outputFile);
