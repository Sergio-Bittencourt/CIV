% FUNCTION image2blocks
% 
%   Separates an image matrix into NxN blocks.
%
%   [imBlocks] = (imMatrix, blockParam)
%       imMatrix: Chosen image in double matrix form
%       imSize:   Image height or width
%       N:        Parameter used to determine the size of the blocks
%       imBlocks: Cell array that contains the image blocks
% 
function imBlocks = image2blocks(imMatrix, imSize, N)

% If N isn't passed to the function set its default value to 8.
if nargin < 3
    N = 8;
end

% Calculate the number of NxN blocks that can be created.
numberOfBlocks = imSize./N;

% Generate the blocks.
imBlocks = mat2cell(imMatrix, repmat(N, numberOfBlocks,1), ...
    repmat(N, numberOfBlocks,1)); 
end