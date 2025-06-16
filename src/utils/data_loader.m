function [radar_data, time_data, fs] = data_loader(file_path, params)
    % DATA_LOADER - Standardized data loading function
    % Input:
    %   file_path - path to CSV file
    %   params    - parameters structure
    % Output:
    %   radar_data - radar signal data
    %   time_data  - time stamps
    %   fs         - calculated sampling frequency
    
    if nargin < 2
        params = parameters();
    end
    
    % Validate file
    [isValid, errorMsg] = validate_data(file_path);
    if ~isValid
        error('Data validation failed: %s', errorMsg);
    end
    
    % Load data
    try
        data = readtable(file_path);
        radar_data = table2array(data(:, 2));
        time_data = table2array(data(:, 6));
        
        % Calculate sampling frequency
        time_intervals = diff(time_data);
        fs = 1 / mean(time_intervals);
        
        % Remove any NaN or infinite values
        valid_idx = isfinite(radar_data) & isfinite(time_data);
        radar_data = radar_data(valid_idx);
        time_data = time_data(valid_idx);
        
        % Ensure minimum data length
        if length(radar_data) < 1000
            warning('Data length is less than 1000 samples: %d', length(radar_data));
        end
        
    catch ME
        error('Failed to load data from %s: %s', file_path, ME.message);
    end
end
