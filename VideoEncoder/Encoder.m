[Y, U, V]  = readyuv('VideoDatabase/container_qcif_176x144_30.yuv',176,144,300);

macroblockLength = 8;

NumberOfFrames = size(Y,3);
LumaSize = [size(Y,1) size(Y,2)];
ChromaSize = [size(U, 1) size(U, 2)];
NumberOfBlocks = (LumaSize(1)/macroblockLength)*(LumaSize(2)/macroblockLength);

%% Split each channel (Luminance and Chrominance) of video into macroblocks of fixed size  
Yblocks = mat2cell(Y, macroblockLength*ones(LumaSize(1)/macroblockLength, 1).',  macroblockLength*ones(LumaSize(2)/macroblockLength, 1).', NumberOfFrames);
Ublocks = mat2cell(U, (macroblockLength/2)*ones(LumaSize(1)/macroblockLength, 1).',  (macroblockLength/2)*ones(LumaSize(2)/macroblockLength, 1).', NumberOfFrames);      
Vblocks = mat2cell(V, (macroblockLength/2)*ones(LumaSize(1)/macroblockLength, 1).',  (macroblockLength/2)*ones(LumaSize(2)/macroblockLength, 1).', NumberOfFrames);    