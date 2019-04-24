% This file configurates the parameters used in the program
% Author: Sean Quirin, modified by Weijian Yang 2014-2019

%% SLM parameters
SLM='BNS';
%SLM='Holoeye';

if strcmp(SLM, 'BNS')           % BNS SLM
    SLMm=512;            % pixel number in the horizontal axis of the SLM
    SLMn=512;            % pixel number in the vertical axis of the SLM
    SLMLoadTime=0.05;    % SLM load time
% the default linear LUT file name for BNS SLM
    defaultLUTfileName='C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\linear.LUT';                           
% the calibrated LUT file name for BNS SLM 
%%%% the following files work for the BNS SLM    
    calibratedLUTfileName='C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\slm3329_at1064_P8.LUT';   % non-regional LUT
    calibratedRegionalLUTfileName='C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\SLM_3329_20150303.txt';  % regional LUT
% the file that is used to optimize the BNS SLM 
    SLMOptimizationDataFileName='C:\BLINK_PCIe\Image_Files\BLANK.bmp';
% default loaded image when initialize the BNS SLM
    SLMInitializationImageFileName='C:\BLINK_PCIe\Image_Files\BLANK.bmp';
    SLMInitializationImageMat=[];
else                     % Holoeye SLM
    SLM_M=1920;          % total pixel number in the horizontal axis of the SLM
    SLM_N=1080;          % total pixel number in the vertical axis of the SLM; the extra number is to make the screen larger so as to avoid SLM blinking
    SLMm=1080;           % pixel number in the horizontal axis of the SLM that are to be illuminated
    SLMn=1080;           % pixel number in the vertical axis of the SLM that are to be illuminated
    SLMm0=1;             % pixel coordinate in the horizontal axis, representing the bottom left of the image 
    SLMn0=1;             % pixel coordinate in the vertical axis, representing the bottom left of the image
    SLMLoadTime=0.1;     % SLM load time
% the default linear LUT file name for Holoeye SLM
    defaultLUTfileName='C:\BLINK_PCIe\LUT_Files\linear.LUT';                           
% the calibrated LUT file name for Holoeye SLM 
    calibratedLUTfileName='C:\BLINK_PCIe\LUT_Files\gamma_cal_940nm_Holoeye_901D.lut';
    calibratedLUTFunctionfileName='C:\BLINK_PCIe\LUT_Files\gamma_cal_940nm_Holoeye_901D.mat';
end

SLMPreset=[0 0];   % [0 12];
objectiveRI=1.33;
illuminationWavelength=1064e-9;

