function [images, numLoaded] = LoadImages(folderPath, filePattern, numImages)
% LOADIMAGES Load images from a folder.
%   [IMAGES, NUMLOADED] = LOADIMAGES(FOLDERPATH) loads all the images in the folder
%   specified by FOLDERPATH and returns them in a cell array IMAGES. It also returns
%   the number of images loaded as NUMLOADED.
%
%   [IMAGES, NUMLOADED] = LOADIMAGES(FOLDERPATH, FILEPATTERN) loads all the images in the
%   folder specified by FOLDERPATH that match the pattern specified by
%   FILEPATTERN and returns them in a cell array IMAGES. It also returns
%   the number of images loaded as NUMLOADED.
%
%   [IMAGES, NUMLOADED] = LOADIMAGES(FOLDERPATH, FILEPATTERN, NUMIMAGES) loads the first
%   NUMIMAGES images in the folder specified by FOLDERPATH that match the
%   pattern specified by FILEPATTERN and returns them in a cell array IMAGES. It also returns
%   the number of images loaded as NUMLOADED.
    % If filePattern is not provided, use the default pattern 'Cam_*.tif'.
    if nargin < 2
        filePattern = 'Cam_*.tif';
    end
    
    % If numImages is not provided, load all images.
    if nargin < 3
        numImages = Inf;
    end
    
    % Find all files with the specified pattern.
    filePattern = fullfile(folderPath, filePattern);
    files = dir(filePattern);
    
    % Preallocate a cell array to hold images.
    images = cell(min(length(files), numImages), 1);

    % Load and store images with imread.
    for k = 1 : min(length(files), numImages)
        baseFileName = files(k).name;
        fullFileName = fullfile(folderPath, baseFileName);
        currentImage = imread(fullFileName);
        images{k} = currentImage;
    end
    
    % Return the number of images loaded.
    numLoaded = length(images);
end
