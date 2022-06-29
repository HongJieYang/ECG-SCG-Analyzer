function [data, pos] = segmentSCG(data, limit, offset)

    % Segment data by QRS detection of ECG signal. Then remove SCG segments
    % that contain artifacts

    % Input:   [data]   = ECG & SCG data vector ([m by 2])
    %          [limit]  = Minimum voltage [V] for QRS complex peak (double)
    %          [offset] = offset coefficient, between 0 and 1
    % Output:  [first]  = beginning index of each segment
    %          [last]   = ending index of each segment

    ECG = data(:, 1);
    [pks, loc] = findpeaks(ECG); % Find local maximas
    pos = [];
    j = 1;
    
    for i = 1:length(pks) % Repeat for each peak
        
        if (pks(i, 1) > limit) % Skip non QRS peaks
            pos(j, 1) = loc(i, 1); 
            j = j + 1;
        end % if statement
        
    end % for loop
    
    % remove artifacts
    order = 3; % autoregression order
    SCG = data(:, 2);
    N = length(SCG);
    Z = ones(N - order, order); % allocate space
    
    for i = 1:order
        column = SCG(order - i + 1 : N - i);
        Z(:, i) = column;
    end % for loop
    
    % least square minimization
    a = (Z' * Z)^(-1) * Z' * SCG(order + 1:end);
    
    % prediction with past values
    p_z = Z * a;
    
    % residual
    w_z = SCG(order + 1:end) - p_z;
    L = 1000;
    step = L - 1;
    
    v = movingvar(w_z, L, step); % variance of model residual
    mid = median(v);
    th = 2 * mid;
    
    first = [];
    last = [];
    flag = 1;
    
    for i = 1 : length(pos) - 1
        low = pos(i);
        up = pos(i + 1);
        
        if (low - L) >= 1 % negative index
            for j = low-L : up-L
                if v(j) > th % Exceeds threshold
                    flag = 0;
                    break;
                end  % if statement
            end % for loop
            
            if flag == 1
                first = [first ; low];
                last = [last ; up];
            end 
            
            flag = 1;
        end % if statement
    end % for loop
    
    % offset segments
    temp = 0;
    
    for i = 2:length(pos)
        temp = temp + pos(i) - pos(i-1);
    end % for loop
    
    off = round(temp / (length(pos)-1) * offset) * ones(size(first));
    first = first - off;
    last = last - off;

    if first(1) < 0 % if the first cardiac cycle is not long enough
        first = first(2:end);
        last = last(2:end);
    end
    
    % Remove inadequate sections
    diff = last - first;

    pos = zeros(length(first) + 1, 1);
    pos(1) = first(1);
    pos(2) = last(1);

    for i = 1:(length(last) - 1) % Loop for all position values
        
        % Create new position and data vector
        pos(i + 2) = pos(i + 1) + diff(i + 1);
        data_recon(pos(i) - pos(1) + 1:pos(i + 1) - pos(1) + 1, :) = data(first(i):last(i), :);
    
    end % for loop

    i = i + 1; 
    data_recon(pos(i) - pos(1) + 1:pos(i + 1) - pos(1) + 1, :) = data(first(i):last(i), :);
    data = data_recon;
    pos = pos - min(pos) + 1;
    
end % segment function


