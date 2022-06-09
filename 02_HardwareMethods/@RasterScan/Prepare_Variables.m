function Prepare_Variables(rs)

	fprintf('[RasterScan] Allocating memory... ');
	rs.MeanDataUs = zeros(rs.nSamples, rs.nX, rs.nY, 'single');
	if rs.flagKeepAv
		rs.RawDataUs = zeros(rs.nSamples, rs.nAverages, rs.nX, rs.nY, 'int16');
	end

	if ~(rs.flagUs)
		rs.MeanDataPd = zeros(rs.nSamples, rs.nX, rs.nY, 'single');
		if rs.flagKeepAv
			rs.RawDataPd = zeros(rs.nSamples, rs.nAverages, rs.nX, rs.nY, 'int16');
		end
	else
		rs.RawDataPd = [];
		rs.MeanDataPd = [];
	end

	fprintf('done!\n');

end