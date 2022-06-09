% file      getSpeedOfSound.m
% author    Urs Hofmann
% date      30. Jan 2018
% version   1.0
% mail      urshofmann@gmx.net

% Function gives back the speed of sound in destilled water as a function of temperature.

% Input: degree celsius
% Output: mm/s

% input arguments
% 	- unit 	mm or m

function speedOfSound = getSpeedOfSound(temp, varargin)

	% defualt arguments
	unit = 'mm';

	for iargin = 1:2:(nargin-1)
		switch varargin{iargin}
			case 'unit'
				unit = varargin{iargin + 1};
			otherwise
				error('Invalid argument passed');
			end
	end

  speedOfSound = ...
    1.40238742e3 + ...
    5.03821344 * temp - ...
    5.80539349e-2 * temp^2 + ...
    3.32000870e-4 * temp^3 - ...
    1.44537900e-6 * temp^4 + ...
    2.99402365e-9 * temp^5;

  % Convert from m/s to mm/s
  if (strcmp(unit , 'mm') )
  	speedOfSound = speedOfSound * 1000;
	end

end
