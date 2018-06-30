[Y, U, V]  = readyuv('VideoDatabase/container_qcif_176x144_30.yuv',176,144,300);

macroblockLength = 8;

NumberOfFrames = size(Y,3);
LumaSize = [size(Y,1) size(Y,2)];
ChromaSize = [size(U, 1) size(U, 2)];
NumberOfBlocks = (LumaSize(1)/macroblockLength)*(LumaSize(2)/macroblockLength);

quantizMatrix = [16 11 10 16 24 40 51 61; 
                12 12 14 19 26 58 60 55;
                14 13 16 24 40 57 69 56; 
                14 17 22 29 51 87 80 62;
                18 22 37 56 68 109 103 77;
                24 35 55 64 81 104 113 92;
                49 64 78 87 103 121 120 101;
                72 92 95 98 112 100 103 99];




%% Splits each channel (Luminance and Chrominance) of video into macroblocks of fixed size  
Yblocks = mat2cell(double(Y), macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1));
Ublocks = mat2cell(double(U), (macroblockLength/2)*ones(LumaSize(1)/macroblockLength, 1).',  (macroblockLength/2)*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1));
Vblocks = mat2cell(double(V), (macroblockLength/2)*ones(LumaSize(1)/macroblockLength, 1).',  (macroblockLength/2)*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 

%% Used to track the data available in the decoder's input at the time of decoding, thus allowing a most accurate prevision of the Closest Movement Vector  
FrameTrack = zeros(size(Y));
FrameTrack =  mat2cell(FrameTrack, macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 

%% Inicializing the variables to store the Residue and the Closest Movement Vector of each block 

ClosestMovementVector = zeros(macroblockLength, macroblockLength, NumberOfBlocks);
Residue = zeros(size(Y));
Residue = mat2cell(Residue, macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', ones(NumberOfFrames,1)); 

for k=1:NumberOfFrames
    PreviousFrame = FrameTrack(:,:,k); %% Loads the information available on decoder for the prevision
    PreviousFrame = reshape(cell2mat(PreviousFrame), [macroblockLength, macroblockLength, NumberOfBlocks]);
    c=1;
    for j=1:LumaSize(2)/macroblockLength
        for i=1:LumaSize(1)/macroblockLength
            distortion=bsxfun(@minus, Yblocks{i,j,k}, PreviousFrame);
            distortion=distortion.^2;
            distortion = sum(sum(distortion));
            ClosestMV_Index = find(distortion==min(distortion),1);
            ClosestMovementVector(i,j,k) = ClosestMV_Index;
            Residue{i,j,k} = Yblocks{i,j,k}-PreviousFrame(:,:,ClosestMV_Index);
            TransformedResidue = dct(Residue{i,j,k});
            QuantizedFrame = round(TransformedResidue/quantizMatrix);
            ReconstructedFrame = QuantizedFrame*quantizMatrix;
            FrameTrack{i,j,k+1} = idct(ReconstructedFrame) + PreviousFrame(ClosestMV_Index);
            c=c+1;
        end
    end
end


%% P.S: We most elaborate a function that discards the null and negative 
%% coefficients of quantized DCT and incorporate the zig-zag scan,
%% as well evaluating the results we've got with the pair of quantization and reconstruction matrices