function [] = graphSegment(app)

    % Plot currently selected data by user
    
    % Input:  [app] = app object from appdesigner

    if (strcmp(app.is_Segment.Value, 'Processed Data')) % Display entire signal

        plot(app.ECG_plot, app.ECG);
        app.ECG_plot.XLim = [1 length(app.ECG)];
        app.SCG_plot.YLim = [app.min_val_SCG_global * 1.1 app.max_val_SCG_global * 1.1];        

        plot(app.SCG_plot, app.SCG);
        app.SCG_plot.XLim = [1 length(app.SCG)];
        app.ECG_plot.YLim = [app.min_val_ECG_global * 1.1 app.max_val_ECG_global * 1.1];                

    elseif (strcmp(app.is_Segment.Value, 'Segmented')) % Segmented display

        if (app.curr_display_type == 0) % Slide based display

            app.ECG_plot.XLim = [1 length(app.ECG)];

            offset = round((app.pos(app.curr_discrete_val + 1) - app.pos(app.curr_discrete_val)) / 2 + app.base); % Offset to center

            % Get y limits for ECG plot
            max_val_ECG = max(app.ECG(app.pos(app.curr_discrete_val) + offset:app.pos(app.curr_discrete_val + 1) + offset));
            min_val_ECG = min(app.ECG(app.pos(app.curr_discrete_val) + offset:app.pos(app.curr_discrete_val + 1) + offset));

            plot(app.ECG_plot, app.ECG(app.pos(app.curr_discrete_val) + offset:app.pos(app.curr_discrete_val + 1) + offset));
            app.ECG_plot.XLim = [1 app.max_range];
            app.ECG_plot.YLim = [min_val_ECG * 1.1 max_val_ECG * 1.1];

            for j = 1:length(app.ECG_pos_global(app.curr_discrete_val, :)) % ECG data
                line(app.ECG_plot, [app.ECG_pos_global(app.curr_discrete_val, j) app.ECG_pos_global(app.curr_discrete_val, j)], ...
                    [min_val_ECG * 1.1 max_val_ECG * 1.1], 'Color', 'black');
            end % for loop

            % Get y limits for SCG plots
            max_val_SCG = max(app.SCG(app.pos(app.curr_discrete_val) + offset:app.pos(app.curr_discrete_val + 1) + offset));
            min_val_SCG = min(app.SCG(app.pos(app.curr_discrete_val) + offset:app.pos(app.curr_discrete_val + 1) + offset));

            plot(app.SCG_plot, app.SCG(app.pos(app.curr_discrete_val) + offset:app.pos(app.curr_discrete_val + 1) + offset));
            app.SCG_plot.XLim = [1 app.max_range];
            app.SCG_plot.YLim = [min_val_SCG * 1.1 max_val_SCG * 1.1];

            app.Curr_Display.Value = app.curr_discrete_val;

            for k = 1:length(app.SCG_pos_global(app.curr_discrete_val, :)) % SCG data
                line(app.SCG_plot, [app.SCG_pos_global(app.curr_discrete_val, k) app.SCG_pos_global(app.curr_discrete_val, k)], ...
                    [min_val_SCG * 1.1 max_val_SCG * 1.1], 'Color', 'black');
            end % for loop

        else % Continuous display

            app.ECG_plot.XLim = [app.curr_continuous_val app.curr_continuous_val + 1000];
            app.SCG_plot.XLim = [app.curr_continuous_val app.curr_continuous_val + 1000];

            app.Curr_Display.Value = app.increment;

        end % if statement 

    else % Raw data  

        plot(app.ECG_plot, app.raw_ECG);
        app.ECG_plot.XLim = [1 length(app.raw_ECG)];
        app.ECG_plot.YLim = [min(app.raw_ECG) * 1.1 max(app.raw_ECG) * 1.1];        

        plot(app.SCG_plot, app.raw_SCG);
        app.SCG_plot.XLim = [1 length(app.raw_SCG)];
        app.SCG_plot.YLim = [min(app.raw_SCG) * 1.1 max(app.raw_SCG) * 1.1];       

    end % if statement
end % graphSegment function