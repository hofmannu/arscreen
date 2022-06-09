% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 05.05.2021
% Description: Prints a preview of the acquired scan

function Print_Preview(ts, varagin)

	fprintf('[ThorScan] Generating preview images... ');

	% fore readability 
	[~, nLambda, nAv, nX, nY] = size(ts.RawDataUs);
	usCropVec = (ts.sett.usCropPreview(1):ts.sett.usCropPreview(2)) - ts.sett.usCrop(1) + 1;
	nT = length(usCropVec);
	tVec = ts.tVec(usCropVec);
	scaleFactor = ts.sett.sensitivityUs / single(intmax('int16')) * 1e-3;

	for iLambda = 1:nLambda	

		% extract single wavelength and average
		RawDataUsTemp = single(ts.RawDataUs(usCropVec, iLambda, :, :, :)) * scaleFactor;
		RawDataUsTemp = reshape(RawDataUsTemp, [nT, nAv, nX, nY]);
		RawDataUsTemp = mean(RawDataUsTemp, 2);
		RawDataUsTemp = reshape(RawDataUsTemp, [nT, nX, nY]);

		% flip every second x scan and remove DC offset
		RawDataUsTemp(:, :, 2:2:end) = flip(RawDataUsTemp(:, :, 2:2:end), 2);
		dcOffset = mean(RawDataUsTemp, 1);
		dcOffset = reshape(dcOffset, [1, nX, nY]);
		dcOffset = repmat(dcOffset, [nT, 1, 1]);
		RawDataUsTemp = RawDataUsTemp - dcOffset;

		% generate path name
		pathFig = [ts.Paths.rawPath(1:end-7), num2str(ts.sett.wavelengths(iLambda)), '_preview.pdf'];

		centerX = round(nX / 2);
		centerY = round(nY / 2);

		sliceX = RawDataUsTemp(:, :, centerY);
		sliceX = reshape(sliceX, [nT, nX]);
		sliceY = RawDataUsTemp(:, centerX, :);
		sliceY = reshape(sliceY, [nT, nY]);

		[mipZ, idxZ] = max(abs(RawDataUsTemp), [], 1);
		mipZ = reshape(mipZ, [nX, nY]);
		idxZ = reshape(idxZ, [nX, nY]);

		[~, maxTotalIdx] = max(abs(RawDataUsTemp(:)));
		[maxT, maxX, maxY] = ind2sub([nT, nX, nY], maxTotalIdx);

		f = figure();
		f.PaperUnits = 'centimeters';
		f.PaperType = 'A4';
		f.PaperSize = [21.0, 29.7];

		% maximum amplitude projection along x
		ax1 = subplot(3, 2, 1);

		imagesc(ts.yVec, ts.xVec, mipZ);

		title('MIPz');
		colormap(ax1, bone(1024));
		colorbar;
		xlabel('y [mm]');
		ylabel('x [mm]');
		axis image;

		% depth map along z
		ax2 = subplot(3, 2, 2);

		imScIdx = imagesc(ts.yVec, ts.xVec, ts.zVec(idxZ));
		mipZ = mipZ / max(abs(mipZ(:)));
		imScIdx.AlphaData = mipZ;
		ax2.Color = [0, 0, 0];
		title('Depth map');
		colormap(ax2, parula(1024));
		colorbar;
		xlabel('y [mm]');
		ylabel('x [mm]');
		axis image;

		% crosssection along x
		ax3 = subplot(3, 2, 3);

		imagesc(ts.xVec, tVec, sliceX);
		title('Crossection x');
		colormap(ax3, redblue(1024));
		xlabel('x [mm]');
		ylabel('Time [s]');
		maxAbsVal = max(abs(sliceX(:)));
		caxis([-maxAbsVal, maxAbsVal]);

		ax4 = subplot(3, 2, 4);

		imagesc(ts.yVec, tVec, sliceY);
		title('Crosssection y');
		colormap(ax4, redblue(1024));
		xlabel('y [mm]');
		ylabel('Time [s]');
		maxAbsVal = max(abs(sliceY(:)));
		caxis([-maxAbsVal, maxAbsVal]);

		ax5 = subplot(3, 2, [5, 6]);

		hold on
		plot(tVec, RawDataUsTemp(:, centerX, centerY));
		plot(tVec, RawDataUsTemp(:, maxX, maxY));

		grid on
		axis tight
		xlabel('Time [s]');
		ylabel('OA amplitude [V]');
		title('A scan');

		print(f, pathFig, '-dpdf', '-fillpage');

	end

	fprintf('done!\n');

end