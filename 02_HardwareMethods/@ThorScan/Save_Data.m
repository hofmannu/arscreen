% File:     Save_Data.m @ thorscan
% Author:   Urs Hofmann
% Date:     09. Apr 2018
% Version:  1.0
% Mail:     urshofmann@gmx.net

% Description: Saves the data of the scan to a folder.

function Save_Data(thorscan)

  if thorscan.sett.saveData == 1

    fprintf('[ThorScan] Saving processed data to file.\n');

    % Results = thorscan.Results;
    % save(thorscan.ScanSettings.procPath, 'Results', '-nocompression');
    % clear Results;

    % ScanSettings = thorscan.ScanSettings;
    % save(thorscan.ScanSettings.procPath, 'ScanSettings', '-append', '-nocompression');

    % try
    %   figResults = thorscan.outputFigure;
    %   print(figResults, thorscan.ScanSettings.imagename, '-dpng');
    %   clear figResults;
    % catch
    %   warning('Could not save figure since it was already closed by user.');
    % end

  else
    warning('[ThorScan] Not saving data since flag is off.');
  end

end
  