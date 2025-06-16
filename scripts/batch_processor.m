function batch_processor(input_folder, output_folder, processing_function, batch_size)
    % BATCH_PROCESSOR - Process files in batches to manage memory
    % Input:
    %   input_folder - folder containing input files
    %   output_folder - folder to save processed files
    %   processing_function - function handle for processing
    %   batch_size - number of files to process at once
    
    if nargin < 4
        batch_size = 10;
    end
    
    % Get list of files
    files = dir(fullfile(input_folder, '*.csv'));
    total_files = length(files);
    
    if total_files == 0
        fprintf('No CSV files found in: %s\n', input_folder);
        return;
    end
    
    % Create output folder
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % Initialize logger
    logger = logging();
    logger.log(sprintf('Starting batch processing: %d files', total_files), 'INFO');
    
    % Process in batches
    num_batches = ceil(total_files / batch_size);
    processed_count = 0;
    
    for batch_idx = 1:num_batches
        start_idx = (batch_idx - 1) * batch_size + 1;
        end_idx = min(batch_idx * batch_size, total_files);
        
        logger.log(sprintf('Processing batch %d/%d (files %d-%d)', ...
                          batch_idx, num_batches, start_idx, end_idx), 'INFO');
        
        % Process current batch
        for file_idx = start_idx:end_idx
            try
                file_path = fullfile(input_folder, files(file_idx).name);
                processing_function(file_path, output_folder);
                processed_count = processed_count + 1;
                
                % Progress update
                if mod(processed_count, 5) == 0
                    fprintf('Processed %d/%d files (%.1f%%)\n', ...
                            processed_count, total_files, ...
                            100 * processed_count / total_files);
                end
                
            catch ME
                logger.log(sprintf('Error processing %s: %s', ...
                                 files(file_idx).name, ME.message), 'ERROR');
            end
        end
        
        % Clear memory between batches
        if batch_idx < num_batches
            clear variables;
            pause(0.1); % Brief pause to allow memory cleanup
        end
    end
    
    logger.log(sprintf('Batch processing completed: %d/%d files processed', ...
                      processed_count, total_files), 'INFO');
end
