% FUNCTION encode JPEG
%   
%   Encodes a grayscale image with JPEG.
%
%   
function encodeJPEG(imageFilename)

% Reads image in imageFilename into a matrix.
imageMatrix = imread(imageFilename);

% Separates imageMatrix into a cell array of 8x8 blocks.
[imageBlocks] = image2blocks(imageMatrix);

end