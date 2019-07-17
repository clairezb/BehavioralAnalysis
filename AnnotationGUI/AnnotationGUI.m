function varargout = AnnotationGUI(varargin)
    % ANNOTATIONGUI MATLAB code for AnnotationGUI.fig
    %      ANNOTATIONGUI, by itself, creates a new ANNOTATIONGUI or raises the existing
    %      singleton*.
    %
    %      H = ANNOTATIONGUI returns the handle to a new ANNOTATIONGUI or the handle to
    %      the existing singleton*.
    %
    %      ANNOTATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in ANNOTATIONGUI.M with the given input arguments.
    %
    %      ANNOTATIONGUI('Property','Value',...) creates a new ANNOTATIONGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before AnnotationGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to AnnotationGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help AnnotationGUI

    % Last Modified by GUIDE v2.5 16-Jun-2019 20:24:12
    
    % Begin initialization code - DO NOT EDIT 
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @AnnotationGUI_OpeningFcn, ...
        'gui_OutputFcn',  @AnnotationGUI_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    
    addpath(['ThirdParty',filesep,'BresenhamAlgorithm']);
% End initialization code - DO NOT EDIT


% --- Executes just before AnnotationGUI is made visible.
function AnnotationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to AnnotationGUI (see VARARGIN)

    % Choose default command line output for AnnotationGUI
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = AnnotationGUI_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in SelectImageFolder.
function SelectImageFolder_Callback(hObject, eventdata, handles)

    global directoryName
    global imageList
    global imageListLength
    global imageIndex
    global thisImage
    global originalAxis1
    global labelCoordinate
    global labelCoordinateCentral
    global thisTag
    global labelImageFolderPath
    global labelImageFolderName
    global directoryNameSep
    global newLabelImage

    % obtain user's directory selection
    dirAnswer = uigetdir;
    if dirAnswer == 0
        return;
    else
        % select the image directory and display its name
        directoryName = dirAnswer;

        % obtain the whole list of images in the directory
        imageList = dir(fullfile(directoryName, '*.tif'));
        imageListLength = length(imageList);
        for imageIndex = 1:imageListLength
            imageList(imageIndex).name = [directoryName, filesep, imageList(imageIndex).name];
        end

        % display the first image in the directory and its name
        imageIndex = 1;
        thisImage = imread(imageList(imageIndex).name); 
        set(handles.statictext2,'String',['Current Image: ', imageList(imageIndex).name]);
        axes(handles.axes1);
        imshow(thisImage); 

        % save the original axis limits of axes1
        originalAxis1 = [xlim, ylim];

        % create a black background of the same size as the loaded image in axes2
        axes(handles.axes2);
        newLabelImage = zeros(size(thisImage,1),size(thisImage,2)); 
        imshow(newLabelImage);

        % initiate a matrix to record addlabel coordinates
        % initiate a matrix to record the centroids of label lines
        labelCoordinate = [];
        labelCoordinateCentral = [];
        thisTag = '1';

        % make a new directory to store labeled images
        directoryNameSep = strfind(directoryName, filesep);
        labelImageFolderPath = directoryName(1:directoryNameSep(end)-1);
        labelImageFolderName = [directoryName((directoryNameSep(end)+1):end), ' Label'];
        mkdir(fullfile(labelImageFolderPath, labelImageFolderName));

    end


% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)

    global imageIndex
    global thisImage
    global imageList
    global imageListLength
    global labelCoordinate
    global labelCoordinateCentral
    global newLabelImage
    global thisTag

    % if the last image was labeled, clear all roi drawings and axes2,
    % clear label coordinate and label centroid records
    if isempty(labelCoordinate) == 0
        for i=1:1:size(labelCoordinate, 1)
            delete(findobj('Tag', num2str(i)));
        end
        labelCoordinate = [];
        labelCoordinateCentral = [];
        thisTag = '1';
        set(handles.CurrentLabel, 'String', 'Label Index');
        axes(handles.axes2);
        newLabelImage(:) = 0;
        imshow(newLabelImage);
    end

    % move onto the next image with the image size reset to default
    imageIndex = imageIndex + 1;
    if imageIndex <= imageListLength
        thisImage = imread(imageList(imageIndex).name);
    elseif imageIndex > imageListLength 
        imageIndex = imageListLength;
        warndlg('This is the last image in the folder! No more next images.');
    end
    set(handles.CurrentLabel, 'String', 'Label Index');
    set(handles.statictext2, 'String', ['Current Image: ', imageList(imageIndex).name]); 
    ResetImage_Callback(handles.ResetImage, eventdata, handles);
    imshow(thisImage);


% --- Executes on button press in PreviousImage.
function PreviousImage_Callback(hObject, eventdata, handles)

    global imageIndex
    global thisImage
    global imageList
    global labelCoordinate
    global labelCoordinateCentral
    global newLabelImage
    global thisTag

    % if the last image was labeled, clear all roi drawings and axes2, 
    % clear label coordinate and label centroid records
    if isempty(labelCoordinate) == 0
        for i=1:1:size(labelCoordinate, 1)
            delete(findobj('Tag', num2str(i)));
        end
        labelCoordinate = [];
        labelCoordinateCentral = [];
        thisTag = '1';
        set(handles.CurrentLabel, 'String', 'Label Index');
        axes(handles.axes2);
        newLabelImage(:) = 0;
        imshow(newLabelImage);
    end

    % move onto the next image with the image size reset to default
    imageIndex = imageIndex - 1;
    if imageIndex < 1
        imageIndex = imageIndex + 1;
        warndlg('This is the first image in the folder! No more previous images.');
    elseif imageIndex >= 1
        thisImage = imread(imageList(imageIndex).name);
    end
    set(handles.CurrentLabel, 'String', 'Label Index');
    set(handles.statictext2, 'String', ['Current Image: ', imageList(imageIndex).name]);
    ResetImage_Callback(handles.ResetImage, eventdata, handles);
    imshow(thisImage);


% --- Executes on slider movement.
function ImageContrastSlider_Callback(hObject, eventdata, handles)
    
    global thisImage
    
    % move the slider to adjust image contrast
    sliderValue = get(hObject,'value');
    axes(handles.axes1);
    hold on
    minIntensity = double(min(thisImage(:))) / 255;
    maxIntensity = double(max(thisImage(:))) / 255;
    imshow(imadjust(thisImage, [minIntensity,maxIntensity], [], sliderValue));

% --- Executes during object creation, after setting all properties.
function ImageContrastSlider_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


% --- Executes on button press in ZoomIn.
function ZoomIn_Callback(hObject, eventdata, handles)

    % select a rectangular region and zoom in
    axes(handles.axes1);
    region = getrect;
    axis([region(1), region(1)+region(3), region(2), region(2)+region(4)]);


% --- Executes on button press in ResetImage.
function ResetImage_Callback(hObject, eventdata, handles)
    
    global originalAxis1
    
    % reset to the original axis limits in axes1
    axes(handles.axes1);
    axis(originalAxis1);


% --- Executes on button press in AddLabel.
function AddLabel_Callback(hObject, eventdata, handles)

    global labelLine
    global thisTag
    global addOrDelete
    global labelCoordinate

    axes(handles.axes1);
    hold on

    % check if the user is making a new label, draw a line if the label is new
    % AddLabel: addOrDelete = 1; DeleteLabel: addOrDelete = 0;
    % AddLabel after previously deleted a label: addOrDelete = 2
    
    if str2double(thisTag) ~= size(labelCoordinate,1)+1 
        set(handles.CurrentLabel, 'String', ['Previously Deleted and Now Adding Label ', thisTag]);
        addOrDelete = 2;
    else
        set(handles.CurrentLabel, 'String', ['Adding Label ', thisTag]);
        addOrDelete = 1;
    end
    labelLine = drawline('Color', 'r', 'linewidth', 2, 'Tag', thisTag,'Deletable',false);
        
    UpdateLabel(hObject,eventdata,handles);


    % --- Executes on button press in DeleteLabel.
function DeleteLabel_Callback(hObject, eventdata, handles)

    global thisTag
    global labelCoordinateCentral
    global addOrDelete  
    
    % AddLabel: addOrDelete = 1; DeleteLabel: addOrDelete = 0;
    % AddLabel after previously deleted a label: addOrDelete = 2
   
    axes(handles.axes1);
    [deleteX,deleteY] = ginput(1);
    set(gcf,'Pointer','arrow');
    
    % delete the label to which the cursor click is the nearest to
    % Euclidean distance used
    distance = [];
    centralCoordinate = [];
    for i = 1:1:size(labelCoordinateCentral,1)
        centralCoordinate = labelCoordinateCentral(i,:);
        distance(i) = (deleteX - centralCoordinate(1))^2 + (deleteY-centralCoordinate(2))^2;
    end
    closestLabel = find(distance == min(distance));
    thisTag = num2str(closestLabel);
    delete(findobj('Tag',thisTag));
    set(handles.CurrentLabel, 'String', ['Deleting Label ', thisTag]);
    addOrDelete = 0;
    
    UpdateLabel(hObject,eventdata,handles);
    

function UpdateLabel(hObject,eventdata,handles)

    global labelLine
    global labelCoordinate
    global labelCoordinateCentral
    global thisTag
    global newLabelImage
    global addOrDelete
        
    % display white addlabel on axes2 if making a new label
    % fill the old addlabel black on axes2 if deleting a label
    % format stored in labelCoordinate: [headX,headY,tailX,tailY]
    
    axes(handles.axes2);
    hold on;
    
    % to add a new label
    if addOrDelete == 1 || addOrDelete == 2
        
        % record the label and label centroid coordinates
        labelCoordinate(str2double(thisTag),1) = labelLine.Position(1,1);
        labelCoordinate(str2double(thisTag),2) = labelLine.Position(1,2);
        labelCoordinate(str2double(thisTag),3) = labelLine.Position(2,1);
        labelCoordinate(str2double(thisTag),4) = labelLine.Position(2,2);
        labelCoordinateCentral(str2double(thisTag),1) = 0.5 * (labelLine.Position(1,1) + labelLine.Position(2,1));
        labelCoordinateCentral(str2double(thisTag),2) = 0.5 * (labelLine.Position(1,2) + labelLine.Position(2,2));
        
        % use Bresenham Algorithm to draw new label
        [xCoordinate,yCoordinate] = bresenham(labelLine.Position(1,1), labelLine.Position(1,2), labelLine.Position(2,1), labelLine.Position(2,2));
        for i = 1:1:length(xCoordinate)
            newLabelImage(yCoordinate(i),xCoordinate(i)) = str2double(thisTag);
        end
        
        % move onto the next tag index
        thisTag = num2str(size(labelCoordinate, 1)+1);
        set(handles.CurrentLabel, 'String', ['Total Number of Labels: ', num2str(size(labelCoordinate, 1))]);
        imagesc(imdilate(newLabelImage,strel('square',2)));
    
    % to delete a label
    elseif addOrDelete == 0
        
        % use Bresenham Algorithm to fill out the label
        [xCoordinate, yCoordinate] = bresenham(labelCoordinate(str2double(thisTag), 1),labelCoordinate(str2double(thisTag), 2),labelCoordinate(str2double(thisTag), 3), labelCoordinate(str2double(thisTag), 4));
        for i = 1:1:length(xCoordinate)
            newLabelImage(yCoordinate(i), xCoordinate(i)) = 0;
        end
        
        % clear the cooresponding label and label centroid coordinates
        labelCoordinate(str2double(thisTag), :) = 0;
        labelCoordinateCentral(str2double(thisTag), :) = 0;
        
        set(handles.CurrentLabel, 'String', ['Deleted Label ', thisTag, '; Total Number of Labels: ', num2str(size(labelCoordinate, 1)-1)]);
        imagesc(imdilate(newLabelImage,strel('square', 2)));
    end

    
% --- Executes on button press in SaveLabelImage.
function SaveLabelImage_Callback(hObject, eventdata, handles)

    global labelImageFolderPath
    global labelImageFolderName
    global imageIndex
    global newLabelImage
    
    % save image in the new directory
    axes(handles.axes2);
    newLabelImageName = sprintf('imageLabel%03d.tif', imageIndex);
    imwrite(uint8(newLabelImage), fullfile([labelImageFolderPath, filesep, labelImageFolderName], newLabelImageName));
    msgbox('Image Label Saved!');


% --- Executes on button press in SaveCoordinates.
function SaveCoordinates_Callback(hObject, eventdata, handles)

    global labelCoordinate
    global labelImageFolderPath
    global directoryName
    global directoryNameSep
    global imageIndex

    % save the coordinates in a .xls sheet
    % sheet number corresponding to image index
    % each sheet records coordinates within one image
    writematrix(labelCoordinate, [labelImageFolderPath, filesep, directoryName((directoryNameSep(end)+1):end), ' Coordinates.xls'], 'Sheet', imageIndex);
    msgbox('Coordinates Saved!');


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

    switch eventdata.Key
        case 's' 
            SelectImageFolder_Callback(hObject, eventdata, handles);
        case 'rightarrow'
            NextImage_Callback(hObject, eventdata, handles);
        case 'leftarrow'
            PreviousImage_Callback(hObject, eventdata, handles);
        case 'z'
            ZoomIn_Callback(hObject, eventdata, handles);
        case 'r'
            ResetImage_Callback(hObject, eventdata, handles);
        case 'a'
            AddLabel_Callback(hObject, eventdata, handles);
        case 'd'
            DeleteLabel_Callback(hObject, eventdata, handles);
        case 'space'
            UpdateLabel_Callback(hObject, eventdata, handles);
        case 'i'
            SaveLabelImage_Callback(hObject, eventdata, handles);
        case 'c'
            SaveCoordinates_Callback(hObject, eventdata, handles);
    end

