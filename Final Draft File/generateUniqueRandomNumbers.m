% Function to generate unique random numbers
% Function to generate unique random numbers without overlap with another vector
function numbers = generateUniqueRandomNumbers(range, count, exclude)
    numbers = randi(range, 1, count);
    while numel(unique(numbers)) ~= count || any(ismember(numbers, exclude))
        numbers = randi(range, 1, count);
    end
end