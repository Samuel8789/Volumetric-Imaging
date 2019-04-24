%% Modal Adaptive Optics
% This set of codes are used to measure the aberrations and create SLM 
% correction phase mask. This measurement should be done for different 
% imaging depths, and a correction mask should be created for each depth. 
% Run "assemble_ao_phase.m" to assemble the correction mask for different
% imaging depths into a single calibration file, which can then be used as 
% part of the calibration in "ImagingControl.m" when performing volumetric 
% imaging. 

% Author: Weijian Yang, Shuting Han, 2017-2019

% This program assumes the SLM is from BNS (Meadowlark Optics) or Holoeye
% It uses NI DAQ to trigger the data acquisition
% One has to set up the SLM and NI DAQ before running this program.

%% set up and open SLM
CFG2;
handles.SLMPreset = SLMPreset;
handles.applyAO = 0;
handles.adaptiveOpticsCal_phase = [];
handles.adaptiveOpticsCal_depth = [];
if strcmp(SLM, 'BNS')
    handles.SLM_handles = BNS_SLMOverDrive_Initialize(calibratedRegionalLUTfileName, SLMInitializationImageFileName);
else
    handles.SLM_handles = Holoeye_SLM_LoadImage(zeros(SLMm, SLMn), SLM_M, SLM_N, SLMm0, SLMn0);
end
weight = 1;
objectiveNA = 0.4;
f_SLMActivation_Calibration( handles.SLM_handles, [handles.SLMPreset 0], weight, objectiveNA, handles );  

% load axial calibration file
load('axialCal_file.mat');

%% set up NI
so = daq.createSession ('ni');
ch = addDigitalChannel(so,'dev1', 'Port0/Line7', 'OutputOnly');
outputSingleScan(so,0);

%% setup parameters for adaptive optics
% z defocus
z = 200e-6;              % [m] defocus depth
xyzp = [0 0 z];      

% parameters
w = 5; % range of weight
dw = w/20; % step size
totalModeNum = 15; % number of mode to try
scaling = 2; % weight range update scaling factor
wVec = -w:dw:w;
wVecNum = length(wVec);

% imaging acquisition average number
avgNum = 5;

% initialization
objectiveNA = f_SLMFocusCalFun(z);
basePhase = f_SLM_PhaseHologram( xyzp, SLMm, SLMn,  weight, objectiveNA, objectiveRI, illuminationWavelength, handles);

% construct n and m set
nmSet = zeros(totalModeNum,2);
weightSet = zeros(totalModeNum,1);
n = 0;
m = 0;
for idx = 2:totalModeNum
    m = m+2;
    if m > n
        n = n+1;
        m = -n;
    end
    nmSet(idx,1) = n;
    nmSet(idx,2) = m;
end

%% start correction
% construct the mode
for k = 4:totalModeNum % skip the first three modes for now
    
    % get corresponding zernike functions
    n = nmSet(k,1);
    m = nmSet(k,2);
    modalPhase = zernikeFunction(n,m,SLMm,SLMn);
    flag = 1;
    wVecIter = wVec;
    
    % loop through different weight
    count = 0;
    while flag==1
        
        count = count+1;
        disp(['Mode ' num2str(k) '; Iteration ' num2str(count)]);
        
        for idx = 1:wVecNum
            
            testPhase = basePhase+modalPhase*wVecIter(idx);
            testPhase = mod(testPhase,2*pi);
        
            % SLM activation
            if strcmp(SLM, 'BNS')
                testPhase = 255.*( testPhase )./(2*pi);            % BNS phase range 0~255
                calllib('Blink_SDK_C', 'Write_overdrive_image', handles.SLM_handles, 1, testPhase, 0, 0);
            else                                             
                testPhase = ( testPhase )./(2*pi);                 % Holoeye phase range 0~1  
                Holoeye_SLM_LoadImage( testPhase', SLM_M, SLM_N, SLMm0, SLMn0, handles.SLM_handles, calibratedLUTFunctionfileName );
            end
            
            % send trigger
            outputSingleScan(so,1);
            pause(0.04*avgNum);

            % reset trigger
            outputSingleScan(so,0);
            
        end
        
        % acquire an extra image to finish scanImage acquisition
        outputSingleScan(so,1);
        pause(0.07);
        outputSingleScan(so,0);
        
        % input the best weight
        bestWeightID = input(['Please choose the best weight (1~' num2str(wVecNum) '): ']);
        basePhase = basePhase + modalPhase*wVecIter(bestWeightID);
        weightSet(k) = weightSet(k) + wVecIter(bestWeightID);

        % proceed to the next mode?
        fprintf('Previous w: %2.4f; current w: %2.4f\n',weightSet(k)-wVecIter(bestWeightID),weightSet(k));
        decision = input('More iterations? (Y/N) (ESC to end)','s');
        if strcmp(decision,'n') || strcmp(decision,'N')
            flag = 2;
        elseif strcmp(decision,'y') || strcmp(decision,'Y')
            flag = 1;
            % update parameter range
            wVecIter = wVecIter/scaling;
        else 
            flag=3;
        end

    end
    if flag==3
        break;
    end
end

%% close SLM
if strcmp(SLM, 'BNS')
    BNS_SLMOverDrive_Close(handles.SLM_handles);
else
    close(handles.SLM_handles);
end

%% save file
% subtract focus correction
k = 5;
n = nmSet(k,1);
m = nmSet(k,2);
modalPhase = zernikeFunction(n,m,SLMm,SLMn);

basePhase0 = f_SLM_PhaseHologram( xyzp, SLMm, SLMn,  weight, objectiveNA, objectiveRI, illuminationWavelength, handles);
AOPhase = basePhase-basePhase0-weightSet(k)*modalPhase;


