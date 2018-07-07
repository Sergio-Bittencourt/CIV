% function FastDecode(filename,  WidthVideo, HeightVideo, NumberOfFrames,  macroblockLength)



 filename = 'VideoDatabase/news_qcif_176x144_30.yuv';
 macroblockLength = 8;
 HeightVideo = 144; 
 WidthVideo = 176;
 NumberOfFrames = 300;

[Y, U, V]  = readyuv(filename, WidthVideo, HeightVideo, NumberOfFrames);

LumaSize = [size(Y,1) size(Y,2)];
ChromaSize = [size(U, 1) size(U, 2)];
NumberOfBlocks = (LumaSize(1)/macroblockLength)*(LumaSize(2)/macroblockLength);

if macroblockLength==16
    
           quantizMatrix =  [32    22    20    32    48    80   102   122   32    22    20    32    48    80   102   122;
                            24    24    28    38    52   116   120   110   24    24    28    38    52   116   120   110;
                            28    26    32    48    80   114   138   112   28    26    32    48    80   114   138   112;
                            28    34    44    58   102   174   160   124   28    34    44    58   102   174   160   124;
                            36    44    74   112   136   218   206   154   36    44    74   112   136   218   206   154;
                            48    70   110   128   162   208   226   184   48    70   110   128   162   208   226   184;
                            98   128   156   174   206   242   240   202   98   128   156   174   206   242   240   202;
                           144   184   190   196   224   200   206   198   144   184   190   196   224   200   206   198;
                            32    22    20    32    48    80   102   122   32    22    20    32    48    80   102   122;
                            24    24    28    38    52   116   120   110   24    24    28    38    52   116   120   110;
                            28    26    32    48    80   114   138   112   28    26    32    48    80   114   138   112;
                            28    34    44    58   102   174   160   124   28    34    44    58   102   174   160   124;
                            36    44    74   112   136   218   206   154   36    44    74   112   136   218   206   154;
                            48    70   110   128   162   208   226   184   48    70   110   128   162   208   226   184;
                            98   128   156   174   206   242   240   202   98   128   156   174   206   242   240   202;
                           144   184   190   196   224   200   206   198   144   184   190   196   224   200   206   198;];
                 
                      
                     
                     
                    

            
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
    PreviousFrame =reshape(cell2mat(PreviousFrame), [macroblockLength, macroblockLength, NumberOfBlocks]);
    PreviousU = Utrack(:,:,k); %% Loads the information available on decoder for the chroma component U
    PreviousU = reshape(cell2mat(PreviousU), [macroblockLength/2, macroblockLength/2, NumberOfBlocks]);
    PreviousV = Vtrack(:,:,k); %% Loads the information available on decoder for the chroma component V
    PreviousV = reshape(cell2mat(PreviousV), [macroblockLength/2, macroblockLength/2, NumberOfBlocks]);    
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
            TransformedResidue = dct2(ResidueU{i,j,k});
            QuantizedCoeficientsU{i,j,k} = round(TransformedResidue./chromaQuantizMatrix);
            ReconstructedFrame = QuantizedCoeficientsU{i,j,k}.*chromaQuantizMatrix;
            Utrack{i,j,k+1} = idct2(ReconstructedFrame) + double(PreviousU(:,:,ClosestMV_Index));
            ResidueV{i,j,k} = Vblocks{i,j,k}-double(PreviousV(:,:,ClosestMV_Index));
            TransformedResidue = dct2(ResidueV{i,j,k}); 
            QuantizedCoeficientsV{i,j,k} = round(TransformedResidue./chromaQuantizMatrix);
            ReconstructedFrame = QuantizedCoeficientsV{i,j,k}.*chromaQuantizMatrix;
            Vtrack{i,j,k+1} = idct2(ReconstructedFrame) + double(PreviousV(:,:,ClosestMV_Index));
        end
    end
end

Utrack = Utrack(:,:,2:end);
Vtrack = Vtrack(:,:,2:end);
FrameTrack = FrameTrack(:,:,2:end);

writeyuv('FastDecoded.yuv', uint8(cell2mat(FrameTrack)), uint8(cell2mat(Utrack)), uint8(cell2mat(Vtrack)));

% end




