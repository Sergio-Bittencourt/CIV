function encodedBlock = runlengthcode(block)

    if numel(find(block))==0
      
        encodedBlock = [0];
        
    else

        zigzagBlock = zigzagscan(block);

        nonZeroIndexes = find(zigzagBlock);
    
        maxNonZeroIndex = nonZeroIndexes(end);

        encodedBlock = [maxNonZeroIndex zigzagBlock(1:maxNonZeroIndex)];

    end
end