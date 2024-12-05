% include short tutorial program in intoduction
% include short tutorial program in introduction
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

targetSize = [227, 227]; % Maintain your target size

% Get the screen number for the primary display
screenNumber = max(Screen('Screens'));

% Pre-define color values
white = WhiteIndex(screenNumber); % Dynamic white level based on screen calibration
black = BlackIndex(screenNumber); % Dynamic black level based on screen calibration
grey = [0.5 0.5 0.5] * white; % Mid-grey color

% Open a fullscreen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% Since the window is fullscreen, these variables will cover the entire screen
xpix = windowRect(3);
ypix = windowRect(4);
sizex = xpix; % Fullscreen width
sizey = ypix; % Fullscreen height

% With the fullscreen setup, leftCoord and topCoord effectively become 0,0 at the top left corner
leftCoord = 400;
topCoord = 0;

% No need to open the window again as it's already fullscreen
% Instead, directly proceed to utilize the fullscreen window as needed

% Get the size of the window again (redundant, as it's already fullscreen, but included for completeness)
[xpix, ypix] = Screen('WindowSize', window);

% Calculate the center of the screen/window
[xCenter, yCenter] = RectCenter(windowRect);     

% Open the window with the calculated position


% Get the new window size
[xpix, ypix] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
 

originalFolderPath = fileparts(mfilename('fullpath'));

Probability_Finder = fullfile(originalFolderPath, 'T2 MRI', 'Probability Finder');
controlFolder = fullfile(originalFolderPath, 'T2 MRI', 'Healthy-Control (Updated)');
meningiomaTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Meningioma (Updated)');


programNumber = 3;
if programNumber == 1
    folderThree = fullfile(originalFolderPath, 'T2 MRI', 'Astrocytoma (Updated)');
    tumorType = 'astrocytoma';
    letter = 'a';
elseif programNumber ==2
     folderThree = fullfile(originalFolderPath, 'T2 MRI', 'Oligoastrocytoma (Updated)');
     tumorType = 'oligoastrocytoma';
     letter = 'o';
elseif programNumber ==3 
    folderThree = fullfile(originalFolderPath, 'T2 MRI', 'Oligodendroglioma (Updated)');
    tumorType = 'oligodendroglioma';
    letter = 'd';
end 
 
thirdFilePattern = fullfile(folderThree, '*.jpg');
thirdFiles = dir(thirdFilePattern);

meningiomaFilePattern = fullfile(meningiomaTestingFolder, '*.jpg');
meningiomaFiles = dir(meningiomaFilePattern);

controlFilePattern = fullfile(controlFolder, '*.jpg');
controlFiles = dir(controlFilePattern);

totalFiles = length(thirdFiles) + length(meningiomaFiles) + length(controlFiles); % + length(oligoastroFiles)+ length(oligodenFiles);
imageNames = cell(totalFiles, 1);

storedNumbers = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
sNint = 0;
imageArrayOArray = [];


thirdNumbers = []; %11 1,2,3
meningiomaNumbers = []; %13 4,5,6,7,8
controlNumbers = []; %19 9,10,11,12


[imageNames, storedNumbers, sNint, imageArrayOArray, thirdNumbers] = fileProcess(thirdFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, thirdNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, meningiomaNumbers] = fileProcess(meningiomaFiles, imageNames, 5 , storedNumbers, sNint, imageArrayOArray, meningiomaNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, controlNumbers] = fileProcess(controlFiles, imageNames, 6, storedNumbers, sNint, imageArrayOArray, controlNumbers);


% Vertically concatenate the matrices
concatenatedMatrix = [thirdNumbers; meningiomaNumbers; controlNumbers]; % oligoastroNumbers; oligodenNumbers];

% Determine the number of images
numImages = size(concatenatedMatrix, 1);

% Repeat each row (image) three times
repeatedMatrix = repmat(concatenatedMatrix, 20, 1);
% Generate a random order
randomOrder = randperm(numImages * 20);

% Use the random order to shuffle the rows of the repeated matrix
orderMatrix = repeatedMatrix(randomOrder, :);
responseMatrix = cell(length(orderMatrix), 3);

% Create textures for each image in orderMatrix
% Create textures for each image in orderMatrix

counter = 1;

% Initialize time variables; make sure this is NOT commented out when
% running experiment
%TIMEDELAY = 0.3; % Time delay in seconds
%inputDelay = .2;

%TEST TIME DELAY (comment out when not a test!!!!!)
TIMEDELAY = 0.001; 
inputDelay = 0.001;

y = 1; % Initialize y
yCycle = 0; % Initialize yCycle

% astrocytoma 203 40 --> imageArrayOArray 1,1 --> 12,1 



% control 100307 03 --> imageArrayOArray 1,9 --> 3,1
% oligodendroglioma 229 15--> 1,19 --> 3,1 
% oligoastrocytoma 280 32 --> 1,16 --> 7,1

% Path to the introductory slide
% Path to the introductory slide
introSlidePath = fullfile(originalFolderPath, 'T2 MRI', 'Probability Finder', 'TutorialIntroduction.jpg');



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

tutorialImages = {
    fullfile(Probability_Finder , 'astrocytomatutorial.png'),  % astrocytoma
    fullfile(Probability_Finder, 'meningiomTutorial.png'),  % meningioma
    fullfile(Probability_Finder, 'tutorial.jpg'),  % control
    fullfile(Probability_Finder, 'oligodendrogliomaTutorial.png'),  % oligodendroglioma
    fullfile(Probability_Finder, 'oligoAstrocytomaTutorial.png')  % oligoastrocytoma
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
    if ismember(orderMatrix(counter), thirdNumbers)
        currentLetter = letter;
    elseif ismember(orderMatrix(counter), meningiomaNumbers)
       currentLetter = 'm';
    elseif ismember(orderMatrix(counter), controlNumbers)
        currentLetter = 'c';
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
controlAccuracyMatrix = zeros(length(controlNumbers), 1);
thirdAccuracyMatrix = zeros(length(thirdNumbers), 1);

% Iterate through accuracyMatrix to calculate percentages for each group
for row = 1:length(accuracyMatrix)
    percentage = accuracyMatrix(row, 1) / accuracyMatrix(row, 2);
    
    % Check if the row corresponds to a specific group and update the
    % relevant accuracy matrix
    if ismember(row, meningiomaNumbers)
        index = (row - min(meningiomaNumbers) + 1);
        meningiomaAccuracyMatrix(index) = percentage;
    elseif ismember(row, controlNumbers)
        index = (row - min(controlNumbers) + 1);
        controlAccuracyMatrix(index) = percentage;
    elseif ismember(row, thirdNumbers)
        index = (row - min(thirdNumbers) + 1);
        thirdAccuracyMatrix(index) = percentage;
    end
end
% Display the accuracy matrices for each group
disp('Meningioma Accuracy Matrix:');
disp(meningiomaAccuracyMatrix);

disp('Control Accuracy Matrix:');
disp(controlAccuracyMatrix);

disp('Third Accuracy Matrix:');
disp(thirdAccuracyMatrix);

matrixVarName = [tumorType, 'AccuracyMatrix'];
eval([matrixVarName ' = thirdAccuracyMatrix;']);

%% Prompt the user for their name with a dialog box


prompt = {'Enter your name:'};
dlgtitle = 'User Name Input';
dims = [1 35]; % Defines the dimensions of the input dialog box
definput = {'YourName'}; % Default input or a hint for the user
userNameAnswer = inputdlg(prompt, dlgtitle, dims, definput);

% Check if the user provided a name or clicked cancel
if isempty(userNameAnswer)
    disp('User canceled the operation.');
    return; % Exit the script or handle the cancellation appropriately
else
    userName = userNameAnswer{1}; % Extract the string from the cell array
end

currentDate = datetime('today', 'Format', 'dd-MMM-yyyy');

% Define the filenamem
filename = sprintf('PFTHAM_%d_%s_%s.mat', programNumber, userName, currentDate);

% Specify the directory where you want to save the file (e.g., user's desktop)
% desktopPath = fullfile(getenv('USERPROFILE'), 'Desktop');

% Sam and Christina - 7/23/24 Temporary fix for save issue, this following
% line seems to fix the problem, along with adding heiger\desktop to path
% before running the program
desktopPath = "C:\Users\samso\OneDrive\Desktop\lab\code\Haran\Data Sam"; 

% Construct the full file path using the desktop path and the filename
fullFilePath = fullfile(desktopPath, filename);

% Save the data to the file on the desktop
save(fullFilePath, 'letter','meningiomaNumbers', 'controlNumbers', 'thirdNumbers', 'meningiomaAccuracyMatrix', 'thirdAccuracyMatrix', 'controlAccuracyMatrix');

% Inform the user where the file has been saved
fprintf('Your experiment results have been saved to: %s\n', fullFilePath);

% Now you have separate accuracy matrices for each group with percentages

function destRect = getDestinationRectangle(index, firstRowXPos, secondRowXPos, firstRowYPos, secondRowYPos, imageWidth, imageHeight)
    if index <= 3  % First row images
        destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], firstRowXPos(index), firstRowYPos);
    else  % Second row images
        destRect = CenterRectOnPointd([0 0 imageWidth imageHeight], secondRowXPos(index-3), secondRowYPos);
    end
end