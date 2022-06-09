% File:     Scan.m @ thorscan
% Author:   Urs Hofmann
% Mail:     hofmannu@biomed.ee.ethz.ch
% Date:     27. Feb 2018
% Version:  2.0

% Description: Scanning procedure for a wide field performed at a high speed w/o
% using the laser distance sensor.

function Run(thorscan, microscope)
    
  thorscan.Prepare(microscope); % Prep varibales, read settings, initialize hardware
  thorscan.Acquire(microscope); % Acquire data
  thorscan.Post_Hardware(microscope); % Post hardware
  thorscan.Create_File_Name(); % Generate file names
  thorscan.Save_Raw_Data(); % Save raw data to file

  if thorscan.sett.flagGenPreview
 		thorscan.Print_Preview();
  end
end

