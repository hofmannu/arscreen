% File: Post_Hardware.m @ ThorScan
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Description: Brings hardware into wait mode

function Post_Hardware(thorscan, microscope)

  % Move stages back to center
  microscope.FastStage.pos = thorscan.sett.ctr(1);
  microscope.SlowStage.pos = thorscan.sett.ctr(2);

  microscope.Trigger.Stop; % Stop trigger
  microscope.Trigger.Stop; 

  microscope.Cascader.Stop(); % start cascade for next scan

  % reset data acquisition card
  microscope.DAQ.Stop();
  microscope.DAQ.Free_FIFO_Buffer();
  microscope.DAQ.Close_Connection();

  % unsilence hardware
  microscope.Trigger.flagVerbose = 0;
  microscope.DAQ.flagVerbose = 0;
  microscope.FastStage.beSilent = 0;
  microscope.SlowStage.beSilent = 0;

end