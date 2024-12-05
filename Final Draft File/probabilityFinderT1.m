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


% Vertically concatenate the matrices
concatenatedMatrix = [astrocytomaNumbers; meningiomaNumbers; controlNumbers; oligoastroNumbers; oligodenNumbers];

% Determine the number of images
numImages = size(concatenatedMatrix, 1);

% Repeat each row (image) three times
repeatedMatrix = repmat(concatenatedMatrix, 3, 1);

% Generate a random order
randomOrder = randperm(numImages * 3);

% Use the random order to shuffle the rows of the repeated matrix
orderMatrix = repeatedMatrix(randomOrder, :);
responseMatrix = cell(length(orderMatrix), 3);

% Create textures for each image in orderMatrix
% Create textures for each image in orderMatrix

counter = 1;
TIMEDELAY = 0.3; % Time delay in seconds
thisLastInputTime = GetSecs;
inputDelay = 0.5;
y = 1; % Initialize y
yCycle = 0; % Initialize yCycle

% astrocytoma 203 40 --> imageArrayOArray 1,1 --> 12,1
% meningioma 004 26 --> imageArrayOArray 1,5 --> 6,1
% control 100307 03 --> imageArrayOArray 1,9 --> 3,1
% oligodendroglioma 229 15--> 1,19 --> 3,1 
% oligoastrocytoma 280 32 --> 1,16 --> 7,1

% Path to the introductory slide
% Path to the introductory slide
introSlidePath = fullfile(originalFolderPath, 'T1 MRI', 'Probability Finder', 'TutorialIntroduction.jpg');

% Check if the file exists
if exist(introSlidePath, 'file') == 2
    % File exists, so read the image
    introImage = imread(introSlidePath);
else
    % File does not exist, throw an error
    error('File does not exist: %s', introSlidePath);
end

% Load the introductory image
introImage = imread(introSlidePath);

% Create a texture from the image
introTexture = Screen('MakeTexture', window, introImage);

% Get the size of the window
[windowWidth, windowHeight] = Screen('WindowSize', window);

% Make the destination rectangle the size of the window to fit the image to the screen
destRect = [0 0 windowWidth windowHeight];

% Draw the texture to the screen, scaling it to fit
Screen('DrawTexture', window, introTexture, [], destRect);

% Update the screen to show the introductory slide
Screen('Flip', window);

exitSlide = false;
spaceKey = KbName('space'); % Get the keycode for the space bar once to optimize
thisLastInputTime = GetSecs; % Record the time when the last space was pressed

while ~exitSlide
    [keyIsDown, secs, keyCode] = KbCheck;
    % Check if space was pressed and if enough time has passed since the last press
    if keyIsDown && keyCode(spaceKey) && (secs - thisLastInputTime) > inputDelay
        exitSlide = true;
        thisLastInputTime = secs; % Update the time of the last space press
    end
end

% Clear the introductory texture from memory
Screen('Close', introTexture);

% Define the tutorial images - assuming 'tutorial.jpg' is the name of the tutorial image in each folder
tutorialImages = {
    fullfile(astrocytomaTestingFolder, 'tutorial.jpg'),  % astrocytoma
    fullfile(meningiomaTestingFolder, 'tutorial.jpg'),  % meningioma
    fullfile(controlFolder, 'tutorial.jpg'),  % control
    fullfile(oligodenTestingFolder, 'tutorial.jpg'),  % oligodendroglioma
    fullfile(oligoastroTestingFolder, 'tutorial.jpg')  % oligoastrocytoma
};

% Define the size for each image
imageWidth = 175;  % Width of the images
imageHeight = 175; % Height of the images

% Calculate positions for the first row
firstRowYPos = sizey / 4 + imageHeight / 4;  % Y position for the first row
firstRowXPos = linspace(sizex / 6, (sizex / 6) * 5, 3);  % Evenly spaced X positions for the first row

% Calculate positions for the second row
secondRowYPos = 3 * sizey / 4;  % Y position for the second row
secondRowXPos = linspace(sizex / 4, (sizex / 4) * 3, 2);  % Evenly spaced X positions for the second row

% Load images and create textures for the tutorial images
textures = [];
for i = 1:length(tutorialImages)
    imgPath = tutorialImages{i};  % Get the path of the tutorial image
    img = imread(imgPath);  % Load the image
    img = imresize(img, [imageWidth, imageHeight]);  % Resize image
    textures(i) = Screen('MakeTexture', window, img);  % Create texture
end

% Define labels for each group
groupLabels = {'Astrocytoma', 'Meningioma', 'Control', 'Oligodendroglioma', 'Oligoastrocytoma'};

% Define the text properties
textSize = 12;  % Adjust the font size as needed
textColor = black;  % Text color
Screen('TextSize', window, textSize);

% Draw the images and their labels
for i = 1:3
    destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], firstRowXPos(i), firstRowYPos);
    Screen('DrawTexture', window, textures(i), [], destRect);
    DrawFormattedText(window, groupLabels{i}, (destRect(1)+destRect(3))/2, destRect(4) + 12, textColor);
end

for i = 1:2
    destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], secondRowXPos(i), secondRowYPos);
    Screen('DrawTexture', window, textures(i+3), [], destRect);
    DrawFormattedText(window, groupLabels{i+3}, (destRect(1)+destRect(3))/2, destRect(4) + 12, textColor);
end

% Update the screen to show the images and labels
Screen('Flip', window);

% Wait for a key press to exit the tutorial
exitTutorial = false;
thisLastInputTime = GetSecs; % Reset the time for the tutorial section

while ~exitTutorial
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && keyCode(spaceKey) && (secs - thisLastInputTime) > inputDelay
        exitTutorial = true;
        thisLastInputTime = secs; % Update the time of the last space press
    end
end

lastValidInputTime = GetSecs;


while counter <= length(orderMatrix)
    disp("counter: " + counter);
    imageLength = length(imageArrayOArray{orderMatrix(counter)}); % length of image array of the current image
    if ismember(orderMatrix(counter), astrocytomaNumbers)
        currentLetter = 'a';
    elseif ismember(orderMatrix(counter), meningiomaNumbers)
       currentLetter = 'm';
    elseif ismember(orderMatrix(counter), oligodenNumbers)
        currentLetter = 'd';
    elseif ismember(orderMatrix(counter), controlNumbers)
        currentLetter = 'c';
    else ismember(orderMatrix(counter), oligoastroNumbers)
        currentLetter = 'o';
    end
   
    % Insert currentLetter into the responseMatrix
    responseMatrix{counter, 2} = currentLetter;
    responseMatrix{counter,3} = orderMatrix(counter);
    validInput = false; 
    lastInputTime = 0;

    while validInput == false
        % Define the text instructions
        instructions = {
            'Press the corresponding key for'
            'the pathology:'
            'm = Meningioma'
            'a = Astrocytoma'
            'o = Oligoastrocytoma'
            'd = Oligodendroglioma'
            'c = Control'
        };
        
        % Text properties
        textSize2 = 24;  % Adjust the font size as needed
        textColor = black;  % Text color
        
        % Calculate the position for the text instructions (right half of the screen)
        textX = xCenter - sizex/2;
        textY = yCenter-yCenter/2;
        
        % Loop through each line of the instructions and draw them on the screen
        for i = 1:length(instructions)
            DrawFormattedText(window, instructions{i}, textX, textY + (i-1) * textSize2, textColor);
        end
        
        centerImage = imageArrayOArray{orderMatrix(counter)}{y};
        [mouseX, mouseY] = GetMouse(window);
        currentTime = GetSecs;
        elapsedTime = currentTime - lastInputTime;
        
        originaly = sizey/1.5;
        originalx = sizey/1.5;
       % Create the imageRect with the modified left coordinate and center vertically
        imageRect = CenterRectOnPointd([0 0 originalx originaly], leftCoord + originalx/2, yCenter);
        
        if elapsedTime >= TIMEDELAY && mouseX >= imageRect(1) && mouseX <= imageRect(3) && mouseY >= imageRect(2) && mouseY <= imageRect(4)
            disp('y:' + y);
            if mod(yCycle, 2) == 0 && y < imageLength
                y = y + 1;
                lastInputTime = currentTime;
            elseif mod(yCycle, 2) == 1 && y > 1
                y = y - 1;
                lastInputTime = currentTime;
            else
                yCycle = yCycle + 1;
            end
        end 
        
        imageArray = imread(centerImage);
        imageArray = imresize(imageArray, targetSize);
        imageTexture = Screen('MakeTexture', window, imageArray);
        Screen('TextSize', window, textSize2);
        Screen('DrawTexture', window, imageTexture, [], imageRect);
        % Draw otherImageTexture if needed
        Screen('Flip', window);
        
        [~, ~, keyCode] = KbCheck;
        userInput = KbName(find(keyCode, 1, 'first'));
        % Check if enough time has passed since the last number input
        thisTime = GetSecs;
        totalTime = thisTime - thisLastInputTime;
            
        pressedKeys = KbName(find(keyCode));
          % Check for key press
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            % Get the first pressed key
            pressedKeys = KbName(keyCode);
            if ~isempty(pressedKeys)
                userInput = pressedKeys(1);
                
                % Check if the pressed key is one of the valid responses and if the time delay has passed
                if ismember(userInput, ['c', 'm', 'o', 'd', 'a']) && (secs - lastValidInputTime) > inputDelay 
                    % Update the response matrix with the user input
                    responseMatrix{counter, 1} = userInput;
                    
                    % Set the flag to true as valid input has been detected
                    validInput = true;
                    
                    % Update the time of the last valid input
                    lastValidInputTime = secs;
                    
                    % Increment the counter to move to the next image
                    counter = counter + 1;
                    
                    % Reset y for the next image
                    y = 1;
                end
            end
        end
    end 
end

Screen('CloseAll');
sca;


accuracyMatrix = zeros(length(imageArrayOArray),2);
% Iterate through responseMatrix
for row = 1:length(responseMatrix)
    % Extract the user's response (1st column) and the actual pathology (2nd column)
    userResponse = responseMatrix{row, 1};
    actualPathology = responseMatrix{row, 2};
    imageNumber = responseMatrix{row, 3};
    
    % Check if the user's response matches the actual pathology
    if userResponse == actualPathology
        % Update both numerator and denominator
        accuracyMatrix(imageNumber, 1) = accuracyMatrix(imageNumber, 1) + 1;
    end

    % Always increment the denominator
    accuracyMatrix(imageNumber, 2) = accuracyMatrix(imageNumber, 2) + 1;
end

% Initialize separate accuracy matrices and percentages for each group
meningiomaAccuracyMatrix = zeros(length(meningiomaNumbers), 1);
oligodendrogliomaAccuracyMatrix = zeros(length(oligodenNumbers), 1);
oligoastroAccuracyMatrix = zeros(length(oligoastroNumbers), 1);
controlAccuracyMatrix = zeros(length(controlNumbers), 1);
astrocytomaAccuracyMatrix = zeros(length(astrocytomaNumbers), 1);

% Iterate through accuracyMatrix to calculate percentages for each group
for row = 1:length(accuracyMatrix)
    percentage = accuracyMatrix(row, 1) / accuracyMatrix(row, 2);
    
    % Check if the row corresponds to a specific group and update the
    % relevant accuracy matrix
    if ismember(row, meningiomaNumbers)
        index = (row - min(meningiomaNumbers) + 1);
        meningiomaAccuracyMatrix(index) = percentage;
    elseif ismember(row, oligodenNumbers)
        index = (row - min(oligodenNumbers) + 1);
        oligodendrogliomaAccuracyMatrix(index) = percentage;
    elseif ismember(row, oligoastroNumbers)
        index = (row - min(oligoastroNumbers) + 1);
        oligoastroAccuracyMatrix(index) = percentage;
    elseif ismember(row, controlNumbers)
        index = (row - min(controlNumbers) + 1);
        controlAccuracyMatrix(index) = percentage;
    elseif ismember(row, astrocytomaNumbers)
        index = (row - min(astrocytomaNumbers) + 1);
        astrocytomaAccuracyMatrix(index) = percentage;
    end
end
% Display the accuracy matrices for each group
disp('Meningioma Accuracy Matrix:');
disp(meningiomaAccuracyMatrix);

disp('Oligodendroglioma Accuracy Matrix:');
disp(oligodendrogliomaAccuracyMatrix);

disp('Oligoastrocytoma Accuracy Matrix:');
disp(oligoastroAccuracyMatrix);

disp('Control Accuracy Matrix:');
disp(controlAccuracyMatrix);

disp('Astrocytoma Accuracy Matrix:');
disp(astrocytomaAccuracyMatrix);

% Prompt the user to select a file location
[filename, filepath] = uiputfile('*.mat', 'Save Data');

% Check if the user canceled the operation
if isequal(filename, 0) || isequal(filepath, 0)
    disp('File saving canceled.');
    return;
end



% Construct the full file path
fullFilePath = fullfile(filepath, filename);

% Save the data to the selected file
save(fullFilePath, 'meningiomaAccuracyMatrix', 'oligodendrogliomaAccuracyMatrix', 'oligoastroAccuracyMatrix', 'astrocytomaAccuracyMatrix', 'controlAccuracyMatrix');


% Now you have separate accuracy matrices for each group with percentages

function destRect = getDestinationRectangle(index, firstRowXPos, secondRowXPos, firstRowYPos, secondRowYPos, imageWidth, imageHeight)
    if index <= 3  % First row images
        destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], firstRowXPos(index), firstRowYPos);
    else  % Second row images
        destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], secondRowXPos(index-3), secondRowYPos);
    end
end
