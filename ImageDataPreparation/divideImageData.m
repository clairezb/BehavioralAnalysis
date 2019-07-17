% This function takes in a directory of images and another one of labeled
% images. The function randomly divides them into three categories: training set,
% validation set, and test set, each in a new directory.

function ImageDataDivisionFunction = divideImageData(quantity, trainRatio, valRatio, testRatio, imageDir, labelDir)

%{
 Example:
 quantity = 200;
 trainRatio = 0.85;
 valRatio = 0.05;
 testRatio = 0.1;
 imageDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Resized';
 labelDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Label Resized Binarized';
%}

    [trainInd, valInd, testInd] = dividerand(quantity, trainRatio, valRatio, testRatio);
    
    imageList = dir(fullfile(imageDir, '*.tif'));
    labelList = dir(fullfile(labelDir, '*.tif'));
    
    trainImageDir = [imageDir, ' Training'];
    valImageDir = [imageDir, ' Validation'];
    testImageDir = [imageDir, ' Test'];
    trainLabelDir = [labelDir, ' Training'];
    valLabelDir = [labelDir, ' Validation'];
    testLabelDir = [labelDir, ' Test'];
    mkdir(trainImageDir);
    mkdir(valImageDir);
    mkdir(testImageDir);
    mkdir(trainLabelDir);
    mkdir(valLabelDir);
    mkdir(testLabelDir);
    
    for i=1:length(trainInd)
        thisImage = imread([imageList(trainInd(i)).folder, filesep, imageList(trainInd(i)).name]);
        imwrite(thisImage, fullfile(trainImageDir, ['Training', imageList(trainInd(i)).name]));
        thisLabel = imread([labelList(trainInd(i)).folder, filesep, labelList(trainInd(i)).name]);
        imwrite(thisLabel, fullfile(trainLabelDir, ['Training', labelList(trainInd(i)).name]));
    end
    
    for i=1:length(valInd)
        thisImage = imread([imageList(valInd(i)).folder, filesep, imageList(valInd(i)).name]);
        imwrite(thisImage, fullfile(valImageDir, ['Validation', imageList(valInd(i)).name]));
        thisLabel = imread([labelList(valInd(i)).folder, filesep, labelList(valInd(i)).name]);
        imwrite(thisLabel, fullfile(valLabelDir, ['Validation', labelList(valInd(i)).name]));
    end
    
    for i=1:length(testInd)
        thisImage = imread([imageList(testInd(i)).folder, filesep, imageList(testInd(i)).name]);
        imwrite(thisImage, fullfile(testImageDir, ['Test', imageList(testInd(i)).name]));
        thisLabel = imread([labelList(testInd(i)).folder, filesep, labelList(testInd(i)).name]);
        imwrite(thisLabel, fullfile(testLabelDir, ['Test', labelList(testInd(i)).name]));
    end
    
end
