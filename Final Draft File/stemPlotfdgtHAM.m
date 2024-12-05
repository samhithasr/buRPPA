
fileArray = {'/Users/haraneiger/Desktop/T1HAMTrialRun.mat', '/Users/haraneiger/Desktop/T1HAMV2.mat', '/Users/haraneiger/Desktop/T1HAMV3.mat'};
probabilityArray = {'/Users/haraneiger/Desktop/probabilityFinderHAMTrial.mat', '/Users/haraneiger/Desktop/probabilityFinderTestV2.mat', '/Users/haraneiger/Desktop/probabilityFinderT1V3.mat' };
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

fileArrayLength = length(fileArray);



for k = 1:fileArrayLength
    load(fileArray{k}, 'thirdPoints', 'meningiomaPoints', 'controlPoints', 'point_mapping', 'meningiomaNumbers', 'numberVarName', 'controlNumbers', 'thirdNumbers');
    load(probabilityArray{k}, 'meningiomaAccuracyMatrix', 'matrixVarName', 'controlAccuracyMatrix', 'thirdAccuracyMatrix');
       
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
        
        if strcmp(numberVarName, 'astrocytomaNumbers')
            ap = [ap;thirdPoints];
            aN = [aN, fillerA + 13 * (k-1)];
        elseif strcmp(numberVarName, 'oligoastrocytmaNumbers')
            oap = [oap;thirdPoints];
            oaN = [oaN, fillerO + 13 * (k-1)];
        elseif strcmp(numberVarName, 'oligodendrogliomaNumbers') 
            odp = [odp;thirdPoints];
            odN = [odN, fillerO + 13 * (k-1)];
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
arrays = {'c', 'm', 'a', 'oa', 'od'};
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
    lowerBoundX = q1X - 1.5 * iqrX;
    upperBoundX = q3X + 1.5 * iqrX;
    
    lowerBoundY = q1Y - 1.5 * iqrY;
    upperBoundY = q3Y + 1.5 * iqrY;

    boundingBox = [lowerBoundX, lowerBoundY, upperBoundX, upperBoundY];
    boundingBoxes{i} = boundingBox;

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
    disp('group numbers');
    disp(groupNumbers);
    disp("variable content");
    disp(variableContent);
    disp("group points");
    disp(groupPoints); %passing through correct points and accuracies 
    recursiveRefinement(boundingBoxes{i}(1), boundingBoxes{i}(3),boundingBoxes{i}(2), boundingBoxes{i}(4), -Inf,arrayName, groupNumbers, pm, variableContent);
end


function [bestR2, bestPrototypePoint] = recursiveRefinement(minX, maxX, minY, maxY, previousR2, groupName, groupNumbers, pm, accuracyMatrix)
    % Initialize the best R^2 and prototype point
    bestR2 = previousR2;
    bestPrototypePoint = [];

    % Generate the vertices for the current level
    gridSize = 20; % The number of points per dimension
    [Xgrid, Ygrid] = meshgrid(linspace(minX, maxX, gridSize), linspace(minY, maxY, gridSize));
    vertices = [Xgrid(:) Ygrid(:)];

    % Plot the stem plot at the start
    figure;
    hold on;
    title(sprintf('Stem plot for %s group', groupName));
    xlabel('MDS X');
    ylabel('MDS Y');
    zlabel('Probability');

    % Iterate over each vertex to find the best fit
    for vertexIdx = 1:size(vertices, 1)
        vertex = vertices(vertexIdx, :);
        distances = [];
        accuracies = [];
        counter = 1;

        % Calculate distances and accuracies for the current vertex
        for dataIndex = groupNumbers
            dataPoint = pm(dataIndex).point; % Assuming pm is an array of structs with field 'point'
            distance = norm(dataPoint - vertex);
            accuracy = accuracyMatrix(counter); % Assuming accuracyMatrix is indexed by groupNumbers

            % Append distances and accuracies
            distances(end+1) = distance;
            accuracies(end+1) = accuracy;
            counter = counter + 1;

            % Add the stems to the plot for each group number
            stem3(dataPoint(1), dataPoint(2), accuracy, 'filled');
        end

        % Fit the model to the data for this vertex
        [fitresult, gof] = fit(distances', accuracies', 'exp(-a*x)', 'StartPoint', 1);

        % If the R^2 is better, update the best R^2 and best prototype point
        if gof.rsquare > bestR2
            bestR2 = gof.rsquare;
            bestPrototypePoint = vertex;
            
            % Recursive call is inside the condition now
            [bestR2, bestPrototypePoint] = recursiveRefinement( vertex(1) - (maxX - minX) / (2*gridSize), vertex(1) + (maxX - minX) / (2*gridSize), vertex(2) - (maxY - minY) / (2*gridSize), vertex(2) + (maxY - minY) / (2*gridSize), bestR2,groupName, groupNumbers,pm, accuracyMatrix);
        end
    end

    % Finalize the stem plot with prototype point if it's the first call to the function
    if previousR2 == -Inf && ~isempty(bestPrototypePoint)
        % Add the prototype point to the plot
        plot3(bestPrototypePoint(1), bestPrototypePoint(2), bestR2, 'rp', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
    end

    hold off;

    % Only print the stopping message if recursion actually occurred
    if bestR2 == previousR2
        fprintf('No better R^2 found, stopping recursion.\n');
    else
        fprintf('Current best R^2: %f\n', bestR2);
    end
end


