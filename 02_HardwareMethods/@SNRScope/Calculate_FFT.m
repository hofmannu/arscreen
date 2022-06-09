% File: Calculate_FFT.m @ SNRScope
% Author: Urs Hofmann
% Date: 19.09.2018
% Mail: hofmannu@student.ethz.ch

function Caluclate_FFT(snrscope)

	% Do calculation for each wavelength if there is more than one
	% Calculate fft
	rawFFT = fft(snrscope.acquiredDataUs(snrscope.oaPlotRange, :, :), snrscope.nFFT, 1);
	
	% Get two sided absolute
	P2 = abs(rawFFT / double(snrscope.nFFT));

 	snrscope.P1 = P2(1:(snrscope.nFFT / 2 + 1), :, :);
 	snrscope.P1(2:end-1, :, :) = 2 * snrscope.P1(2:end-1, :, :);

 	snrscope.P1mean = squeeze(mean(snrscope.P1, 3)); 
end