% File: VPrintf.m @ SNRScope
% Author: Urs Hofmann
% Date: 05.06.2020
% Mail: hofmannu@biomed.ee.ethz.ch

% Description: Generates verbose output

function VPrintf(ss, txtMsg, flagName)

	if ss.flagVerbose
		if flagName
			txtMsg = ['[SNRScope] ', txtMsg];
		end
		fprintf(txtMsg);
	end
	
end