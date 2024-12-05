function MRITutorialV2
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

%control 225x225
%glioma: height = 656, width = 875
%meningioma: height = 656, width = 875
%control: height = 227, width = 227

targetSize = [227, 227];

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
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
TIMELIM = 30;

originalTutorialFolderPath = fileparts(mfilename('fullpath'));
controlTutorialFolder = '/Applications/MATLAB/Final Draft File/T2 MRI/Healthy-Control (Updated)';
gliomaTutorialTestingFolder = fullfile(originalTutorialFolderPath, 'InstructionFolder', 'Training', 'Glioma');
meningiomaTutorialTestingFolder = fullfile(originalTutorialFolderPath, 'InstructionFolder', 'Training', 'Meningioma');

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
TIMEDELAYT = .3; % Time delay in seconds
thisLastInputTimeT = GetSecs;
inputDelayT = .2;

while GetSecs - thisLastInputTimeT < 1
    originalText = 'Welcome to the MRI Image Rating Program TUTORIAL:';
    bulletText = '       • You will be presented with pairs of cycling MRI \n       images \n       • Each is an MRI of meningioma, astrocytoma, \n       oligodendroglioma, oligoastrocytoma, or control  \n       • Rate each pair of images on a scale from 1 to 9 \n       by pressing the corresponding key      \n       • Lower Rating: More confident in similarity between \n       pathological conditions      \n       • Higher rating: Less confident in similarity between \n       pathological conditions      \n       • Hover over an image with your mouse to cycle \n       through the MRI images';
    textFont = 'Arial';
    textSize = round(sizex * 0.039);
    textColor = black;
    Screen('TextSize', window, textSize);
    DrawFormattedText(window, originalText, 'center', sizey * 0.2, textColor, [], [], [], [], [], windowRect);
    DrawFormattedText(window, bulletText, 'left', sizey * 0.3, textColor, [], [], [], [], [], windowRect);

    Screen('Flip', window);
end

thisLastInputTimeT = GetSecs;

while GetSecs - thisLastInputTimeT < 1
    noteText = 'NOTE: You must provide this \n trial program and the actual \n program with access to your machines \n keystrokes or it will not run. ';
    textSize = round(sizex * 0.05);
    Screen('TextSize', window, textSize);
    DrawFormattedText(window, noteText, 'center', sizey * 0.3, textColor, [], [], [], [], [], windowRect);
    Screen('Flip', window);

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

while GetSecs - thisLastInputTimeT < 2
    originalText = 'After you have finished providing your answers \n you will be prompted to save the data to a MATLAB file. \n Email this file to the adress xyz@gmail.com. \n Thank you for your time and cooperation';
    textFont = 'Arial';
    textSize = round(sizex * 0.039);
    textColor = black;
    Screen('TextSize', window, textSize);
    DrawFormattedText(window, originalText, 'center', sizey * 0.2, textColor, [], [], [], [], [], windowRect);
    Screen('Flip', window);
end


