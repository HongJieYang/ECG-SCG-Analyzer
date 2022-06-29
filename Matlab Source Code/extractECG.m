function [features] = extractECG(data, pos, base)

    % Return a list of ECG characteristics (PQRST) positions 

    % Input:      [data] = ECG (1), SCG(2) data vector ([m by 2])
    %              [pos] = Position vector for segment splitting ([n by 1])
    % Output: [features] = ECG feature positions [PQRST] ([m by 5])

    features = zeros(length(pos) - 2, 5);

    for i = 1:(length(pos) - 2) % Loop for every segment
    
        offset = round((pos(i+1) - pos(i)) / 2 + base); % Offset to center
        
        curr = data(pos(i) + offset:pos(i + 1) + offset, 1);
        curr_pos = findECG(curr);
        features(i, :) = curr_pos;
    
    end % for loop
    
end % extractECG function

