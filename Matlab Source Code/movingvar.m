function variance = movingvar(data, width, overlap)

    % Return variance of data over a moving window

    % Input:   [data]    = Column vector
    %          [width]   = Width of the window
    %          [overlap] = Overlap portion of the window (overlap < width)
    % Output: [variance] = Variance of data over the moving window

    increment = width - overlap;
    
    % max number of evaluation
    num = (length(data) - width) / increment;
    num = floor(num) + 2;
    variance = zeros(num, 1);
    
    % caluculate variance
    a = 1; % starting index of window
    
    for i = 1 : num
        
        % calculate variance of each window
        a = 1 + (i - 1) * increment; % starting index of window
        b = width + (i - 1) * increment;
        
        if b > length(data) % Reached end of data
            break;
        end % if statement
        
        v = var(data(a:b), 0, 1);
        variance(i) = v;
    end
    
    % last window
    v = var(data(a:end), 0, 1);
    variance(i) = v;
    
end % movingvar function

