% FUNCTION encode JPEG
%   
%   Encodes a grayscale image with JPEG.
%
%   
function encodeJPEG(imageFilename)

% Reads image in imageFilename into a matrix and read the images'
% dimensions.
imageMatrix = double(imread(imageFilename));
[imageSize, ~] = size(imageMatrix);

% Separates imageMatrix into a cell array of 8x8 blocks.
imageBlocks = image2blocks(imageMatrix, imageSize);

% Performs a DCT transform on all blocks.
imageBlocksDCT = cellfun(@dct2, imageBlocks, 'UniformOutput', false);

% Define a standard quantization matrix (Pls dont kill me)
% TEMPORARY SOLUTION CREATE BETTER QUANTIZATION LATER
quantizMatrix = [16 11 10 16 24 40 51 61; 
                12 12 14 19 26 58 60 55;
                14 13 16 24 40 57 69 56; 
                14 17 22 29 51 87 80 62;
                18 22 37 56 68 109 103 77;
                24 35 55 64 81 104 113 92;
                49 64 78 87 103 121 120 101;
                72 92 95 98 112 100 103 99];

% Quantize DCT coefficients in image blocks.
imageQuantizDCT = cellfun(@(x) round(x./quantizMatrix), imageBlocksDCT, ...
    'UniformOutput', false);

% Read all blocks using the zigzag algorithm.
imageZigzag = cellfun(@runlengthcode, imageQuantizDCT);
end