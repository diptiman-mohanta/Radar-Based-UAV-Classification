clc;
clear all;
close all;

% Specify the folder containing the CSV files
folderPath = 'D:\DIAT-uSAT_dataset_mat_file\CSV Files\Train Data';  % Replace with your folder path
outputFolder = fullfile(folderPath, 'Spectrograms');  % Folder to save spectrogram images

% Create output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Get a list of all CSV files in the folder
csvFiles = dir(fullfile(folderPath, '*.csv'));
numFiles = length(csvFiles);  % Total number of files
processedFiles = 0;  % Initialize the counter for processed files

% Loop through each CSV file in the folder
for fileIdx = 1:numFiles
    % Read current CSV file
    fileName = csvFiles(fileIdx).name;
    filePath = fullfile(folderPath, fileName);
    fprintf('Processing file %d of %d: %s\n', fileIdx, numFiles, fileName);

    % Load radar data
    data = readtable(filePath);
    radar_Data = table2array(data(:, 2));  
    time_Data = table2array(data(:, 6));  

    % Original sampling frequency calculation
    time_intervals = diff(time_Data);
    Fs_original = 1 / mean(time_intervals);

    % Downsampling and resampling
    downsample_factor = 20;  % More aggressive downsampling to reduce memory usage
    Fs_downsampled = Fs_original / downsample_factor;
    radar_Data_downsampled = downsample(radar_Data, downsample_factor);
    time_Data_downsampled = downsample(time_Data, downsample_factor);
    Fs_new = 10000;  % New sampling frequency (10 kHz)
    radar_Data_resampled = resample(radar_Data_downsampled, Fs_new, Fs_downsampled);

    % Low-pass filtering
    Fc = 2000;
    order = 4;
    [b, a] = butter(order, Fc / (Fs_new / 2), 'low');
    filtered_radar_Data = filtfilt(b, a, radar_Data_resampled);

    % SVMD Parameters Initialization
    maxAlpha = 20000;   % Compactness of mode
    tau = 0;            % Time-step of the dual ascent
    tol = 1e-6;         % Tolerance of convergence criterion
    stopc = 4;          % Stopping criteria
    fs = 125;           % Original sampling frequency

    % Apply Successive Variational Mode Decomposition (SVMD)
    [u, ~] = svmd(filtered_radar_Data, maxAlpha, tau, tol, stopc);
    u = u.';  % Transpose for easier handling

    % Define STFT parameters
    window_length = min(256, min(cellfun(@length, num2cell(u, 2)))); % Adjust window length
    noverlap = round(window_length * 0.5);  % 50% overlap
    nfft = 1024;  % Number of FFT points

    % Initialize cross-term-free STFT
    cross_term_free_STFT = zeros(nfft, length(filtered_radar_Data));
    t = [];  % Initialize t

    % Compute STFT for each IMF and sum to create cross-term-free representation
    for i = 1:size(u, 1)
        IMF = u(i, :);
        
        % Check if IMF length is greater than or equal to window length
        if length(IMF) >= window_length
            % Compute STFT for each IMF
            [s, f, t] = stft(IMF, Fs_new, 'Window', hann(window_length), 'OverlapLength', noverlap, 'FFTLength', nfft);
            
            % Sum the magnitudes of the STFTs of IMFs to create cross-term-free representation
            cross_term_free_STFT = cross_term_free_STFT + abs(s);
        else
            warning('IMF length is shorter than the window length, skipping STFT computation for this IMF.');
        end
    end

    % Check if t is defined after the loop
    if ~isempty(t)
        % Extract the base file name without extension
        [~, baseFileName, ~] = fileparts(fileName);
        
        % Plot and save cross-term-free STFT as an image
        figure('Visible', 'off');  % Do not display the figure
        imagesc(t, f, abs(cross_term_free_STFT));
        axis off;  % Remove axes and labels
        set(gca, 'Position', [0 0 1 1]);  % Remove margins

        % Save the image
        saveas(gcf, fullfile(outputFolder, sprintf('spectrogram_%s.png', baseFileName)));
        close(gcf);  % Close the figure
    else
        warning('No valid IMF found for STFT computation for file: %s.', fileName);
    end

    % Update and display the processed file counter
    processedFiles = processedFiles + 1;
    fprintf('Processed %d out of %d files.\n', processedFiles, numFiles);
end

fprintf('All files processed. Total number of files: %d.\n', numFiles);
