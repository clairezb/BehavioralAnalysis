function ImageExtractFunction = ExtractImage(inputVideoName, videoFileName,numberOfImages,pathName)
    % Example:
    % inputVideoName --> '20160317 10 dpf 60 fps 15 min (2).avi'
    % videoFileName --> '20160317 10 dpf 60 fps 15 min (2)'
    % numberOfImages --> 200
    % pathName(the directory where the video is) --> '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis'


    % read the video
    myvideo = VideoReader(inputVideoName);
    nFrame = myvideo.NumberOfFrames;


    % store the sum of frame difference absolute values in a matrix
    differenceSum = zeros(1,nFrame-1); % sum of the pixel differences between two consecutive frames
    % if each frame is a 2D array
    for i=1:1:(nFrame-1)
        if ndims(read(myvideo,i))==2 % if the dimension of the array is 2
            lastFrame = read(myvideo,i);
            thisFrame = read(myvideo,i+1);
        elseif ndims(read(myvideo,i))==3 % if the dimension of the array is 3
            lastFrame = rgb2gray(read(myvideo,i));
            thisFrame = rgb2gray(read(myvideo,i+1));
        end
        frameDifference = abs(lastFrame-thisFrame);
        differenceSum(1,i) = sum(sum(frameDifference));   
    end


    % find where the local maximum of frame difference exists
    frameNumber = []; % frame number of the local maximum in ascending order
    counter = 1;
    for j=1:1:(nFrame-1)
        if (j~=1)&& (j~=nFrame-1)
            if (differenceSum(j)>differenceSum(j-1))&&(differenceSum(j)>differenceSum(j+1))
                frameNumber(counter)=j;
                counter = counter + 1;
            end
        end
    end
    % select top (numberOfImages/2) local maximums or fewer
    if counter>(numberOfImages/2)
        frameNumber = zeros(1,numberOfImages); % image pairs: before change and after change
        differenceSumSorted = sort(differenceSum,'descend');
        for k = 1:(numberOfImages/2)
            [nRow,nColumn]=find(differenceSum==differenceSumSorted(k));
            frameNumber(1,2*k-1)=nColumn;
            frameNumber(1,2*k)=nColumn+1;
        end
    end

    % sort the selected frames
    frameNumberSorted = sort(frameNumber);

    % create new folder to store the images
    folderName = [videoFileName,' Selected Images'];
    mkdir(fullfile(pathName,folderName));

    % save the images to this new folder as .tif
    newFolderPathName = [pathName,'/',folderName];
    for i=1:1:length(frameNumberSorted)
        thisImage = read(myvideo,frameNumberSorted(i));
        thisImageName = sprintf('image%03d.tif', i);
        imwrite(thisImage,fullfile(newFolderPathName,thisImageName));
    end


end