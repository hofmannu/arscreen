% File: Print_Progress.m @ FastScanHuge
% Author: Urs Hofmann
% Mail: urshofmann@gmx.net
% Date: 24th July 2018

% Description: Prints the current progress of the scan

function Print_Progress(thorscan, yi, scanTimer)

  tElapsed = toc(scanTimer);
  donePercent = yi / double(thorscan.nY) * 100;
  remainingTime = tElapsed / donePercent * (100 - donePercent);

  thorscan.progressText = ['[ThorScan] Line: ', num2str(yi), ' / ', ...
    num2str(thorscan.nY), ' (', num2str(donePercent,2), ...
    ' Precent). Remaining time: ', num2str(floor(remainingTime/60)), ' min ', ...
    num2str(remainingTime-floor(remainingTime/60)*60, 2), ' s.\n'];
  
  fprintf(thorscan.progressText);

end
