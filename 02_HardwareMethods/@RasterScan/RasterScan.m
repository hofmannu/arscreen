% File: RasterScan.m @ RasterScan
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Version: 1.0

classdef RasterScan < handle

	properties(SetAccess = private)
		name(1, :) char = 'unnamed';
		RawDataUs(:, :, :, :) int16; % [iz/it, iAverage, iX, iY]
		RawDataPd(:, :, :, :) int16; % [iz/it, iAverage, iX, iY]
		MeanDataUs(:, :, :) int16;
		MeanDataPd(:, :, :) int16;
		dr(1, 2) single = [0.1, 0.1]; % [dz, dx, dy]
		center(1, 2) single = [25, 25]; % [xCenter, yCenter]
		width(1, 2) single = [5, 5]; % [xWidth, yWidth]
		df(1, 1) uint64 = 250e6; % sampling frequency of dac
		nSamples(1, 1) uint16 = 2048; % number of samples acquired in each a scan
		nAverages(1, 1) uint16 = 1;
		sensitivityUs(1, 1) uint16 = 5000; % [mV]
		sensitivityPd(1, 1) uint16 = 10000;
		prf(1, 1) uint16 = 5e3;
		flagUs(1, 1) logical = 1; % flag defining if US
		flagKeepAv(1, 1) logical = 0;
		mass(1, 1) single = 50; % mass of transducer and holder [g]
		wavelengths(1, :) uint16 = 532;
		usCrop(1, 2) uint32 = [400, 2048];
	end

	properties(Dependent)
		dX single;
		dY single;
		dZ single;
		xVec(1, :) single;
		yVec(1, :) single;
		nX uint32; % number of pixels in x
		nY uint32; % number of pixels in y
		usPlotRange uint32;
	end

	methods

		Run(rs, A); % A is instance of ARMicroscope for hardware interfacing

		function usPlotRange = get.usPlotRange(rs)
			usPlotRange = rs.usCrop(1):rs.usCrop(2);
		end

		function dX = get.dX(rs)
			dX = rs.dr(1);
		end

		function dY = get.dY(rs)
			dY = rs.dr(2);
		end

		function nX = get.nX(rs)
			nX = floor(rs.width(1) / rs.dX) + 1;
		end

		function nY = get.nY(rs)
			nY = floor(rs.width(2) / rs.dY) + 1;
		end

		function xVec = get.xVec(rs)
			xVec = single(0:(rs.nX-1)) * rs.dX + rs.center(1) - rs.width(1) / 2;
		end

		function yVec = get.yVec(rs)
			yVec = single(0:(rs.nY-1)) * rs.dY + rs.center(2) - rs.width(2) / 2;
		end

		function set.sensitivityUs(rs, sensUs)
			if any(~(int16(sensUs) - int16([200, 500, 1000, 2000, 5000, 10000])))
				rs.sensitivityUs = sensUs;
			else
				error('Invalid sensitivity for DAC');
			end
		end

		function set.sensitivityPd(rs, sensPd)
			if any(~(int16(sensPd) - int16([200, 500, 1000, 2000, 5000, 10000])))
				rs.sensitivityPd = sensPd;
			else
				error('Invalid sensitivity for DAC');
			end
		end

	end

end