function plot_spectrogram(data, Fs, title_str, save_path)
    % PLOT_SPECTROGRAM - Create and optionally save spectrogram
    % Input:
    %   data      - signal data
    %   Fs        - sampling frequency
    %   title_str - title for the plot
    %   save_path - path to save figure (optional)
    
    % STFT parameters
    window_length = 256;
    noverlap = 200;
    nfft = 1024;
    
    % Create spectrogram
    [S, F, T] = spectrogram(data, hamming(window_length), noverlap, nfft, Fs);
    
    % Create figure
    figure('Position', [100, 100, 800, 600]);
    imagesc(T, F, 10*log10(abs(S)));
    axis xy;
    colorbar;
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title(title_str);
    colormap(jet);
    
    % Save if path provided
    if nargin > 3 && ~isempty(save_path)
        saveas(gcf, save_path);
        close(gcf);
    end
end
