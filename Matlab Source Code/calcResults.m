function [final_results] = calcResults(result)

    % Return variability and average of timing intervals

    % Input: result = Timing Interval [LVET ICT PEP ISR] ([m by 4]);
    % Output: final_results = Variability (Top) and average (Bottom) ([2 by 4]);

    result = result(all(result, 2), :); % Remove outliers with 0
    total = zeros(1, 4);

    for i = 1:(length(result) - 1) % Variability of intervals
    
        curr = result(i + 1, :) - result(i, :);
        curr = curr.*curr;
        total = total + curr;
      
    end % for loop 
    
    final_results = [sqrt(total) ; mean(result, 1)]; 

end % calcVariability function
