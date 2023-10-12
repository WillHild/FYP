close all;
%% Settings
%imageFolder = '/Volumes/New Volume/Coaxial_80bar_Free_Zoom'; % James Laptop
imageFolder = 'F:\Angle_80bar_Free_Zoom'; % James Desktop
timeDataPath = "Timestamp_Current\Angled_80bar_Free_Zoom.csv";

filePattern = 'Cam_*.tif'; 

intervalCount = 30;

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
% Preallocate means array 
intervalMeans = cell(intervalCount, 1);
intervalTimes = (0.5*(intervals(1:end-1)+intervals(2:end)) / frameRate)';
pressuresAtIntervalTimes = interp1(timeData, pressureData, intervalTimes);
for k = 1:intervalCount
    startIndex = intervals(k);
    endIndex = intervals(k + 1);
    intervalImages = images(startIndex:endIndex);
    intervalMeans{k} = uint8(mean(cat(3, intervalImages{:}), 3));
end
% Background image subtraction (not super important for finding spray angle, but I thought that i would try it out)
meanBackgroundRemoved = cell(intervalCount, 1);
for k = 1:intervalCount
    meanBackgroundRemoved{k} = RemoveBackground(avgBackgroundImage, intervalMeans{k});
end
% Resize Images and crop
resizedImages = cell(intervalCount, 1);
croppedImages = cell(intervalCount, 1);
for k = 1:intervalCount
    currentImage = meanBackgroundRemoved{k};
    crop_region = [40, 0, size(currentImage,2)/2 - 100, size(currentImage,1)/2 - 400];
    croppedImages{k} = imcrop(currentImage, crop_region);
    resizedImages{k} = imresize(croppedImages{k},rescaleFactor);
    
end

% Canny edge detection to calculate cone angles
meanEdgeDetected = cell(intervalCount, 1);
for k = 1:intervalCount
    meanEdgeDetected{k} = edge(resizedImages{k}, 'sobel');
end
% Crop images and find angles
angles = zeros(intervalCount,1);
lineGroups = cell(intervalCount, 1);

for k = 1:intervalCount
    % Define crop region
    currentImage = meanEdgeDetected{k};
    [angles(k), lineGroups{k}] = FindAngles(meanEdgeDetected{k});
end
% Correct for qeird angled stuff
angles = 68 - 180 + angles;
%% Plotting 
shouldPlotDetailed = true;
if (shouldPlotDetailed)
    subplotCols = ceil(sqrt(intervalCount));
    subplotRows = ceil(intervalCount / subplotCols);
    % Plot images 
    figure(10)
    for k = 1:intervalCount
        subplot(subplotRows, subplotCols, k);
        imshow(uint8(intervalMeans{k}))
        title(num2str(k));
    end
    % Plot images with background subtracted
    figure(11)
    for k = 1:intervalCount
        subplot(subplotRows, subplotCols, k);
        imshow(uint8(meanBackgroundRemoved{k}))
        title(num2str(k));
    end
    % Plot resized images
    figure(12)
    for k = 1:intervalCount
        subplot(subplotRows, subplotCols, k);
        imshow(resizedImages{k})
        title(num2str(k));
    end
    % Plot images with canny edge detection
    figure(13)
    for k = 1:intervalCount
        subplot(subplotRows, subplotCols, k);
        imshow(meanEdgeDetected{k})
        title(num2str(k));
    end
    % Plot images with canny edge detection
    figure(13)
    for k = 1:intervalCount
        subplot(subplotRows, subplotCols, k);
        imshow(meanEdgeDetected{k})
        title(num2str(k));
    end
    
    % Display original image with detected lines overlaid
    figure(14);
    for i = 1:intervalCount
        currentImage = resizedImages{i};
        subplot(subplotRows, subplotCols, i);
        imshow(currentImage);
        title(num2str(i));
        hold on;
        lineGroup = lineGroups{i};
        for k = 1:length(lineGroup)
           line = lineGroup(k);
           point1 = line.point1;
           point2 = line.point2;
           % Plot line on the figure
           xy = [point1; point2];
           plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        end
        hold off;
    end
end

%% Plot cone angle for 10 shots
figure(5);
correctedPressures = polyval(polyfit(intervalTimes(14:end),pressuresAtIntervalTimes(14:end),1),intervalTimes);
plot(correctedPressures, angles, "*");
title("Spray Angle vs Pressure (Single Jet)")
xlabel("Pressure (Pa)")
ylabel("Cone Angle (deg)")
grid on

figure();
title("Spray Angle and Pressure over time")
yyaxis left
plot(intervalTimes, angles)
xlabel("Time (s)")
ylabel("Cone Angle (deg)")
yyaxis right
hold on
%plot(timeData, pressureData)
plot(intervalTimes, correctedPressures)
xlabel("Time (s)")
ylabel("Pressure (Pa)")
hold off


difference = RemoveBackground(avgBackgroundImage, avgSprayImage);

sampleSprayImage = RemoveBackground(avgBackgroundImage, images{sampleImageIndex});

corr(correctedPressures, angles)