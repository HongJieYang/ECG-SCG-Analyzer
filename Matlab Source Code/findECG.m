function [pos] = findECG(data)

    % Find position of ECG characteristics

    % Input: [data] = ECG data ([1 by n])
    % Output: [pos] = ECG feature positions [PQRST] ([1 by 5]);

    try % No error
            [val, r_pos] = max(data); % r peak position
            [val, q_pos] = min(data(r_pos - 100:r_pos)); % q wave
            q_pos = q_pos + r_pos - 100;
            [val, s_pos] = min(data(r_pos: r_pos + 100)); % s wave
            s_pos = s_pos + r_pos;
            [val, t_pos] = max(data(r_pos + 200:end)); % t wave
            t_pos = t_pos + r_pos + 200;
            [val, p_pos] = max(data(1:r_pos - 100)); % p wave

            pos = [p_pos q_pos r_pos s_pos t_pos];
    catch % Otherwise return null vector
        pos = [0 0 0 0 0];
    end % try - catch  
        
end % findECG function

