% This function takes in a directory of labeled images, transforms their
% resolutions, and stores the transformed images in a new directory

function LabelImageTransformationFunction = transformLabelImage(labelDir, ratio, dilateWidth)

% Example:
% labelDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Label';
% ratio = 0.2; --> to make the resolution power of 2
% dilateWidth = 5;

    % obtain the original list of images
    imageList = dir(fullfile(labelDir, '*.tif'));
    resizedImageList = cell(length(imageList),1);
    
    % transform images: dilate first, then resize
    for i = 1:length(imageList)
        thisImage = imread([imageList(i).folder, filesep, imageList(i).name]);
        thisImageDilated = imdilate(thisImage, strel('square', dilateWidth));
        thisImageResized = imresize(thisImageDilated, ratio, 'Method', 'nearest');
        resizedImageList{i} = thisImageResized;
    end
    
    % store the transformed images in the new directory
    resizedLabelDir = [labelDir,' Resized'];
    mkdir(resizedLabelDir);

    for i = 1:length(imageList)
        imwrite(resizedImageList{i},fullfile(resizedLabelDir, ['Resized', imageList(i).name]));
    end
    
end
