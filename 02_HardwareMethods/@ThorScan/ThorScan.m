% File:     thorscan.m @ thorscan
% Author:   Urs Hofmann
% Date:     27. Feb 2018
% Version:  2.2

% Description: This class should be used to perform a fast scan over a very
% broad window of 50 to 50 mm.

% Changelog:
%   - moved plotting to separate function
%   - include averaging at multiple wavelengths

classdef ThorScan < GeneralScan

  properties
    % sett(1, 1) ScanSettings;
    % Default setting is to read the settings from the file, will be overwritten
    % by some other functions

    Paths;
    PostProSettings;

    RawDataTemp; % Matrix used to store data between line scans
    %RawDataUs int16; % full raw data us, order: z / t, lambda, x, y
    %RawDataPd int16; % full raw data pd, order: z / t, lambda, x, y
    tPoints(:, :, :, :) single; % store timepoints of each trigger event, order: lambda, x, y
    tBScan(1, :) single;
    filteredData(:, :, :, :) single; % prefiltered data, z / t, lambda, x, y 
    Results = struct(); % struct used to store postprocessed results
    %xVec(1, :) double; % x vector in mm (fast stage direction)
    %yVec(1, :) double; % y vector in mm (slow stage direction)
    %zVec(1, :) double; % z vector in mm
    %tVec(1, :) double; % time vector in s
    %flagVerbose(1, 1) logical = 1; % enable / disable verbose output
    %flagPreview(1, 1) logical = 1; % enable / disable scan result preview
    % nAverages(1, 1) uint32 {mustBePositive} = 1; % number of averages at each position
  end

  properties (Hidden)
    temp; % varibale used for debugging etc
    progressText = '';
    outputFigure;
  end

  properties (Dependent, Hidden)
    nShotsB uint32; % number of a scans during a single b scan
    nSamplesB uint32; % number of samples acquired during a single b scan
    dZ(1, 1) double; % step size in z direction in mm
  end

  methods

   function nShotsB = get.nShotsB(ts) % number of a scans in bscan
      nShotsB = uint32(ts.nX) * uint32(ts.sett.nLambda) * uint32(ts.sett.nAverages);
    end

    function nSamplesB = get.nSamplesB(ts) % number of samples during b scan
      nSamplesB = ts.nShotsB * uint32(ts.nZ);
    end

    function dZ = get.dZ(ts) % step size in z direction
      if (length(ts.zVec) > 2)
        dZ = abs(ts.zVec(2) - ts.zVec(1));
      else
        dZ = NaN;
      end
    end

  end
end