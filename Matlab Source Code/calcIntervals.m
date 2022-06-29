function [interval] = calcIntervals(ECG_pos, SCG_pos, fs)

    % Return timing intervals between SCG features

    % Input:  [ECG_pos] = ECG feature positions [PQRST] ([m by 5])
    %         [SCG_pos] = SCG feature positions [AO AC MO MC] ([m by 4])
    % Output: [results] = Timing intervals [LVET ICT PEP ISR] ([m by 3]);

    T = 1 / fs;
    
    LVET = (SCG_pos(:, 2) - SCG_pos(:, 1)) * T; % Aortic Opening to Aortic Closure
    PEP = (SCG_pos(:, 1) - ECG_pos(:, 2)) * T; % Q Wave to Aortic Opening
    ICT = (SCG_pos(:, 1) - SCG_pos(:, 4)) * T; % Mitral Closure to Aortic Opening
    ISR = (SCG_pos(:, 3) - SCG_pos(:, 2)) * T;% Aortic Closure to Mitral Opening
    
    interval = [LVET ICT PEP ISR];

end % calcIntervals function


