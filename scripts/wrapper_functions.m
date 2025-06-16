function generate_training_spectrograms_wrapper(config)
    % GENERATE_TRAINING_SPECTROGRAMS_WRAPPER - Wrapper for training spectrogram generation
    
    folderPath = config.train_data_path;
    outputFolder = config.train_spectrograms_path;
    
    % Ensure output folder exists
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    % Get list of CSV files
    csvFiles = dir(fullfile(folderPath, '*.csv'));
    numFiles = length(csvFiles);
    
    if numFiles == 0
        error('No CSV files found in training data folder: %s', folderPath);
    end
    
    % Initialize logger
    logger = logging();
    logger.log(sprintf('Starting training spectrogram generation for %d files', numFiles), 'INFO');
    
    % Initialize performance monitor
    monitor = performance_monitor();
    
    % Process files
    for fileIdx = 1:numFiles
        try
            fileName = csvFiles(fileIdx).name;
            filePath = fullfile(folderPath, fileName);
            
            % Process single file
            process_single_training_file(filePath, outputFolder);
            
            if mod(fileIdx, 10) == 0
                report_performance(monitor, sprintf('Training Batch %d', fileIdx));
            end
            
        catch ME
            logger.log(sprintf('Error processing training file %s: %s', fileName, ME.message), 'ERROR');
        end
    end
    
    logger.log('Training spectrogram generation completed', 'INFO');
end

function extract_features_wrapper(config)
    % EXTRACT_FEATURES_WRAPPER - Wrapper for feature extraction
    
    spectrogramPath = config.train_spectrograms_path;
    outputPath = config.features_path;
    
    % Check if spectrograms exist
    imgFiles = dir(fullfile(spectrogramPath, '*.png'));
    if isempty(imgFiles)
        error('No spectrogram images found in: %s', spectrogramPath);
    end
    
    % Initialize logger
    logger = logging();
    logger.log(sprintf('Starting feature extraction for %d images', length(imgFiles)), 'INFO');
    
    try
        % Load image datastore
        imds = imageDatastore(spectrogramPath);
        
        % Load pretrained network
        net = squeezenet;
        inputSize = net.Layers(1).InputSize;
        augimds = augmentedImageDatastore(inputSize(1:2), imds);
        
        % Extract features
        layer = 'ClassificationLayer_predictions';
        featureTrain = activations(net, augimds, layer, 'OutputAs', 'rows');
        
        % Generate labels
        labels = generate_labels_from_filenames(imds.Files);
        
        % Combine features and labels
        F = featureTrain;
        
        % Save features
        if ~exist(outputPath, 'dir')
            mkdir(outputPath);
        end
        
        save(fullfile(outputPath, 'extracted_features.mat'), 'F', 'labels', 'imds');
        
        logger.log('Feature extraction completed successfully', 'INFO');
        
    catch ME
        logger.log(sprintf('Feature extraction failed: %s', ME.message), 'ERROR');
        rethrow(ME);
    end
end

function generate_test_spectrograms_wrapper(config)
    % GENERATE_TEST_SPECTROGRAMS_WRAPPER - Wrapper for test spectrogram generation
    
    folderPath = config.test_data_path;
    
    % Get list of CSV files
    csvFiles = dir(fullfile(folderPath, '*.csv'));
    numFiles = length(csvFiles);
    
    if numFiles == 0
        error('No CSV files found in test data folder: %s', folderPath);
    end
    
    % Initialize logger
    logger = logging();
    logger.log(sprintf('Starting test spectrogram generation for %d files', numFiles), 'INFO');
    
    % Process files
    for fileIdx = 1:numFiles
        try
            fileName = csvFiles(fileIdx).name;
            filePath = fullfile(folderPath, fileName);
            
            % Process single file
            process_single_test_file(filePath, folderPath);
            
        catch ME
            logger.log(sprintf('Error processing test file %s: %s', fileName, ME.message), 'ERROR');
        end
    end
    
    logger.log('Test spectrogram generation completed', 'INFO');
end

function labels = generate_labels_from_filenames(filePaths)
    % GENERATE_LABELS_FROM_FILENAMES - Generate labels based on filename patterns
    
    labels = strings(length(filePaths), 1);
    
    for i = 1:length(filePaths)
        filename = filePaths{i};
        
        if contains(filename, 'drone', 'IgnoreCase', true) && ~contains(filename, 'bird', 'IgnoreCase', true)
            labels(i) = 'drone';
        elseif contains(filename, 'fan_bird', 'IgnoreCase', true) || ...
               (contains(filename, 'drone', 'IgnoreCase', true) && contains(filename, 'bird', 'IgnoreCase', true))
            labels(i) = 'drone + bird';
        elseif contains(filename, 'bird', 'IgnoreCase', true)
            labels(i) = 'bird';
        elseif contains(filename, 'file', 'IgnoreCase', true) || contains(filename, 'rc', 'IgnoreCase', true)
            labels(i) = 'RC plane';
        else
            labels(i) = 'unknown';
        end
    end
end

function process_single_training_file(filePath, outputFolder)
    % PROCESS_SINGLE_TRAINING_FILE - Process one training file using SVMD
    
    params = parameters();
    
    % Load data
    [radar_Data, time_Data, Fs_original] = data_loader(filePath, params);
    
    % Preprocessing
    downsample_factor = params.signal.downsample_factor;
    Fs_new = params.signal.Fs_new;
    
    Fs_downsampled = Fs_original / downsample_factor;
    radar_Data_downsampled = downsample(radar_Data, downsample_factor);
    radar_Data_resampled = resample(radar_Data_downsampled, Fs_new, Fs_downsampled);
    
    % Low-pass filtering
    [b, a] = butter(params.signal.filter_order, params.signal.Fc / (Fs_new / 2), 'low');
    filtered_radar_Data = filtfilt(b, a, radar_Data_resampled);
    
    % Apply SVMD
    try
        [u, ~] = svmd(filtered_radar_Data, params.svmd.maxAlpha, params.svmd.tau, ...
                      params.svmd.tol, params.svmd.stopc);
        u = u.';
    catch
        % Fallback to VMD if SVMD fails
        warning('SVMD failed, using VMD instead');
        [u, ~] = vmd(filtered_radar_Data, 'NumIMFs', 5);
    end
    
    % Generate cross-term-free STFT
    cross_term_free_STFT = generate_cross_term_free_stft(u, Fs_new, params);
    
    % Save spectrogram
    [~, baseFileName, ~] = fileparts(filePath);
    save_spectrogram_image(cross_term_free_STFT, outputFolder, baseFileName);
end

function process_single_test_file(filePath, outputFolder)
    % PROCESS_SINGLE_TEST_FILE - Process one test file using VMD
    
    params = parameters();
    
    % Load data
    [radar_Data, time_Data, Fs_original] = data_loader(filePath, params);
    
    % Limit to specified duration
    total_samples = min(length(radar_Data), Fs_original * params.signal.data_duration);
    radar_Data = radar_Data(1:total_samples);
    time_Data = time_Data(1:total_samples);
    
    % Preprocessing
    downsample_factor = params.signal.downsample_factor;
    Fs_downsampled = Fs_original / downsample_factor;
    radar_Data_downsampled = downsample(radar_Data, downsample_factor);
    radar_Data_resampled = resample(radar_Data_downsampled, Fs_original, Fs_downsampled);
    
    % Low-pass filtering
    [b, a] = butter(params.signal.filter_order, params.signal.Fc / (Fs_original / 2), 'low');
    filtered_radar_Data = filtfilt(b, a, radar_Data_resampled);
    
    % Apply VMD
    [filtered_radar_Data_decompose, ~] = vmd(filtered_radar_Data, 'NumIMFs', params.vmd.num_imfs);
    
    % Generate combined spectrogram
    stft_combined = generate_combined_spectrogram(filtered_radar_Data_decompose, Fs_original, params);
    
    % Save spectrogram
    [~, baseFileName, ~] = fileparts(filePath);
    save_combined_spectrogram_image(stft_combined, outputFolder, baseFileName);
end

function cross_term_free_STFT = generate_cross_term_free_stft(u, Fs, params)
    % GENERATE_CROSS_TERM_FREE_STFT - Generate cross-term-free STFT
    
    window_length = min(params.stft.window_length, min(cellfun(@length, num2cell(u, 2))));
    noverlap = round(window_length * params.stft.overlap_ratio);
    nfft = params.stft.nfft;
    
    % Initialize
    cross_term_free_STFT = [];
    
    for i = 1:size(u, 1)
        IMF = u(i, :);
        
        if length(IMF) >= window_length
            [s, f, t] = stft(IMF, Fs, 'Window', hann(window_length), ...
                           'OverlapLength', noverlap, 'FFTLength', nfft);
            
            if isempty(cross_term_free_STFT)
                cross_term_free_STFT = abs(s);
            else
                cross_term_free_STFT = cross_term_free_STFT + abs(s);
            end
        end
    end
end

function stft_combined = generate_combined_spectrogram(imfs, Fs, params)
    % GENERATE_COMBINED_SPECTROGRAM - Generate combined spectrogram from IMFs
    
    window_length = params.stft.window_length;
    noverlap = params.stft.noverlap;
    nfft = params.stft.nfft;
    
    % Initialize with first IMF
    imf = imfs(:, 1);
    [~, F, T, P] = spectrogram(imf, hamming(window_length), noverlap, nfft, Fs, 'yaxis');
    stft_combined = zeros(size(P));
    
    % Combine all IMFs
    for i = 1:size(imfs, 2)
        imf = imfs(:, i);
        [~, F, T, P] = spectrogram(imf, hamming(window_length), noverlap, nfft, Fs, 'yaxis');
        
        if size(P, 1) ~= size(stft_combined, 1) || size(P, 2) ~= size(stft_combined, 2)
            P = imresize(P, [size(stft_combined, 1), size(stft_combined, 2)]);
        end
        
        stft_combined = stft_combined + abs(P);
    end
    
    % Average the result
    stft_combined = stft_combined / size(imfs, 2);
end

function save_spectrogram_image(spectrogram_data, output_folder, base_filename)
    % SAVE_SPECTROGRAM_IMAGE - Save spectrogram as image without axes
    
    figure('Visible', 'off');
    imagesc(abs(spectrogram_data));
    axis off;
    set(gca, 'Position', [0 0 1 1]);
    
    output_path = fullfile(output_folder, sprintf('spectrogram_%s.png', base_filename));
    saveas(gcf, output_path);
    close(gcf);
end

function save_combined_spectrogram_image(spectrogram_data, output_folder, base_filename)
    % SAVE_COMBINED_SPECTROGRAM_IMAGE - Save combined spectrogram as image
    
    figure('Visible', 'off');
    imagesc(10*log10(abs(spectrogram_data)));
    axis off;
    set(gca, 'position', [0 0 1 1], 'units', 'normalized');
    
    output_path = fullfile(output_folder, sprintf('Combined_Spectrogram_%s.png', base_filename));
    saveas(gcf, output_path);
    close(gcf);
end

function generate_summary_report(config)
    % GENERATE_SUMMARY_REPORT - Generate processing summary report
    
    fprintf('\n=== Processing Summary Report ===\n');
    
    % Count files in each directory
    train_files = length(dir(fullfile(config.train_data_path, '*.csv')));
    test_files = length(dir(fullfile(config.test_data_path, '*.csv')));
    train_spectrograms = length(dir(fullfile(config.train_spectrograms_path, '*.png')));
    test_spectrograms = length(dir(fullfile(config.test_data_path, '*.png')));
    
    fprintf('Training CSV files: %d\n', train_files);
    fprintf('Test CSV files: %d\n', test_files);
    fprintf('Training spectrograms generated: %d\n', train_spectrograms);
    fprintf('Test spectrograms generated: %d\n', test_spectrograms);
    
    % Check for features file
    features_file = fullfile(config.features_path, 'extracted_features.mat');
    if exist(features_file, 'file')
        load(features_file, 'F', 'labels');
        fprintf('Features extracted: %d samples with %d features each\n', size(F));
        
        % Display class distribution
        unique_labels = unique(labels);
        fprintf('\nClass distribution:\n');
        for i = 1:length(unique_labels)
            count = sum(strcmp(labels, unique_labels{i}));
            fprintf('  %s: %d samples\n', unique_labels{i}, count);
        end
    else
        fprintf('Features file not found\n');
    end
    
    fprintf('================================\n\n');
end
