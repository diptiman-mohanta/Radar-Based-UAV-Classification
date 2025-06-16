function logger = logging(log_file)
    % LOGGING - Simple logging utility
    
    if nargin < 1
        log_file = fullfile('logs', ['log_' datestr(now, 'yyyymmdd_HHMMSS') '.txt']);
    end
    
    % Create logs directory if it doesn't exist
    log_dir = fileparts(log_file);
    if ~exist(log_dir, 'dir')
        mkdir(log_dir);
    end
    
    logger.file = log_file;
    logger.start_time = now;
    
    % Initialize log file
    fid = fopen(log_file, 'w');
    if fid ~= -1
        fprintf(fid, '=== Radar UAV Classification Log ===\n');
        fprintf(fid, 'Started: %s\n', datestr(now));
        fprintf(fid, 'MATLAB Version: %s\n', version);
        fprintf(fid, '=====================================\n\n');
        fclose(fid);
    end
    
    % Log function
    logger.log = @(message, level) log_message(log_file, message, level);
    
    % Initial log
    logger.log('Logging system initialized', 'INFO');
end

function log_message(log_file, message, level)
    % LOG_MESSAGE - Write message to log file
    
    if nargin < 3
        level = 'INFO';
    end
    
    timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    log_entry = sprintf('[%s] %s: %s\n', timestamp, level, message);
    
    % Write to file
    fid = fopen(log_file, 'a');
    if fid ~= -1
        fprintf(fid, log_entry);
        fclose(fid);
    end
    
    % Also display to console
    fprintf(log_entry);
end
