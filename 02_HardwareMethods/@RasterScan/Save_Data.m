function Save_Data(rs)

	fprintf('[RasterScan] Saving data... ');

	path_measurements = create_today_folder('C:\PAM_SCANS\');
	count = get_today_scan_count();
	countrStr = num2str(count,'%03i');
	rawPath = [path_measurements, countrStr, '_', rs.name, '_raw.mat'];

	% save averaged data for sure
	MeanDataUs = rs.MeanDataUs;
	save(rawPath, 'MeanDataUs', '-nocompression', '-v7.3');
	clear MeanDataUs;

	MeanDataPd = rs.MeanDataPd;
	save(rawPath, 'MeanDataPd', '-append');
	clear MeanDataPd;

	if rs.flagKeepAv % only save full raw data if necessary
		RawDataUs = rs.RawDataUs;
		save(rawPath, 'RawDataUs', '-append');
		clear RawDataUs;

		if ~rs.flagUs
			RawDataPd = rs.RawDataPd;
			save(rawPath, 'RawDataPd', '-append');
			clear RawDataPd;
		end
	end


	ScanSettings.xVec = rs.xVec;
	ScanSettings.yVec = rs.yVec;
	save(rawPath, 'ScanSettings', '-append');
	clear ScanSettings;

	fprintf('done!\n');

end