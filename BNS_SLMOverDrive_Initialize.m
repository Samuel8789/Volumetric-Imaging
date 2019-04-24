function [ sdk ] = BNS_SLMOverDrive_Initialize( regionalLUTfileName, SLMInitializationImageFileName )
%BNS_SLMOVERDRIVE_INITIALIZE Summary of this function goes here
%   Detailed explanation goes here

% this code is used to initialize SLM with overdrive

% Load the library
loadlibrary('Blink_SDK_C.dll', 'Blink_SDK_C_matlab.h');

% Basic parameters for calling Create_SDK
bit_depth = 8;
slm_resolution = 512;
num_boards_found = libpointer('uint32Ptr', 0);
constructed_okay = libpointer('int32Ptr', 0);
is_nematic_type = 1;
RAM_write_enable = 1;
use_GPU = 1;
max_transients = 10;

% OverDrive Plus Parameters
lut_file = regionalLUTfileName;

% Basic SLM parameters
true_frames = 3;

% Blank calibration image
cal_image = imread(SLMInitializationImageFileName);

sdk = calllib('Blink_SDK_C', 'Create_SDK', bit_depth, slm_resolution, num_boards_found, constructed_okay, is_nematic_type, RAM_write_enable, use_GPU, max_transients, lut_file);

if constructed_okay.value == 0
    disp('Blink SDK was not successfully constructed');
    disp(calllib('Blink_SDK_C', 'Get_last_error_message', sdk));
    calllib('Blink_SDK_C', 'Delete_SDK', sdk);
else
    disp('Blink SDK was successfully constructed');
    fprintf('Found %u SLM controller(s)\n', num_boards_found.value);
    % Set the basic SLM parameters
    calllib('Blink_SDK_C', 'Set_true_frames', sdk, true_frames);
    % A blank calibration file must be loaded to the SLM controller
    calllib('Blink_SDK_C', 'Write_cal_buffer', sdk, 1, cal_image);
    % A linear LUT must be loaded to the controller for OverDrive Plus
    calllib('Blink_SDK_C', 'Load_linear_LUT', sdk, 1);
        
    % Turn the SLM power on
    calllib('Blink_SDK_C', 'SLM_power', sdk, 1);
end