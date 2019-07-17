%%
 % CellCountingGUI.
 % Copyright (C) 2019 J. Stegmaier
 %
 % Licensed under the Apache License, Version 2.0 (the "License");
 % you may not use this file except in compliance with the License.
 % You may obtain a copy of the Liceense at
 % 
 %     http://www.apache.org/licenses/LICENSE-2.0
 % 
 % Unless required by applicable law or agreed to in writing, software
 % distributed under the License is distributed on an "AS IS" BASIS,
 % WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 % See the License for the specific language governing permissions and
 % limitations under the License.
 %
 % Please refer to the documentation for more information about the software
 % as well as for installation instructions.
 %
 % If you use this application for your work, please cite the repository and one
 % of the following publications:
 %
 % TBA
 %
 %%

%% get the global settings
global settings;

%% ensure current slice is valid
settings.currentImage = min(max(1, settings.currentImage), settings.numImages);

%% filter the detections
settings.colormap = settings.colormapStrings{settings.colormapIndex};
figure(settings.mainFigure);
clf;
set(settings.mainFigure, 'Color', 'black');
set(gca, 'Units', 'normalized', 'Position', [0,0,1,1]);

%% visualize the current image
set(settings.mainFigure, 'Name', settings.rawImagePath{settings.currentImage});

%% plot the background images
imagesc(imadjust(settings.rawImage{settings.currentImage}, [settings.minIntensity, settings.maxIntensity], [], settings.gamma)); colormap(settings.colormap); hold on;

%% plot the current detections
if (~isempty(settings.currentDetections{settings.currentImage}))
    plot(settings.currentDetections{settings.currentImage}(:,3), settings.currentDetections{settings.currentImage}(:,4), '.r', 'MarkerSize', settings.markerSize);
    hold off;
end

%% show the group ids and counts
textColors = {'white', 'red'};
text('String', ['#Salm AB: ' num2str(size(settings.currentDetections{settings.currentImage}, 1))], 'FontSize', settings.fontSize, 'Color', [1,1,1], 'Units', 'normalized', 'Position', [0.01 0.98], 'Background', 'black');

%% if enabled, use correct aspect ratio
if (settings.axesEqual == true)
    axis equal;
end
axis off;

%% apply zoom
set(gca, 'XLim', settings.xLim);
set(gca, 'YLim', settings.yLim);
