% File: Prepare_Variables.m @ SNRScope
% Author: Urs Hofmann
% Date: 19.09.2018
% Mail: hofmannu@student.ethz.ch

% Description: Prepares the variables for the scope.

function Prepare_Variables(ss)

  fprintf('[SNRScope] Preparing variables... ');

  % declare matrix for filteredDataUs
  ss.acquiredDataUs = zeros(...
    ss.nSamples, ...
    ss.nWavelengths, ...
    ss.nAverages, 'single');

  ss.acquiredDataPd = zeros(...
    ss.nSamples, ...
    ss.nWavelengths, ...
    ss.nAverages, 'single');

  ss.oaSig = zeros(ss.nSamples, ss.nWavelengths, 'single');
  ss.pdSig = zeros(ss.nSamples, ss.nWavelengths, 'single');

  ss.P1 = zeros(...
    ss.nWavelengths, ...
    ss.nFFT / 2 + 1);

  % Frequency related variables
  ss.f = double(ss.df) * (0: (double(ss.nFFT) / 2)) / double(ss.nFFT);

  for iLambda = 1:ss.nWavelengths
    ss.color{iLambda} = wavelength2color(...
      ss.wavelengths(iLambda), ...
      'outColor', [1, 1, 1]);
  end

  if ~isempty(ss.filterFreq)
    [ss.b, ss.a] = butter(1, (ss.filterFreq / (double(ss.df) / 2)),'bandpass');
  else
    warning('Frequency filtering deactivated');   
  end
  fprintf('done!\n');

end
