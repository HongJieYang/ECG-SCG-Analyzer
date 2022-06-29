function [pos] = findSCG(data, ECG_pos)

    % Return positions of SCG characteristics

    % Input: [data] = SCG data ([n by 1])
    %     [ECG_pos] = Position of ECG features [P Q R S T] ([1 by 5])
    % Output: [pos] = SCG feature positions [AO AC MO MC]([1 by 4]);

    try % No error in algorithm
        [pks, loc] = findpeaks(data(ECG_pos(4):ECG_pos(5))); 

        if (loc(1) < 10) % Faulty peak
            loc = loc(2:end);
        end % if statement
        
        loc = loc + ECG_pos(4);

        MC_pos = loc(1); % Mitral closure
        AO_pos = loc(2); % Aortic opening

        [val, MO_pos] = min(data(ECG_pos(5):end));
        MO_pos = MO_pos + ECG_pos(5);

        [val, AC_max] = max(data(MO_pos - 50:MO_pos));
        AC_max = AC_max + MO_pos - 50;

        [val, AC_pos] = min(data(AC_max - 50:AC_max));
        AC_pos = AC_pos + AC_max - 50;

        pos = [AO_pos AC_pos MO_pos MC_pos];
        
    catch % Otherwise error
        pos = [0 0 0 0]; % Return null vector
    end % try catch 

end % findSCG function

