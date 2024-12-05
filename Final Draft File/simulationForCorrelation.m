% Specify the full path to the data file
filledDataMatrix = '/Applications/MATLAB/Final Draft File/savingYDataMatrix.mat';

% Load the data file and access the variable 'dataMatrix'
loadedData = load(filledDataMatrix);
filled = loadedData.dataMatrix;
[Y] = cmdscale(filled,2);
dist3 = pdist(Y);
dist3 = dist3.';
originalFolderPath = fileparts(mfilename('fullpath')); 
controlFolder = fullfile(originalFolderPath, 'T2 MRI', 'Healthy-Control (Updated)');
astrocytomaTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Astrocytoma (Updated)');
meningiomaTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Meningioma (Updated)');
oligoastroTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Oligoastrocytoma (Updated)');
oligodenTestingFolder = fullfile(originalFolderPath, 'T2 MRI', 'Oligodendroglioma (Updated)');

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

maxIter = 10;
totalStress = NaN(1,maxIter);
correlations = zeros(1,maxIter);
PVals = zeros(1,maxIter);
iter = 1;


for f = 1:maxIter
    disp('iteration');
    disp(iter);
    iter = iter +1; 
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
    
    weighted = 14;
    nonWeighted = 14;
    callNumbers = zeros(length(combinedVector), 1);
    
    n = length(combinedVector);
    dataMatrix = NaN(n);
    dataMatrix(1:n+1:end) = 0;
    
    %Determines Combinations That Will Occur In Pairing
    numComparisons = (length(wColumnVector)*weighted+length(nwColumnVector)*nonWeighted)/2;
    check = false;
    maxAttempts = 5000;
    check = false;
    tries = 1; 
    while ~check
         disp('starting:'); % Update this with the appropriate value
         disp(tries);
         tries = tries+1;
        arrayComb = zeros(numComparisons, 2); % Initialize with zeros
        createdCombos = ones(numComparisons, 2) * 100;
        numCombos = 1;
        counterFirst = 1;
    
        for k = 1:length(wColumnVector)
            for j = 1:weighted
                randomColumn = randi([1, 2]);
                otherColumn = 3 - randomColumn;
                openSpots = (arrayComb(:, randomColumn) == 0); % Find open spots in the specified column
    
                % Ensure that there are open spots available in the chosen column
                if ~any(openSpots)
                    continue; % Skip this iteration and move to the next iteration
                end
    
                % Select a random open spot index
                randomIndex = randi([1, sum(openSpots)]);
                openIndices = find(openSpots); % Find the indices of open spots
                chosenIndex = openIndices(randomIndex); % Select the random open spot index 
                currentCombination = [arrayComb(chosenIndex, otherColumn), wColumnVector(k)];
                reverseCombination = [wColumnVector(k), arrayComb(chosenIndex, otherColumn)];
    
                % Check for duplicate combinations
                while arrayComb(chosenIndex, otherColumn) == wColumnVector(k) || (ismember(currentCombination, createdCombos, 'rows') || ismember(reverseCombination, createdCombos, 'rows'))
                    randomIndex = randi([1, sum(openSpots)]);
                    openIndices = find(openSpots); % Find the indices of open spots
                    chosenIndex = openIndices(randomIndex); % Select the random open spot index
                    currentCombination = [arrayComb(chosenIndex, otherColumn), wColumnVector(k)];
                    reverseCombination = [wColumnVector(k), arrayComb(chosenIndex, otherColumn)];
                end
    
                % Update the arrayComb and createdCombos
                arrayComb(chosenIndex, randomColumn) = wColumnVector(k);
                if arrayComb(chosenIndex, otherColumn) ~= 0 && arrayComb(chosenIndex, randomColumn) ~=0
                    createdCombos(numCombos, :) = [wColumnVector(k), arrayComb(chosenIndex, otherColumn)];
                    numCombos = numCombos + 1;
                end
            end
        end
    
        openSpots = find(arrayComb == 0);
        numOpenSpots = length(openSpots);
        count = 0;
    
        for k = 1:length(nwColumnVector)
            for j = 1:nonWeighted
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
                randomIndex = randi([1, sum(openSpots)]); % Choose a random open spot index
                openIndices = find(openSpots); % Find the indices of open spots
                chosenIndex = openIndices(randomIndex); % Select the random open spot index
                currentCombination = [arrayComb(chosenIndex, otherColumn), nwColumnVector(k)];
                reverseCombination = [nwColumnVector(k), arrayComb(chosenIndex, otherColumn)];
                count = 0;
    
                while arrayComb(chosenIndex, otherColumn) == nwColumnVector(k) || any(ismember([currentCombination; reverseCombination], createdCombos, 'rows'))
                    randomIndex = randi([1, sum(openSpots)]);
                    openIndices = find(openSpots); % Find the indices of open spots
                    chosenIndex = openIndices(randomIndex); % Select the random open spot index
                    currentCombination = [arrayComb(chosenIndex, otherColumn), nwColumnVector(k)];
                    reverseCombination = [nwColumnVector(k), arrayComb(chosenIndex, otherColumn)];
                    count = count+1;
                    if count > maxAttempts
                        arrayComb = zeros(size(arrayComb));
                        break;
                    end
                end
                arrayComb(chosenIndex, randomColumn) = nwColumnVector(k);
                if arrayComb(chosenIndex, otherColumn) ~= 0 && arrayComb(chosenIndex, randomColumn) ~=0
                    createdCombos(numCombos, :) = [nwColumnVector(k), arrayComb(chosenIndex, otherColumn)];
                    numCombos = numCombos + 1;
                end   
            end
    
            % If check is true, a valid combination has been found, exit the loop
            if check
                break;
            end
        end
    
        % Check if there are still open spots in arrayComb
        openSpots = find(arrayComb == 0);
        if ~isempty(openSpots)
            check = false;
        else
            check = true;
        end
    end
    
    for k = 1:length(arrayComb)
        leftSide = arrayComb(k,1);
        rightSide = arrayComb(k,2);
        rating = filled(leftSide,rightSide);
        dataMatrix(leftSide,rightSide) = rating;
        dataMatrix(rightSide,leftSide) = rating;
    end

    disp('dataMatrx');
    disp(dataMatrix);

    numInitialPoints = [6, 5, 6, 6, 6]; % Corresponding to astrocytoma, meningioma, control, oligoastro, and oligoden

    % Initialize the initialConfig matrix
    initialConfig = zeros(sum(numInitialPoints), 2);
    count = 1;
    
    %Loop through each group and assign initial points
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
    % Perform MDS with the provided initial configuration to eliminate
    % error
   % try

    %[Y, stress] = mdscale(dataMatrix, 2, 'Start', initialConfig);
        
    [out, stress, disparities1] = mdscale(dataMatrix, 2, 'Start', initialConfig);
    % catch exception
    %     disp('Error during MDS optimization:');
    %     disp(exception.message);
    %     f = f - 1;  % Decrement f to skip this iteration
    %     continue;  % Skip this iteration and proceed to the next one
    % end
   
    totalStress(f) = stress;
    [filename, filepath] = uiputfile('*.mat', 'Save Data');

    %Check if the user canceled the operation
    if isequal(filename, 0) || isequal(filepath, 0)
        disp('File saving canceled.');
        return;
    end

    %Construct the full file path
   fullFilePath = fullfile(filepath, filename);

   % Save the data to the selected file
    save(fullFilePath, 'out', 'dataMatrix');
    distances = pdist(out);
    distances = distances.';
    [correlations(f), PVals(f)] = corr(dist3,distances,'type','Spearman');
    disp('correlations:');
    disp(correlations(f));
    disp('stress');
    disp(stress);
    
end
disp('correlation');
meanCorrelation = mean(correlations);
stdCorrelation = std(correlations);
disp('mean');
disp(meanCorrelation);
disp('std');
disp(stdCorrelation);
disp('stress');
meanStress = mean(totalStress);
stdStress = std(totalStress);
disp('mean');
disp(meanStress);
disp('std');
disp(stdStress);

