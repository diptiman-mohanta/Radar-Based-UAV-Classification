clc;
clear all;
close all;

% Load the image datastore
imds = imageDatastore("D:\DIAT-uSAT_dataset_mat_file\CSV Files\train data spectogram");

% Load the pretrained network
net = squeezenet;

% Set the input size for the augmented image datastore
inputSize = net.Layers(1).InputSize;
augimds = augmentedImageDatastore(inputSize(1:2), imds);

% Specify the layer for feature extraction
layer = 'ClassificationLayer_predictions';

% Extract features using the activations function
featureTrain = activations(net, augimds, layer, 'OutputAs', 'rows');

% Initialize the final feature matrix with labels
F = featureTrain;
labels = strings(size(F, 1), 1); % Initialize labels array

% Initialize the counter
counter = 0;

% Loop through files and assign labels based on file name
for i = 1:numel(imds.Files)
    filename = imds.Files{i};
    counter = counter + 1; % Increment the counter
    fprintf('Processing file %d: %s\n', counter, filename); % Display the counter and file name

    if contains(filename, 'drone', 'IgnoreCase', true)
        labels(i) = 'drone';
    elseif contains(filename, 'fan_bird', 'IgnoreCase', true)
        labels(i) = 'drone + bird';
    elseif contains(filename, 'bird', 'IgnoreCase', true)
        labels(i) = 'bird';
    elseif contains(filename, 'file', 'IgnoreCase', true)
        labels(i) = 'RC plane';
    else
        labels(i) = 'unknown'; % In case of any unmatched file names
    end
end

% Append labels to the feature matrix
F = [F, labels];

% Display the labeled feature matrix
disp(F);
