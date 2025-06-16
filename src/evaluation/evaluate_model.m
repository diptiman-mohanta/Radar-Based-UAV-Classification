function results = evaluate_model(features_file, test_spectrograms_path)
    % EVALUATE_MODEL - Evaluate the classification model
    % Input:
    %   features_file - path to saved features file
    %   test_spectrograms_path - path to test spectrograms
    % Output:
    %   results - structure containing evaluation metrics
    
    fprintf('Loading features and preparing evaluation...\n');
    
    % Load training features (assuming they're saved)
    if exist(features_file, 'file')
        load(features_file, 'F', 'labels');
        features_train = F;
        labels_train = labels;
    else
        error('Features file not found: %s', features_file);
    end
    
    % Load test spectrograms and extract features
    test_imds = imageDatastore(test_spectrograms_path);
    
    if isempty(test_imds.Files)
        error('No test images found in: %s', test_spectrograms_path);
    end
    
    % Load pretrained network
    net = squeezenet;
    inputSize = net.Layers(1).InputSize;
    test_augimds = augmentedImageDatastore(inputSize(1:2), test_imds);
    
    % Extract features from test images
    layer = 'ClassificationLayer_predictions';
    features_test = activations(net, test_augimds, layer, 'OutputAs', 'rows');
    
    % Generate test labels (you might need to modify this based on your test data naming)
    labels_test = generate_test_labels(test_imds.Files);
    
    % Simple classification using k-NN (you can replace with your preferred classifier)
    mdl = fitcknn(features_train, labels_train, 'NumNeighbors', 5);
    predicted_labels = predict(mdl, features_test);
    
    % Calculate metrics
    results = calculate_metrics(labels_test, predicted_labels);
    
    % Display results
    display_results(results);
end

function labels = generate_test_labels(file_paths)
    % GENERATE_TEST_LABELS - Generate labels for test files
    labels = strings(length(file_paths), 1);
    
    for i = 1:length(file_paths)
        filename = file_paths{i};
        if contains(filename, 'drone', 'IgnoreCase', true)
            labels(i) = 'drone';
        elseif contains(filename, 'fan_bird', 'IgnoreCase', true)
            labels(i) = 'drone + bird';
        elseif contains(filename, 'bird', 'IgnoreCase', true)
            labels(i) = 'bird';
        elseif contains(filename, 'file', 'IgnoreCase', true)
            labels(i) = 'RC plane';
        else
            labels(i) = 'unknown';
        end
    end
end

function results = calculate_metrics(true_labels, predicted_labels)
    % CALCULATE_METRICS - Calculate classification metrics
    
    % Confusion matrix
    [C, order] = confusionmat(true_labels, predicted_labels);
    results.confusion_matrix = C;
    results.class_order = order;
    
    % Overall accuracy
    results.accuracy = sum(diag(C)) / sum(C(:));
    
    % Per-class metrics
    num_classes = length(order);
    results.precision = zeros(num_classes, 1);
    results.recall = zeros(num_classes, 1);
    results.f1_score = zeros(num_classes, 1);
    
    for i = 1:num_classes
        TP = C(i, i);
        FP = sum(C(:, i)) - TP;
        FN = sum(C(i, :)) - TP;
        
        results.precision(i) = TP / (TP + FP);
        results.recall(i) = TP / (TP + FN);
        results.f1_score(i) = 2 * (results.precision(i) * results.recall(i)) / ...
                              (results.precision(i) + results.recall(i));
    end
    
    % Handle NaN values
    results.precision(isnan(results.precision)) = 0;
    results.recall(isnan(results.recall)) = 0;
    results.f1_score(isnan(results.f1_score)) = 0;
end

function display_results(results)
    % DISPLAY_RESULTS - Display evaluation results
    
    fprintf('\n=== Evaluation Results ===\n');
    fprintf('Overall Accuracy: %.2f%%\n', results.accuracy * 100);
    
    fprintf('\nPer-class Performance:\n');
    fprintf('%-15s %-10s %-10s %-10s\n', 'Class', 'Precision', 'Recall', 'F1-Score');
    fprintf('%s\n', repmat('-', 1, 50));
    
    for i = 1:length(results.class_order)
        fprintf('%-15s %-10.3f %-10.3f %-10.3f\n', ...
                results.class_order{i}, ...
                results.precision(i), ...
                results.recall(i), ...
                results.f1_score(i));
    end
    
    fprintf('\nConfusion Matrix:\n');
    disp(results.confusion_matrix);
    fprintf('Class order: '); disp(results.class_order');
end
