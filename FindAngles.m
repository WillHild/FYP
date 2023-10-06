function [angle, lines] = FindAngles(image)
%FINDRIGHTMOSTANGLE Summary of this function goes here
%   Detailed explanation goes here

% Define crop region
crop_region = [size(image,2)/2, size(image,1)/2, size(image,2)/2 - 12, size(image,1)/2];

% Crop image using specified region
image = imcrop(image, crop_region);

iEdge = edge(image, 'canny');

% Define Hough transform parameters
thetaResolution = 0.5;
rhoResolution = 0.5;

% Detect lines using Hough transform
[H,T,R] = hough(iEdge,'Theta',-90:thetaResolution:89,...
    'RhoResolution',rhoResolution);

% Find peaks in Hough transform matrix
numPeaks = 3;
peaks = houghpeaks(H,numPeaks);

% Extract lines from Hough transform matrix using peaks
lines = houghlines(iEdge,T,R,peaks,'FillGap',5,'MinLength',7);

% Find midpoint of each line and sort by x-coordinate
midpoints = zeros(length(lines), 2);
for k = 1:length(lines)
    point1 = lines(k).point1;
    point2 = lines(k).point2;
    midpoints(k,:) = [(point1(1) + point2(1))/2, (point1(2) + point2(2))/2];
end
[~, idx] = sort(midpoints(:,1), 'descend');

% Calculate angle of rightmost line
point1 = lines(idx(1)).point1;
point2 = lines(idx(1)).point2;
angle = atan2(point2(2)-point1(2), point2(1)-point1(1));
if angle < 0
    angle = angle + pi;
end
angle = rad2deg(angle);

% Display original image with detected lines overlaid
figure;
imshow(image);
hold on;
for k = 1:length(lines)
   point1 = lines(k).point1;
   point2 = lines(k).point2;
   % Plot line on the figure
   xy = [point1; point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end

end