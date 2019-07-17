%% train the network

trainImageDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Resized Training';
trainLabelDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Label Resized Binarized Training';
valImageDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Resized Validation';
valLabelDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Label Resized Binarized Validation';

% Create an imageDatastore holding the training images
imds = imageDatastore(trainImageDir);

% Define the class names and their associaed label IDs
classNames = ["label", "background"];
labelIDs = [1 0];

% Creates a pixelLabelDatastore holding the ground truth pixel labels for
% the training images
pxds = pixelLabelDatastore(trainLabelDir, classNames, labelIDs);

% Create U-Net
imageSize = [128 128];
numClasses = 2;
lgraph = unetLayers(imageSize, numClasses)

% Create data source for training a semantic segmentation network
ds = pixelLabelImageDatastore(imds, pxds);

% Create data source for validation
imdsVal = imageDatastore(valImageDir);
pxdsVal = pixelLabelDatastore(valLabelDir, classNames, labelIDs);
dsVal = pixelLabelImageDatastore(imdsVal, pxdsVal);

% Set up training options
options = trainingOptions('sgdm', 'InitialLearnRate', 0.005, 'MaxEpochs', 10, 'MiniBatchSize', 2, 'ValidationData', dsVal, 'ValidationFrequency', 20, 'Plots', 'training-progress');

% Train the network
net = trainNetwork(ds, lgraph, options)

% Save the network
save net

%% test the network

testImageDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Resized Test';
testLabelDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Label Resized Binarized Test';

% Create an image datastore holding the test images
imdsTest = imageDatastore(testImageDir);

% Create a pixel label datastore holding the ground truth pixel labels of
% the test images
pxdsTruth = pixelLabelDatastore(testLabelDir, classNames, labelIDs);

% Load a semantic segmentation network that has been trained on the
% training images
net = load('net.mat');
net = net.net;

% Run the network on the test images. Predicted labels are written to disk
% in a temporary folder and returned as a pixelLabelDatastore
pxdsResults = semanticseg(imdsTest, net, "WriteLocation", tempdir);

% Evaluate the prediction results against the ground truth
metrics = evaluateSemanticSegmentation(pxdsResults, pxdsTruth)

% metrics.ConfusionMatrix
% metrics.NormalizedConfusionMatrix
% metrics.DataSetMetrics
% metrics.ClassMetrics
% metrics.ImageMetrics

%% visualize some results

I = imread('TestResizedimage002.tif');
[C, scores] = semanticseg(I, net);

% overlay input and prediction
B = labeloverlay(I, C);
figure; imshow(B)
figure;imshow(I)

% classification score - confidence
figure;imagesc(scores);colorbar

%% test the customized layer
layer = weightedClassificationLayer('weightedClass');
validInputSize = [1 1 10];
checkLayer(layer, validInputSize, 'ObservationDimension', 4);




