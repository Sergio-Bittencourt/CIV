 function ExpGolombCode = ExpGolomb(NumberArray)
 
    BitsNeeded = 0;
    for i=1:numel(NumberArray)
        BitsNeeded = BitsNeeded + 2*floor(log2(NumberArray(i)+1))+1;
    end
    
    ExpGolombCode = char(zeros(1,BitsNeeded));
    j=1;
    c=1;
    while j<BitsNeeded
         NumberOfBits = 2*floor(log2(NumberArray(c)+1))+1;
         ExpGolombCode(j:j+NumberOfBits-1) = dec2bin(NumberArray(c)+1, NumberOfBits);
         j = j + NumberOfBits;
         c = c+1;
    end
end