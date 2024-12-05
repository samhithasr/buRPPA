function output = checkComboNumbers(imageNumber,wVector)
    if ismember(imageNumber, wVector)
        output = 13;
    else
        output = 12;
    end

