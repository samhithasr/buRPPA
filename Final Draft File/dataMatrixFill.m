originalFolderPath = fileparts(mfilename('fullpath')); 
    
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
[imageNames, storedNumbers, sNint, imageArrayOArray, oligoastroNumbers] = fileProcess(oligoastroFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, oligoastroNumbers);
[imageNames, storedNumbers, sNint, imageArrayOArray, oligodenNumbers] = fileProcess(oligodenFiles, imageNames, 3, storedNumbers, sNint, imageArrayOArray, oligodenNumbers);

wAstro = generateUniqueRandomNumbers([astrocytomaNumbers(1), astrocytomaNumbers(end)], 2, []);
wMeningioma = generateUniqueRandomNumbers([meningiomaNumbers(1), meningiomaNumbers(end)], 2, []);
wControl = generateUniqueRandomNumbers([controlNumbers(1), controlNumbers(end)], 2, []);
wOligoDen = generateUniqueRandomNumbers([oligodenNumbers(1), oligodenNumbers(end)], 2, []);
wOligoAstro = generateUniqueRandomNumbers([oligoastroNumbers(1), oligoastroNumbers(end)], 2, []);
wColumnVector = [wAstro.'; wMeningioma.'; wControl.'; wOligoDen.'; wOligoAstro.'];

%ratio of pair involvement between weighted and unweighted the same - 16/16
%or 15/15
nwAstro = generateUniqueRandomNumbers([astrocytomaNumbers(1), astrocytomaNumbers(end)], 4, wAstro);
nwMeningioma = generateUniqueRandomNumbers([meningiomaNumbers(1), meningiomaNumbers(end)], 3, wMeningioma);
nwControl = generateUniqueRandomNumbers([controlNumbers(1), controlNumbers(end)], 4, wControl);
nwOligoDen = generateUniqueRandomNumbers([oligodenNumbers(1), oligodenNumbers(end)], 4, wOligoDen);
nwOligoAstro = generateUniqueRandomNumbers([oligoastroNumbers(1), oligoastroNumbers(end)], 4, wOligoAstro);
nwColumnVector = [nwAstro.'; nwMeningioma.'; nwControl.'; nwOligoDen.'; nwOligoAstro.'];

combinedVector = sort([wColumnVector; nwColumnVector]);

% Remove empty array from imageArrayOArray if it exists
if isempty(imageArrayOArray{end})
    imageArrayOArray = imageArrayOArray(1:end-1);
end

weighted = 28;
nonWeighted = 28;
callNumbers = zeros(length(combinedVector), 1);

%Determines Combinations That Will Occur In Pairing
numComparisons = (length(wColumnVector)*weighted+length(nwColumnVector)*nonWeighted)/2;
arrayComb = zeros(numComparisons, 2); % Initialize with zeros
counterFirst = 1;
done = false;
usedCombinations = zeros(numComparisons, 2);

for k = 1:length(wColumnVector)
    for j = 1:weighted
        validCombinationFound = false;
        
        while ~validCombinationFound
            randomColumn = randi([1, 2]);
            otherColumn = 3 - randomColumn;
            
            openSpots = (arrayComb(:, randomColumn) == 0); % Find open spots in the specified column
            openIndices = find(openSpots); % Find the indices of open spots
            
            randomIndex = openIndices(randi([1, sum(openSpots)])); % Choose a random open spot index
            
            % Check if this combination has already been used
            if ~any(ismember(usedCombinations, [randomIndex, otherColumn], 'rows'))
                if arrayComb(randomIndex, otherColumn) ~= wColumnVector(k)
                    arrayComb(randomIndex, randomColumn) = wColumnVector(k);
                    usedCombinations(counterFirst, :) = [randomIndex, randomColumn];
                    validCombinationFound = true;
                end
            end
        end
    end
end

openSpots = find(arrayComb == 0);

for k = 1:length(nwColumnVector)
    for j = 1:nonWeighted
        validCombinationFound = false;
        
        while ~validCombinationFound
            randomColumn = randi([1, 2]);
            
            openSpots = (arrayComb(:, randomColumn) == 0); % Find open spots in the specified column
            
            if all(~openSpots)
                if randomColumn == 1
                    randomColumn = 2;
                else
                    randomColumn = 1;
                end
            end
            
            otherColumn = 3 - randomColumn;
            openSpots = (arrayComb(:, randomColumn) == 0);
            openIndices = find(openSpots); % Find the indices of open spots
            
            randomIndex = openIndices(randi([1, sum(openSpots)])); % Choose a random open spot index
            
            % Check if this combination has already been used
            if ~any(ismember(usedCombinations, [randomIndex, otherColumn], 'rows'))
                if arrayComb(randomIndex, otherColumn) ~= nwColumnVector(k)
                    arrayComb(randomIndex, randomColumn) = nwColumnVector(k);
                    usedCombinations(counterFirst, :) = [randomIndex, randomColumn];
                    validCombinationFound = true;
                end
            end
        end
    end
end
counter = 1;
leftSide = 0;
rightSide = 0;

% Preallocate the selectedNumbers struct
selectedNumbers = [];
n = length(combinedVector);
dataMatrix = NaN(n);
dataMatrix(1:n+1:end) = 0;
% Initialize time variables
TIMEDELAY = .3; % Time delay in seconds
thisLastInputTime = GetSecs;
inputDelay = .2;
thresh = 0;


% while counter <= numComparisons
while counter <= numComparisons
  randomInteger = counter;
    
  leftSide = arrayComb(randomInteger,1);
  rightSide = arrayComb(randomInteger,2);

   x = 1; %tracking longer length
   y = 1; % tracking shorter length
   leftImage = imageArrayOArray{leftSide}{y};
   rightImage = imageArrayOArray{rightSide}{x};
               
    
       % leftCall = checkComboNumbers(leftSide, wColumnVector);
       % rightCall = checkComboNumbers(rightSide, wColumnVector);
        
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

    % if leftNum == rightNum
    %     rating = randi([1, 3]);
    % elseif (ismember(leftNum, [2,4,5]) && ismember(rightNum, [2,4,5])) || (ismember(leftNum, [1,3]) && ismember(rightNum, [1,3]))
    %     rating  = randi([4,6]);
    % else 
    %     % (ismember(leftNum, [2,4,5]) && ismember(rightNum, [1,3])) || (ismember(leftNum, [1,3]) && ismember(rightNum, [2,4,5]))
    %     rating = randi([7,9]);
    % end
    rating = 2;
    leftIndex = find(combinedVector == leftSide);
    rightIndex = find(combinedVector == rightSide);
    dataMatrix(leftIndex, rightIndex) = rating;
    dataMatrix(rightIndex, leftIndex) = rating;
    disp('rating:');
    disp(rating);
    counter = counter + 1; 
end 

% Close the window and clean up
% Data imbalance MDS - division
% Initialize the points for the five groups
% Define the number of initial points for each group

numInitialPoints = [6, 5, 6, 6, 6]; % Corresponding to astrocytoma, meningioma, control, oligoastro, and oligoden

% Initialize the initialConfig matrix
initialConfig = zeros(sum(numInitialPoints), 2);
count = 1;

% Loop through each group and assign initial points
for i = 1:length(numInitialPoints)
    for j = 1:numInitialPoints(i)
        if i == 1
            initialConfig(count, :) = [1 + 0.01 * j, 0];
        elseif i == 2
            initialConfig(count, :) = [0.3090 + 0.01 * j, 0.9511];
        elseif i == 3
            initialConfig(count, :) = [-0.809 + 0.01 * j, 0.5878];
        elseif i == 4
            initialConfig(count, :) = [-0.809 + 0.01 * j, -0.5878];
        elseif i == 5
            initialConfig(count, :) = [0.3090, -0.9511 + 0.01 * j];
        end
        count = count + 1;
    end
end

low = 0.5;
outFinal = [];
avgDiff = [];
opts = statset('MaxIter',1000);

[out, stress, disparities1] = mdscale(dataMatrix, 2,'Start',initialConfig, 'Options',opts);
totalStress(k) = stress;
distances = pdist(out);
distances = distances.';
[correlations(k), PVals(k)] = corr(distances,dist3,'type','Spearman');



