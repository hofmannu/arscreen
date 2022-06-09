% File: get_com_port.m
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date:	14.12.2021

% Description: returns tjhe serial numbers 

function port = get_com_port(idString)

	idString = char(idString);

	switch idString
		case 'Onda532'
			error("Not implemented yet");
		case 'Onda1064'
			error("Not implemented yet");
		case 'pm'
			port = 'COM5';
		case 'FastStage'
			port = '28250672';
		case 'SlowStage'
			port = '28250654';
		case 'Trigger'
			port = 'COM4'; %dont connect yet
		case 'Cascader'
			port = 'COM10'; 
		otherwise
			error("Invalid identifier specified");
	end


end