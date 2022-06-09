function Run(rs, A)

	rs.Read_Settings();
	rs.Prepare_Variables();
	rs.Prepare_Hardware(A);

	figure();
	subplot(2, 2, 1)
	mip = zeros(rs.nX, rs.nY, 'int16');
	imgMip = imagesc(rs.yVec, rs.xVec, mip);
	colormap(bone(1064));
	xlabel('y [mm]');
	ylabel('x [mm]');
	axis image;
	colorbar;
	title('Maximum amplitude projection')
	drawnow();

	subplot(2, 2, 2)
	depthMap = zeros(rs.nX, rs.nY, 'int16');
	imgDepthMap = imagesc(rs.yVec, rs.xVec, depthMap);
	colormap(bone(1064));
	xlabel('y [mm]');
	ylabel('x [mm]');
	axis image;
	colorbar;
	title('Depth map')
	drawnow();

	subplot(2, 2, 3)
	meanSig = zeros(1, length(rs.usPlotRange), 'int16');
	meanSigPlot = plot(meanSig);
	title('Last A-scan');
	xlabel('Sample index');
	ylabel('Signal intensity');
	axis tight;

	tic
	A.Trigger.Start();
	A.Cascader.Start();

	temp = zeros(2, rs.nSamples * rs.nAverages, 'int16');

	for iY = 1:rs.nY
		fprintf('Scanning line %d of %d\n', iY, rs.nY);
	  A.SlowStage.pos = rs.yVec(iY);
		for iX = 1:rs.nX
	    
	    if rem(iY, 2)
	    	iXIdx = iX;
	    else
	    	iXIdx = rs.nX - (iX - 1);
	    end
			
			A.FastStage.pos = rs.xVec(iXIdx);
	    A.DAQ.Start_Multi_Mode();
			temp = reshape(A.DAQ.Acquire_Multi_Data(), [2, rs.nSamples, rs.nAverages]);
			meanTemp = mean(single(temp), 3);

			% save raw data if we want to keep averages, otherwise not
			if rs.flagKeepAv
				rs.RawDataUs(:, :, iXIdx, iY) = temp(2, :, :);
				if (~rs.flagUs)
					rs.RawDataPd(:, :, iXIdx, iY) = temp(1, :, :);
				end
			end

			rs.MeanDataUs(:, iXIdx, iY) = meanTemp(2, :);
			if (~rs.flagUs)
				rs.MeanDataPd(:, iXIdx, iY) = meanTemp(1, :);
			end
			
			[mip(iXIdx, iY), depthMap(iXIdx, iY)] = max(abs(rs.MeanDataUs(rs.usPlotRange, iXIdx, iY)));
			if (iY == 1) && (iX == 1)
				mip(:, :) = mip(iXIdx, iY);
				depthMap(:, :) = depthMap(iXIdx, iY);
			end

	    % update live preview
	    set(imgMip, 'cdata', mip);
	    set(imgDepthMap, 'cdata', depthMap);
	    set(meanSigPlot, 'ydata', squeeze(rs.MeanDataUs(rs.usPlotRange, iXIdx, iY)));
	    drawnow();
		end
		tElapsed = toc;
		fprintf('Remaining time: %.1f min\n', tElapsed / 60 / iY * (rs.nY - iY));
	end
	toc

	rs.Save_Data();

end