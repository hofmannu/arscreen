% File: thor_scan_settings.m
% Author: Urs Hofmann
% Date: 13.11.2018
% Mail: hofmannu@student.ethz.ch

% Description: Settings for the FastScanHuge procedure.

function [scanSett, PostProSettings] = thorscan_settings()

  scanSett = ScanSettings();
  scanSett.scanName = 'pulse_echo_chip_v23'; % name of scan and resulting file
  scanSett.transducer = 'pa_50MHz'; 
  % transducer name
  % - russian_johanna_8mm
  % - pa_50MHz
  scanSett.fiber = 'none'; % type of illumination fiber
  scanSett.PPE = [0]; % approximate per pulse energy in microJ / energy lvl of transducer
  scanSett.ctr = [25, 10]; % center point x y [mm], default 25 10 
  % 25 to 32
  % reminder x pos:5A.FastStage.pos; y pos: A.SlowStage.pos 
  scanSett.width = [10, 10] %size of FOV x y [mm]
  scanSett.dr = [0.05, 0.05]; % add resolution x y [mm] 40 min
  scanSett.wavelengths = [0]; % for US just keep 0
  % specifies the used wavelenths in nm Depending on this we will initialize the laser
  % trigger cascae correspondingly. Choose wisely!
  % scanSett.laserPower = 79;
  scanSett.nAverages = 1;  % 1, 5
  scanSett.sensitivityPd = 5e3; % Adjust this value if required / not important for US
  scanSett.sensitivityUs = 5e3; % 5e3 for US measruements
  % Options: 500, 1000, 2500, 5000, 10000
  scanSett.maxPRF = 5e3; % maximum allowable pulse repition frequency for the scan  
  scanSett.vel(1) = 20; % velocity of fast moving stage (up to 500 mm/s) usually 10-50 mm/s is fast enough
  scanSett.nSamples = 2048 * 3; % 512 + n * 16
  scanSett.samplingFreq = 250e6; % sampling freq of DAC [Hz]
  scanSett.temp = 23;
  scanSett.pdCrop = [1, 250]; % not required for US
  scanSett.usCrop = [500, 2048*3];
  scanSett.usCropPreview = [2800, 5900];  
  scanSett.delayDac = 0; % [s] * [Hz]
  scanSett.mass = 100; % mass hold by fast stage in g
  scanSett.flagSaveData = 1;
  scanSett.flagPdComp = 0; % Flag to enable or disable PD compensation
  scanSett.flagReadSettings = 1;
  scanSett.flagGenPreview = 1;
  PostProSettings.flagHilbert = 1;
  PostProSettings.flagFreqFiltering = 1;
  PostProSettings.filterFreq = [1e6, 90e6];

end
