function [isValid, errorMsg] = validate_data(filePath)
    % VALIDATE_DATA - Check if CSV file has correct format
    % Input:
    %   filePath - path to CSV file
    % Output:
    %   isValid  - boolean indicating if data is valid
    %   errorMsg - error message if validation fails
    
    errorMsg = '';
    isValid = true;
    
    try
        % Check if file exists
        if ~exist(filePath, 'file')
            isValid = false;
            errorMsg = 'File does not exist';
            return;
        end
        
        % Try to read the file
        data = readtable(filePath);
        
        % Check if file has enough columns
        if width(data) < 6
            isValid = false;
            errorMsg = 'File must have at least 6 columns';
            return;
        end
        
        % Check if radar data column (2) and time column (6) exist and are numeric
        if ~isnumeric(table2array(data(:, 2)))
            isValid = false;
            errorMsg = 'Column 2 (radar data) must be numeric';
            return;
        end
        
        if ~isnumeric(table2array(data(:, 6)))
            isValid = false;
            errorMsg = 'Column 6 (time data) must be numeric';
            return;
        end
        
        % Check if data has sufficient length
        if height(data) < 1000
            isValid = false;
            errorMsg = 'Insufficient data points (minimum 1000 required)';
            return;
        end
        
    catch ME
        isValid = false;
        errorMsg = ['Error reading file: ', ME.message];
    end
end
