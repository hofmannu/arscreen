% File: ScreeningStation.m @ ScreeningStation
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 14.12.2021

% Description: Main hardware container containing all interfacing

classdef ScreeningStation < handle

	properties
		FastStage(1, 1) = ThorlabsStage('stageId', get_com_port('FastStage'));
		SlowStage(1, 1) = ThorlabsStage('stageId', get_com_port('SlowStage'));
		% zStage(1, 1) = ThorlabsZStage();
		FLCamera(1, 1) = uEyeCam();
		% FLStage(1, 1) = Stage_RSPro();
		DAQ(1, 1) = M4DAC16();
		Trigger(1, 1) = TeensyCommunicator();
		Cascader(1, 1) = CascadeCommunicator();

		% here we need all the lasers at some point
	end

	properties(Dependent)
		pos(1, 4) single; % position of stages: x, y, z, fl  

	end

	methods



		% define total position
		function pos = get.pos(ss)
			pos = zeros(1, 4, 'single');
			pos(1) = ss.FastStage.pos;
			pos(2) = ss.SlowStage.pos;
			pos(3) = ss.zStage.pos;
			pos(4) = ss.FLStage.pos;
		end

		function set.pos(ss, pos)
			ss.FastStage.pos = pos(1);
			ss.SlowStage.pos = pos(2);
			ss.zStage.pos = pos(3);
			% missing FL stage so far
		end
	end

end