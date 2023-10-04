%% Settings
imageFolder = '/Volumes/New Volume/Coaxial_LP_Free_Zoom/Coaxial_LP_Free_Zoom';

% Files adhere to the following pattern
filePattern = fullfile(imageFolder, 'Cam_*.tif');

% Sample image index
sampleImageIndex = 1000;

% Droplet threshold value (Should be determined algorythmically in the
% future)
dropletThreshold = 70;

%% Load Images (First run only)
if(~exist('images','var'))
    files = dir(filePattern);
    % Preallocate a matrix for holding the mean brightness of each frame
    meanBrightness = zeros(length(files),1);
    % Preallocate a cell array to hold images
    images = cell(length(files), 1);
    for k = 1 : length(files)
      % Load and store images with imread. 
      baseFileName = files(k).name;
      fullFileName = fullfile(imageFolder, baseFileName);
      currentImage = imread(fullFileName);
      images{k} = currentImage;
      
      % Add image to meanBrightness array. Average twice to reduce both
      % dimensions
      meanBrightness(k) = mean(mean(currentImage));
    end
end

% Background Brightness threshold. This is used to automatically determine
% the mmaximum brightness of an image before it is determined to be a
% background image
backgroundBrightnessThreshold = 0.5*max(meanBrightness) + 0.5 * min(meanBrightness);

%% Processing to determine background image and to determine mean spray image
% Preallocate a matrix to hold the sum of all images, both background and
% spray
sprayImagesSum = [];
backgroundImagesSum = [];

for k = 1 : length(images)
  % Read in image as an array with imread()
  currentImage = images{k};
  
  % Add current image to respective sum
  if (meanBrightness(k) < backgroundBrightnessThreshold)
      if isempty(sprayImagesSum)
        % If sumImage is empty, initialize it with the current image
        sprayImagesSum = double(currentImage);
      else
        % Otherwise, add the current image to sumImage
        sprayImagesSum = sprayImagesSum + double(currentImage);
      end
  else
      if isempty(backgroundImagesSum)
        % If sumImage is empty, initialize it with the current image
        backgroundImagesSum = double(currentImage);
      else
        % Otherwise, add the current image to sumImage
        backgroundImagesSum = backgroundImagesSum + double(currentImage);
      end
  end
end

% Compute number of images for each average
sprayImagesLength = sum(meanBrightness < backgroundBrightnessThreshold);
backgroundImagesLength = sum(meanBrightness >= backgroundBrightnessThreshold);

% Compute the average spray image
avgSprayImage = sprayImagesSum / sprayImagesLength;
% Convert back to uint8 for display purposes
avgSprayImage = uint8(avgSprayImage);
% Compute the average background image
avgBackgroundImage = backgroundImagesSum / backgroundImagesLength;
% Convert back to uint8 for display purposes
avgBackgroundImage = uint8(avgBackgroundImage);

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




%% Function Definition
function processedImage = RemoveBackground(background, spray)
    difference = double(spray) - double(background);
    % Rescale the image so all brightness values sit in the uint8 range
    difference = (difference - min(difference(:))) / (max(difference(:)) - min(difference(:)));
    % Convert difference back to uint8 for display
    processedImage = im2uint8(difference);
end