decodedStream = Decoder('test.bin');
k = uint16(decodedStream);

matrix_pointer = 1;
max_matrix_ptr = length(k);

cell_blocks = cell(1, 64*64);

i = 1;
while matrix_pointer < max_matrix_ptr
    block_numbers = k(matrix_pointer);
    matrix_pointer = matrix_pointer + 1;

    cell_blocks{i} = reconstructBlock(k(matrix_pointer:matrix_pointer+(block_numbers-1)), ...
        block_numbers);
    
    i = i + 1;
    matrix_pointer = matrix_pointer + block_numbers;
end

recon_image = reshape(cell_blocks, [64,64]);

quantizMatrix = [16 11 10 16 24 40 51 61; 
                12 12 14 19 26 58 60 55;
                14 13 16 24 40 57 69 56; 
                14 17 22 29 51 87 80 62;
                18 22 37 56 68 109 103 77;
                24 35 55 64 81 104 113 92;
                49 64 78 87 103 121 120 101;
                72 92 95 98 112 100 103 99];
            
unquant_image = cellfun(@(x) double(x).*quantizMatrix, recon_image, ...
    'UniformOutput', false);

undct_image = cellfun(@idct2, unquant_image, 'UniformOutput', false);

imwrite(cell2mat(undct_image), 'new_lena.jpg');
imshow('new_lena.jpg');