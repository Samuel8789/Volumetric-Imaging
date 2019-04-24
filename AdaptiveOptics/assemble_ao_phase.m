% This code is used to assemble the correction mask for different
% imaging depths (obtained in "AdaptiveOptics_modal.m") into a single 
% calibration file, which can then be used as part of the calibration in
% "ImagingControl.m" when performing volumetric imaging. 

% Author: Weijian Yang, Shuting Han, 2017-2019

fname = {'AOPhase_M200um','AOPhase_M100um','AOPhase_0um','AOPhase_P100um','AOPhase_P200um'};
depth = [-200,-100,0,100,200]*1e-6;

num_file = length(fname);
AOPhase = zeros(SLMm,SLMn,num_file);

for n = 1:num_file
    ld = load([fname{n} '.mat']);
    AOPhase(:,:,n) = ld.AOPhase;
end

save('AOCal_20171130_withOffsetLens.mat','AOPhase','depth');