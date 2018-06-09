% FUNCTION encode JPEG
%   
%   Encodes a grayscale image with JPEG.
%
%   
function encodeJPEG(imageFilename)

% Reads image in imageFilename into a matrix and read the images'
% dimensions.
imageMatrix = imread(imageFilename);
[imageSize, ~] = size(imageMatrix);

% Separates imageMatrix into a cell array of 8x8 blocks.
[imageBlocks] = image2blocks(imageMatrix, imageSize);

end