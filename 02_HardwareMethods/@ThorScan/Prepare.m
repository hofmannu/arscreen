% File: 		Prepare.m @ ThorScan
% Author: 	Urs Hofmann
% Mail: 		hofmannu@biomed.ee.ethz.ch
% Date: 		27. Feb 2018
% Version:	1.0


function Prepare(thorscan, microscope)

  thorscan.Read_Settings(); % Read in settings
  thorscan.Define_Geometry(microscope); % Generate vectors and region of interest
  thorscan.Prepare_Hardware(microscope);% Prepare hardware

end
