function Read_Settings(rs)

	ScanSettings = rasterscan_settings();

	rs.name = ScanSettings.name;

	% defining geometry of scan area
	rs.center = ScanSettings.center;
	rs.dr = ScanSettings.dr;
	rs.width = ScanSettings.width;

	% sampling frequency of DAC
	rs.df = ScanSettings.df;

	rs.nSamples = ScanSettings.nSamples;
	rs.nAverages = ScanSettings.nAverages;

	rs.sensitivityUs = ScanSettings.sensitivityUs; % [mV]
	rs.sensitivityPd = ScanSettings.sensitivityPd; % [mV]
	rs.prf = ScanSettings.prf;

	rs.mass = ScanSettings.mass; % [g]

	rs.wavelengths = ScanSettings.wavelengths;

	rs.usCrop = ScanSettings.usCrop;

	rs.flagKeepAv = ScanSettings.flagKeepAv; % should we keep unaveraged signals
 
end