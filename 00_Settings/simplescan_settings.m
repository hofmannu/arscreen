function ScanSettings = simplescan_settings()
	ScanSettings.name = 'GFP3_after';
	ScanSettings.ctr = [35, 30]; % center point x y [mm], default 25 10
  ScanSettings.width = [5, 5]; % size of FOV x y [mm]
  ScanSettings.dr = [0.05 , 0.05]; % resolution x y [mm]
  ScanSettings.nAverages = 100;
  ScanSettings.nSamples = 32000;
  ScanSettings.mass = 30;
  ScanSettings.usCrop = [800, 32000];
  ScanSettings.wavelengths = 1064;
end