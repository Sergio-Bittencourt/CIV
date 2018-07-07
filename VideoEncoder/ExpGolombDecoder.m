 function Decoded = ExpGolombDecoder(ExpGolombEncoded)

bitstream = ExpGolombEncoded; 

ptr = 1;
i=1;

while ptr<length(bitstream) 
size = 0; 
    while bitstream(ptr)~='1'
        ptr = ptr+1;
        size = size+1;
    end
Decoded(i)=bin2dec(bitstream(ptr:ptr+size))-1;
i=i+1;
ptr = ptr + size + 1;
end

end