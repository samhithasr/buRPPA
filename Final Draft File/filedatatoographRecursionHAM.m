
fileArray = {"C:\Users\heiger\Desktop\T2HAM_1_Test4_23-Jul-2024.mat"};
probabilityArray = {"C:\Users\heiger\Desktop\PFTHAM_1_TESTTEST_30-Jul-2024.mat" };
cp = [];
mp = [];
ap = [];
oap = [];
odp = [];

aN = [];
cN = [];
mN = [];
odN = [];
oaN = [];
originalA = [1,2,3];
originalC = [9,10,11,12];
originalM = [4,5,6,7,8];
originalOD = [17,18,19,20];
originalOA = [13,14,15,16];
blank = [21];
ap = [];
oap = [];
odp = [];
aM = [];
cM = [];
mM = [];
oaM = [];
odM = [];
pm = [];
cK = [];
mK = [];
aK = [];
odK = [];
oaK = [];


fileArrayLength = length(fileArray);



for k = 1:fileArrayLength
    load(fileArray{k}, 'thirdPoints', 'meningiomaPoints', 'controlPoints', 'point_mapping', 'meningiomaNumbers', 'numberVarName', 'controlNumbers', 'thirdNumbers');
    load(probabilityArray{k}, 'meningiomaAccuracyMatrix', 'letter', 'controlAccuracyMatrix', 'thirdAccuracyMatrix');
       
        if numel(point_mapping) == 12
            % Add a new element with a default point and number
            % Replace 'defaultPoint' and 'defaultNumber' with appropriate values
            point_mapping(13).point = [NaN, NaN]; % Assuming NaN is a suitable default
            point_mapping(13).index = 21; % Assuming NaN is a suitable default
        end


        pm = [pm; point_mapping];
        cp = [cp;controlPoints];
        mp = [mp;meningiomaPoints];
        cM = [cM;controlAccuracyMatrix];
        mM = [mM; meningiomaAccuracyMatrix];
        cN = [cN, originalC + 21*(k-1)];
        cK = [cK, repmat(k, 1, length(originalC))];
        mN = [mN, originalM + 21*(k-1)];
        mK = [mK, repmat(k, 1, length(originalM))];
        disp(numberVarName);
        
        if strcmp(numberVarName, 'astrocytomaNumbers')
            ap = [ap;thirdPoints];
            aN = [aN, originalA + 21*(k-1)];
            aK = [aK, repmat(k, 1, length(originalA))];
        elseif strcmp(numberVarName, 'oligoastrocytmaNumbers')
            disp('entered');
            oap = [oap;thirdPoints];
            oaN = [oaN, originalOA + 21*(k-1)];
            oaK = [oaK, repmat(k, 1, length(originalOA))];
        elseif strcmp(numberVarName, 'oligodendrogliomaNumbers') 
            odp = [odp;thirdPoints];
            odN = [odN, originalOD + 21*(k-1)];
            oaK = [oaK, repmat(k, 1, length(originalOD))];
        end
        
        if strcmp(letter,'a')
            aM = [aM;thirdAccuracyMatrix];
        elseif strcmp(letter,'d') 
            odM = [odM;thirdAccuracyMatrix];
        elseif strcmp(letter,'o') 
            oaM = [oaM;thirdAccuracyMatrix];
        end

end

hold on;
% Check if arrays are not empty and then plot
if ~isempty(mp)
    plot(mp(:, 1), mp(:, 2), 'r.', 'MarkerSize', 20); % Meningioma points in red
end

if ~isempty(ap)
    plot(ap(:, 1), ap(:, 2), 'b.', 'MarkerSize', 20); % Astrocytoma points in blue
end

if ~isempty(cp)
    plot(cp(:, 1), cp(:, 2), 'g.', 'MarkerSize', 20); % Control points in green
end

if ~isempty(oap)
    plot(oap(:, 1), oap(:, 2), 'c.', 'MarkerSize', 20); % Oligoastrocyte points in cyan
end

if ~isempty(odp)
    plot(odp(:, 1), odp(:, 2), 'k.', 'MarkerSize', 20); % Oligoden points in black
end

% Define group colors
groupColors = {'g', 'r', 'b', 'c', 'k'};
hold off;

legend('Meningioma', 'Astrocytoma', 'Control', 'Oligoastrocytoma', 'Oligodendroglioma'); % Updated legend labels

maxX = -Inf;
minX = Inf;
maxY = -Inf;
minY = Inf;

% Loop through each array
arrays = {'c', 'm', 'a', 'oa', 'od'};
for i = 1:length(arrays)
    arrayName = arrays{i};
    placeHolder = [arrayName, 'p'];
    disp(arrayName);
    points = eval(placeHolder); % Get the points array
    
    % Extract x and y values
    disp('points');
    disp(points);
    x = points(:, 1); % Assuming x is in the first column
    y = points(:, 2); % Assuming y is in the second column
    
    % Calculate the IQR for x and y
    q1X = prctile(x, 25); % First quartile (25th percentile) for x
    q3X = prctile(x, 75); % Third quartile (75th percentile) for x
    iqrX = q3X - q1X; % Interquartile Range for x
    
    q1Y = prctile(y, 25); % First quartile (25th percentile) for y
    q3Y = prctile(y, 75); % Third quartile (75th percentile) for y
    iqrY = q3Y - q1Y; % Interquartile Range for y
    
    % Define the lower and upper bounds for potential outliers for x and y
    lowerBoundX = q1X - 1.5 * iqrX;
    upperBoundX = q3X + 1.5 * iqrX;
    
    lowerBoundY = q1Y - 1.5 * iqrY;
    upperBoundY = q3Y + 1.5 * iqrY;

    boundingBox = [lowerBoundX, lowerBoundY, upperBoundX, upperBoundY];
    boundingBoxes{i} = boundingBox;
    disp(boundingBox);

end 

% Initialize the groupDistances structure
groupDistances = struct();

% Define the group numbers mapping for easy access
groupNumbersMap = containers.Map({'a', 'c', 'm', 'od', 'oa'}, ...
                                 {aN, cN, mN, odN, oaN});


for i =1:length(arrays)
    arrayName = arrays{i};
    placeHolder = [arrayName, 'p'];
    groupPoints = eval(placeHolder);
    placeHolder = [arrayName,'N'];
    groupNumbers = eval(placeHolder);
    variableName = [arrayName, 'M'];
    variableContent = eval(variableName);
    placeHolder = [arrayName, 'K'];
    hashMapKeys = eval(placeHolder);

    recursiveRefinement(boundingBoxes{i}(1), boundingBoxes{i}(3),boundingBoxes{i}(2), boundingBoxes{i}(4), -Inf,arrayName, groupNumbers, pm, variableContent, hashMapKeys);
end


function bestR2 = recursiveRefinement(minX, maxX, minY, maxY, previousR2, groupName, groupNumbers, pm, accuracyMatrix, hashMapKeys)
    
    
    % Define the bounding box using the provided minX, maxX, minY, maxY
    boundingBox = [minX, minY, maxX, maxY];

    % Initialize a matrix to store unique vertices
    uniqueVertices = [];

    % Divide the bounding box into 16 equally sized sectors
    constant = 4;
    for j = 1:constant
        for k = 1:constant
            x1 = boundingBox(1) + (k - 1) * (boundingBox(3) - boundingBox(1)) / constant;
            x2 = boundingBox(1) + k * (boundingBox(3) - boundingBox(1)) / constant;
            y1 = boundingBox(2) + (j - 1) * (boundingBox(4) - boundingBox(2)) / constant;
            y2 = boundingBox(2) + j * (boundingBox(4) - boundingBox(2)) / constant;

            uniqueVertices = [uniqueVertices; x1 y1; x2 y1; x2 y2; x1 y2];
        end
    end

    % Remove duplicate vertices
    uniqueVertices = unique(uniqueVertices, 'rows');

    % Initialize an array to store distances
    groupDistances = [];

    % Iterate over each vertex
    for vertexIdx = 1:size(uniqueVertices, 1)
        vertex = uniqueVertices(vertexIdx, :);

        % Iterate over each data point for the current group
        for dataIndex = length(groupNumbers)
            index = groupNumbers(dataIndex)-(21*(hashMapKeys(dataIndex)-1));
            disp(groupNumbers(dataIndex));
            disp(hashMapKeys(dataIndex));
            disp(index);
            dataPoint = pm(index).point;

            % Calculate the distance from the data point to the vertex
            distance = norm(dataPoint - vertex);

            % Store the information in a structure
            resultStruct = struct('vertex', vertex, ...
                                  'imageNumber', dataIndex, ...
                                  'distance', distance);

            % Append to the groupDistances array
            groupDistances = [groupDistances; resultStruct];
        end
    end

    % Return the bestR2 value (this is a placeholder, you'll need to compute it)
    bestR2 = previousR2;
    bestDistances = [];
    bestAccuracies = [];
    bestVertex = [];
    bestFitResult = [];
    
    lengthOfField = length(groupDistances);
    disp(lengthOfField);
    
    for vertexIdx = 1:size(uniqueVertices, 1)
        distances = zeros(1, floor(lengthOfField/((constant+1)*(constant+1))));
        accuracies = zeros(1, floor(lengthOfField/((constant+1)*(constant+1))));
        vertex = uniqueVertices(vertexIdx, :);

        for r = 1:floor(lengthOfField/((constant+1)*(constant+1)))
            index = (vertexIdx-1)*floor(lengthOfField/((constant+1)*(constant+1))) + r;
            distances(r) = groupDistances(index).distance;
            accuracies(r) = accuracyMatrix(r);
        end
    
        disp("distances:");
        disp(distances);
        disp("accuracies:");
        disp(accuracies);
        % Fit the model to the data
        f = fittype('exp(-a*x)', 'independent', 'x', 'dependent', 'y');
        opts = fitoptions(f);
        opts.StartPoint = 1;
        [fitresult, gof] = fit(distances', accuracies', f, opts);

        % Check if this R^2 is the best for this group
        if gof.rsquare > bestR2
            bestR2 = gof.rsquare;
            bestDistances = distances;
            bestAccuracies = accuracies;
            bestVertex = vertex;
            bestFitResult = fitresult;
        end
    end

    % Check if bestDistances is still empty
  if ~isempty(bestDistances) % Check if bestDistances is not empty
    disp('here')
    figure;
    plot(bestDistances, bestAccuracies, '.', 'DisplayName', 'Data Points', 'MarkerSize', 20); % Adjust MarkerSize as needed
    hold on;
    x_fit = linspace(0, max(bestDistances(:)), 1000);
    y_fit = exp(-bestFitResult.a * x_fit);
    plot(x_fit, y_fit, 'r-', 'LineWidth', 2, 'DisplayName', 'Line of Best Fit: y = e^{-ax}');
    xlabel('Distance from Prototype');
    ylabel('Accuracy');
    titleStr = sprintf('Group: %s, Vertex Coordinate: (%.2f, %.2f)', groupName, bestVertex(1), bestVertex(2));
    title(titleStr);
    legend;
    grid on;
    textStr = sprintf('R^2 = %.4f', bestR2);
    text(max(bestDistances)*0.7, max(bestAccuracies)*0.9, textStr, 'FontSize', 10, 'BackgroundColor', 'white');
    hold off;
    % After plotting the best graph for this group, adjust the bounding box
    halfWidth = (maxX - minX) / 2;
    halfHeight = (maxY - minY) / 2;

    % Adjust the bounding box to be centered around the best vertex
    newMinX = bestVertex(1) - halfWidth / 2;
    newMaxX = bestVertex(1) + halfWidth / 2;
    newMinY = bestVertex(2) - halfHeight / 2;
    newMaxY = bestVertex(2) + halfHeight / 2;

    % Make a recursive call with the new bounding box
    recursiveRefinement(newMinX, newMaxX, newMinY, newMaxY, bestR2, groupName, groupNumbers, pm, accuracyMatrix);
else
    disp(['No distances found for group: ', groupName]);
end
    return;
end
