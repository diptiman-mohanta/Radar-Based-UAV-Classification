function setup_environment()
    % SETUP_ENVIRONMENT - Set up the MATLAB environment for the project
    
    fprintf('Setting up Radar-Based UAV Classification environment...\n\n');
    
    %% Check MATLAB version
    matlab_version = version('-release');
    year = str2double(matlab_version(1:4));
    if year < 2020
        warning('This code is optimized for MATLAB R2020b or later. Some features may not work properly.');
    else
        fprintf('✓ MATLAB version: %s\n', matlab_version);
    end
    
    %% Check required toolboxes
    required_toolboxes = {
        'Signal Processing Toolbox', 'signal';
        'Deep Learning Toolbox', 'nnet';
        'Image Processing Toolbox', 'images';
        'Statistics and Machine Learning Toolbox', 'stats'
    };
    
    fprintf('\nChecking required toolboxes:\n');
    missing_toolboxes = {};
    
    for i = 1:size(required_toolboxes, 1)
        toolbox_name = required_toolboxes{i, 1};
        toolbox_dir = required_toolboxes{i, 2};
        
        if license('test', toolbox_dir)
            fprintf('✓ %s\n', toolbox_name);
        else
            fprintf('✗ %s - NOT AVAILABLE\n', toolbox_name);
            missing_toolboxes{end+1} = toolbox_name;
        end
    end
    
    if ~isempty(missing_toolboxes)
        fprintf('\nWARNING: The following toolboxes are missing:\n');
        for i = 1:length(missing_toolboxes)
            fprintf('  - %s\n', missing_toolboxes{i});
        end
        fprintf('Please install these toolboxes for full functionality.\n');
    end
    
    %% Create directory structure
    fprintf('\nCreating directory structure:\n');
    params = parameters();
    
    dirs_to_create = {
        params.paths.train_data,
        params.paths.test_data,
        params.paths.train_spectrograms,
        params.paths.test_spectrograms,
        params.paths.features,
        params.paths.results,
        params.paths.logs,
        'examples/sample_results/',
        'docs/figures/'
    };
    
    for i = 1:length(dirs_to_create)
        if ~exist(dirs_to_create{i}, 'dir')
            mkdir(dirs_to_create{i});
            fprintf('✓ Created: %s\n', dirs_to_create{i});
        else
            fprintf('✓ Exists: %s\n', dirs_to_create{i});
        end
    end
    
    %% Add paths to MATLAB path
    fprintf('\nAdding project directories to MATLAB path:\n');
    project_dirs = {
        'src/',
        'src/data_preprocessing/',
        'src/feature_extraction/',
        'src/utils/',
        'src/evaluation/',
        'src/visualization/',
        'config/',
        'scripts/'
    };
    
    for i = 1:length(project_dirs)
        if exist(project_dirs{i}, 'dir')
            addpath(project_dirs{i});
            fprintf('✓ Added to path: %s\n', project_dirs{i});
        end
    end
    
    %% Test core functions
    fprintf('\nTesting core functionality:\n');
    
    % Test signal processing
    try
        test_signal = randn(1000, 1);
        [b, a] = butter(4, 0.3);
        filtered = filtfilt(b, a, test_signal);
        fprintf('✓ Signal processing functions working\n');
    catch ME
        fprintf('✗ Signal processing test failed: %s\n', ME.message);
    end
    
    % Test deep learning
    try
        net = squeezenet;
        fprintf('✓ SqueezeNet loaded successfully\n');
    catch ME
        fprintf('✗ Deep learning test failed: %s\n', ME.message);
    end
    
    %% Save setup info
    setup_info.date = datestr(now);
    setup_info.matlab_version = matlab_version;
    setup_info.missing_toolboxes = missing_toolboxes;
    
    save('setup_info.mat', 'setup_info');
    
    fprintf('\n=== Environment setup completed! ===\n');
    fprintf('Setup information saved to: setup_info.mat\n');
    
    if isempty(missing_toolboxes)
        fprintf('All required toolboxes are available. You can now run the pipeline.\n');
    else
        fprintf('Please install missing toolboxes before running the full pipeline.\n');
    end
    
    fprintf('\nTo get started:\n');
    fprintf('1. Place your training data in: %s\n', params.paths.train_data);
    fprintf('2. Place your test data in: %s\n', params.paths.test_data);
    fprintf('3. Run: run_complete_pipeline()\n');
end
