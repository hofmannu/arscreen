% File: SNRScope.m @ SNRScope
% Author: Johannes Rebling, Urs Hofmann
% Date: 21. Juni 2018
% Version: 3.1

% Description: Simple SNRScope used to estimate signal-to-noise ratio, calibrate
% z levels and so on.

classdef SNRScope < handle

  properties
    nAverages uint32 {mustBeNonnegative} = 1; % number of averages for each measurement
    filterFreq double = [0.5e6 60e6]; % for band-pass filter [Hz]
        % if isempty filterFreq we will not filter, otherwise lowercutoff, highercutoff
    df(1, 1) uint32 {mustBeNonnegative} = 250e6; % sampling rate of recorded signal [HZ]
    prf uint32 {mustBeNonnegative} = 100; % pulse repition frequency [Hz]
    sensitivityPd uint16 {mustBeNonnegative} = 10000; % sensitivity of PD channel [mV]
    sensitivityUs uint16 {mustBeNonnegative}  = 1000; % us channel sensitivity [mV]
    nSamples(1, 1) uint32 {mustBeNonnegative} = 3200; % number of samples to acquire [1]   
    temp(1, 1) double = 23; % T of coupling medium for improved z accuarcy [degCels]
    wavelengths(1, :) uint16 {mustBeNonnegative} = [532, 1064];
    usCrop(1, 2) uint32 {mustBePositive} = [500, 2500];
    pdCrop(1, 2) uint32 {mustBePositive} = [1, 500];
    flagVerbose(1, 1) logical = 1;
    SOS_WATER(1, 1) double = 1495; % assumed speed of sound in water [m/s]
  end

  properties (SetAccess = private, Hidden)
    color; % array holding the color definitions of the different plots
    fig; % handle for figure
    zVector(1, :) double; % converts samples to z distance for OA
    sigMeans;
    f(1, :) double; % vector representing frequencies for f-domain plot
    P1 double; % Result of FFT
    P1mean double; % averaged result of FFT
    oaSig(:, :) single; % mean oa signal after averaging [iZ, iLambda]
    pdSig(:, :) single; % mean pd signal after averaging [iZ, iLambda]
    oaFSig double; % averaged frequency domain signal
    acquiredDataUs(:, :, :) single; % raw unfiltered oa signal: [iZ, iLambda, iAverage]
    acquiredDataPd(:, :, :) single; % raw unfiltered pd signal: [iZ, iLambda, iAverage]
    a; % filter kernel
    b; % filter kernel
  end

  properties (Dependent, Hidden)
    nFFT(1, 1) uint32;
    dt(1, 1) double {mustBeNonnegative};
    nWavelengths uint8 {mustBeNonnegative};
    oaPlotRange(1, :) uint32; 
    pdPlotRange(1, :) uint32;
  end

  methods
    [calData, posData] = Run(snrscope, microscope);
    % microscope of class Microscope, linking all important hardware
    Prepare_Hardware(snrscope, microscope);
    Calculate_Distance(snrscope, microscope); % calculates zVector
    VPrintf(snrscope, txtMsg, flagName);

    % define number of samples
    function set.nSamples(ss, nSamples)
        % manual nonnegativity constraint
        if (nSamples < 1)
            warning("Number of samples cannot be smaller then 1, setting to 1");
            nSamples = 1;
        end

        nSamples = uint16(nSamples);

        % check if usCrop is lower then nSamples, if so adjust it
        if (ss.usCrop(2) > nSamples)
            ss.usCrop(2) = nSamples;
        end
        
        ss.nSamples = nSamples;
    end

    % define pulse repitition frequency
    function set.prf(ss, prf)
        if (prf <= 0)
            warning("Pulse repitition frequency cannot be smaller or equal 0");
            prf = 1;
        end
        ss.prf = prf;
    end

    % define number of averages which should be acquired in scan
    function set.nAverages(ss, nAverages)
        if (nAverages < 1)
            warning("Number of averages cannot be below 1.");
            nAverages = 1;
        end
        ss.nAverages = uint32(round(nAverages));
    end

    % define sensitivity on ultrasound channel
    function set.sensitivityUs(ss, sensUs)
        optionsVals = int16([200, 500, 1000, 2000, 5000, 10000]);
        if any(~(int16(sensUs) - optionsVals))
            ss.sensitivityUs = sensUs;
        else
            warning('Invalid sensitivity value, rounding to closest match.');
            [~, idx] = min(abs(int16(sensUs) - optionsVals));
            ss.sensitivityUs = optionsVals(idx);
        end    
    end

    % define sensitivity on photodiode channel
    function set.sensitivityPd(ss, sensPd)
        optionsVals = int16([200, 500, 1000, 2000, 5000, 10000]);
        if any(~(int16(sensPd) - optionsVals))
            ss.sensitivityPd = sensPd;
        else
            warning('Invalid sensitivity value, rounding to closest match.');
            [~, idx] = min(abs(int16(sensPd) - optionsVals));
            ss.sensitivityPd = optionsVals(idx);
        end 
    end

    function pdPlotRange = get.pdPlotRange(ss)
        pdPlotRange = ss.pdCrop(1):ss.pdCrop(2);
    end

    % element size in time direction
    function dt = get.dt(ss)
        dt = 1 / double(ss.df);
    end

    function nWavelengths = get.nWavelengths(ss)
        nWavelengths = length(ss.wavelengths);
    end

    function zVector = get.zVector(ss)
        if (ss.flagUs == 0)
            zVector = double(ss.oaPlotRange - 1) .* ss.dt .* ss.SOS_WATER * 1e3;
        else
            zVector = double(ss.oaPlotRange - 1) .* ss.dt .* ss.SOS_WATER * 1e3 / 2;   
        end
    end

    function oaPlotRange = get.oaPlotRange(ss)
        oaPlotRange = ss.usCrop(1):ss.usCrop(2);
    end

    function nFFT = get.nFFT(ss)
        nCrop = ss.usCrop(2) - ss.usCrop(1) + 1;
        nFFT = 2^nextpow2(ss.nSamples); 
    end
  end

end