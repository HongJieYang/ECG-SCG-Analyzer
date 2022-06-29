function [ECG_pos, SCG_pos] = calcSegments(data, pos, base)

    % Return a list of ECG and SCG feature positions

    % Input:     [data] = ECG (1), SCG(2) data vector ([m by 2])
    %             [pos] = Position vector for segment splitting ([n by 1])
    %            [base] = Addition offset to center waveforms (integer)
    % Output: [ECG_pos] = Matrix of ECG feature positions ([n by 5])
    %         [SCG_pos] = Matrix of SCG feature positions ([n by 4])

    ECG_pos = extractECG(data, pos, base);
    SCG_pos = extractSCG(data, pos, base, ECG_pos);
    
end % calcSegments function

