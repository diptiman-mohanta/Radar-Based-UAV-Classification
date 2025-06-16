function params = parameters()
    % PARAMETERS - Configuration parameters for the radar classification system
    
    %% Signal Processing Parameters
    params.signal.downsample_factor = 20;          % Downsampling factor
    params.signal.Fs_new = 10000;                  % New sampling frequency (Hz)
    params.signal.data_duration = 3;               % Data duration (seconds)
    params.signal.Fc = 2000;                       % Low-pass cutoff frequency (Hz)
    params.signal.filter_order = 4;                % Filter order
    
    %% SVMD Parameters
    params.svmd.maxAlpha = 20000;                   % Compactness of mode
    params.svmd.tau = 0;                            % Time-step of dual ascent
    params.svmd.tol = 1e-6;                         % Tolerance of convergence
    params.svmd.stopc = 4;                          % Stopping criteria
    params.svmd.fs = 125;                           % Original sampling frequency
    
    %% VMD Parameters
    params.vmd.num_imfs = 9;                        % Number of IMFs for VMD
    
    %% STFT Parameters
    params.stft.window_length = 256;                % Window length (samples)
    params.stft.noverlap = 200;                     % Overlap length (samples)
    params.stft.nfft = 1024;                        % DFT points
    params.stft.overlap_ratio = 0.5;                % Overlap ratio (50%)
    
    %% Deep Learning Parameters
    params.dl.network = 'squeezenet';               % Pre-trained network
    params.dl.layer = 'ClassificationLayer_predictions'; % Feature extraction layer
    params.dl.input_size = [227, 227, 3];          % Input size for SqueezeNet
    
    %% File Paths (relative to project root)
    params.paths.train_data = 'data/raw/train/';
    params.paths.test_data = 'data/raw/test/';
    params.paths.train_spectrograms = 'data/processed/train_spectrograms/';
    params.paths.test_spectrograms = 'data/processed/test_spectrograms/';
    params.paths.features = 'data/features/';
    params.paths.results = 'results/';
    params.paths.logs = 'logs/';
    
    %% Classification Parameters
    params.classification.classes = {'drone', 'bird', 'RC plane', 'drone + bird', 'unknown'};
    params.classification.filename_patterns = {
        'drone', 'drone';
        'fan_bird', 'drone + bird';
        'bird', 'bird';
        'file', 'RC plane'
    };
    
    %% Processing Parameters
    params.processing.batch_size = 50;              % Files to process in one batch
    params.processing.verbose = true;               % Display progress
    params.processing.save_intermediate = true;     % Save intermediate results
    
    %% Visualization Parameters
    params.viz.figure_size = [800, 600];           % Default figure size
    params.viz.dpi = 300;                          % Figure resolution
    params.viz.colormap = 'jet';                   % Default colormap
end