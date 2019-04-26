% This set of codes analyze the images acquired by ScanImage for the same
% Zernike mode but different phase amplitudes. One can then choose the best
% phase amplitude as a correction weight for that Zernike mode. 
% This program should be run in conjunction with "AdaptiveOptics_modal.m".
% Refer "AdaptiveOptics_modal.m" for more details.

% Author: Weijian Yang, Shuting Han, 2017-2019

%% set up parameters
% file path
dpath = '\ImageStoragePath';
fnames = dir([dpath '\*.tif']);

% weight parameters
w = 5;
dw = w/20;
wVec = -w:dw:w;
wVecNum = length(wVec);

fnames = fnames(end-wVecNum:end-1);

%% calculate average image
im_avg = double(imread([dpath '\' fnames(1).name]));
for n = 1:wVecNum
    im = double(imread([dpath '\' fnames(n).name]));
    im_avg = im_avg+im;
end

%% select region
figure; imagesc(im_avg); axis equal tight
title('select ROI')
bbox = round(getrect);
close

%% calculate region intensity in each image
dmat = zeros(wVecNum,1);
for m = 1:wVecNum
    im = double(imread([dpath '\' fnames(m).name]));
    im = im(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
    dmat(m) = mean(im(:));
end

% find maximum
[max_val,max_indx] = max(dmat);
fprintf('Max index: %u\n',max_indx);

figure;
plot(dmat);
hold on;
scatter(max_indx,max_val,'r*');
title(['Max index: ' num2str(max_indx)]);


