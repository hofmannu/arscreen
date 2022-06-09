% File: Save_Raw_Data.m @ thorscan
% Author: Urs Hofmann
% Date: 29.08.2018
% Version: 1.0
% Mail: hofmannu@student.ethz.ch

% Description: Saves settings and raw data right after the scan.

function Save_Raw_Data(thorscan)

  if thorscan.sett.flagSaveData

    fprintf('[ThorScan] Saving raw data to file.\n');
    % Get important variables out of structure

    % Save them to file
    RawDataUs = thorscan.RawDataUs; 
    RawDataPd = thorscan.RawDataPd;
    savefast(thorscan.Paths.rawPath, 'RawDataUs', 'RawDataPd');
    clear RawDataPd; clear RawDataUs;

    sett = thorscan.sett;
    save(thorscan.Paths.rawPath, 'sett', '-append', '-nocompression');
    clear sett;

    tPoints = thorscan.tPoints;
    save(thorscan.Paths.rawPath, 'tPoints', '-append', '-nocompression');
    clear tPoints;

    tBScan = thorscan.tBScan;
    save(thorscan.Paths.rawPath, 'tBScan', '-append', '-nocompression');
    clear tBScan;

  else
    warning('[ThorScan] Not saving raw data since flag is disabled');
  end

end
