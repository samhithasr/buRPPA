
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


controlFolder = fullfile(originalFolderPath, 'T2 MRI', 'Healthy-Control (Updated)');
astrocytomaTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Astrocytoma (Updated)');
meningiomaTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Meningioma (Updated)');
oligoastroTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Oligoastrocytoma (Updated)');
oligodenTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Oligodendroglioma (Updated)');
folderNamesArray = {'Healthy-Control (Updated)', 'Astrocytoma (Updated)', 'Meningioma (Updated)', 'Oligoastrocytoma (Updated)', 'Oligodendroglioma (Updated)'};

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
[imageNames, storedNumbers, sNint, imageArrayOArray, meningiomaNumbers] = fileProcess(meningiomaFiles, imageNames, 5, storedNumbers, sNint, imageArrayOArray, meningiomaNumbers);
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
for k = 1:length(arrayComb)
        
       
        leftSide = arrayComb(k).subjectOne;
        rightSide = arrayComb(k).subjectTwo;
        
        x = 1; %tracking longer length
        y = 1; % tracking shorter length
       leftImage = imageArrayOArray{leftSide}{y};
       rightImage = imageArrayOArray{rightSide}{x};
        folderPath = fileparts(leftImage);
        folderParts = strsplit(folderPath, filesep);
        folderName = folderParts{end};
        
        % Display the folder name
        
        leftText = folderName;
    
         % Extract the folder name
        folderPathTwo = fileparts(rightImage);
        folderPartsTwo = strsplit(folderPathTwo, filesep);
        folderNameTwo = folderPartsTwo{end};
        
        % Display the folder name
        
        rightText = folderNameTwo;
        
        leftNum = find(strcmp(folderNamesArray, leftText));
        rightNum = find(strcmp(folderNamesArray, rightText));
    
        %folderNamesArray = {'Healthy-Control (Updated)', 'Astrocytoma (Updated)', 'Meningioma (Updated)', 'Oligoastrocytoma (Updated)', 'Oligodendroglioma (Updated)'};
    
        if leftNum == rightNum
            rating = randi([1, 3]);
        elseif (ismember(leftNum, [2,4,5]) && ismember(rightNum, [2,4,5])) || (ismember(leftNum, [1,3]) && ismember(rightNum, [1,3]))
            rating  = randi([4,6]);
        elseif (ismember(leftNum, [2,4,5]) && ismember(rightNum, [1,3])) || (ismember(leftNum, [1,3]) && ismember(rightNum, [2,4,5]))
            rating = randi([7,9]);
        end
        % rating =2;
        dataMatrix(leftSide, rightSide) = rating;
        dataMatrix(rightSide, leftSide) = rating;
        disp('rating:');
        disp(rating);
        counter = counter + 1; 
    end
    
    % Close the window and clean up
    % Data imbalance MDS - division
    % Initialize the points for the five groups
    % Define the number of initial points for each group
    
    % numInitialPoints = [6, 5, 6, 6, 6]; % Corresponding to astrocytoma, meningioma, control, oligoastro, and oligoden
    % 
    % % Initialize the initialConfig matrix
    % initialConfig = zeros(sum(numInitialPoints), 2);
    % count = 1;
    % 
    % % Loop through each group and assign initial points
    % for i = 1:length(numInitialPoints)
    %     for j = 1:numInitialPoints(i)
    %         if i == 1
    %             initialConfig(count, :) = [1 + 0.01 * j, 0];
    %         elseif i == 2
    %             initialConfig(count, :) = [0.3090 + 0.01 * j, 0.9511];
    %         elseif i == 3
    %             initialConfig(count, :) = [-0.809 + 0.01 * j, 0.5878];
    %         elseif i == 4
    %             initialConfig(count, :) = [-0.809 + 0.01 * j, -0.5878];
    %         elseif i == 5
    %             initialConfig(count, :) = [0.3090, -0.9511 + 0.01 * j];
    %         end
    %         count = count + 1;
    %     end
    % end
% Close the window and clean up
Y = cmdscale(dataMatrix, 2);

astrocytomaPoints = Y(1:length(astrocytomaNumbers), 1:2); % the meningioma indices in the Y values directly corresponds to the timing they were inputted 
meningiomaPoints = Y(length(astrocytomaNumbers)+1:(length(astrocytomaNumbers)+length(meningiomaNumbers)), 1:2);
controlPoints = Y(length(astrocytomaNumbers)+1+length(meningiomaNumbers):length(astrocytomaNumbers)+length(meningiomaNumbers)+length(controlNumbers), 1:2);
oligoastroPoints = Y(length(astrocytomaNumbers)+1+length(meningiomaNumbers)+length(controlNumbers):length(astrocytomaNumbers)+length(meningiomaNumbers)+length(controlNumbers)+length(oligoastroNumbers), 1:2);
oligodenPoints = Y(length(astrocytomaNumbers)+1+length(meningiomaNumbers)+length(controlNumbers)+length(oligoastroNumbers):length(astrocytomaNumbers)+length(meningiomaNumbers)+length(controlNumbers)+length(oligoastroNumbers)+length(oligodenNumbers), 1:2);


Screen('CloseAll');
sca;

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
save(fullFilePath, 'astrocytomaPoints', 'meningiomaPoints', 'controlPoints', 'oligoastroPoints', 'oligodenPoints', 'dataMatrix', 'Y');


%data imbalance MDS - division 
