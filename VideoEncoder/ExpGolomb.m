function ExpGolombCode = ExpGolomb(Number)

NumberOfBits = 2*floor(log2(Number+1))+1;
ExpGolombCode = dec2bin(Number+1, NumberOfBits);

end 