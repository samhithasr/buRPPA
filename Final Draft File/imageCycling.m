function [x, xCycle, lastInputTime] = imageCycling(rect, timeDelay, mouseX, mouseY, xCycle,x, length, elapsedTime, currentTime)
    if elapsedTime >= timeDelay && mouseX >= rect(1) && mouseX <= rect(3) && mouseY >= rect(2) && mouseY <= rect(4)
                    if mod(xCycle, 2) == 0 && x < length
                        x = x + 1;
                        lastInputTime = currentTime;
                    elseif mod(xCycle, 2) == 1 && x > 1
                        x = x - 1;
                        lastInputTime = currentTime;
                    else
                        xCycle = xCycle + 1;
                    end
    end