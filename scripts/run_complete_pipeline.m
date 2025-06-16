function run_complete_pipeline()
    % RUN_COMPLETE_PIPELINE - Execute the entire processing pipeline
    
    clc; clear; close all;
    
    fprintf('=== Radar-Based UAV Classification Pipeline ===\n\n');
    
    % Configuration
    config = get_config();
    
    % Step 1: Validate paths
    fprintf('Step 1: Validating paths...\n');
    if ~exist(config.train_data_path, 'dir')
        error('Training data path does not exist: %s', config.train_data_path);
    end
    if ~exist(config.test_data_path, 'dir')
        error('Test data path does not exist: %s', config.test_data_path);
    end
    fprintf('✓ All paths validated\n\n');
    
    % Step 2: Generate training spectrograms
    fprintf('Step 2: Generating training spectrograms...\n');
    generate_training_spectrograms_wrapper(config);
    fprintf('✓ Training spectrograms generated\n\n');
    
    % Step 3: Extract features
    fprintf('Step 3: Extracting features using SqueezeNet...\n');
    extract_features_wrapper(config);
    fprintf('✓ Features extracted\n\n');
    
    % Step 4: Generate test spectrograms
    fprintf('Step 4: Generating test spectrograms...\n');
    generate_test_spectrograms_wrapper(config);
    fprintf('✓ Test spectrograms generated\n\n');
    
    % Step 5: Performance summary
    fprintf('Step 5: Pipeline summary...\n');
    generate_summary_report(config);
    
    fprintf('\n=== Pipeline completed successfully! ===\n');
end

function config = get_config()
    % GET_CONFIG - Get configuration parameters
    config.train_data_path = 'data/raw/train/';
    config.test_data_path = 'data/raw/test/';
    config.train_spectrograms_path = 'data/processed/train_spectrograms/';
    config.test_spectrograms_path = 'data/processed/test_spectrograms/';
    config.features_path = 'data/features/';
    
    % Create directories if they don't exist
    dirs = {config.train_spectrograms_path, config.test_spectrograms_path, config.features_path};
    for i = 1:length(dirs)
        if ~exist(dirs{i}, 'dir')
            mkdir(dirs{i});
        end
    end
end
