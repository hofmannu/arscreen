% File: GeneralScan.m @ GeneralScan
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 22.03.2021

% Description: Desbribes the properties scans share in common

classdef GeneralScan < handle

	properties
		sett(1, 1) ScanSettings;
		flagVerbose(1, 1) logical = 1; % enable / disable verbose output
		flagPreview(1, 1) logical = 0;

		RawDataUs int16;
		RawDataPd int16;

		xVec(1, :) double;
		yVec(1, :) double;
		zVec(1, :) double;
		tVec(1, :) double;
	end

	properties(Dependent)
		nX(1, 1) uint32; % number of elements in x direction
		nY(1, 1) uint32; % number of elements in y direction
		nZ(1, 1) uint32; % number of elements in depth direction
	end

	methods
		function nX = get.nX(ts) % number of elements in x direction
      nX = length(ts.xVec);
    end

    function nY = get.nY(ts) % number of elements in y direction
      nY = length(ts.yVec);
    end

    function nZ = get.nZ(ts) % number of elements in z direction
      nZ = length(ts.zVec);
    end

	end

end