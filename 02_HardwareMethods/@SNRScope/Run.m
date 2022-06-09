% File: Run.m @ SNRScope
% Author: Urs Hofmann
% Date: 19.09.2018
% Mail: hofmannu@student.ethz.ch

% Description: Self-explaining.

function Run(ss, microscope)

  ss.Prepare_Variables();
  ss.Prepare_Hardware(microscope);

  ss.fig = figure; % initialize figure
  ss.fig.Color = [0,0,0];
  axUs = subplot(2, 2, [1 2]);

  hold on;
  % First plot for measured data
  for iWavelength = 1:ss.nWavelengths
    hOa{iWavelength} = plot(...
      1, 1, '-', ...
      'Color', ss.color{iWavelength});
    hOaMax{iWavelength} = plot([0, 0], [0, 1], 'Color', ss.color{iWavelength});
    hOaMin{iWavelength} = plot([0, 0], [0, 1], 'Color', ss.color{iWavelength});
  end

  hold off;

  axis tight
  title('Channel 1: US signal');
  xlabel('Position [mm]');
  ylabel('Signal [V]');

  hold off;
  axUs.Color = [0,0,0];
  axUs.XColor = [0.9, 0.9, 0.9];
  axUs.YColor = [0.9, 0.9, 0.9];

  % fft plot
  axFft = subplot(2, 2, 3);
  hold on
  for iSig = 1:ss.nWavelengths
    hFreq{iSig} = plot(ss.f, ss.f, 'Color', ss.color{iSig});
  end
  hold off
  % xlim([0.5e6 60e6]);
  axis tight
  title('FFT of US signal');
  xlabel('Frequency [Hz]');
  ylabel('|P|');
  axFft.Color = [0,0,0];
  axFft.XColor = [0.9, 0.9, 0.9];
  axFft.YColor = [0.9, 0.9, 0.9];

  % generate photodiode signal plot
  axPd = subplot(2,2,4);
  hold on
  axis tight
  for iSig = 1:ss.nWavelengths
    hPd{iSig} = plot(...
      (ss.pdPlotRange - 1) * ss.dt, ... % time in [s]
      ss.pdPlotRange, '-', 'Color', ss.color{iSig}); % pd signal
    hPdMax{iSig} = plot([1, 1] * ss.dt , [0, 1], 'Color', ss.color{iSig});
  end
  hold off
  title('Channel 2: PD signal')
  xlabel('Time [s]');
  ylabel('Signal intensity');
  axPd.Color = [0,0,0];
  axPd.XColor = [0.9, 0.9, 0.9];
  axPd.YColor = [0.9, 0.9, 0.9];

  textBox = uicontrol('Style', 'text', ...
    'String', 'Here is a lot more information');
  set(textBox,'Position' ,[100, 20, 150, 60]);


  iter = 0;
  % oldPos needs to store one value for each wavelength
  oldPos = zeros(1, ss.nWavelengths);
  absMax = 0;

  % generate button to allow user breaking the SNRScope
  H = uicontrol('Style', 'PushButton', ...
                    'String', 'Break', ...
                    'Callback', 'delete(gcbf)');

  drawnow();
  microscope.Cascader.Start();

  microscope.Trigger.Start();
  microscope.DAQ.flagVerbose = 0;

  while (ishandle(H))
    iter = iter + 1;

    microscope.DAQ.Start(); % make card ready for acquisition
    microscope.DAQ.Enable_Trigger();
    temp = microscope.DAQ.Acquire_Multi_Data(); % read data from card

    % Reshape into correct format
    tempUs = reshape(temp(microscope.usChannel + 1, :), ...
      [ss.nSamples, ss.nWavelengths, ss.nAverages]);
    ss.acquiredDataUs = tempUs(:, :, :);
    
    ss.acquiredDataPd = reshape(temp(microscope.pdChannel + 1, :), ...
      [ss.nSamples, ss.nWavelengths, ss.nAverages]);
    % data structure: shot samples (z), wavelength, averages

    % Check if DAQ saturates before filtering the data
    if (max(abs(ss.acquiredDataUs(:))) > (ss.sensitivityUs / 1000))
      fprintf('[SNRScope] DAC saturation at US channel.\n');
    end
    if (max(abs(ss.acquiredDataPd(:))) > (ss.sensitivityPd / 1000))
      fprintf('[SNRScope] DAC saturation at PD channel.\n');
    end
    
    ss.Calculate_FFT(); % Calculate P1 signals of oaSig before filtering 

    if ~isempty(ss.filterFreq) % bandpass filter OA data
      ss.acquiredDataUs = ...
        single(filtfilt(ss.b, ss.a, double(ss.acquiredDataUs)));
    end

    % Write acquired data into vectors
    ss.acquiredDataUs = reshape(ss.acquiredDataUs, ...
      [ss.nSamples, ss.nWavelengths, ss.nAverages]);

    % Calculate average along third dimension for both channels
    ss.oaSig = reshape(...
      mean(ss.acquiredDataUs, 3), ... 
      [ss.nSamples, ss.nWavelengths]); 
    ss.pdSig = reshape(...
      mean(ss.acquiredDataPd, 3), ...
      [ss.nSamples, ss.nWavelengths]);
    
    % if (ss.flagUs == 0) % get maximum pd signal and intensity for z shift and max plot
    %  
    %   zOffset = zOffsetIdx * ss.dt * ss.SOS_WATER;
    % else % for US, ignore PD
    %   zOffset = 0;
    %   zOffsetIdx = 0;
    %   maxPd = 0;
    % end

    % same for oa
    [maxOa, maxPosOa] = max(ss.oaSig(ss.oaPlotRange, :), [], 1);
    [minOa, minPosOa] = min(ss.oaSig(ss.oaPlotRange, :), [], 1);

    if ishandle(H) % Avoids anozing cannot draw error
      % update pd plot for each wavelength

      for iSig = 1:ss.nWavelengths
        % calculate updated z vector for current wavelength
        if (ss.wavelengths(iSig) ~= 0) % OA imaging
          [maxPd, zOffsetIdx] = max(ss.pdSig(ss.pdPlotRange, :), [], 1);
          % zOffsetIdx(iSig) = 147;
          zLambda = (double(ss.oaPlotRange) - zOffsetIdx(iSig)) .* ss.dt .* ss.SOS_WATER .* 1e3; % ss.zVector - zOffset(1, iSig);
        else % US imaging
          [maxPd, zOffsetIdx(iSig)] = max(abs(ss.oaSig(1:1000, iSig)));
          zLambda = (double(ss.oaPlotRange) - zOffsetIdx(iSig)) .* ss.dt .* ss.SOS_WATER .* 1e6 / 2; % only half the distance 
        end

        posData = (maxPosOa + minPosOa) / 2;% [zOffsetIdx, maxPosOa, minPosOa, maxOa, minOa];
        posData = zLambda(round(posData));
        % update z vector of us channel plot depending on delay measured on pd channel
        set(hOa{iSig}, 'xdata', zLambda); % update x of main plot
        set(hOa{iSig}, 'ydata', ss.oaSig(ss.oaPlotRange, iSig));
        % update maximum line
        set(hOaMax{iSig}, 'xdata', [zLambda(maxPosOa(iSig)), zLambda(maxPosOa(iSig))]);
        set(hOaMax{iSig}, 'ydata', [0, maxOa(iSig)]);
        % update minimum line
        set(hOaMin{iSig}, 'xdata', [zLambda(minPosOa(iSig)), zLambda(minPosOa(iSig))]);
        set(hOaMin{iSig}, 'ydata', [0, minOa(iSig)]);
      
        if (ss.wavelengths(iSig) ~= 0)
          set(hPd{iSig}, 'xdata', single(ss.pdPlotRange - 1) * ss.dt);
          set(hPd{iSig}, 'ydata', ss.pdSig(ss.pdPlotRange, iSig));
          if (ss.wavelengths(iSig) ~= 0)
           set(hPdMax{iSig}, 'xdata', [zOffsetIdx(iSig), zOffsetIdx(iSig)] * ss.dt);
          end
          set(hPdMax{iSig}, 'ydata', [0, maxPd(1, iSig)]);
        end 
        set(hFreq{iSig}, 'ydata', ss.P1mean(1:end, iSig));
      end
    
      % calculate signal to noise ratio
      noiseMatrixUs = [];
      noiseMatrixPd = [];
      for (iSig = 1:ss.nWavelengths)
        if ss.wavelengths(iSig) ~= 0
          idxRange = 1:400;
          noiseMatrixPdTemp = ss.acquiredDataPd(1:100, iSig, :);
          noiseMatrixPd = [noiseMatrixPd, noiseMatrixPdTemp(:)];
        else
          idxRange = (ss.nSamples - 399):ss.nSamples;
        end
        noiseMatrixUsTemp = ss.acquiredDataUs(idxRange, iSig, :);
        noiseMatrixUs = [noiseMatrixUs, noiseMatrixUsTemp(:)];
      end

      noiseLevelUs = std(noiseMatrixUs) * 1000;
      noiseLevelPd = std(noiseMatrixPd) * 1000;

      snrUs = (maxOa * 1000) / noiseLevelUs;
      snrPd = (maxPd * 1000) / noiseLevelPd;
      txtString = sprintf("Noise Level US: %.1f mV \n Noise Level PD: %.1f mV \n SNR US: %.1f dB\n SNR PD: %.1f dB", ...
        noiseLevelUs, noiseLevelPd, mag2db(snrUs), mag2db(snrPd));
      set(textBox, 'String', num2str(txtString));
    end

    drawnow limitrate;
  end

  % post hardware
  microscope.Trigger.Stop();
  microscope.Cascader.Stop();
  microscope.DAQ.Close_Connection();
  microscope.DAQ.flagVerbose = 1;
end