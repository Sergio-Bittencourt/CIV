% 
% 
% 
% 
% 
function zigzagArray = zigzagscan(block)

tempBlock = reshape(1:numel(block), size(block));

order = fliplr(spdiags(fliplr(tempBlock)));

order(:,1:2:end) = flipud(order(:,1:2:end));

order(order==0) = [];

zigzagArray = block(order);

end