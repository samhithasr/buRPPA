
fileArray = {'/Users/haraneiger/Desktop/heigerT1HAMv3.mat', '/Users/haraneiger/Desktop/heigerT1HAMv2.mat', '/Users/haraneiger/Desktop/heigerT1HAMv1.mat'};
probabilityArray = {'/Users/haraneiger/Desktop/heigerPFT1v3.mat', '/Users/haraneiger/Desktop/heigerPFHAMT1v2.mat', '/Users/haraneiger/Desktop/heigerT1PFHAMv1.mat' };
% T1PF: v3 = astrocytoma, v2 = oligoastrocytoma, v1 = oligodendroglioma
% T1HAM: v3 = oligodendroglioma, v2 = oligoastrocytoma, v1 = astrocytoma
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
gN = [];

originalC = [9,10,11,12];
originalM = [4,5,6,7,8];
fillerO = [1,2,3,13];
fillerA = [1,2,3];
ap = [];
oap = [];
odp = [];
aM = [];
cM = [];
mM = [];
oaM = [];
odM = [];
pm = [];
gM = [];
gp = [];
fileArrayLength = length(fileArray);



for k = 1:fileArrayLength
    load(fileArray{k}, 'thirdPoints', 'meningiomaPoints', 'controlPoints', 'point_mapping', 'meningiomaNumbers', 'numberVarName', 'controlNumbers', 'thirdNumbers');
    load(probabilityArray{k}, 'meningiomaAccuracyMatrix', 'matrixVarName', 'controlAccuracyMatrix', 'thirdAccuracyMatrix', 'gliomaAccuracyMatrix');
        if k == 1
        % Set the base points with control and meningioma points from the first file
        baseControlPoints = controlPoints;
        baseMeningiomaPoints = meningiomaPoints;
        else
        % Combine control and meningioma points for Procrustes analysis
        combinedBasePoints = [baseControlPoints; baseMeningiomaPoints]; %landmark points 
        combinedNewPoints = [controlPoints; meningiomaPoints];

        % Perform Procrustes analysis without scaling to align combinedNewPoints to combinedBasePoints
        [~, ~, transformation] = procrustes(combinedBasePoints, combinedNewPoints, 'Scaling', false, 'Reflection', 'best');

        % Apply the transformation to the new controlPoints and meningiomaPoints
        controlPoints = transformation.b * controlPoints * transformation.T + transformation.c(1:size(controlPoints, 1), :);
        meningiomaPoints = transformation.b * meningiomaPoints * transformation.T + transformation.c(1:size(meningiomaPoints, 1), :);
        thirdPoints = transformation.b * thirdPoints * transformation.T + transformation.c(1:size(thirdPoints, 1), :);
        
         end
        
        if numel(point_mapping) == 12
            % Add a new element with a default point and number
            % Replace 'defaultPoint' and 'defaultNumber' with appropriate values
            point_mapping(13).point = [0, 0]; % Assuming NaN is a suitable default
            point_mapping(13).index = 21; % Assuming NaN is a suitable default
        end

        
        pm = [pm; point_mapping];
        cp = [cp;controlPoints];
        mp = [mp;meningiomaPoints];
        cM = [cM;controlAccuracyMatrix];
        mM = [mM; meningiomaAccuracyMatrix];
        cN = [cN, originalC + 13 * (k - 1)];
        mN = [mN, originalM + 13 * (k-1)];
        gM = [gM; gliomaAccuracyMatrix];
        gp = [gp; thirdPoints];
        
        if strcmp(numberVarName, 'astrocytomaNumbers')
            ap = [ap;thirdPoints];
            aN = [aN, fillerA + 13 * (k-1)];
            gN = [gN, fillerA + 13 * (k-1)];
        elseif strcmp(numberVarName, 'oligoastrocytmaNumbers')
            oap = [oap;thirdPoints];
            oaN = [oaN, fillerO + 13 * (k-1)];
            gN = [gN, fillerO + 13 * (k-1)];
        elseif strcmp(numberVarName, 'oligodendrogliomaNumbers') 
            odp = [odp;thirdPoints];
            odN = [odN, fillerO + 13 * (k-1)];
            gN = [gN, fillerO + 13 * (k-1)];
        end
        
        if strcmp(matrixVarName,'astrocytomaAccuracyMatrix')
            aM = [aM;thirdAccuracyMatrix];
        elseif strcmp(matrixVarName,'oligodendrogliomaAccuracyMatrix') 
            odM = [odM;thirdAccuracyMatrix];
        elseif strcmp(matrixVarName,'oligoastrocytomaAccuracyMatrix') 
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
arrays = {'c', 'm', 'a', 'oa', 'od', 'g'};
for i = 1:length(arrays)
    arrayName = arrays{i};
    placeHolder = [arrayName, 'p'];
    points = eval(placeHolder); % Get the points array
    
    % Extract x and y values
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
    lowerBoundX = q1X - 100 * iqrX;
    upperBoundX = q3X + 100 * iqrX;
    
    lowerBoundY = q1Y - 100 * iqrY;
    upperBoundY = q3Y + 100 * iqrY;

    boundingBox = [lowerBoundX, lowerBoundY, upperBoundX, upperBoundY];
    boundingBoxes{i} = boundingBox;

end 

% Initialize the groupDistances structure
groupDistances = struct();

% Define the group numbers mapping for easy access
groupNumbersMap = containers.Map({'a', 'c', 'm', 'od', 'oa', 'g'}, ...
                                 {aN, cN, mN, odN, oaN, gN});


for i =1:length(arrays)
    arrayName = arrays{i};
    placeHolder = [arrayName, 'p'];
    groupPoints = eval(placeHolder);
    placeHolder = [arrayName,'N'];
    groupNumbers = eval(placeHolder);
    variableName = [arrayName, 'M'];
    variableContent = eval(variableName);
    disp('group numbers');
    disp(groupNumbers);
    disp("variable content");
    disp(variableContent);
    disp("group points");
    disp(groupPoints); %passing through correct points and accuracies 
    generateStemPlot(arrayName, groupPoints, variableContent);
    recursiveRefinement(boundingBoxes{i}(1), boundingBoxes{i}(3),boundingBoxes{i}(2), boundingBoxes{i}(4), -Inf,arrayName, groupNumbers, pm, variableContent);
end


function bestR2 = recursiveRefinement(minX, maxX, minY, maxY, previousR2, groupName, groupNumbers, pm, accuracyMatrix)

    % Define the bounding box using the provided minX, maxX, minY, maxY
    boundingBox = [minX, minY, maxX, maxY];

    % Initialize a matrix to store unique vertices
    uniqueVertices = [];

    % Divide the bounding box into 16 equally sized sectors
    constant = 20;
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
        for dataIndex = groupNumbers
            row = floor((dataIndex - 1) / 13) + 1;
            column = mod(dataIndex - 1, 13) + 1;
            dataPoint = pm(row, column).point;
            % Calculate the distance from the data point to the vertex
            distance = norm(dataPoint - vertex);

            % Store the information in a structure
            resultStruct = struct('vertex', vertex, 'imageNumber', dataIndex, 'distance', distance, 'dataPoint', dataPoint);

            % Append to the groupDistances array
            groupDistances = [groupDistances; resultStruct];
        end
    end

    % Initialize variables for tracking the best fit
    bestR2 = previousR2;
    bestDistances = [];
    bestAccuracies = [];
    bestVertex = [];
    bestFitResult = [];
    
    lengthOfField = length(groupDistances);
    
    % Iterate over each vertex to find the best fit
    for vertexIdx = 1:size(uniqueVertices, 1)
        distances = zeros(1, floor(lengthOfField/((constant+1)*(constant+1))));
        accuracies = zeros(1, floor(lengthOfField/((constant+1)*(constant+1))));
        vertex = uniqueVertices(vertexIdx, :);

        for r = 1:floor(lengthOfField/((constant+1)*(constant+1)))
            index = (vertexIdx-1)*floor(lengthOfField/((constant+1)*(constant+1))) + r;
            distances(r) = groupDistances(index).distance;
            accuracies(r) = accuracyMatrix(r);
        end

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

    % Plot the graph only if the best fit is found
    if ~isempty(bestDistances)
        figure;
        plot(bestDistances, bestAccuracies, '.', 'DisplayName', 'Data Points', 'MarkerSize', 20);
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
    else
        disp(['No distances found for group: ', groupName]);
    end

    return;
end

function generateStemPlot(groupName, groupPoints, accuracyMatrix)
    % This function generates a 3D stem plot for the given group.
    
    % Create a new figure for the stem plot
    figure;
    hold on;
    title(sprintf('3D Stem Plot for Group: %s', groupName));
    xlabel('MDS X');
    ylabel('MDS Y');
    zlabel('Probability');

    % Plot each data point as a stem in the plot
    for i = 1:length(groupPoints)
        dataPoint = groupPoints(i,:);
        accuracy = accuracyMatrix(i);
        stem3(dataPoint(1), dataPoint(2), accuracy, 'filled'); % Plot each data point
    end

    hold off;
end

