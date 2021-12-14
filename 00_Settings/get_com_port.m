function get_com_port(idString)

	idString = char(idString);

	switch idString
		case 'Onda532'
			error("Not implemented yet");
		case 'Onda1064'
			error("Not implemented yet");
		case 'pm'
			port = 'COM5';
		otherwise
			error("Invalid identifier specified");
	end
end