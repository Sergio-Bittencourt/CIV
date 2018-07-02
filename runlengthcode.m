function encodedBlock = runlengthcode(block)

zigzagBlock = zigzagscan(block);

nonZeroIndexes = find(zigzagBlock);

maxNonZeroIndex = nonZeroIndexes(end);

encodedBlock = [maxNonZeroIndex zigzagBlock(1:maxNonZeroIndex)];
end