% File: Read_Settings.m @ thorscan
% Author: Urs Hofmann
% Date: 20.08.2018
% Mail: hofmannu@student.ethz.ch

% Description: Reads the settings from file if readSettingsFlag is enabled and checks their
% validity

function Read_Settings(thorscan)

  if thorscan.sett.flagReadSettings
    thorscan.VPrintf('Reading settings from file.\n', 1) % 1 is the flagName
    [thorscan.sett, thorscan.PostProSettings] = thorscan_settings(); %get all the setting from file"thorscan_settings"

    nSamples = thorscan.sett.nSamples;
    if (rem(nSamples - 512, 16) > 0) %Find the remainder after division, change Samples automatically
        warning('nSamples not valid, adapting it to next value');
        n = ceil((nSamples - 512) / 16);
        thorscan.sett.nSamples = 512 + n * 16;
    end

    % Check if nsamples is valid
    if rem(thorscan.sett.nSamples, 16)
    	error("nSamples must be a multifold of 16.");
    end

    if (thorscan.sett.usCrop(2) > thorscan.sett.nSamples)
    	error("Upper limit of usCrop is larger then number of samples");
    end

    % if prf would result in a higher value then maximum allowable prf
    if (thorscan.sett.maxPRF < (thorscan.sett.vel(1) / thorscan.sett.dr(1)))
        error("Cannot start scan since we would have higher PRF than allowed.");
    end

    % check if field of view matches with max stage range
    if any((thorscan.sett.ctr - thorscan.sett.width / 2) < 0)
        error("Your settings are hitting the negative limit of the stage.");
    end

    if any((thorscan.sett.ctr + thorscan.sett.width / 2) > 50)
        error("Your settings are hitting the positive limit of the stage")
    end

    % check if we can do all averages right is done in Prepare_Hardware.m

  else
    thorscan.VPrintf('Not reading settings from file.\n', 1);
  end


end
