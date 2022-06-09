% File:       Post_Processing.m @ thorscan
% Author:     Urs Hofmann
% Mail:       hofmannu@student.ethz.ch
% Date:       29.08.2018
% Version:    1.2

% Description: Postprocesses the data acquired in the thorscan.

% Changelog:
%       UH: Added warning if DAC saturates during measurements.
%       UH: Added photodiode compensation before interpolation.
%       UH: Switched to improved filtering and interpolation algorithms

function Post_Processing(thorscan)
  
  % Get cropped zVector
  zRange = ...
    thorscan.PostProSettings.zCrop(1) - thorscan.ScanSettings.usCrop(1) : ...
    thorscan.PostProSettings.zCrop(2) - thorscan.ScanSettings.usCrop(1);

  fprintf('[ThorScan] Post-Processing.\n');

  % check for saturation
  if (max(abs(thorscan.RawDataUs(:))) >= 32767)
    warning('US channel saturated!');
  end

  % check for saturation
  if (max(abs(thorscan.RawDataPd(:))) >= 32767)
    warning('PD channel saturated!');
  end

  % Note rawDataFilterFlag indicates if datasets are already filtered
  if thorscan.Results.rawDataFilterFlag == 0
    
    % Declare full3d matrix
    thorscan.Results.full3d = zeros(...
      length(thorscan.ScanSettings.x)-thorscan.ScanSettings.missedX, ...
      length(thorscan.ScanSettings.y), ...
      thorscan.ScanSettings.nSamples);
  
    % Compensate for laser fluctuations by taking the photodiode signal into account
    thorscan.Compensate_Pd_Signal();

    % Frequency based filtering
    if thorscan.PostProSettings.flagFreqFiltering
      fprintf('[ThorScan] Frequency domain filtering.\n');
      tic
      thorscan.Results.full3d = temporal_frequency_filtering(...
          thorscan.RawDataUs, ...
          thorscan.PostProSettings.filterFreq, 'vector');
      toc
    end
  
    % Hilbert transformation of signal
    if thorscan.PostProSettings.flagHilbert
      fprintf('[ThorScan] Hilbert transformation of signal.\n');
      tic
      thorscan.Results.full3d = fast_hilbert_matrix(thorscan.Results.full3d, 'vector');
      toc
    end
    
    % flip every second line
    thorscan.Results.full3d(:,2:2:end,:) = flipud(thorscan.Results.full3d(:,2:2:end,:));
    
    thorscan.Results.rawDataFilterFlag = 1;
    thorscan.Results.mipz = max(abs(squeeze(thorscan.Results.full3d(:,:,zRange))), [], 3);
  
  end

  % Get cropped zVector
  % plot_this_3d(...
  %   squeeze(thorscan.Results.full3d(:,:,zRange)), ...
  %   thorscan.xVec, ...
  %   thorscan.yVec, ...
  %   thorscan.zVec(zRange), ...
  %   'Title', 'Final plots - thorscan', ...
  %   'OutputPath', thorscan.ScanSettings.imagename);

end
