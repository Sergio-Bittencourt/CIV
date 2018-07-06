filename = 'VideoDatabase/foreman_qcif_174x144_30.yuv';

MovementVectorName = strrep(filename, '.yuv', '_info.bin');
encodedYname = strrep(filename, '.yuv', '_y_encoded.bin');
encodedUname = strrep(filename, '.yuv', '_u_encoded.bin');
encodedVname = strrep(filename, '.yuv', '_v_encoded.bin');

EncodedMVid = fopen(MovementVectorName, 'r');

%% Parsing the informations at Header

MVheader = fgetl(EncodedMVid);

MVHeader = strsplit(MVheader, ' ');
HeightVideo = double(str2num(MVHeader{1}));
WidthVideo = double(str2num(MVHeader{2}));
NumberOfFrames = double(str2num(MVHeader{3}));
macroblockLength = double(str2num(MVHeader{4}));
NumberOfBlocksPerFrame =  WidthVideo*HeightVideo/macroblockLength^2;
NumberOfBlocks =  WidthVideo*HeightVideo*NumberOfFrames/macroblockLength^2;

MVBits = double(str2num(MVHeader{5}));
MVbitsUsed = (WidthVideo*HeightVideo*NumberOfFrames*MVBits)/macroblockLength^2;

%% Decoding the Movement Vector through a simple split, knowing they we're coded by a Fixed Length Code 

FixedLengthEncodedMV = fread(EncodedMVid, [1, inf], 'uint8');
FixedLengthEncodedMV = arrayfun(@(x) dec2bin(x, 8), FixedLengthEncodedMV, 'UniformOutput', false);
FixedLengthEncodedMV = cell2mat(FixedLengthEncodedMV);
FixedLengthEncodedMV = FixedLengthEncodedMV(1:MVbitsUsed);
MovementVector = reshape(FixedLengthEncodedMV, MVBits, [])';
MovementVector = bin2dec(MovementVector);
MovementVector = reshape(MovementVector, [HeightVideo/macroblockLength, WidthVideo/macroblockLength, NumberOfFrames]);

%% Recovering Movement Vector

% residuesOfYrle = huffDecode(encodedYname);
file_id = fopen('Yrle.txt','r');
residuesOfYrle = fread(file_id, [1,inf], 'char');
residuesOfYrle = char(residuesOfYrle);
residuesOfYrle = strsplit(residuesOfYrle, ' ');
residuesOfYrle = cellfun(@str2double, residuesOfYrle, 'UniformOutput', false);

% residuesOfUrle = huffDecode(encodedUname);
file_id = fopen('Urle.txt','r');
residuesOfUrle = fread(file_id, [1,inf], 'char');
residuesOfUrle = char(residuesOfUrle);
residuesOfUrle = strsplit(residuesOfUrle, ' ');
residuesOfUrle = cellfun(@str2double, residuesOfUrle, 'UniformOutput', false);

% residuesOfVrle = huffDecode(encodedVname);
file_id = fopen('Vrle.txt','r');
residuesOfVrle = fread(file_id, [1,inf], 'char');
residuesOfVrle = char(residuesOfVrle);
residuesOfVrle = strsplit(residuesOfVrle, ' ');
residuesOfVrle = cellfun(@str2double, residuesOfVrle, 'UniformOutput', false);
 
ResiduesOfY = cell(HeightVideo/macroblockLength, WidthVideo/macroblockLength, NumberOfFrames);
ptr = 1;
i=1;
while ptr<length(residuesOfYrle)
	element_number = cell2mat(residuesOfYrle(ptr));
    if element_number == 0;
        ResiduesOfY{i} = UnRLE(element_number, element_number, macroblockLength);
    end
	if(ptr+element_number<length(residuesOfYrle))
		block = cell2mat(residuesOfYrle(ptr+1:ptr+element_number)); 
		ResiduesOfY{i} = UnRLE(block, element_number, macroblockLength);
    else
        block = cell2mat(residuesOfYrle(ptr+1:end));
        ResiduesOfY{i} = UnRLE(block, element_number, macroblockLength);
	end
	ptr = ptr + element_number + 1;
    i = i+1;
end
 
ResiduesOfV = cell(HeightVideo/(macroblockLength), WidthVideo/(macroblockLength), NumberOfFrames);
ptr = 1;
i=1;
while ptr<length(residuesOfVrle)
	element_number = cell2mat(residuesOfVrle(ptr));
    if element_number == 0;
        ResiduesOfV{i} = UnRLE(element_number, element_number, macroblockLength);
    end
	if(ptr+element_number<length(residuesOfVrle))
		block = cell2mat(residuesOfVrle(ptr+1:ptr+element_number)); 
		ResiduesOfV{i} = UnRLE(block, element_number, macroblockLength/2);
    else
        block = cell2mat(residuesOfVrle(ptr+1:end));
        ResiduesOfV{i} = UnRLE(block, element_number, macroblockLength/2);
	end
	ptr = ptr + element_number + 1;
    i = i+1;
end

ResiduesOfU = cell(HeightVideo/(macroblockLength), WidthVideo/(macroblockLength), NumberOfFrames);
ptr = 1;
i=1;
while ptr<length(residuesOfUrle)
	element_number = cell2mat(residuesOfUrle(ptr));
    if element_number == 0;
        ResiduesOfU{i} = UnRLE(element_number, element_number, macroblockLength);
    end
	if(ptr+element_number<length(residuesOfUrle))
		block = cell2mat(residuesOfUrle(ptr+1:ptr+element_number)); 
		ResiduesOfU{i} = UnRLE(block, element_number, macroblockLength/2);
    else
        block = cell2mat(residuesOfUrle(ptr+1:end));
        ResiduesOfU{i} = UnRLE(block, element_number, macroblockLength/2);
	end
	ptr = ptr + element_number + 1;
    i = i+1;
end
 

%% Decoding 

if macroblockLength==16
    
    quantizMatrix = [7 7 7 7 7 7 8 8 9 9 10 11 12 13 14 15;
                     7 7 7 7 7 8 8 9 9 10 11 1  2 13 14 15 17;
                     7 7 7 7 8 8 9 9 10 11 12 13 14 15 17 18;
                     7 7 7 8 8 9 9 10 11 12 13 14 15 17 18 20;
                     7 7 8 8 9 9 10 11 12 13 14 15 17 18 20 22;
                     7 8 8 9 9 10 11 12 13 14 15 17 18 20 22 24;
                     8 8 9 9 10 11 12 13 14 15 17 18 20 22 24 26;
                     8 9 9 10 11 12 13 14 15 17 18 20 22 24 26 28;
                     9 9 10 11 12 13 14 15 17 18 20 22 24 26 28 30;
                     9 10 11 12 13 14 15 17 18 20 22 24 26 28 30 33;
                     10 11 12 13 14 15 17 18 20 22 24 26 28 30 33 36;
                     11 12 13 14 15 17 18 20 22 24 26 28 30 33 36 39;
                     12 13 14 15 17 18 20 22 24 26 28 30 33 36 39 42;
                     13 14 15 17 18 20 22 24 26 28 30 33 36 39 42 45;
                     14 15 17 18 20 22 24 26 28 30 33 36 39 42 45 49;
                     15 17 18 20 22 24 26 28 30 33 36 39 42 45 49 52;];
            
 chromaQuantizMatrix = [17	18	24	47	99	99	99	99;
                        18	21	26	66	99	99	99	99;
                        24	26	56	99	99	99	99	99;
                        47	66	99	99	99	99	99	99;
                        99	99	99	99	99	99	99	99;
                        99	99	99	99	99	99	99	99;
                        99	99	99	99	99	99	99	99;
                        99	99	99	99	99	99	99	99;];                
else
    quantizMatrix = [16 11 10 16 24 40 51 61; 
                    12 12 14 19 26 58 60 55;
                    14 13 16 24 40 57 69 56; 
                    14 17 22 29 51 87 80 62;
                    18 22 37 56 68 109 103 77;
                    24 35 55 64 81 104 113 92;
                    49 64 78 87 103 121 120 101;
                    72 92 95 98 112 100 103 99];
            
     chromaQuantizMatrix = [17 18 24 47;
                            18 21 26 66;
                            24 26 56 99 ;
                            47 66 99 99;];
end



DecodedSize = [HeightVideo, WidthVideo, NumberOfFrames];
DecodedFrames = zeros(DecodedSize);
DecodedFrames =  mat2cell(DecodedFrames, macroblockLength*ones(HeightVideo/macroblockLength, 1).', ...  
                 macroblockLength*ones(WidthVideo/macroblockLength, 1).', ones(NumberOfFrames,1)); 
             
DecodedV = [HeightVideo/2, WidthVideo/2, NumberOfFrames];
DecodedV = zeros(DecodedV);
DecodedV =  mat2cell(DecodedV, (macroblockLength/2)*ones(HeightVideo/macroblockLength, 1).', ...  
                 (macroblockLength/2)*ones(WidthVideo/macroblockLength, 1).', ones(NumberOfFrames,1));

             
DecodedU = [HeightVideo/2, WidthVideo/2, NumberOfFrames];
DecodedU = zeros(DecodedU);
DecodedU =  mat2cell(DecodedU, (macroblockLength/2)*ones(HeightVideo/macroblockLength, 1).', ...  
                 (macroblockLength/2)*ones(WidthVideo/macroblockLength, 1).', ones(NumberOfFrames,1));             
for k=1:NumberOfFrames
    if k>1
        LastFrame = DecodedFrames(:,:,k-1);
        LastU = DecodedU(:,:,k-1);
        LastV = DecodedV(:,:,k-1);
    else
        LastFrame = DecodedFrames(:,:,k);
        LastU = DecodedU(:,:,k);
        LastV = DecodedV(:,:,k);
    end
    LastFrame = uint8(reshape(cell2mat(LastFrame), [macroblockLength, macroblockLength, NumberOfBlocksPerFrame]));  
    LastU = uint8(reshape(cell2mat(LastU), [macroblockLength/2, macroblockLength/2, NumberOfBlocksPerFrame]));  
    LastV = uint8(reshape(cell2mat(LastV), [macroblockLength/2, macroblockLength/2, NumberOfBlocksPerFrame])); 
    for j=1:WidthVideo/macroblockLength
        for i=1:HeightVideo/macroblockLength
            ClosestVector = MovementVector(i,j,k);
            ReconstructedFrame = ResiduesOfY{i,j,k}.*quantizMatrix;
            DecodedFrames{i,j,k} = uint8(idct2(ReconstructedFrame) + double(LastFrame(:,:,ClosestVector)));
            VReconstructedFrame = ResiduesOfV{i,j,k}.*chromaQuantizMatrix;
            DecodedV{i,j,k} = uint8(idct2(VReconstructedFrame)  + double(LastV(:,:,ClosestVector))) + 128;
            UReconstructedFrame = ResiduesOfU{i,j,k}.*chromaQuantizMatrix;
            DecodedU{i,j,k} = uint8(idct2(UReconstructedFrame)+ double(LastU(:,:,ClosestVector))) + 128;
        end
    end
end

keyboard;
writeyuv('ForemanN.yuv', uint8(cell2mat(DecodedFrames)), cell2mat(DecodedU), cell2mat(DecodedV));



