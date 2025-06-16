clc;
clear all;
close all;

% Specify the folder containing the radar data files
folderPath = 'D:\DIAT-uSAT_dataset_mat_file\CSV Files\Test Data';  % Replace with your actual folder path
files = dir(fullfile(folderPath, '*.csv'));  % Get all CSV files in the folder

% Specifications
data_duration = 3;  % Data collection time in seconds
window_length = 256;  % Window length in samples (25.6 ms)
noverlap = 200;  % Overlap length in samples (20.0 ms)
nfft = 1024;  % DFT points
Fc = 2000;  % Cutoff frequency in Hz
order = 4;  % Filter order

% Initialize a counter for processed files
processedFileCount = 0;

% Loop through all the files in the folder
for k = 1:length(files)
    % Load radar data
    filePath = fullfile(folderPath, files(k).name);
    data = readtable(filePath);
    radar_Data = table2array(data(:, 2));  
    time_Data = table2array(data(:, 6));  

    % Calculate the sampling frequency (Fs) from time data
    time_diff = diff(time_Data);  % Compute time differences between consecutive samples
    Fs = 1 / mean(time_diff);  % Calculate the average sampling frequency in Hz
    disp(['Calculated Sampling Frequency: ', num2str(Fs), ' Hz']);

    % Determine the total number of samples
    total_samples = Fs * data_duration;  % Total number of samples (30000 for 10 kHz and 3 seconds)

    % Downsampling and resampling
    downsample_factor = 20;  % Downsampling factor
    Fs_downsampled = Fs / downsample_factor;
    radar_Data_downsampled = downsample(radar_Data(1:total_samples), downsample_factor);  % Downsample the first 30000 samples
    time_Data_downsampled = downsample(time_Data(1:total_samples), downsample_factor);

    % Resample data to original sampling frequency
    radar_Data_resampled = resample(radar_Data_downsampled, Fs, Fs_downsampled);

    % Low-pass filtering
    [b, a] = butter(order, Fc / (Fs / 2), 'low');
    filtered_radar_Data = filtfilt(b, a, radar_Data_resampled);

    % Apply VMD
    [filtered_radar_Data_decompose, ~] = vmd(filtered_radar_Data, 'NumIMFs', 9);

    % Initialize variables to store STFT results for combined IMF
    imf = filtered_radar_Data_decompose(:, 1);
    [~, F, T, P] = spectrogram(imf, hamming(window_length), noverlap, nfft, Fs, 'yaxis');
    stft_combined = zeros(size(P));

    % Perform STFT on each IMF and combine results
    for i = 1:size(filtered_radar_Data_decompose, 2)
        imf = filtered_radar_Data_decompose(:, i);
        [~, F, T, P] = spectrogram(imf, hamming(window_length), noverlap, nfft, Fs, 'yaxis');

        % Ensure the size of P matches stft_combined
        if size(P, 1) ~= size(stft_combined, 1) || size(P, 2) ~= size(stft_combined, 2)
            % Resize P if necessary (e.g., by padding or truncating)
            P = imresize(P, [size(stft_combined, 1), size(stft_combined, 2)]);
        end

        % Sum the STFT magnitudes
        stft_combined = stft_combined + abs(P);
    end

    % Average the combined STFT
    stft_combined = stft_combined / size(filtered_radar_Data_decompose, 2);

    % Plot the combined spectrogram without any labels or scales
    figure('Visible', 'off');  % Make the figure invisible while creating it
    imagesc(T, F, 10*log10(abs(stft_combined)));
    axis off;  % Turn off axes
    set(gca, 'position', [0 0 1 1], 'units', 'normalized');  % Remove white border

    % Save the figure
    saveas(gcf, fullfile(folderPath, ['CombinedSpectrogram', files(k).name(1:end-4), '.png']));
    close(gcf);  % Close the figure after saving

    % Increment the processed file counter
    processedFileCount = processedFileCount + 1;
    disp(['Processed ', num2str(processedFileCount), ' out of ', num2str(length(files)), ' files.']);
end

% Display the total number of processed files
disp(['Total number of files processed: ', num2str(processedFileCount)]);
