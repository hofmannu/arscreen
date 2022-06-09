% File: Prepare_Hardware @ SNRScope
% Author: Urs Hofmann
% Date: 19.09.2018
% Mail: hofmannu@student.ethz.ch

% Description: Prepares the hardware for the SNRScope.

function Prepare_Hardware(snrscope, microscope)

  % reset dac
  if microscope.DAQ.isConnected
    microscope.DAQ.Close_Connection();
  end
  microscope.DAQ.Open_Connection();
  microscope.DAQ.Reset();

  % Set trigger (in this case on this PC we talk to position based trigger)
  microscope.Trigger.triggerFreq = snrscope.prf;
  microscope.Trigger.trigPin = 2; % define output pin
  microscope.Trigger.nShots = 0;
  microscope.Trigger.flagVerbose = 0;
  
  % set cascader
  microscope.Cascader.wavelengths = snrscope.wavelengths;
  microscope.Cascader.tAcquire = single(snrscope.nSamples) * snrscope.dt * 2e6;
  microscope.Cascader.nAverages = 1;
  microscope.Cascader.Calculate();
  microscope.Cascader.Initialize();
  microscope.Cascader.Set_Input_Pin(16);

  microscope.DAQ.dataType = 1; % data type acquisition
  microscope.DAQ.samplingRate = snrscope.df; % set dac sampling rate [Hz]
  microscope.DAQ.timeout = 10e3; % define data acquisition card timeout [ms]
  microscope.DAQ.delay = 0;

  memsamples = uint64(snrscope.nSamples) * ...
    uint64(snrscope.nAverages) * uint64(snrscope.nWavelengths);
  multiMode = struct(...
    'chMaskH', 0,  ...
    'chMaskL', 3,  ...
    'memsamples', memsamples,  ...
    'segmentsize',  snrscope.nSamples, ...
    'postsamples', snrscope.nSamples - 16); % [bytes]
  microscope.DAQ.multiMode = multiMode;
  microscope.DAQ.Setup_Multi_Mode();

  % Setup external trigger mode
  externalTrigger = ExternalTrigger();
  externalTrigger.extMode = 1; % 1 for positive edges
  externalTrigger.trigTerm = 0; % 1: 50 Ohm termination, 0: 1 or 10 kOhm
  externalTrigger.pulseWidth = 0;
  externalTrigger.singleSrc = 1;
  externalTrigger.extLine = 0; % is 0 for the new microscope and 1 for the old microscope
  microscope.DAQ.externalTrigger = externalTrigger;

  PdSettings = Channel();
  PdSettings.path = 0; % 0 = buffered, 50 ohm or 1 Mohm term;  1 = HF, 50 ohm term;
  PdSettings.inputrange = snrscope.sensitivityPd; % ±500 mV, ±1000 mV, ±2500 mV, ±5000 mV
  PdSettings.term = 0;
  PdSettings.acCpl = 0;
  PdSettings.inputoffset = 0;
  PdSettings.bwLim = 0;

  UsSettings = Channel();
  UsSettings.path = 0; % 0 = buffered, 50 ohm or 1 Mohm term;  1 = HF, 50 ohm term;
  UsSettings.inputrange = snrscope.sensitivityUs; % ±500 mV, ±1000 mV, ±25000 mV, ±5000 mV
  UsSettings.term = 0; % 1 = 50 Ohm, 0 = high impedance (only when path = )
  UsSettings.acCpl = 0;
  UsSettings.inputoffset = 0;
  UsSettings.bwLim = 0;

  microscope.DAQ.Setup_Analog_Input_Channel(microscope.usChannel, UsSettings);
  microscope.DAQ.Setup_Analog_Input_Channel(microscope.pdChannel, PdSettings);

end
