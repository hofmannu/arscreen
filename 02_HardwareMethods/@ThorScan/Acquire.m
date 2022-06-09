% File: Acquire.m @ thorscan
% Author: Urs Hofmann
% Date: 27. Feb 2018
% Mail: hofmannu@ethz.ch
% Version:  2.0
% 
% Description: Controls the data acquisition of the thorscan procedure.

function Acquire(ts, m)

 

  ts.VPrintf('Allocating memory... ', 1);

  % % define crop vector for a single a scan
  usCropVec = ts.sett.usCrop(1):ts.sett.usCrop(2);
  pdCropVec = ts.sett.pdCrop(1):ts.sett.pdCrop(2);
  nUs = length(usCropVec);
  nPd = length(pdCropVec);
  ts.tPoints = zeros(ts.sett.nLambda, ts.sett.nAverages, ts.nX, ts.nY, 'single');  % creat a 4 dimension 0 matrix /XL
  
  % allocate memory for RawDataUs and RawDataPd
  ts.RawDataUs = [];
  ts.RawDataPd = [];
  nSamplesBUs = nUs * ts.nShotsB;
  nSamplesBPd = nPd * ts.nShotsB;
  RawDataUs = zeros(nSamplesBUs, ts.nY, 'int16');
  RawDataPd = zeros(nSamplesBPd, ts.nY, 'int16');

  usCropDef = zeros(ts.sett.nSamples, ts.sett.nLambda, ts.sett.nAverages, ts.nX, 'logical');
  pdCropDef = zeros(ts.sett.nSamples, ts.sett.nLambda, ts.sett.nAverages, ts.nX, 'logical');

  usCropDef(ts.sett.usCrop(1):ts.sett.usCrop(2), :, :, :) = 1;
  usCropDef = usCropDef(:);
  pdCropDef(ts.sett.pdCrop(1):ts.sett.pdCrop(2), :, :, :) = 1;
  pdCropDef = pdCropDef(:);

  tS = zeros(1, ts.nShotsB, 'single'); %how many Triggers vector; /XL

  ts.VPrintf('done!\n', 0); %0 means dont need to print [ThorScan]

  % limit figure updating to every second
  figureUpdateTimer = tic;
  lastTDraw = 0;

  if ts.flagPreview    %For previwe plot /XL
    f = figure('Name', '[ThorScan] LivePreview');
    
    ts.Results.mipz = zeros(ts.sett.nLambda, ts.nX, ts.nY, 'single'); % nLambda, x, y
    ts.Results.pdMip = zeros(ts.sett.nLambda, ts.nX, ts.nY, 'single');

    for iLambda = 1:ts.sett.nLambda
      ax(iLambda, 1) = subplot(ts.sett.nLambda, 2, 2 * iLambda - 1);

      % plot image
      mipdata(iLambda) = imagesc(ts.yVec, ts.xVec, ...
        squeeze(ts.Results.mipz(iLambda, :, :)));
      xlabel('y [mm]');
      ylabel('x [mm]');
      title('MIPz');
      colormap(ax(iLambda, 1), bone);
      axis image;

      ax(iLambda, 2) = subplot(ts.sett.nLambda, 2, 2 * iLambda);

      lastBScan(iLambda) = imagesc(ts.zVec(usCropVec), flipud(ts.xVec), ...
        zeros(ts.nZ, ts.nX));
      
      ylabel('x [mm]');
      xlabel('z [mm]');
      title('Last B Scan');
      colormap(ax(iLambda, 2), redblue);
      axis image;

    end
  end

  ts.VPrintf('Acquiring actual data.\n', 1);
  scanTimer = tic; % starting stopwatch
  ts.progressText = '';
  counterFailed = 0;
  m.Cascader.StartN(); % removed from actual 
  ts.tBScan = zeros(1, ts.nY, 'single');
  lineScanCounter = 0;

  for yi = 1:ts.nY
    successLine = 0; % flag showing if previous line scan was successfull
    dispPrevLine = 0;
    m.SlowStage.Move_No_Wait(ts.yVec(yi)); % Move to next y-position
    while(~successLine)
      m.DAQ.Setup_FIFO_Multi_Mode(); % prepare dac for acquiring data
      m.DAQ.Start();
      ts.tBScan(yi) = toc(scanTimer);
      m.DAQ.Enable_Trigger();
      % m.Trigger.Start(); % starts trigger & waits for handshake --> slow but secure
      m.Trigger.Start_Blind(); % starts trigger without waiting for response
      
      m.FastStage.Wait_Move(); % wait until prvious line scan is finished
      if rem(yi, 2) % either move lr or rl
        m.FastStage.Move_No_Wait(ts.xVec(end));
      else
        m.FastStage.Move_No_Wait(ts.xVec(1));
      end
      % Update previous line for live preview and perform line by line postprocessing
      % only if not done yet
      if (ts.flagPreview && ~dispPrevLine)
        if (yi > 1) % first line was not acquired yet
          tempPd = RawDataPd(:, yi - 1);

          tempPd = reshape(tempPd, ...
            [nPd, ts.sett.nLambda, ts.sett.nAverages * ts.nX]);
          [~, pdOffset] = max(abs(tempPd), [], 1);
          pdMipTemp = sum(tempPd, 1);
          pdMipTemp = reshape(single(pdMipTemp), [ts.sett.nLambda, ts.sett.nAverages, ts.nX]);
          pdMipTemp = mean(pdMipTemp, 2);
          pdMipTemp = reshape(pdMipTemp, [ts.sett.nLambda, ts.nX]);

          pdOffset = reshape(pdOffset, [ts.sett.nLambda, ts.sett.nAverages * ts.nX]);
           if ~rem(yi, 2) % distinguish between going backward and forward
            pdMipTemp = flip(pdMipTemp, 2);
          end

          ts.Results.pdMip(:, :, yi -1) = pdMipTemp;

          pdOffset = squeeze(mean(pdOffset, 2)); % means one value for each lambda

          temp = single(RawDataUs(:, yi - 1));

          % remove dc offset of signal for each a scan individually
          temp = reshape(temp, [nUs, ts.sett.nLambda * ts.sett.nAverages * ts.nX]);
          previewCrop = (ts.sett.usCropPreview(1):ts.sett.usCropPreview(2)) - ts.sett.usCrop(1) + 1;
          tempMean = mean(temp(previewCrop, :), 1);
          temp = temp - repmat(tempMean, [nUs, 1]);

          tempMeanLine = mean(temp, 2);
          temp = temp - repmat(tempMeanLine, [1, ts.sett.nLambda * ts.sett.nAverages * ts.nX]);

          % reshape into readable format
          temp = reshape(temp, ...
            [nUs, ts.sett.nLambda, ts.sett.nAverages, ts.nX]);


          if ~rem(yi, 2) % distinguish between going backward and forward
            temp = flip(temp, 4);
          end
          temp = mean(temp, 3); % calculate average signal over last b scan
          temp = reshape(temp, [nUs, ts.sett.nLambda, ts.nX]);

          % calculate mip for last b scan, order of mip: nLambda, x, y
          ts.Results.mipz(:, :, yi - 1) = max(abs(temp(previewCrop, :, :)), [], 1);

          % correct for pd fluctuations
          for (iLambda = 1:ts.sett.nLambda)
            if (ts.sett.wavelengths(iLambda) ~= 0) % only correct if not us
              ts.Results.mipz(iLambda, :, yi - 1) = ts.Results.mipz(iLambda, :, yi - 1) ./ ...
                ts.Results.pdMip(iLambda, :, yi - 1);
            end
          end

          % get new mins and maxs
          currMip =  ts.Results.mipz(:, :, yi - 1);
          currMip = reshape(currMip, [ts.sett.nLambda, ts.nX]);
          maxOaCurr = max(currMip, [], 2);
          minOaCurr = min(currMip, [], 2);
          if ((yi - 1) == 1)
            minOa = minOaCurr;
            maxOa = maxOaCurr;
          else
            minOa(minOaCurr < minOa) = minOaCurr(minOaCurr < minOa);
            maxOa(maxOaCurr > maxOa) = maxOaCurr(maxOaCurr > maxOa);
          end

          % update image and colorbar limts
          for iLambda = 1:ts.sett.nLambda
            % update z axis
            if ts.sett.wavelengths(iLambda) == 0
              tempOffsetUs = squeeze(temp(1:500, iLambda, :));
              [~, usOffset] = max(abs(tempOffsetUs), [], 1);
              zVec = (single(0:(ts.sett.nSamples - 1)) - mean(usOffset)) ...
                / ts.sett.samplingFreq * ...
                getSpeedOfSound(ts.sett.temp) / 2;
            else
              zVec = (single(0:(ts.sett.nSamples - 1)) - pdOffset(iLambda)) ...
                / ts.sett.samplingFreq * ...
                getSpeedOfSound(ts.sett.temp);
            end

            set(lastBScan(iLambda) , 'xdata', zVec(previewCrop));
            % update mips
            set(mipdata(iLambda), 'cdata', flipud(squeeze(ts.Results.mipz(iLambda, :, :))));
            lbs =  flipud(squeeze(temp(previewCrop, iLambda, :))');
            set(lastBScan(iLambda), 'cdata', lbs);
            maxAbsLbs = max(abs(lbs(:)));

            % check if we have a new min or max
            caxis(ax(iLambda, 1), [minOa(iLambda), maxOa(iLambda)]);
            caxis(ax(iLambda, 2), [-maxAbsLbs, maxAbsLbs]);
          end

          deltaT = toc(figureUpdateTimer) - lastTDraw;
          if (deltaT > 1)
            drawnow();
            lastTDraw = toc(figureUpdateTimer);
          end
        end
        dispPrevLine = 1;
      end

      % order is us/pd * z / t * lambda\ * x, y
      % [RawDataPd(:, yi), RawDataUs(:, yi), tS] = m.DAQ.Acquire_Multi_FIFO_Data_Minimal();
      [tempDataUs, tempDataPd, tS] = m.DAQ.Acquire_Multi_FIFO_Data_Minimal();
      m.DAQ.Stop();
      m.DAQ.Free_FIFO_Buffer();

      if (length(tempDataUs) ~= ts.nSamplesB) % retry because we did not acquire anything
        warning('Line scan failed, retrying now.');
        if ~rem(yi, 2) % either move lr or rl
          m.FastStage.pos = ts.xVec(end);
        else
          m.FastStage.pos = ts.xVec(1);
        end
        counterFailed = counterFailed + 1;
        m.Cascader.Stop();
        m.Cascader.StartN();
      else % dont retry
        % crop measurement

        RawDataPd(:, yi) = tempDataPd(pdCropDef); % RawDataUs/Pd: z/t, lambda, x, y
        RawDataUs(:, yi) = tempDataUs(usCropDef);
        if (max(abs(tempDataUs(:))) > 3e4)
          warning('Saturation on US channel');
        end
        ts.tPoints(:, :, :, yi) = reshape(tS, [ts.sett.nLambda, ts.sett.nAverages, ts.nX]);
        successLine = 1;
        ts.Print_Progress(yi, scanTimer); % Show progress
      end
      
    end
  end
  m.Cascader.Stop();

  ts.RawDataUs = RawDataUs;
  clear RawDataUs;
  ts.RawDataPd = RawDataPd;
  clear RawDataPd;
  
  % reshape to easily readbale 4D format
  ts.RawDataUs = reshape(ts.RawDataUs, ...
    [nUs, ...
    ts.sett.nLambda, ...
    ts.sett.nAverages, ...
    ts.nX, ...
    ts.nY]);
  ts.RawDataPd = reshape(ts.RawDataPd, ...
    [nPd, ...
    ts.sett.nLambda, ...
    ts.sett.nAverages, ...
    ts.nX, ...
    ts.nY]);

  % wait for all stages to finish moving
  m.FastStage.Wait_Move();
  ts.Results.tScan = toc(scanTimer); % save scan time in seconds to output
  ts.VPrintf(['This scan took ', num2str(ts.Results.tScan) ' s.\n'], 1);
  ts.VPrintf([num2str(counterFailed), ' line scans failed.\n'], 1);
  
  % check for saturation
  if (max(abs(ts.RawDataUs(:))) >= (intmax('int16') - 1))
    mip = max(abs(ts.RawDataUs), [], 1);
    mip = (mip >= (intmax('int16') - 1));
    nSat = sum(mip(:));
    perc = nSat / (ts.sett.nLambda * ts.sett.nAverages * ts.nX * ts.nY);
    perc = perc * 100;
    warning('Saturation on US channel!');

  end

  % check for saturation on photodiode channel
  if (max(abs(ts.RawDataPd(:))) >= (intmax('int16') - 1))
    warning('Saturation on PD channel!');
  end

end