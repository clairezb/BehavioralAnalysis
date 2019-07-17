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
 
function mouseUp(obj, evt)

    %% add the settings variable
    global settings;

    %% handle different mouse up events
    switch get(obj, 'SelectionType')
        
        %% no action for left pressed
        case 'normal'
           
        %% delete detection closest to the click position
        case 'alt'
            
            %% get the current detections and the current click position
            currentDetections = settings.currentDetections{settings.currentImage};
            currentPoint = get(gca, 'CurrentPoint');
            currentPoint = currentPoint(1,1:2);
            
            %% identify the closest existing detection to the click position
            distances = sqrt((currentDetections(:,3) - currentPoint(1)).^2 + (currentDetections(:,4) - currentPoint(2)).^2);
            [~, minIndex] = min(distances);
            
            %% update the current detections
            settings.currentDetections{settings.currentImage}(minIndex, :) = [];
            disp(['Removing detection at ' num2str(currentPoint)]);
            
        %% use double click to add a new detection
        case 'open'
            
            %% get the current click position
            currentPoint = get(gca, 'CurrentPoint');
            currentPoint = currentPoint(1,1:2);

            %% update the current detections
            settings.currentDetections{settings.currentImage} = [settings.currentDetections{settings.currentImage}; [size(settings.currentDetections{settings.currentImage},1), 1, currentPoint(1), currentPoint(2), 1]];
            disp(['Adding detection at ' num2str(currentPoint)]);
    end    
    
    %% update the visualization
    updateVisualization;
end