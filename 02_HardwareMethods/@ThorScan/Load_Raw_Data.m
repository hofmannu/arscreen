% File: Load_Data.m @ thorscan
% Author: Urs Hofmann
% Date: 29.08.2018
% Version: 1.0
% Mail: hofmannu@student.ethz.ch

% Description: Loads data from a previous thorscan to the current one. Allows to use postprocessing
% functions or saving data with a different format.

function Load_Raw_Data(thorscan, filePath)

  if isfile(filePath)

    fprintf('[ThorScan] Loading data from file... ');

    mFile = matfile(filePath, 'Writable', false);
    
    if 
    thorscan.sett = mFile.ScanSettings;
    thorscan.RawDataUs = mFile.RawDataUs;
    if ndims(thorscan.RawDataUs) == 4
      thorscan.RawDataUs = permute(thorscan.RawDataUs, [4, 3, 1, 2]);
      [nT, nAv, nX, nY] = size(thorscan.RawDataUs)
      thorscan.RawDataUs = reshape(thorscan.RawDataUs, [nT, 1, nAv, nX, nY]);
    end
    thorscan.RawDataPd = mFile.RawDataPd;

    % redefine all paths
    thorscan.Paths.rawPath = filePath;


    thorscan.Define_Geometry();


    fprintf('done!\n');
  else
    error('Specified path is not pointing to a file');
  end

end
