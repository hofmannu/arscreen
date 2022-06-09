function Prepare_Hardware(rs, A)

	% push mass of fast moving stage over
	A.FastStage.mass = rs.mass;

	% Prepare DAC
	% reset dac
	if A.DAQ.isConnected
	  A.DAQ.Close_Connection();
	end
	A.DAQ.Connect();
	A.DAQ.Reset();

	A.DAQ.sensitivityPd = rs.sensitivityUs;
	A.DAQ.sensitivityUs = rs.sensitivityPd;
	A.DAQ.dataType = 0; % 0: int16, 1: single
	A.DAQ.samplingRate = rs.df;

	% Setup external trigger mode
	externalTrigger.extMode = 1;
	externalTrigger.trigTerm = 1;
	externalTrigger.pulseWidth = 0;
	externalTrigger.singleSrc = 1;
	externalTrigger.extLine = 0; % is 0 for the new microscope and 1 for the old microscope
	externalTrigger.extLevel = 2000;
  externalTrigger.acCoupling = 0;
	A.DAQ.externalTrigger = externalTrigger;

	memsamples = uint64(rs.nSamples);
	multiMode = struct(...
	  'chMaskH',      0,  ...
	  'chMaskL',      3,  ...
	  'memsamples', memsamples * uint64(rs.nAverages),  ...
	  'segmentsize',  memsamples, ...
	  'postsamples', memsamples - 16); % [bytes]
	A.DAQ.multiMode = multiMode;
	A.DAQ.Setup_Multi_Mode();

	% stop prevoius events on cascade and trigger
	A.Cascader.Stop;
	A.Trigger.Stop;
	pause(0.2);

	% Set trigger
	A.Trigger.triggerType = 'f';
	A.Trigger.triggerFreq = rs.prf;
	A.Trigger.nShots = 0;
	A.Trigger.Initialize();

	% set cascader
  pause(0.2);
  A.Cascader.wavelengths = rs.wavelengths;
  A.Cascader.tAcquire = 6;
  A.Cascader.Calculate();
  A.Cascader.Initialize();

end