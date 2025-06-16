function demo_single_file()
    % DEMO_SINGLE_FILE - Demonstrate processing of a single radar file
    
    clc; clear; close all;
    
    fprintf('=== Single File Processing Demo ===\n\n');
    
    % You would set this to an actual file path
    demo_file = 'data/raw/train/sample_drone_data.csv';
    
    if ~exist(demo_file, 'file')
        fprintf('Demo file not found: %s\n', demo_file);
        fprintf('Please place a sample CSV file at the specified location.\n');
        return;
    end
    
    % Validate the file
    [isValid, errorMsg] = validate_data(demo_file);
    if ~isValid
        fprintf('File validation failed: %s\n', errorMsg);
        return;
    end
    
    fprintf('Processing file: %s\n', demo_file);
    
    % Load and process the data (simplified version of your main code)
    data = readtable(demo_file);
    radar_Data = table2array(data(:, 2));
    time_Data = table2array(data(:, 6));
    
    % Calculate sampling frequency
    Fs = 1 / mean(diff(time_Data));
    fprintf('Detected sampling frequency: %.2f Hz\n', Fs);
    
    % Basic preprocessing
    downsample_factor = 20;
    Fs_new = 10000;
    radar_Data_downsampled = downsample(radar_Data, downsample_factor);
    radar_Data_resampled = resample(radar_Data_downsampled, Fs_new, Fs/downsample_factor);
    
    % Apply low-pass filter
    Fc = 2000;
    [b, a] = butter(4, Fc / (Fs_new / 2), 'low');
    filtered_data = filtfilt(b, a, radar_Data_resampled);
    
    % Create visualizations
    figure('Position', [100, 100, 1200, 800]);
    
    subplot(2, 2, 1);
    plot(radar_Data(1:1000));
    title('Original Signal (First 1000 samples)');
    xlabel('Sample'); ylabel('Amplitude');
    
    subplot(2, 2, 2);
    plot(filtered_data(1:1000));
    title('Filtered Signal (First 1000 samples)');
    xlabel('Sample'); ylabel('Amplitude');
    
    subplot(2, 2, 3);
    [S, F, T] = spectrogram(filtered_data, 256, 200, 1024, Fs_new);
    imagesc(T, F, 10*log10(abs(S)));
    axis xy; colorbar;
    title('Spectrogram');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    
    subplot(2, 2, 4);
    [Pxx, f] = pwelch(filtered_data, [], [], [], Fs_new);
    semilogy(f, Pxx);
    title('Power Spectral Density');
    xlabel('Frequency (Hz)'); ylabel('PSD');
    
    % Save the figure
    output_dir = 'examples/sample_results/';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    saveas(gcf, fullfile(output_dir, 'demo_single_file_analysis.png'));
    
    fprintf('\nDemo completed! Results saved to: %s\n', output_dir);
    fprintf('Check the generated visualization for signal analysis.\n');
end
