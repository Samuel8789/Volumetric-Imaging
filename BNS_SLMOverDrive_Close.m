function BNS_SLMOverDrive_Close( sdk )
%BNS_SLM_CLOSE_OVERDRIVE Summary of this function goes here
%   Detailed explanation goes here

% this code is used to close SLM with overdrive

calllib('Blink_SDK_C', 'Delete_SDK', sdk);
unloadlibrary('Blink_SDK_C');
disp('Blink SDK was successfully closed');

end

