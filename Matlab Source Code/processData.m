function [] = processData(app)

    % Process the SCG data and update LVET, ICT, PEP, ISR values to
    % interactive app
    
    % Input:  [app] = app object from appdesigner

    data = load(fullfile(app.path, app.file)).data;
    
    app.raw_ECG = data(:, 1);
    app.raw_SCG = data(:, 2);
    
    % Filter data
    filter_signal(:, 1) = filterLP(data(:, 1), app.fs_sys, app.fc_LP_ECG, 30);
    filter_signal(:, 2) = filterLP(data(:, 2), app.fs_sys, app.fc_LP_SCG, 30);
    filter_signal(:, 2) = filterHP(filter_signal(:, 2), app.fs_sys, app.fc_HP, 90);

    % Segment data
    [processed_data, app.pos] = segmentSCG(filter_signal, 1, 0);

    app.max_range = max(app.pos(2:end) - app.pos(1:end - 1));

    app.ECG = processed_data(:, 1);
    app.SCG = processed_data(:, 2);
    app.max_val_ECG_global = max(app.ECG);
    app.min_val_ECG_global = min(app.ECG);
    app.max_val_SCG_global = max(app.SCG);
    app.min_val_SCG_global = min(app.SCG);

    [app.ECG_pos_global, app.SCG_pos_global] = calcSegments(processed_data, app.pos, 100);

    % Calculate features
    result = calcIntervals(app.ECG_pos_global, app.SCG_pos_global, 1e3);
    final = calcResults(result);

    % Display values
    app.LVET_Var.Value = final(1);
    app.LVET_Ave.Value = final(2);
    app.ICT_Var.Value = final(3);
    app.ICT_Ave.Value = final(4);
    app.PEP_Var.Value = final(5);
    app.PEP_Ave.Value = final(6);
    app.ISR_Var.Value = final(7);
    app.ISR_Ave.Value = final(8);

    app.is_Segment.Enable = 'on';
    app.curr_continuous_val = 1; % Reset scrolling
    app.curr_discrete_val = 1; % Reset slide

end % processData function