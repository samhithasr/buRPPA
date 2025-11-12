function [imageNames, storedNumbers, sNint, imageArrayOArray, tumorNumbers] = fileProcess(tumorFiles, imageNames, patternNum, storedNumbers, sNint, imageArrayOArray, tumorNumbers)
  

for k = 1:length(tumorFiles)
        tumorBaseFileName = tumorFiles(k).name;
        disp(tumorBaseFileName);
        tumorFullFileName = fullfile(tumorFiles(k).folder, tumorBaseFileName);
        imageNames{k} = tumorFullFileName;
        pattern = sprintf('\\d{%d}', patternNum);
        match = regexp(tumorBaseFileName, pattern, 'match', 'once');
        
        
        if ~isempty(match)
            firstSixDigitNumber = str2double(match);
            if ~isKey(storedNumbers, firstSixDigitNumber)
                sNint = sNint + 1;
                storedNumbers(firstSixDigitNumber) = sNint;
                imageArrayOArray{sNint} = {tumorFullFileName};
                tumorNumbers = [tumorNumbers; sNint];
            else
                imageArrayOArray{storedNumbers(firstSixDigitNumber)} = [imageArrayOArray{storedNumbers(firstSixDigitNumber)}; tumorFullFileName];
            end
        else
            disp('No 3-digit number found in the file name.');
        end
    end
%Cycles through a file and performs all the necessary variable
%transformations to group the images patient by patient. 7/10/23

