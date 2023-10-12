close all;
%% Settings
%imageFolder = '/Volumes/New Volume/Coaxial_80bar_Free_Zoom'; % James Laptop
imageFolder = 'F:/Coaxial_80bar_Free_Zoom'; % James Desktop
timeDataPath = "Timestamp_Current\Coaxial_80bar_Free_Zoom_new.csv";

filePattern = 'Cam_*.tif'; 

intervalCount = 24;

% Sample image index
sampleImageIndex = 2000;

% Droplet threshold value
dropletThreshold = 70;

%
rescaleFactor = 0.2;

% Frame rate
frameRate = 1040; % Hz

%% Load Images and data (First run only)
% This code will only run if you have selected a different data source or
% if it is the first time running the code this session
if(~exist('images','var') || isempty(images) || ~isequal(LoadImages(imageFolder, filePattern, 1), images(1)))
    [images, imageCount] = LoadImages(imageFolder, filePattern);
    [timeData, pressureData, flowRateData, manTempData, tankTempData] = LoadTimeData(timeDataPath);
end

%% Processing
% Processing to determine background image and to determine mean spray image
[avgBackgroundImage, avgSprayImage, backgroundEndIndex] = FindBackground(images);

% Average the image a specified number of times
intervals = floor(linspace(backgroundEndIndex, imageCount, intervalCount + 1));

% Interpolate 
intervalTimes = (0.5*(intervals(1:end-1)+intervals(2:end)) / frameRate)';
pressuresAtIntervalTimes = interp1(timeData, pressureData, intervalTimes);


% Background image subtraction (not super important for finding spray angle, but I thought that i would try it out)
backgroundRemoved = cell(imageCount, 1);
for k = 1:imageCount
    backgroundRemoved{k} = RemoveBackground(avgBackgroundImage, images{k});
end
% Resize Images and crop
croppedImages = cell(imageCount, 1);
for k = 1:imageCount
    currentImage = backgroundRemoved{k};
    crop_region = [60, 0, 300, size(currentImage,1)];
    croppedImages{k} = imcrop(currentImage, crop_region);   
end
% Threshold Images
threshImages = cell(imageCount, 1);
for k = 1:imageCount
    currentImage = croppedImages{k};
    level = graythresh(currentImage);
    threshImages{k} = ~imbinarize(currentImage, level);   
end
% bwareaaopen
bwareaImages = cell(imageCount, 1);
for k = 1:imageCount
    bwareaImages{k} = bwareaopen(threshImages{k}, 5);   
end

% Accumulate droplet distributions in the intervals
areaDistributions = cell(intervalCount, 1);
SMDs = zeros(intervalCount, 1);
for k = 1:intervalCount
    areaDistributions{k} = [];
    for i = intervals(k):intervals(k+1)
        stats = regionprops('table', bwareaImages{i} , 'Area');
        areaDistributions{k} = [areaDistributions{k};stats.Area];
    end
    areaDistributions{k} = (areaDistributions{k}*0.04^2).^(1/2);
end

for k = 1:intervalCount
    anss = areaDistributions{k};
    SMDs(k) = mean(anss(anss < 1));
end

figure()
subplot(3,3,1)
imshow(images{sampleImageIndex});
subplot(3,3,2)
imshow(backgroundRemoved{sampleImageIndex});
subplot(3,3,3)
imshow(croppedImages{sampleImageIndex});
subplot(3,3,4)
imshow(threshImages{sampleImageIndex});
subplot(3,3,5)
imshow(bwareaImages{sampleImageIndex});

%% Droplet detection

%% Plotting 
shouldPlotDetailed = true;
if (shouldPlotDetailed)
    subplotCols = ceil(sqrt(intervalCount));
    subplotRows = ceil(intervalCount / subplotCols);
    % Plot images 
    figure(10)
    for k = 1:intervalCount
        subplot(subplotRows, subplotCols, k);
        data = areaDistributions{k};
        histogram(data(data < 1), 50)
        title(num2str(k));
    end
end

correctedPressures = polyval(polyfit(intervalTimes(14:end),pressuresAtIntervalTimes(14:end),1),intervalTimes);

figure()
hold on
yyaxis left
plot(1:24, SMDs);
yyaxis right
plot(1:24,correctedPressures);

figure()
plot(correctedPressures, SMDs, ".");
title("Mean droplet size vs Pressure")
xlabel("Pressure (Pa)");
ylabel("Droplet SMD (mm)")
grid on

figure()
data = areaDistributions{24};
histogram(data(data < 1), 50);
hold on
data = areaDistributions{1};
histogram(data(data < 1), 50);
title("Comparison of Droplet Size Distributions")
xlabel("Droplet Diameter (mm)");
ylabel("No. of Droplets")
legend("P = 1.7MPa", "P = 2.5MPa")
grid on


