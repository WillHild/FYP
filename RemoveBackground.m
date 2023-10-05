% REMOVEBACKGROUND - This function removes the background from a spray
% image and rescales it to fill the range 0-255
%   PROCESSEDIMAGE = REMOVEBACKGROUND(BACKGROUND, SPRAY) removes the 
%   background from a spray image.
%   The function takes two input arguments: BACKGROUND and SPRAY. It 
%   returns the processed image as PROCESSEDIMAGE.
function processedImage = RemoveBackground(background, spray)
    difference = double(spray) - double(background);
    % Rescale the image so all brightness values sit in the uint8 range
    difference = (difference - min(difference(:))) / (max(difference(:)) - min(difference(:)));
    % Convert difference back to uint8 for display
    processedImage = im2uint8(difference);
end