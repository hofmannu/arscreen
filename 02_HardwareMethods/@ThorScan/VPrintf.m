% File: VPrintf.m @ ThorScan
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 19.05.2020

% Description: Verbose output

function VPrintf(ts, txtMsg, flagName)

	if ts.flagVerbose % enable / disable verbose output

		if flagName
			txtMsg = ['[ThorScan] ', txtMsg];
		end

		fprintf(txtMsg);
	end

end