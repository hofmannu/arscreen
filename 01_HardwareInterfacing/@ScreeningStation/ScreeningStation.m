% File: ScreeningStation.m @ ScreeningStation
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 14.12.2021

% Description: Main hardware container containing all interfacing

classdef ScreeningStation < handle

	properties
		% FastStage(1, 1) = ThorlabsStage();
		% SlowStage(1, 1) = ThorlabsStage();
		zStage(1, 1) = ThorlabsZStage();
		FLCamera(1, 1) = uEyeCam();
		DAQ(1, 1) = M4DAC16();
	end


	methods

	end

end