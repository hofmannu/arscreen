# arscreen
A MATLAB based protein screening platform as we use it in Zurich to screen for optoacoustic reporter proteins.

## Hardware setup

To prepare your PC before using this repository, the following software should be installed:

*  MATLAB R2021b
*  git for code repository management
*  Thorlabs Kinesis
*  We use VirtualHere client in Zurich to share devices without replugging the USB ports into different PCs

I will provide CAD files for the setup at some point, for now we will only have a list of components here.

*  zStage: [Thorlabs MTS50](https://github.com/razanskylab/Stage_Thorlabs_MTS50)
*  FL camera: [ueyecam](https://github.com/razanskylab/ueyecam)
*  x and y stage: [Thorlabs DDSM50](https://github.com/razanskylab/Stage_Thorlabs_DDSM50)
*  [Quadrature_Decoder_Board](git@github.com:razanskylab/Quadrature_Decoder_Board.git): selfmade piece of electronics responsible to monitor the steps of the laser, PCB and firmware can be found in linked repository
*  data acuqisition card [M4 Spectrum DAQ](git@github.com:razanskylab/DAQ_Spectrum_M4i4420.git)
*  dye laser [Sirah Credo](https://github.com/razanskylab/Laser_Sirah_Credo)
*  edgewave laser [Edge](https://github.com/razanskylab/Laser_Edgewave_Innoslab)
*  optional: Onda lasers for fixed wavelengths

## Libraries

