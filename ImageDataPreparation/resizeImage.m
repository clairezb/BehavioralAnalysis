% This function takes in a directory of unlabeled images, transforms their
% resolutions, and stores the transformed images in a new directory

function ImageTransformationFunction = transformImage(imageDir, ratio)

% Example:
% imageDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images';
% ratio = 0.2; --> to make the resolution power of 2

    % obtain the original list of images
    imageList = dir(fullfile(imageDir,'*.tif'));
    resizedImageList = cell(length(imageList),1);
    
    % transform images by resizing
    for i = 1:length(imageList)
        thisImage = imread([imageList(i).folder, filesep, imageList(i).name]);
        thisImageResized = imresize(thisImage, ratio);
        resizedImageList{i} = thisImageResized;
    end
    
    % store the transformed images in the new directory
    resizedLabelDir = [imageDir,' Resized'];
    mkdir(resizedLabelDir);

    for i = 1:length(imageList)
        imwrite(resizedImageList{i},fullfile(resizedLabelDir, ['Resized', imageList(i).name]));
    end
    
end
