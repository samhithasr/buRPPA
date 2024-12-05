function result = changeDimension(dimensionX, meningiomaFolder, fileName, value)
     [filePath, ~, ~] = fileparts(fileName);
     if strcmp(filePath, meningiomaFolder)
        dimensionX = dimensionX + value;
     end  
     result = dimensionX;
end

% Custom function to yield the desired size of control images which for
% some reason are being processed as larger than meningioma and glioma. In
% this code the number 60 is arbitrary and guessed based off of what I see.
% In the future look to parameterize it. 