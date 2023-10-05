% FINDBACKGROUND - This function computes the average spray and background images from a set of images.
%   [AVERAGEBACKGROUND, AVERAGESPRAY, BACKGROUNDENDINDEX] = FINDBACKGROUND(IMAGES) computes the average spray and background images from a set of images.
%   The function also returns the index of the first image with an average brightness less than the threshold.
function [averageBackground, averageSpray, backgroundEndIndex] = FindBackground(images)
    backgroundEndIndex = 0;
    imageCount = length(images);
    meanBrightness = zeros(imageCount,1);

    % Calculate a brightness distribution.
    for k = 1 : length(images)
        currentImage = images{k};
        meanBrightness(k) = mean(mean(currentImage));
    end

    % Background Brightness threshold. This is used to automatically determine
    % the maximum brightness of an image before it is determined to be a
    % background image
    backgroundBrightnessThreshold = 0.5*max(meanBrightness) + 0.5 * min(meanBrightness);

    % Define arrays before use
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
      
      % Compute the index of the first image with an average brightness less than the threshold.
      if (meanBrightness(k) < backgroundBrightnessThreshold && backgroundEndIndex == 0)
          backgroundEndIndex = k;
      end
      
    end

    % Compute number of images for each average
    sprayImagesLength = sum(meanBrightness < backgroundBrightnessThreshold);
    backgroundImagesLength = sum(meanBrightness >= backgroundBrightnessThreshold);

    % Compute the average spray image
    averageSpray = sprayImagesSum / sprayImagesLength;
    % Convert back to uint8 for display purposes
    averageSpray = uint8(averageSpray);
    
    % Compute the average background image
    averageBackground = backgroundImagesSum / backgroundImagesLength;
    % Convert back to uint8 for display purposes
    averageBackground = uint8(averageBackground);
end
