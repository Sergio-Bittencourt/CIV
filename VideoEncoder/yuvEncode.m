filename = 'VideoDatabase/foreman_qcif_174x144_30.yuv';

HeightVideo = 176;
WidthVideo = 144;
NoF = 300;

[Y, U, V]  = readyuv(filename,HeightVideo,WidthVideo,NoF);

macroblockLength = 8;

NumberOfFrames = size(Y,3);
LumaSize = [size(Y,1) size(Y,2)];
ChromaSize = [size(U, 1) size(U, 2)];
NumberOfBlocks = (LumaSize(1)/macroblockLength)*(LumaSize(2)/macroblockLength);

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

%% Splits each channel (Luminance and Chrominance) of video into macroblocks of fixed size  
Yblocks = mat2cell(double(Y), macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1));
Ublocks = mat2cell(double(U), (macroblockLength/2)*ones(LumaSize(1)/macroblockLength, 1).',  (macroblockLength/2)*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1));
Vblocks = mat2cell(double(V), (macroblockLength/2)*ones(LumaSize(1)/macroblockLength, 1).',  (macroblockLength/2)*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 

%% Used to track the data available in the decoder's input at the time of decoding, thus allowing a most accurate prevision of the Closest Movement Vector  
FrameTrack = uint8(zeros(size(Y)));
FrameTrack =  mat2cell(FrameTrack, macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 
Utrack = uint8(zeros(size(U)));
Utrack =  mat2cell(Utrack, macroblockLength/2*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength/2*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 
Vtrack = uint8(zeros(size(V)));
Vtrack =  mat2cell(Vtrack, macroblockLength/2*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength/2*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 


%% Inicializing the variables to store the Residue and the Closest Movement Vector of each block 

ClosestMovementVector = zeros(LumaSize(1)/macroblockLength, LumaSize(2)/macroblockLength, NumberOfFrames);
Residue = zeros(size(Y));
Residue = mat2cell(Residue, macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 
QuantizedCoeficients = zeros(size(Y));
QuantizedCoeficients = mat2cell(QuantizedCoeficients, macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 
ResidueU = zeros(size(U));
ResidueU = mat2cell(ResidueU, macroblockLength/2*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength/2*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 
QuantizedCoeficientsU = zeros(size(U));
QuantizedCoeficientsU = mat2cell(QuantizedCoeficientsU, macroblockLength/2*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength/2*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 
ResidueV = zeros(size(V));
ResidueV = mat2cell(ResidueV, macroblockLength/2*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength/2*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 
QuantizedCoeficientsV = zeros(size(V));
QuantizedCoeficientsV = mat2cell(QuantizedCoeficientsV, macroblockLength/2*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength/2*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 

tic
for k=1:NumberOfFrames
    PreviousFrame = FrameTrack(:,:,k); %% Loads the information available on decoder for the prevision
    PreviousFrame = uint8(reshape(cell2mat(PreviousFrame), [macroblockLength, macroblockLength, NumberOfBlocks]));
    PreviousU = Utrack(:,:,k); %% Loads the information available on decoder for the chroma component U
    PreviousU = uint8(reshape(cell2mat(PreviousU), [macroblockLength/2, macroblockLength/2, NumberOfBlocks]));
    PreviousV = Vtrack(:,:,k); %% Loads the information available on decoder for the chroma component V
    PreviousV = uint8(reshape(cell2mat(PreviousV), [macroblockLength/2, macroblockLength/2, NumberOfBlocks]));    
    for j=1:LumaSize(2)/macroblockLength
        for i=1:LumaSize(1)/macroblockLength
            distortion=bsxfun(@minus, Yblocks{i,j,k}, double(PreviousFrame));
            distortion=distortion.^2;
            distortion = sum(sum(distortion));
            ClosestMV_Index = find(distortion==min(distortion),1);
            ClosestMovementVector(i,j,k) = ClosestMV_Index;
            Residue{i,j,k} = Yblocks{i,j,k}-double(PreviousFrame(:,:,ClosestMV_Index));
            TransformedResidue = dct2(Residue{i,j,k});
            QuantizedCoeficients{i,j,k} = round(TransformedResidue./quantizMatrix);
            ReconstructedFrame = QuantizedCoeficients{i,j,k}.*quantizMatrix;
            FrameTrack{i,j,k+1} = uint8(idct2(ReconstructedFrame) + double(PreviousFrame(:,:,ClosestMV_Index)));
            ResidueU{i,j,k} = Ublocks{i,j,k}-double(PreviousU(:,:,ClosestMV_Index));
            TransformedResidue = dct2(ResidueU{i,j,k}-128);
            QuantizedCoeficientsU{i,j,k} = round(TransformedResidue./chromaQuantizMatrix);
            ReconstructedFrame = QuantizedCoeficientsU{i,j,k}.*chromaQuantizMatrix;
            Utrack{i,j,k+1} = uint8(idct2(ReconstructedFrame) + double(PreviousV(:,:,ClosestMV_Index)))+128;
            ResidueV{i,j,k} = Vblocks{i,j,k}-double(PreviousV(:,:,ClosestMV_Index));
            TransformedResidue = dct2(ResidueV{i,j,k}-128); 
            QuantizedCoeficientsV{i,j,k} = round(TransformedResidue./chromaQuantizMatrix);
            ReconstructedFrame = QuantizedCoeficientsV{i,j,k}.*chromaQuantizMatrix;
            Vtrack{i,j,k+1} = uint8(idct2(ReconstructedFrame) + double(PreviousV(:,:,ClosestMV_Index)))+128;
        end
    end
end



Utrack = Utrack(:,:,2:end);
Vtrack = Vtrack(:,:,2:end);
FrameTrack = FrameTrack(:,:,2:end);
keyboard;
% writeyuv('ForemanX.yuv',uint8(cell2mat(FrameTrack)), uint8(cell2mat(Utrack)), uint8(cell2mat(Vtrack)));

MovementVector = ClosestMovementVector(:).';
MVBits = floor(log2(max(MovementVector)))+1;
ClosestMovementVector = arrayfun(@(x) dec2bin(x, MVBits),  ClosestMovementVector, 'UniformOutput', false);

for i=1:8*ceil(length(MovementVector)/8)-length(MovementVector)
    MovementVector{end+1}=num2str(0);
end


MovementVector = cell2mat(ClosestMovementVector(:).');
c=1;
output_bitstream = blanks(ceil(length(MovementVector)/8));
 for i=1:8:8*ceil(length(MovementVector)/8)
    output_bitstream(c)=bin2dec(MovementVector(i:i+7));
    c=c+1;
 end




name_infofile = strrep(filename, '.yuv', '_info.bin');
infoFile = fopen(name_infofile, 'w'); %% Cleans the file, if has something written on it
fclose(infoFile); 
infoFile = fopen(name_infofile, 'a'); %% Opens the new file
dlmwrite(name_infofile,[size(Y) macroblockLength MVBits], '-append', 'delimiter',' '); 

% MovementVector = ExpGolomb(ClosestMovementVector);




% output_bitstream=[];

% for i=1:8*ceil(length(MovementVector)/8)-length(MovementVector)
  %  MovementVector(end+1)=0;
% end


% c=1;

% for i=1:8:8*ceil(length(MovementVector)/8)
  %  output_bitstream(c)=bin2dec(num2str(MovementVector(i:i+7)));
  %  c=c+1;
% end

fwrite(infoFile, output_bitstream);

Vrle = cellfun(@runlengthcode, QuantizedCoeficientsV, 'UniformOutput', false);
Vrle = cellfun(@num2str, Vrle, 'UniformOutput', false);
Vrle = strjoin(Vrle);
huffEncode(Vrle, strrep(filename, '.yuv', '_v_Encoded.bin'),0);


Urle = cellfun(@runlengthcode, QuantizedCoeficientsU, 'UniformOutput', false);
Urle = cellfun(@num2str, Urle, 'UniformOutput', false);
Urle = strjoin(Urle);
huffEncode(Urle, strrep(filename, '.yuv', '_u_Encoded.bin'),0);

Yrle = cellfun(@runlengthcode, QuantizedCoeficients, 'UniformOutput', false);
Yrle = cellfun(@num2str, Yrle, 'UniformOutput', false);
Yrle = strjoin(Yrle);
huffEncode(Yrle, strrep(filename, '.yuv', '_y_Encoded.bin'),0);
keyboard;
   
fclose('all');

