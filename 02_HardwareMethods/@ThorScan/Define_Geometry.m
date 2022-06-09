% File: Define_Geometry.m @ thorscan
% Author: Urs Hofmann
% Date: 20.09.2018
% Mail: hofmannu@biomed.ee.ethz.ch

% Description: Defines the scan geometry covered by thorscan.

function Define_Geometry(ts, microscope)

  % Calcualte region of interest
  xMin = ts.sett.ctr(1) - ts.sett.width(1) / 2; % xmin [mm]
  xMax = ts.sett.ctr(1) + ts.sett.width(1) / 2; % xmax [mm]
  yMin = ts.sett.ctr(2) - ts.sett.width(2) / 2; % ymin [mm]
  yMax = ts.sett.ctr(2) + ts.sett.width(2) / 2; % ymax [mm]

  % check if valid
  if (xMin < 0)
    error('Cannot go beyond 0 in x direction');
  end

  if (yMin < 0)
    error('Cannot go beyond 0 in y direction');
  end

  if (xMax > 50)
    error('Cannot go beyond 50 in x direction');
  end

  if (yMax > 50)
    error('Cannot go beyond 50 in y direction');
  end

  % Create x and y vectors
  ts.xVec = xMin:ts.sett.dr(1):xMax;
  ts.yVec = yMin:ts.sett.dr(2):yMax;

  % create time vector
  dt = 1 / ts.sett.samplingFreq; % temporal resolution
  ts.tVec = (0 : (single(ts.sett.nSamples) - 1)) * dt; % define t vector
  ts.zVec = ts.tVec * getSpeedOfSound(ts.sett.temp); % define z
  
end
 