function x = runlengthcode(block)

zigzagBlock = zigzagscan(block);

zigzagBlock(abs(zigzagBlock) < 4) = 0;

nonZeroIndexes = find(zigzagBlock);

maxNonZeroIndex = nonZeroIndexes(end);

x = [maxNonZeroIndex zigzagBlock(1:maxNonZeroIndex)];
end