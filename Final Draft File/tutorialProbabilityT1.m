% include short tutorial program in intoduction
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

targetSize = [227, 227];

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
% 
screens = Screen('Screens');
screenNumber = max(screens);
white = [1 1 1]; % White color
black = [0 0 0]; % Black color
grey = [0.5 0.5 0.5]; % Grey color
xpix = 300;
ypix = 300;
% Calculate the center position for the window
% Calculate the center position for the window
screenWidth = RectWidth(Screen('Rect', screenNumber));
screenHeight = RectHeight(Screen('Rect', screenNumber));

% Set the window size to half of the screen size
sizex = screenWidth / 2;
sizey = screenHeight / 2;

% Calculate the left and top coordinates to center the window
leftCoord = (screenWidth - sizex) / 2;
topCoord = (screenHeight - sizey) / 2;

% Open the window with the calculated position
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [leftCoord, topCoord, leftCoord + sizex, topCoord + sizey]);

% Get the new window size
[xpix, ypix] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

originalFolderPath = fileparts(mfilename('fullpath'));

controlFolder = fullfile(originalFolderPath, 'T1 MRI', 'Healthy (Updated) - 2 - use');
astrocytomaTestingFolder = fullfile(originalFolderPath, 'T1 MRI', 'Astrocytoma (Updated)');
meningiomaTestingFolder = fullfile(originalFolderPath, 'T1 MRI', 'Meningioma (Updated) ');
oligoastroTestingFolder = fullfile(originalFolderPath, 'T1 MRI', 'Oligoastrocytoma (Updated)');
oligodenTestingFolder = fullfile(originalFolderPath, 'T1 MRI', 'Oligodendroglioma (Updated)');

astrocytomaFilePattern = fullfile(astrocytomaTestingFolder, '*.jpg');
astrocytomaFiles = dir(astrocytomaFilePattern);

meningiomaFilePattern = fullfile(meningiomaTestingFolder, '*.jpg');
meningiomaFiles = dir(meningiomaFilePattern);

controlFilePattern = fullfile(controlFolder, '*.jpg');
controlFiles = dir(controlFilePattern);

oligoastroFilePattern = fullfile(oligoastroTestingFolder, '*.jpg');
oligoastroFiles = dir(oligoastroFilePattern);

oligodenFilePattern = fullfile(oligodenTestingFolder, '*jpg');
oligodenFiles = dir(oligodenFilePattern);

totalFiles = length(astrocytomaFiles) + length(meningiomaFiles) + length(controlFiles) + length(oligoastroFiles)+ length(oligodenFiles);
imageNames = cell(totalFiles, 1);

storedNumbers = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
sNint = 0;
imageArrayOArray = [];


astrocytomaNumbers = []; %11 1,2,3
meningiomaNumbers = []; %13 4,5,6,7,8
controlNumbers = []; %19 9,10,11,12
oligoastroNumbers = []; %58 13,14,15,16
oligodenNumbers = []; %41 17,18,19,20
% Store astrocytoma image names

disp('Calling fileProcess for astrocytomaFiles:');
disp(['astrocytomaFiles: ', num2str(length(astrocytomaFiles))]);
disp(['imageNames length: ', num2str(length(imageNames))]);
disp(['storedNumbers count: ', num2str(storedNumbers.Count)]);
disp(['sNint: ', num2str(sNint)]);
disp(['imageArrayOArray length: ', num2str(length(imageArrayOArray))]);
disp(['astrocytomaNumbers length: ', num2str(length(astrocytomaNumbers))]);

[imageNames, storedNumbers, sNint, imageArrayOArray, astrocytomaNumbers] = fileProcess(astrocytomaFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, astrocytomaNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, meningiomaNumbers] = fileProcess(meningiomaFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, meningiomaNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, controlNumbers] = fileProcess(controlFiles, imageNames, 6, storedNumbers, sNint, imageArrayOArray, controlNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, oligoastroNumbers] = fileProcess(oligoastroFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, oligoastroNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, oligodenNumbers] = fileProcess(oligodenFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, oligodenNumbers);

% Define the tutorial images
tutorialImages = {
    imageArrayOArray{1,1},  % astrocytoma
    imageArrayOArray{1,5},  % meningioma
    imageArrayOArray{1,9},  % control
    imageArrayOArray{1,19}, % oligodendroglioma
    imageArrayOArray{1,16}  % oligoastrocytoma
};

% Define the size for each image
imageWidth = 227;  % Width of the images
imageHeight = 227; % Height of the images

% Calculate positions for the first row
firstRowYPos = screenHeight / 4;  % Y position for the first row
firstRowXPos = linspace(screenWidth / 6, (screenWidth / 6) * 5, 3);  % Evenly spaced X positions for the first row

% Calculate positions for the second row
secondRowYPos = 3 * screenHeight / 4;  % Y position for the second row
secondRowXPos = linspace(screenWidth / 4, (screenWidth / 4) * 3, 2);  % Evenly spaced X positions for the second row

% Load images and create textures for the tutorial images
textures = [];
for i = 1:length(tutorialImages)
    imgPath = tutorialImages{i};  % Get the path of the image
    img = imread(imgPath);  % Load the image
    img = imresize(img, [imageWidth, imageHeight]);  % Resize image
    textures(i) = Screen('MakeTexture', window, img);  % Create texture
end

% Draw the first row images
for i = 1:3
    destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], firstRowXPos(i), firstRowYPos);
    Screen('DrawTexture', window, textures(i), [], destRect);
end

% Draw the second row images
for i = 4:5
    destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], secondRowXPos(i-3), secondRowYPos);
    Screen('DrawTexture', window, textures(i), [], destRect);
end

% Update the screen
Screen('Flip', window);

% Wait for a key press
KbWait;

% Cleanup: Close textures and window
for i = 1:length(textures)
    Screen('Close', textures(i));
end
Screen('CloseAll');

% Vertically concatenate the matrices