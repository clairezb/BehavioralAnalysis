% This function takes in a directory of images and binarizes all images,
% setting all non-zero pixel values to 1.

function ImageBinarizationFunction = binarizeImage(imageDir)

% Example;
% imageDir = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2) Selected Images Label Resized';

    imageList = dir(fullfile(imageDir, '*.tif'));
    binarizedImageList = cell(length(imageList),1);

    for i = 1:length(imageList)
        thisImage = imread([imageList(i).folder, filesep, imageList(i).name]);
        thisImageBinarized = imbinarize(thisImage, 0);
        binarizedImageList{i} = thisImageBinarized;
    end
    
    newImageDir = [imageDir, ' Binarized'];
    mkdir(newImageDir);
    
    for i = 1:length(imageList)
        imwrite(binarizedImageList{i},fullfile(newImageDir, ['Binarized', imageList(i).name]));
    end
    
end