function visualize_results(features_file, output_dir)
    % VISUALIZE_RESULTS - Create visualizations of the results
    
    if nargin < 2
        output_dir = 'examples/sample_results/';
    end
    
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Load features
    if exist(features_file, 'file')
        load(features_file, 'F', 'labels');
    else
        error('Features file not found: %s', features_file);
    end
    
    % 1. Feature distribution visualization
    visualize_feature_distribution(F, labels, output_dir);
    
    % 2. Class distribution
    visualize_class_distribution(labels, output_dir);
    
    % 3. Sample spectrograms
    create_sample_spectrogram_grid(output_dir);
    
    fprintf('Visualizations saved to: %s\n', output_dir);
end

function visualize_feature_distribution(features, labels, output_dir)
    % Visualize first 3 principal components
    [coeff, score] = pca(features);
    
    figure('Position', [100, 100, 800, 600]);
    unique_labels = unique(labels);
    colors = lines(length(unique_labels));
    
    for i = 1:length(unique_labels)
        idx = strcmp(labels, unique_labels{i});
        scatter3(score(idx, 1), score(idx, 2), score(idx, 3), ...
                50, colors(i, :), 'filled', 'DisplayName', unique_labels{i});
        hold on;
    end
    
    xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
    title('Feature Distribution (First 3 Principal Components)');
    legend('Location', 'best');
    grid on;
    
    saveas(gcf, fullfile(output_dir, 'feature_distribution_3d.png'));
    close(gcf);
end

function visualize_class_distribution(labels, output_dir)
    % Class distribution bar chart
    [unique_labels, ~, idx] = unique(labels);
    counts = accumarray(idx, 1);
    
    figure('Position', [100, 100, 600, 400]);
    bar(counts);
    set(gca, 'XTickLabel', unique_labels);
    title('Class Distribution');
    ylabel('Number of Samples');
    xlabel('Classes');
    
    % Add count labels on bars
    for i = 1:length(counts)
        text(i, counts(i) + max(counts)*0.01, num2str(counts(i)), ...
             'HorizontalAlignment', 'center');
    end
    
    saveas(gcf, fullfile(output_dir, 'class_distribution.png'));
    close(gcf);
end

function create_sample_spectrogram_grid(output_dir)
    % Create a grid of sample spectrograms (placeholder function)
    % You would implement this based on your actual spectrogram data
    
    fprintf('Sample spectrogram grid creation - implement based on your data\n');
    % This would load sample spectrograms and create a grid visualization
end
