function [f_sig] = filterHP(data, fs, fc, n)

    % Return filtered input data by using a FIR filter with hamming window 
    % of order n, cutoff frequency fc, and sampled at sampling rate fs

    % Input:   [data] = Data vector ([m by 1])
    %            [fs] = Sampling frequency [Hz] (Int)
    %            [fc] = Cutoff frequency [Hz] (Int)
    %             [n] = Order of the filter (Int)
    % Output: [f_sig] = Filtered data vector ([m by 1]);

    wc = fc / (fs / 2); % Normalized cutoff frequency
    [b, a] = fir1(n, wc, 'high'); % Hamming window FIR design
   
    f_sig = filtfilt(b, a, data); % Filtered signal
    
end % filterHP function