% File:     Prepare_Hardware.m @ thorscan
% Date:     27. Feb 2018
% Author:   Urs Hofmann
% Mail:     hofmannu@biomed.ee.ethz.ch

% Description: Prepare all the hardware required for thorscan

% Changelog:
%   - included support for on the fly averaging

function Prepare_Hardware(ts, m)

  % % open connection to data acquisition card and reset
  % if m.DAQ.isConnected
  %   m.DAQ.Close_Connection();
  % end
  % m.DAQ.Connect();

  % m.DAQ.Reset();

  % m.Trigger.Stop(); % stop running processes on position based trigger board
  % m.Cascader.Stop(); % stop any running processes on cascade board
  % % m.FastStage.mass = ts.sett.mass(1);
  m.FastStage.vel = ts.sett.vel(1); % set vel of fast stage
  m.FastStage.backlash = 0;

  ts.VPrintf('Moving stages to starting position.\n', 1)
  m.FastStage.pos = ts.xVec(1); % Move fast stage to initial position
  m.SlowStage.pos = ts.yVec(1); % move slow stage to starting position

  % ts.VPrintf('Preparing trigger board... ', 1);
  % m.Trigger.Reset_Counter();
  % m.Trigger.triggerType = 's';
  % m.Trigger.triggerSteps = ts.sett.dr(1) * 1000;
  % m.Trigger.nShots = ts.nX;
  % m.Trigger.Initialize();
  % ts.VPrintf('done!\n', 0);

  % ts.VPrintf('Preparing cascade board...', 1);
  % m.Cascader.wavelengths = ts.sett.wavelengths;
  % m.Cascader.tAcquire = ts.tVec(end) * 1e6; % acquisition / lambda / average in [micros]

  % if (ts.sett.nAverages > 1)
  %     tMin = 1 / ts.sett.maxPRF * 1e6; % in micros
  %     if ((m.Cascader.tAcquire * ts.sett.nLambda) <= tMin)
  %       m.Cascader.tAcquire = tMin / ts.sett.nLambda;
  %       warning("Limiting acquisition speed due to averaging");
  %     end
  % end
  % % add another micros to make sure we have no overlap
  % m.Cascader.nAverages = ts.sett.nAverages;
  % m.Cascader.nShots = ts.nX;
  % m.Cascader.Calculate();

  % deltaTMin = ts.sett.dX / ts.sett.vel(1) * 1e6; % deltat btw 2 events
  % if (deltaTMin < m.Cascader.tMax) % check if we can fit our cascade into this
  %   error('Cannot run this scan pattern since trigger cascade takes too long.');
  % end

  % if (single(m.Cascader.tMax) * single(ts.sett.nAverages) * 1e-6) > (ts.sett.dX / ts.sett.vel(1)) 
  %   deltaT = m.Cascader.tMax * ts.sett.nAverages * 1e-6;
  %   maxVel = ts.sett.dX / deltaT;
  %   fprintf("Expected maximum velocity: %f", maxVel);
  %   error('Too fast for averaging broh');

  % end

  % m.Cascader.Initialize();
  % m.Cascader.SetN();
  ts.VPrintf('done!\n', 0);

  % Setup external trigger mode
  % externalTrigger = ExternalTrigger();
  % externalTrigger.extMode = 1; 
  % 1 means trigger detection for rising edges
  % 2 means trigger detection for falling edges
  % % 4 means trigger detection for rising and falling edges
  % externalTrigger.trigTerm = 1; 
  % % should trigger be terminated? 0 = high impedance termination, 1 = 50 ohm termination
  % externalTrigger.pulseWidth = 0;
  % externalTrigger.singleSrc = 1;
  % externalTrigger.extLine = 0; % defines the trigger line (0: sma, 1: MMCX)
  % externalTrigger.extLevel = 1750; % [mV]
  % externalTrigger.acCoupling = 0;
  % m.DAQ.externalTrigger = externalTrigger;

  % PdSettings = Channel();
  % PdSettings.path = 1; % 0 = buffered, 50 ohm or 1 Mohm term;  1 = HF, 50 ohm term;
  % PdSettings.inputrange = ts.sett.sensitivityPd; % ±500 mV, ±1000 mV, ±2500 mV, ±5000 mV
  % PdSettings.term = 1;
  % PdSettings.acCpl = 0;
  % PdSettings.inputoffset = 0;
  % PdSettings.bwLim = 0;
  % m.DAQ.Setup_Analog_Input_Channel(m.pdChannel, PdSettings);

  UsSettings = Channel();
  UsSettings.path = 1; % 0 = buffered, 50 ohm or 1 Mohm term;  1 = HF, 50 ohm term;
  UsSettings.inputrange = ts.sett.sensitivityUs; % ±500 mV, ±1000 mV, ±25000 mV, ±5000 mV
  UsSettings.term = 1; % 1 = 50 Ohm, 0 = high impedance (only when path = )
  UsSettings.acCpl = 0;
  UsSettings.inputoffset = 0;
  UsSettings.bwLim = 0;
  % m.DAQ.Setup_Analog_Input_Channel(m.usChannel, UsSettings);

  % m.DAQ.dataType = 0; % 0 int16, 1 single 
  % m.DAQ.samplingRate = ts.ScanSettings.samplingFreq;

  % if you want to use a dac delay: this is the correct place to set the value
  % m.DAQ.delay = ts.sett.delayDac;

  % m.DAQ.FiFo = FiFoSettings();
  % m.DAQ.FiFo.nShots = uint32(ts.sett.nLambda) * uint32(ts.nX) * ...
  %   uint32(ts.sett.nAverages);
  % m.DAQ.FiFo.shotSize = uint32(ts.sett.nSamples);
  % m.DAQ.FiFo.shotSizePd = uint32(ts.sett.nSamples);
  % m.DAQ.FiFo.nChannels = uint32(2);
  % m.DAQ.FiFo.Set_shotsPerNotify();
  % ts.sett.nSamples = m.DAQ.FiFo.shotSize;

  % calculate estimated time per b scan to set dac timeout
  vel = m.FastStage.vel; % mm / 2
  acc = m.FastStage.acc; % mm / s^2
  tAcc = vel / acc; % time required for one acceleration phase
  sAcc = 0.5 * acc * tAcc^2; % distance traveled in one acceleration phase
  sGes = abs(ts.xVec(end) - ts.xVec(1));
  if (sGes < (2 * sAcc))
    tGes = 2 * sqrt(2 * (sGes/2) / acc);
  else   
    sConst = sGes - 2 * sAcc;
    tGes = tAcc * 2 + sConst / vel;
  end

  % m.DAQ.timeout = ceil((tGes * 1.5 + 0.5) * 1000); % set timeout of dac
  % m.DAQ.Enable_Time_Stamps();


  % turn off verbose output
  % m.DAQ.flagVerbose = 0;
  % m.Trigger.flagVerbose = 0;
  m.FastStage.beSilent = 1;
  m.SlowStage.beSilent = 1;
end
