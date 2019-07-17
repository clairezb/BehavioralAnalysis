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

%% get the global settings variable
global settings;
fh = fopen([settings.inputPath 'Counts.csv'], 'wb');

%% print header line
fprintf(fh, 'Filename; Counts\n');

%% iterate over all images and add the file name as well as the current counts
for i=1:settings.numImages
    fprintf(fh, '%s; %i\n', settings.rawImagePath{i}, size(settings.currentDetections{i},1));
end

%% save the current detections to restore the project
currentDetections = settings.currentDetections;
save([settings.inputPath 'detections.mat'], 'currentDetections');
disp('Successfully saved the project!');