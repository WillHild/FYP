close all;
%% Settings
%imageFolder = '/Volumes/New Volume/Coaxial_80bar_Free_Zoom'; % James Laptop
imageFolder = 'F:/Coaxial_80bar_Free_Zoom'; % James Desktop

filePattern = 'Cam_*.tif'; 

intervalCount = 10;

% Sample image index
sampleImageIndex = 2000;

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

%% Average the image a specified number of times
intervals = floor(linspace(backgroundEndIndex, imageCount, intervalCount + 1));
% Preallocate means array 
intervalMeans = cell(intervalCount + 1, 1);
for k = 1:intervalCount
    startIndex = intervals(k);
    endIndex = intervals(k + 1);
    intervalImages = images(startIndex:endIndex);
    intervalMeans{k} = uint8(mean(cat(3, intervalImages{:}), 3));
end
%% Background image subtraction (not super important for finding spray angle, but I thought that i would try it out)
meanBackgroundRemoved = cell(intervalCount + 1, 1);
for k = 1:intervalCount
    meanBackgroundRemoved{k} = RemoveBackground(avgBackgroundImage, intervalMeans{k});
end
%% Canny edge detection to calculate cone angles
meanEdgeDetected = cell(intervalCount + 1, 1);
for k = 1:intervalCount
    meanEdgeDetected{k} = edge(imresize(intervalMeans{k},0.1), 'canny');
end
%% Crop images and find angles
for k = 1:intervalCount
    angles(k) = FindAngles(imresize(meanBackgroundRemoved{k},0.1));
end


%% Plot images 
figure(10)
for k = 1:intervalCount
    subplot(4, 3, k);
    imshow(uint8(intervalMeans{k}))
    title(num2str(k));
end
%% Plot images with background subtracted
figure(11)
for k = 1:intervalCount
    subplot(4, 3, k);
    imshow(uint8(meanBackgroundRemoved{k}))
    title(num2str(k));
end
%% Plot images with canny edge detection
figure(12)
for k = 1:intervalCount
    subplot(4, 3, k);
    imshow(meanEdgeDetected{k})
    title(num2str(k));
end

%% Plot cone angle for 10 shots
figure();
plot(1:10, angles);


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




