function test_pipeline()
    % TEST_PIPELINE - Unit tests for the processing pipeline
    
    fprintf('Running pipeline tests...\n\n');
    
    % Test 1: Parameters loading
    test_parameters();
    
    % Test 2: Data validation
    test_data_validation();
    
    % Test 3: Signal processing functions
    test_signal_processing();
    
    % Test 4: SVMD function
    test_svmd();
    
    % Test 5: Feature extraction
    test_feature_extraction();
    
    fprintf('\n=== All tests completed ===\n');
end

function test_parameters()
    fprintf('Test 1: Parameters loading...\n');
    try
        params = parameters();
        assert(isfield(params, 'signal'), 'Signal parameters missing');
        assert(isfield(params, 'svmd'), 'SVMD parameters missing');
        assert(isfield(params, 'paths'), 'Path parameters missing');
        fprintf('✓ Parameters loaded successfully\n');
    catch ME
        fprintf('✗ Parameters test failed: %s\n', ME.message);
    end
end

function test_data_validation()
    fprintf('Test 2: Data validation...\n');
    
    % Create dummy CSV file for testing
    test_file = 'test_data.csv';
    dummy_data = [(1:1000)', randn(1000, 1), zeros(1000, 3), (1:1000)'/1000];
    writematrix(dummy_data, test_file);
    
    try
        [isValid, ~] = validate_data(test_file);
        assert(isValid, 'Validation should pass for valid data');
        fprintf('✓ Data validation working\n');
        
        % Clean up
        delete(test_file);
    catch ME
        fprintf('✗ Data validation test failed: %s\n', ME.message);
        if exist(test_file, 'file')
            delete(test_file);
        end
    end
end

function test_signal_processing()
    fprintf('Test 3: Signal processing...\n');
    try
        % Create test signal
        fs = 10000;
        t = 0:1/fs:1;
        test_signal = sin(2*pi*100*t) + 0.5*sin(2*pi*500*t) + 0.1*randn(size(t));
        
        % Test filtering
        [b, a] = butter(4, 1000/(fs/2), 'low');
        filtered_signal = filtfilt(b, a, test_signal);
        
        % Test downsampling
        downsampled = downsample(test_signal, 10);
        
        % Test resampling
        resampled = resample(downsampled, fs, fs/10);
        
        assert(length(filtered_signal) == length(test_signal), 'Filter output length mismatch');
        assert(length(downsampled) == length(test_signal)/10, 'Downsample output length mismatch');
        
        fprintf('✓ Signal processing functions working\n');
    catch ME
        fprintf('✗ Signal processing test failed: %s\n', ME.message);
    end
end

function test_svmd()
    fprintf('Test 4: SVMD function...\n');
    try
        % Create test signal with multiple components
        fs = 1000;
        t = 0:1/fs:2;
        test_signal = sin(2*pi*10*t) + sin(2*pi*50*t) + 0.1*randn(size(t));
        
        % Test SVMD (if available)
        if exist('svmd', 'file')
            [u, omega] = svmd(test_signal, 2000, 0, 1e-7, 4);
            assert(size(u, 1) > 0, 'SVMD should return at least one mode');
            fprintf('✓ SVMD function working\n');
        else
            fprintf('⚠ SVMD function not found - using VMD instead\n');
            % Test with built-in VMD
            [imfs, ~] = vmd(test_signal, 'NumIMFs', 3);
            assert(size(imfs, 2) >= 1, 'VMD should return at least one IMF');
            fprintf('✓ VMD function working\n');
        end
    catch ME
        fprintf('✗ SVMD/VMD test failed: %s\n', ME.message);
    end
end

function test_feature_extraction()
    fprintf('Test 5: Feature extraction...\n');
    try
        % Test if SqueezeNet is available
        net = squeezenet;
        assert(~isempty(net), 'SqueezeNet should be loaded');
        
        % Test with dummy image
        dummy_image = uint8(rand(227, 227, 3) * 255);
        features = activations(net, dummy_image, 'ClassificationLayer_predictions');
        assert(~isempty(features), 'Features should not be empty');
        
        fprintf('✓ Feature extraction working\n');
    catch ME
        fprintf('✗ Feature extraction test failed: %s\n', ME.message);
    end
end
