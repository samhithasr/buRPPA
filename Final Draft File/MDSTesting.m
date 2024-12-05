
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

controlFolder = fullfile(originalFolderPath, 'CompleteTesting', 'Healthy');
astrocytomaTestingFolder = fullfile(originalFolderPath, 'CompleteTesting', 'Astrocytoma');
meningiomaTestingFolder = fullfile(originalFolderPath, 'CompleteTesting', 'Meningioma (Kaggle Dataset)');
oligoastroTestingFolder = fullfile(originalFolderPath, 'CompleteTesting', 'Oligoastrocytoma');
oligodenTestingFolder = fullfile(originalFolderPath, 'CompleteTesting', 'Oligodendroglioma');

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
[imageNames, storedNumbers, sNint, imageArrayOArray, controlNumbers] = fileProcess(controlFiles, imageNames, 4, storedNumbers, sNint, imageArrayOArray, controlNumbers);

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

%Ensures no overlap between groups 
smallAstro = generateUniqueRandomNumbers([astrocytomaNumbers(1), astrocytomaNumbers(end)], 3, []);
centerAstro = smallAstro(randi(numel(smallAstro)));
smallMeningioma = generateUniqueRandomNumbers([meningiomaNumbers(1), meningiomaNumbers(end)], 3, []);
centerMeningioma = smallMeningioma(randi(numel(smallMeningioma)));
smallControl = generateUniqueRandomNumbers([controlNumbers(1), controlNumbers(end)], 3, []);
centerControl = smallControl(randi(numel(smallControl)));
smallOligoDen = generateUniqueRandomNumbers([oligodenNumbers(1), oligodenNumbers(end)], 3, []);
centerOligoDen = smallOligoDen(randi(numel(smallOligoDen)));
smallOligoAstro = generateUniqueRandomNumbers([oligoastroNumbers(1), oligoastroNumbers(end)], 3, []);
centerOligoAstro = smallOligoAstro(randi(numel(smallOligoAstro)));
smallColumnVector = [smallAstro.'; smallMeningioma.'; smallControl.'; smallOligoDen.'; smallOligoAstro.'];
largeAstro = generateUniqueRandomNumbers([astrocytomaNumbers(1), astrocytomaNumbers(end)], 3, smallAstro);
largeMeningioma = generateUniqueRandomNumbers([meningiomaNumbers(1), meningiomaNumbers(end)], 3, smallMeningioma);
largeControl = generateUniqueRandomNumbers([controlNumbers(1), controlNumbers(end)], 3, smallControl);
largeOligoDen = generateUniqueRandomNumbers([oligodenNumbers(1), oligodenNumbers(end)], 3, smallOligoDen);
largeOligoAstro = generateUniqueRandomNumbers([oligoastroNumbers(1), oligoastroNumbers(end)], 3, smallOligoAstro);
largeColumnVector = [largeAstro.'; largeMeningioma.'; largeControl.'; largeOligoDen.'; largeOligoAstro.'];
combinedVector = sort([smallColumnVector; largeColumnVector]);

% Remove empty array from imageArrayOArray if it exists
if isempty(imageArrayOArray{end})
    imageArrayOArray = imageArrayOArray(1:end-1);
end

%callNumbers = zeros(length(imageArrayOArray), 1); - don't need this
%variable anymore

%Determines Combinations That Will Occur In Pairing
numComparisons = (length(smallAstro)*5) * (length(largeAstro) *5);
arrayComb = struct('subjectOne', 'int32', 'subjectTwo', 'int32');
counterFirst = 1;

% for k = 1:length(smallColumnVector)
%     for j = 1:length(largeColumnVector)
%         arrayComb(counterFirst).subjectOne = smallColumnVector(k);
%         arrayComb(counterFirst).subjectTwo = largeColumnVector(j);
%         counterFirst = counterFirst + 1;
%     end
% end

for k = 1:length(combinedVector)
    for j = k + 1:length(combinedVector)
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
n = length(smallColumnVector)+length(largeColumnVector);
dataMatrix = NaN(n);
dataMatrix(1:n+1:end) = 0;

% Initialize time variables
TIMEDELAY = .3; % Time delay in seconds
thisLastInputTime = GetSecs;
inputDelay = .2;
% while counter <= numComparisons
while counter <= length(arrayComb)/2
    randomInteger = randi([1, length(arrayComb)]);
    randomSide = randi([0, 1]);
    
    if randomSide == 0
        leftSide = arrayComb(randomInteger).subjectOne;
        rightSide = arrayComb(randomInteger).subjectTwo;
    else
        leftSide = arrayComb(randomInteger).subjectTwo;
        rightSide = arrayComb(randomInteger).subjectOne;
    end
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
            
            leftText = folderName;

             % Extract the folder name
            folderPathTwo = fileparts(rightImage);
            folderPartsTwo = strsplit(folderPathTwo, filesep);
            folderNameTwo = folderPartsTwo{end};
            
            % Display the folder name
            
            rightText = folderNameTwo;
            
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

            originalx = changeDimension(originalx,meningiomaTestingFolder,imageFullFileName,62);
            imageRect = CenterRectOnPointd([0 0 originalx originalx], xCenter - (sizex / 4), yCenter);
                    
            
            otherImageFullFileName = rightImage;
            otherImageArray = imread(otherImageFullFileName);
            otherImageArray = imresize(otherImageArray, targetSize);
            otherImageTexture = Screen('MakeTexture', window, otherImageArray);
            
            otherOriginalx = sizey/1.5;
            otherOriginalx = changeDimension(otherOriginalx,meningiomaTestingFolder, otherImageFullFileName,62);
            otherImageRect = CenterRectOnPointd([0 0 otherOriginalx otherOriginalx], xCenter + (sizex / 4), yCenter);

            Screen('DrawTexture', window, imageTexture, [], imageRect);
            Screen('DrawTexture', window, otherImageTexture, [], otherImageRect);
            
            promptText = 'Rate confidence in tumor similarity between the two images on a scale from 1 to 9:';
            textFont = 'Arial';
            textSize = round(sizex * 0.02);
            textColor = black;

            Screen('TextSize', window, textSize);
            DrawFormattedText(window, promptText, 'center', sizey * 0.95, textColor, [], [], [], [], [], windowRect);
            DrawFormattedText(window, leftText, 'left', sizey * 0.9, textColor, [], [], [], [], [], windowRect);
            DrawFormattedText(window, rightText, 'right', sizey * 0.9, textColor, [], [], [], [], [], windowRect);
            % 
            
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
                disp('leftSide Index');
                disp(combinedVector == leftSide);
                disp('rightSide Index');
                disp(combinedVector == rightSide);
                dataMatrix(combinedVector == leftSide, combinedVector == rightSide) = userInput;
                dataMatrix(combinedVector == rightSide, combinedVector == leftSide) = userInput;
                counter = counter + 1;
                validInput = true;
            end
            end
        end
end

% Close the window and clean up
[Y, stress] = mdscale(dataMatrix, 3, 'Start', 'random');

astrocytomaPoints = Y(1:length(smallAstro)+length(largeAstro), 1:3); % the meningioma indices in the Y values directly corresponds to the timing they were inputted 
meningiomaPoints = Y(length(smallAstro)+length(largeAstro)+1:2*(length(smallAstro)+length(largeAstro)), 1:3);
controlPoints = Y(2*(length(smallAstro)+length(largeAstro))+1:3*(length(smallAstro)+length(largeAstro)), 1:3);
oligoastroPoints = Y(3*(length(smallAstro)+length(largeAstro))+1:4*(length(smallAstro)+length(largeAstro)), 1:3);
oligodenPoints  = Y(4*(length(smallAstro)+length(largeAstro))+1:5*(length(smallAstro)+length(largeAstro)), 1:3);


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
save(fullFilePath, 'astrocytomaPoints', 'meningiomaPoints', 'controlPoints', 'oligoastroPoints', 'oligodenPoints');


%data imbalance MDS - division 