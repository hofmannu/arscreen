% File: Compensate_Pd_Signal.m @ thorscan
% Author: Urs Hofmann
% Date: 28.08.2018
% Version: 1.0
% Mail: hofmannu@student.ethz.ch

% Description: Function is used to compensate for the fluctuations of the laser per pulse energy measured by the photodiode.

function Compensate_Pd_Signal(thorscan)

  if thorscan.ScanSettings.doPDComp == 1
    fprintf('[ThorScan] Process PD dataset...\n');
    % Calculate normalized max Pd signal (will be replaced by Johannes procedure as soon as his class is ready)
      thorscan.Results.pdSignalFactor(:,:) = max(abs(fast_hilbert_matrix(squeeze(thorscan.RawDataPd(:,:,:)), 'parallel')), [], 3);
      meanPdSignal = mean(thorscan.Results.pdSignalFactor(:));
      thorscan.Results.pdSignalFactor(:,:) = ...
        thorscan.Results.pdSignalFactor(:,:) / meanPdSignal; % normalized to mean
  else
    nX = size(thorscan.RawDataUs, 1);
    nY = size(thorscan.RawDataUs, 2);
    thorscan.Results.pdSignalFactor = ones(nX, nY);
  end

end
