DEFAULT_WIDTH = 64;
DEFAULT_HEIGHT = 64;

image_name = 'baboon';

[raw_stream, offset] = huffDecode(strcat(image_name, '.bin'));
decoded_stream = double(raw_stream) - str2double(offset);

matrix_pointer = 1;
max_matrix_ptr = length(decoded_stream);

cell_blocks = cell(1, DEFAULT_WIDTH*DEFAULT_HEIGHT);

itr = 1;
while matrix_pointer < max_matrix_ptr
    block_numbers = decoded_stream(matrix_pointer);
    if ~(decoded_stream(matrix_pointer))
        break;
    end
    matrix_pointer = matrix_pointer + 1;

    cell_blocks{itr} = reconstructBlock(decoded_stream(matrix_pointer:matrix_pointer+(block_numbers-1)), ...
        block_numbers);
    
    itr = itr + 1;
    matrix_pointer = matrix_pointer + block_numbers;
end

recon_image = reshape(cell_blocks, [DEFAULT_WIDTH,DEFAULT_HEIGHT]);

quantizMatrix = [16 11 10 16 24 40 51 61; 
                12 12 14 19 26 58 60 55;
                14 13 16 24 40 57 69 56; 
                14 17 22 29 51 87 80 62;
                18 22 37 56 68 109 103 77;
                24 35 55 64 81 104 113 92;
                49 64 78 87 103 121 120 101;
                72 92 95 98 112 100 103 99];
            
unquant_image = cellfun(@(x) x.*quantizMatrix, recon_image, ...
    'UniformOutput', false);

undct_image = cellfun(@idct2, unquant_image, 'UniformOutput', false);

image = cell2mat(undct_image);
image = image - min(image(:));
image = image/max(image(:));

imwrite(image, strcat(image_name, '.bmp'));
imshow(strcat(image_name, '.bmp'));