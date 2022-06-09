function ScanSettings = rasterscan_settings()

	ScanSettings.name = 'chip_circuit';

	ScanSettings.center = [30, 18.5]; % [mm]
	ScanSettings.dr = [0.025, 0.025]; % [mm]
	ScanSettings.width = [5, 5]; % [mm]
	
	ScanSettings.df = 125e6;

	ScanSettings.nSamples = 10e3;
	ScanSettings.nAverages = 100;

	ScanSettings.sensitivityUs = 2000;
	ScanSettings.sensitivityPd = 2000;
	ScanSettings.prf = 5e3;

	ScanSettings.mass = 50;

	ScanSettings.wavelengths = 1064;

	ScanSettings.usCrop = [400, ScanSettings.nSamples];

	ScanSettings.flagKeepAv = 0;

end