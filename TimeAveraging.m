%% Settings
%imageFolder = '/Volumes/New Volume/Coaxial_80bar_Free_Zoom'; % James Laptop
imageFolder = 'F:/Coaxial_80bar_Free_Zoom'; % James Desktop

filePattern = 'Cam_*.tif'; 

% Sample image index
sampleImageIndex = 1000;

% Droplet threshold value
dropletThreshold = 70;

%% Load Images (First run only)
% This code will only run if you have selected a different data source or
% if it is the first time running the code this session
if(~exist('images','var') || isempty(images) || ~isequal(LoadImages(imageFolder, filePattern, 1), images(1)))
    [images, imageCount] = LoadImages(imageFolder, filePattern);
end

%% Processing to determine background image and to determine mean spray image
[avgBackgroundImage, avgSprayImage, backgroundEndIndex] = FindBackground(images);

%% Background image subtraction (not super important for finding spray angle, but I thought that i would try it out)
% Cast both images to doubles so that the subtraction can return negative
% values.
difference = RemoveBackground(avgBackgroundImage, avgSprayImage);

sampleSprayImage = RemoveBackground(avgBackgroundImage, images{sampleImageIndex});

%% Droplet detection
% Threshold the image. Necessary first step for regionProps droplet
% detection
thresholdedImage = (sampleSprayImage < dropletThreshold);
% Remove droplets smaller than a given size (to remove noise)
noiseRemoved = bwareaopen(thresholdedImage, 5);
% Measure properties of connected components
stats = regionprops('table', noiseRemoved, 'Area');

%% Plotting and presentation
figure(1)
subplot(2,2,1)
imshow(uint8(images{sampleImageIndex}))
subplot(2,2,2)
imshow(sampleSprayImage)
subplot(2,2,3)
imshow(thresholdedImage)
subplot(2,2,4)
imshow(noiseRemoved)

% Histogram of droplet sizes
figure(2)
data = stats.Area;
% Compute the mean and standard deviation of the data
mu = mean(data);
sigma = std(data);
% Define a threshold for outliers in standard deviations
threshold = 2;
% Find outliers
outliers = abs(data - mu) > threshold * sigma;
% Remove outliers
dataTrimmed = data(~outliers);

histogram(dataTrimmed);
xlabel('Area');
ylabel('Frequency');
title('Histogram of Droplet Sizes');




