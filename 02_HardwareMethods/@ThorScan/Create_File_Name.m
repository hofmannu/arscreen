% File: Create_File_Name.m @ thorscan
% Author: Urs Hofmann
% Date: 29.08.2018
% Version: 1.0
% Mail: hofmannu@student.ethz.ch

% Description: Creates the file names for the current measurement.

function Create_File_Name(ts)

  path_measurements = create_today_folder('C:\PAM_SCANS\');
  count = get_today_scan_count(); % get increasing scan numbers for every day
  countrStr = num2str(count, '%03i');

  % path to raw dataset
  ts.Paths.rawPath = [path_measurements, countrStr, '_', ...
    ts.sett.scanName, '_raw.mat'];

  % Path to processed dataset
  ts.Paths.procPath = [path_measurements, countrStr, '_', ...
    ts.sett.scanName, '_proc.mat'];

  % Path to image
  ts.Paths.imagename = [path_measurements, countrStr, '_', ...
    ts.sett.scanName, '.png'];

end
