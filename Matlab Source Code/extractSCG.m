function [features] = extractSCG(data, pos, base, ECG_pos)

    % Return a list of SCG characteristics (AO AC MO MC) positions 

    % Input:      [data] = ECG (1), SCG(2) data vector ([m by 2])
    %              [pos] = Position vector for segment splitting ([n by 1])
    % Output: [features] = SCG feature positions [AO AC MO MC] ([m by 4])

    features = zeros(length(pos) - 2, 4);

    for i = 1:(length(pos) - 2) % Loop for every segment
    
        offset = round((pos(i+1) - pos(i)) / 2 + base); % Offset to center
        
        curr = data(pos(i) + offset:pos(i + 1) + offset, 2);
        curr_pos = findSCG(curr, ECG_pos(i, :));
        features(i, :) = curr_pos;
    
    end % for loop

end % extractSCG function

