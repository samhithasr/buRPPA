                                
% Here we call some default settings for setting up Psychtoolbox
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
sizex = 800;
sizey = 500;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [xpix ypix xpix + sizex ypix + sizey]);
[xpix, ypix] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
CONTROLNUM = 10;

originalFolderPath = fileparts(mfilename('fullpath'));
  
CONTROLNUM = 10;
TIMELIM = 30;
thisLastInputTimeT = 0;

originalTutorialFolderPath = fileparts(mfilename('fullpath'));
controlTutorialFolder = '/Applications/MATLAB/Final Draft File/T2 MRI/Healthy-Control (Updated)';
gliomaTutorialTestingFolder = fullfile(originalTutorialFolderPath, 'InstructionFolder', 'Training', 'Glioma');
meningiomaTutorialTestingFolder = fullfile(originalTutorialFolderPath, 'InstructionFolder', 'Training', 'Meningioma');
imageFolder = fullfile(originalTutorialFolderPath, 'InstructionFolder','Tutorial Images'); 

imageNames = {'Slide1.jpg', 'Slide2.jpg', 'Slide3.jpg'};
imagePaths = cellfun(@(name) fullfile(imageFolder, name), imageNames, 'UniformOutput', false);

% Read the images
numImages = numel(imagePaths);
images = cell(1, numImages);
for i = 1:numImages
    images{i} = imread(imagePaths{i});
end

gliomaTutorialFilePattern = fullfile(gliomaTutorialTestingFolder, '*.jpg');
gliomaTutorialFiles = dir(gliomaTutorialFilePattern);

meningiomaTutorialFilePattern = fullfile(meningiomaTutorialTestingFolder, '*.jpg');
meningiomaTutorialFiles = dir(meningiomaTutorialFilePattern);

controlTutorialFilePattern = fullfile(controlTutorialFolder, '*.jpg');
controlTutorialFiles = dir(controlTutorialFilePattern);

totalTutorialFiles = length(gliomaTutorialFiles) + length(meningiomaTutorialFiles) + length(controlTutorialFiles);
imageTutorialNames = cell(totalTutorialFiles, 1);

storedNumbersT = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
sNintT = 0;
imageArrayOArrayTutorial = {};

gliomaNumbersT = [];
meningiomaNumbersT = [];
controlNumbersT = [];
% Store glioma image names
for k = 1:length(gliomaTutorialFiles)
    gliomaBaseFileNameT = gliomaTutorialFiles(k).name;
    gliomaFullFileNameT = fullfile(gliomaTutorialFiles(k).folder, gliomaBaseFileNameT);
    imageTutorialNames{k} = gliomaFullFileNameT;
    patternT = '\d{6}';
    matchT = regexp(gliomaBaseFileNameT, patternT, 'match', 'once');
    
    
    if ~isempty(matchT)
        firstSixDigitNumberT = str2double(matchT);
        if ~isKey(storedNumbersT, firstSixDigitNumberT)
            sNintT = sNintT + 1;
            storedNumbersT(firstSixDigitNumberT) = sNintT;
            imageArrayOArrayTutorial{sNintT} = {gliomaFullFileNameT};
            gliomaNumbersT = [gliomaNumbersT; sNintT];
        else
            imageArrayOArrayTutorial{storedNumbersT(firstSixDigitNumberT)} = [imageArrayOArrayTutorial{storedNumbersT(firstSixDigitNumberT)}; gliomaFullFileNameT];
        end
    else
        disp('No 6-digit number found in the file name.');
    end
end

% Store meningioma image names
for k = 1:length(meningiomaTutorialFiles)
    meningiomaBaseFileNameT = meningiomaTutorialFiles(k).name;
    meningiomaFullFileNameT = fullfile(meningiomaTutorialFiles(k).folder, meningiomaBaseFileNameT);
    imageTutorialNames{k + length(gliomaTutorialFiles)} = meningiomaFullFileNameT;
    patternT = '\d{5}';
    matchT = regexp(meningiomaBaseFileNameT, patternT, 'match', 'once');
    
    if ~isempty(matchT)
        firstSixDigitNumberT = str2double(matchT);
        
        if ~isKey(storedNumbersT, firstSixDigitNumberT)
            sNintT = sNintT + 1;
            storedNumbersT(firstSixDigitNumberT) = sNintT;
            imageArrayOArrayTutorial{sNintT} = {meningiomaFullFileNameT};
            meningiomaNumbersT = [meningiomaNumbersT;sNintT];
        else
            imageArrayOArrayTutorial{storedNumbersT(firstSixDigitNumberT)} = [imageArrayOArrayTutorial{storedNumbersT(firstSixDigitNumberT)}; meningiomaFullFileNameT];
        end
    else
        disp('No 6-digit number found in the file name.');
    end
end

% Store control image names
for k = 1:length(controlTutorialFiles)
    controlBaseFileNameT = controlTutorialFiles(k).name;
    controlFullFileNameT = fullfile(controlTutorialFiles(k).folder, controlBaseFileNameT);
    imageTutorialNames{k + length(gliomaTutorialFiles) + length(meningiomaTutorialFiles)} = controlFullFileNameT;

    if mod(k, CONTROLNUM) == 1
        sNintT = sNintT + 1;
        imageArrayOArrayTutorial{sNintT} = {controlFullFileNameT};
        controlNumbersT = [controlNumbersT; sNintT];
    else
        imageArrayOArrayTutorial{sNintT} = [imageArrayOArrayTutorial{sNintT}; controlFullFileNameT];
    end
end

% Remove empty array from imageArrayOArray if it exists
if isempty(imageArrayOArrayTutorial{end}) %this is the line with the error indicating that the imageArray is empty at the end 
    imageArrayOArrayTutorial = imageArrayOArrayTutorial(1:end-1);
end

%Determines Combinations That Will Occur In Pairing
numComparisonsT = (length(imageArrayOArrayTutorial) * (length(imageArrayOArrayTutorial) - 1)) / 2;
arrayCombT = struct('subjectOne', 'int32', 'subjectTwo', 'int32');
counterFirstT = 1;

for k = 1:length(imageArrayOArrayTutorial)
    for j = k + 1:length(imageArrayOArrayTutorial)
        arrayCombT(counterFirstT).subjectOne = k;
        arrayCombT(counterFirstT).subjectTwo = j;
        counterFirstT = counterFirstT + 1;
    end
end

% Main loop
counterT = 1;
leftSideT = 0;
rightSideT = 0;

% Preallocate the selectedNumbers struct
selectedNumbersT = [];
dataMatrixT = zeros(length(imageArrayOArrayTutorial));
% Initialize time variables
TIMEDELAYT = 0.3; % Time delay in seconds
inputDelayT = .5 ;

% Load the first image into a texture
texture = Screen('MakeTexture', window, images{1});

% Get the dimensions of the loaded image
imgWidth = size(images{1}, 2);
imgHeight = size(images{1}, 1);

% Get the dimensions of the screen
screenWidth = RectWidth(windowRect);
screenHeight = RectHeight(windowRect);

% Calculate the scaling factor to fit the image to the screen
scaleFactor = min(screenWidth / imgWidth, screenHeight / imgHeight);

% Calculate the dimensions of the resized image
resizedWidth = round(imgWidth * scaleFactor);
resizedHeight = round(imgHeight * scaleFactor);

% Resize the image to fit the screen
resizedImage = imresize(images{1}, [resizedHeight, resizedWidth]);

% Create a texture with the resized image
resizedTexture = Screen('MakeTexture', window, resizedImage);

% Display the resized image and loop until spacebar is pressed
spacePressed = false;
lastKeyPressTime = 0;
while ~spacePressed
    % Display the image
    Screen('DrawTexture', window, resizedTexture);
    Screen('Flip', window);

    % Check for spacebar press
    [keyIsDown, ~, keyCode] = KbCheck;
    currentTime = GetSecs;
    if keyIsDown && keyCode(KbName('space')) && (currentTime - lastKeyPressTime >= inputDelayT)
        spacePressed = true;
        lastKeyPressTime = currentTime;
    end
end

% Load the second image into a texture
texture = Screen('MakeTexture', window, images{2});

% Resize the second image to fit the screen using the same dimensions
resizedImage = imresize(images{2}, [resizedHeight, resizedWidth]);

% Create a texture with the resized second image
resizedTexture = Screen('MakeTexture', window, resizedImage);

% Display the resized second image and loop until spacebar is pressed
spacePressed = false;     
while ~spacePressed
    % Display the image
    Screen('DrawTexture', window, resizedTexture);
    Screen('Flip', window);

    % Check for spacebar press
    [keyIsDown, ~, keyCode] = KbCheck;
    currentTime = GetSecs;
    if keyIsDown && keyCode(KbName('space')) && (currentTime - lastKeyPressTime >= inputDelayT)
        spacePressed = true;
        lastKeyPressTime = currentTime;
    end
end



while counterT <= 4
    xT = 1;
    yT = 1;
    randomIntegerT = randi([1, length(arrayCombT)]);
    randomSideT = randi([0, 1]);
    
    if randomSideT == 0
        leftSideT = arrayCombT(randomIntegerT).subjectOne;
        rightSideT = arrayCombT(randomIntegerT).subjectTwo;
    else
        leftSideT = arrayCombT(randomIntegerT).subjectTwo;
        rightSideT = arrayCombT(randomIntegerT).subjectOne;
    end

    responseText = '';
    if counterT == 1
        leftSideT = 1;
        rightSideT = 2;
        responseText = 'GUIDE: I am CONFIDENT that the two groups of images are depicting \n the same type of brain tumor, please rate these set of images with a 1';
    elseif counterT == 2
        leftSideT = 3;
        rightSideT  = 4;
        responseText = 'GUIDE: I am VERY DOUBTFUL that the two groups of images are depicting \n the same types of brain tumors, please rate these set of images with a 4';
    elseif counterT == 3
        leftSideT = 5; 
        rightSideT = 6;
        responseText = 'GUIDE: I am SLIGHTLY CONFIDENT that the two groups of images are the depicting \n the same type of brain tumors, please rate these set of images with a 2';
    elseif counterT == 4
        leftSideT = 4;
        rightSideT = 1;
        responseText = 'GUIDE: I am SLIGHTLY DOUBTFUL that the two groups of images are the depicting \n the same types of brain tumors, please rate these set of images with a 3';
    end

    if ~ismember(randomIntegerT, selectedNumbersT)
        maxLengthT = max(length(imageArrayOArrayTutorial{leftSideT}), length(imageArrayOArrayTutorial{rightSideT}));
        minLengthT = min(length(imageArrayOArrayTutorial{leftSideT}), length(imageArrayOArrayTutorial{rightSideT}));
        if length(imageArrayOArrayTutorial{leftSideT})>length(imageArrayOArrayTutorial{rightSideT})
            minSideT = rightSideT;
            maxSideT = leftSideT;
        else
            minSideT = leftSideT;
            maxSideT = rightSideT;
        end
       
        prevRightKeyStateT = 0;
        xCycleT = 0;
        yCycleT = 0;
        validInputT = false;
        startingTimeT = GetSecs;
        currentTimeT = 0;
        elapsedTimeT = 0;
        lastInputTime = 0;
        while validInputT == false 
           [mouseXT, mouseYT] = GetMouse(window);
            disp('mouseX');
            disp(mouseXT);
            disp('mouseY');
            disp(mouseYT);
            currentTimeT = GetSecs;
            elapsedTimeT = currentTimeT - lastInputTime;
            originalxT = sizey/1.5;
            imageRectT = CenterRectOnPointd([0 0 originalxT originalxT], xCenter - (sizex / 4), yCenter);
            otherOriginalxT = sizey/1.5;
            otherImageRectT = CenterRectOnPointd([0 0 otherOriginalxT otherOriginalxT], xCenter + (sizex / 4), yCenter);

            if leftSideT == minSideT 
               leftImageT = imageArrayOArrayTutorial{leftSideT}{yT};
               rightImageT = imageArrayOArrayTutorial{rightSideT}{xT};
               xRectT = otherImageRectT;
               yRectT = imageRectT;
            else
               leftImageT = imageArrayOArrayTutorial{leftSideT}{xT};
               rightImageT = imageArrayOArrayTutorial{rightSideT}{yT};
               xRectT = imageRectT;
               yRectT = otherImageRectT;
            end
            
            if elapsedTimeT >= TIMEDELAYT && mouseXT >= xRectT(1) && mouseXT <= xRectT(3) && mouseYT >= xRectT(2) && mouseYT <= xRectT(4)
                if mod(xCycleT, 2) == 0 && xT < maxLengthT
                    xT = xT + 1;
                    lastInputTime = currentTimeT;
                elseif mod(xCycleT, 2) == 1 && xT > 1
                    xT = xT - 1;
                    lastInputTime = currentTimeT;
                else
                    xCycleT = xCycleT + 1;
                end
            end
           
            if elapsedTimeT >= TIMEDELAYT && mouseXT >= yRectT(1) && mouseXT <= yRectT(3) && mouseYT >= yRectT(2) && mouseYT <= yRectT(4)
                if mod(yCycleT, 2) == 0 && yT < minLengthT
                    yT = yT + 1;
                    lastInputTime = currentTimeT;
                elseif mod(yCycleT, 2) == 1 && yT > 1
                    yT = yT - 1;
                    lastInputTime = currentTimeT;
                else
                    yCycleT = yCycleT + 1;
                end
            end 
         

            imageFullFileNameT = leftImageT;
            imageArrayT = imread(imageFullFileNameT);
            imageArrayT = imresize(imageArrayT, targetSize);
            imageTextureT = Screen('MakeTexture', window, imageArrayT);

         
            
           % originalx = changeDimension(originalx,controlFolder,imageFullFileName, -62);
            imageRectT = CenterRectOnPointd([0 0 originalxT originalxT], xCenter - (sizex / 4), yCenter);
                    
            
            otherImageFullFileNameT = rightImageT;
            otherImageArrayT = imread(otherImageFullFileNameT);
            otherImageArrayT = imresize(otherImageArrayT, targetSize);
            otherImageTextureT = Screen('MakeTexture', window, otherImageArrayT);
            
            otherOriginalxT = sizey/1.5;
          % otherOriginalx = changeDimension(otherOriginalx,controlFolder,otherImageFullFileName, -62);
            otherImageRectT = CenterRectOnPointd([0 0 otherOriginalxT otherOriginalxT], xCenter + (sizex / 4), yCenter);
            
            
            
            
            Screen('DrawTexture', window, imageTextureT, [], imageRectT);
            Screen('DrawTexture', window, otherImageTextureT, [], otherImageRectT);
            
            promptText = 'Rate confidence in tumor similarity between the two images on a scale from 1 to 4:';
            textFont = 'Arial';
            textSize = round(sizex * 0.02);
            textColor = black;

            Screen('TextSize', window, textSize);
            DrawFormattedText(window, promptText, 'center', sizey * 0.81, textColor, [], [], [], [], [], windowRect);
            DrawFormattedText(window, responseText, 'center', sizey * 0.91, textColor, [], [], [], [], [], windowRect);

            
            
            Screen('Flip', window);
            [~, ~, keyCode] = KbCheck;
           
            userInputT = KbName(find(keyCode, 1, 'first'));
            userInputT = str2double(regexp(char(userInputT), '\d', 'match'));
            
            % Check if enough time has passed since the last number input
            thisTimeT = GetSecs;
            totalTimeT = thisTimeT - thisLastInputTimeT;
            
            if ~isempty(userInputT) && ismember(userInputT, [1, 2, 3, 4]) && totalTimeT >= inputDelayT
                selectedNumbersT = [selectedNumbersT; randomIntegerT];
                thisLastInputTimeT = GetSecs;
                dataMatrixT(leftSideT, rightSideT) = userInputT;
                dataMatrixT(rightSideT, leftSideT) = userInputT;
                counterT = counterT + 1;
                validInputT = true;
            end
            end
        end
end

% Load the third image into a texture
texture = Screen('MakeTexture', window, images{3});

% Resize the third image to fit the screen using the same dimensions
resizedImage = imresize(images{3}, [resizedHeight, resizedWidth]);

% Create a texture with the resized third image
resizedTexture = Screen('MakeTexture', window, resizedImage);

% Display the resized third image and loop until spacebar is pressed
spacePressed = false;
lastKeyPressTime = 0;
while ~spacePressed
    % Display the image
    Screen('DrawTexture', window, resizedTexture);
    Screen('Flip', window);

    % Check for spacebar press
    [keyIsDown, ~, keyCode] = KbCheck;
    currentTime = GetSecs;
    if keyIsDown && keyCode(KbName('space')) && (currentTime - lastKeyPressTime >= inputDelayT)
        spacePressed = true;
        lastKeyPressTime = currentTime;
    end
end    


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


astrocytomaNumbers = []; %11
meningiomaNumbers = []; %13
controlNumbers = []; %19
oligoastroNumbers = []; %58
oligodenNumbers = []; %41 
% Store astrocytoma image names

[imageNames, storedNumbers, sNint, imageArrayOArray, astrocytomaNumbers] = fileProcess(astrocytomaFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, astrocytomaNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, meningiomaNumbers] = fileProcess(meningiomaFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, meningiomaNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, controlNumbers] = fileProcess(controlFiles, imageNames, 6, storedNumbers, sNint, imageArrayOArray, controlNumbers);

% for k = 1:length(controlFiles)
%     controlBaseFileName = controlFiles(k).name;
%     controlFullFileName = fullfile(controlFiles(k).folder, controlBaseFileName);
%     imageNames{k + length(astrocytomaFiles) + length(meningiomaFiles)} = controlFullFileName;
% 
%     if mod(k, CONTROLNUM) == 1
%         sNint = sNint + 1;
%         imageArrayOArray{sNint} = {controlFullFileName};
%         controlNumbers = [controlNumbers; sNint];
%     else
%         imageArrayOArray{sNint} = [imageArrayOArray{sNint}; controlFullFileName];
%     end
% end

[imageNames, storedNumbers, sNint, imageArrayOArray, oligoastroNumbers] = fileProcess(oligoastroFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, oligoastroNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, oligodenNumbers] = fileProcess(oligodenFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, oligodenNumbers);

% Remove empty array from imageArrayOArray if it exists
if isempty(imageArrayOArray{end})
    imageArrayOArray = imageArrayOArray(1:end-1);
end
callNumbers = zeros(length(imageArrayOArray), 1);

%Determines Combinations That Will Occur In Pairing
numComparisons = (length(imageArrayOArray) * (length(imageArrayOArray) - 1)) / 2;
arrayComb = struct('subjectOne', 'int32', 'subjectTwo', 'int32');
counterFirst = 1;

for k = 1:length(imageArrayOArray)
    for j = k + 1:length(imageArrayOArray)
        arrayComb(counterFirst).subjectOne = k;
        arrayComb(counterFirst).subjectTwo = j;
        counterFirst = counterFirst + 1;
    end
end

% Main loop
counter = 1;
leftSide = 0;
rightSide = 0;

% Preallocate the selectedNumbers struct
selectedNumbers = [];
n = length(imageArrayOArray);
dataMatrix = NaN(n);
dataMatrix(1:n+1:end) = 0;

% Initialize time variables
TIMEDELAY = .3; % Time delay in seconds
thisLastInputTime = GetSecs;
inputDelay = .2;
% while counter <= numComparisons
while counter <= length(arrayComb)
    randomInteger = randi([1, length(arrayComb)]);
    randomSide = randi([0, 1]);
    
    if randomSide == 0
        leftSide = arrayComb(randomInteger).subjectOne;
        rightSide = arrayComb(randomInteger).subjectTwo;
    else
        leftSide = arrayComb(randomInteger).subjectTwo;
        rightSide = arrayComb(randomInteger).subjectOne;
    end
    % leftSide = 19;
    % rightSide = 21;
     x = 1; %tracking longer length
     y = 1; % tracking shorter length

     
    if ~ismember(randomInteger, selectedNumbers)
        maxLength = max(length(imageArrayOArray{leftSide}), length(imageArrayOArray{rightSide}));
        minLength = min(length(imageArrayOArray{leftSide}), length(imageArrayOArray{rightSide}));
        if length(imageArrayOArray{leftSide})>length(imageArrayOArray{rightSide})
            minSide = rightSide;
            maxSide = leftSide;
        else
            minSide = leftSide;
            maxSide = rightSide;
        end
  
        callNumbers(leftSide) = callNumbers(leftSide) + 1;
        callNumbers(rightSide) = callNumbers(rightSide) + 1;
        
        
        prevRightKeyState = 0;
        xCycle = 0;
        yCycle = 0;
        validInput = false;
        startingTime = GetSecs;
        currentTime = 0;
        elapsedTime = 0;
        lastInputTime = 0;
        while validInput == false 
            [mouseX, mouseY] = GetMouse(window);
            currentTime = GetSecs;
            elapsedTime = currentTime - lastInputTime;
            originalx = sizey/1.5;
            imageRect = CenterRectOnPointd([0 0 originalx originalx], xCenter - (sizex / 4), yCenter);
            otherOriginalx = sizey/1.5;
            otherImageRect = CenterRectOnPointd([0 0 otherOriginalx otherOriginalx], xCenter + (sizex / 4), yCenter);

            if leftSide == minSide 
               leftImage = imageArrayOArray{leftSide}{y};
               rightImage = imageArrayOArray{rightSide}{x};
               xRect = otherImageRect;
               yRect = imageRect;
            else
               leftImage = imageArrayOArray{leftSide}{x};
               rightImage = imageArrayOArray{rightSide}{y};
               xRect = imageRect;
               yRect = otherImageRect;
            end
            
            %Testing MDS plotting given different thresholds:
            % Extract the folder name
            folderPath = fileparts(leftImage);
            folderParts = strsplit(folderPath, filesep);
            folderName = folderParts{end};
            
            % Display the folder name
            disp('left');
            leftText = folderName;
            disp(leftText);

             % Extract the folder name
            folderPathTwo = fileparts(rightImage);
            folderPartsTwo = strsplit(folderPathTwo, filesep);
            folderNameTwo = folderPartsTwo{end};
            
            % Display the folder name
            disp('right');
            rightText = folderNameTwo;
            disp(rightText);
            if elapsedTime >= TIMEDELAY && mouseX >= xRect(1) && mouseX <= xRect(3) && mouseY >= xRect(2) && mouseY <= xRect(4)
                if mod(xCycle, 2) == 0 && x < maxLength
                    x = x + 1;
                    lastInputTime = currentTime;
                elseif mod(xCycle, 2) == 1 && x > 1
                    x = x - 1;
                    lastInputTime = currentTime;
                else
                    xCycle = xCycle + 1;
                end
            end
       
            if elapsedTime >= TIMEDELAY && mouseX >= yRect(1) && mouseX <= yRect(3) && mouseY >= yRect(2) && mouseY <= yRect(4)
                if mod(yCycle, 2) == 0 && y < minLength
                    y = y + 1;
                    lastInputTime = currentTime;
                elseif mod(yCycle, 2) == 1 && y > 1
                    y = y - 1;
                    lastInputTime = currentTime;
                else
                    yCycle = yCycle + 1;
                end
            end 
         
            imageFullFileName = leftImage;
            imageArray = imread(imageFullFileName);
            imageArray = imresize(imageArray, targetSize);
            imageTexture = Screen('MakeTexture', window, imageArray);

            %originalx = changeDimension(originalx,meningiomaTestingFolder,imageFullFileName,62);
            imageRect = CenterRectOnPointd([0 0 originalx originalx], xCenter - (sizex / 4), yCenter);
                    
            
            otherImageFullFileName = rightImage;
            otherImageArray = imread(otherImageFullFileName);
            otherImageArray = imresize(otherImageArray, targetSize);
            otherImageTexture = Screen('MakeTexture', window, otherImageArray);
            
            otherOriginalx = sizey/1.5;
            %otherOriginalx = changeDimension(otherOriginalx,meningiomaTestingFolder, otherImageFullFileName,62);
            otherImageRect = CenterRectOnPointd([0 0 otherOriginalx otherOriginalx], xCenter + (sizex / 4), yCenter);

            Screen('DrawTexture', window, imageTexture, [], imageRect);
            Screen('DrawTexture', window, otherImageTexture, [], otherImageRect);
            
            promptText = 'Rate confidence in tumor similarity between the two images on a scale from 1 to 9:';
            textFont = 'Arial';
            textSize = round(sizex * 0.02);
            textColor = black;

            Screen('TextSize', window, textSize);
            DrawFormattedText(window, promptText, 'center', sizey * 0.95, textColor, [], [], [], [], [], windowRect);
           % DrawFormattedText(window, leftText, 'left', sizey * 0.9, textColor, [], [], [], [], [], windowRect);
           % DrawFormattedText(window, rightText, 'right', sizey * 0.9, textColor, [], [], [], [], [], windowRect);
            
            
            Screen('Flip', window);
            [~, ~, keyCode] = KbCheck;
           
            userInput = KbName(find(keyCode, 1, 'first'));
            userInput = str2double(regexp(char(userInput), '\d', 'match'));
            
            % Check if enough time has passed since the last number input
            thisTime = GetSecs;
            totalTime = thisTime - thisLastInputTime;
            
            if ~isempty(userInput) && ismember(userInput, [1, 2, 3, 4,5,6,7,8,9]) && totalTime >= inputDelay
                selectedNumbers = [selectedNumbers; randomInteger];
                thisLastInputTime = GetSecs;
                dataMatrix(leftSide, rightSide) = userInput;
                dataMatrix(rightSide, leftSide) = userInput;  
                counter = counter + 1;
                validInput = true;
            end
            end
        end
end

% Close the window and clean up
[Y, stress] = cmdscale(dataMatrix, 2);

astrocytomaPoints = Y(1:length(astrocytomaNumbers), 1:2); % the meningioma indices in the Y values directly corresponds to the timing they were inputted 1,2,3
meningiomaPoints = Y(length(astrocytomaNumbers)+1:(length(astrocytomaNumbers)+length(meningiomaNumbers)), 1:2); %4,5,6,7,8
controlPoints = Y(length(astrocytomaNumbers)+1+length(meningiomaNumbers):length(astrocytomaNumbers)+length(meningiomaNumbers)+length(controlNumbers), 1:2); %9,10,11,12
oligoastroPoints = Y(length(astrocytomaNumbers)+1+length(meningiomaNumbers)+length(controlNumbers):length(astrocytomaNumbers)+length(meningiomaNumbers)+length(controlNumbers)+length(oligoastroNumbers), 1:2); %13,14,15,16
oligodenPoints = Y(length(astrocytomaNumbers)+1+length(meningiomaNumbers)+length(controlNumbers)+length(oligoastroNumbers):length(astrocytomaNumbers)+length(meningiomaNumbers)+length(controlNumbers)+length(oligoastroNumbers)+length(oligodenNumbers), 1:2); %17,18,19,20

% Create an empty struct array
point_mapping = struct('index', [], 'point', []);

for i = 1:size(Y,1)
    % Populate the struct array
    point_mapping(i).index = i;
    point_mapping(i).point = Y(i,:);
end


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
save(fullFilePath, 'astrocytomaPoints', 'meningiomaPoints', 'controlPoints', 'oligoastroPoints', 'oligodenPoints', 'point_mapping', 'meningiomaNumbers', 'astrocytomaNumbers', 'oligodenNumbers', 'oligoastroNumbers', 'controlNumbers');


%data imbalance MDS - division 
