function [targetPorts, distractorPorts, details, text] = assignPorts(trialManager,trialRecords,responsePorts)
lastResult = [];
lastCorrect = [];
lastWasCorrection = false;
tooBiased = 0;

if ~isempty(trialRecords) && length(trialRecords)>1
    lastRec=trialRecords(end-1);
    
    try % may not have result field
        lastResult = find(lastRec.result);
    end
    try % may not have trialDetails.correct field
        lastCorrect = lastRec.trialDetails.correct;        
    catch
        try % may not have correct field
            lastCorrect = lastRec.correct; %who normally sets this?  i can only find runRealTimeLoop.313 where it is inited to []
        end
    end
    
    try % may not have correctionTrial field
        lastWasCorrection = lastRec.stimDetails.correctionTrial;
        if lastWasCorrection == 2 %Bias control are labeled w/ a 2.
            lastWasCorrection = 0;
        end
    end
    
    try % check for bias
        numtrials = length(trialRecords);
        lefts = [];
        rights = [];
        j = 1;
        if numtrials>52
            for i = numtrials-51:numtrials-1
                lefts(j) = trialRecords(i).phaseRecords(2).responseDetails.tries{1}(1);
                rights(j) = trialRecords(i).phaseRecords(2).responseDetails.tries{1}(3);
                j = j+1;
            end
            leftpct = mean(lefts);
            rightpct = mean(rights);
            biaspct = leftpct-rightpct;
            if biaspct < (-.3)
                tooBiased = 1;
                unBiasedPort = 1;
                biasedPort = 3;
            elseif biaspct > (.3)
                tooBiased = 1;
                unBiasedPort = 3;
                biasedPort = 1;
            else
                tooBiased = 0;
            end
        end

    end
            
        
    
    if length(lastResult)>1
        lastResult = lastResult(1);
    end
    
end

if ~isempty(lastCorrect) && ...
        ~isempty(lastResult) && ...
        ~lastCorrect && ...
        (length(lastRec.targetPorts)==1 || strcmp(trialRecords(end).trialManagerClass,'ball')) && ... %ugh!
        (lastWasCorrection || rand<trialManager.percentCorrectionTrials)
    
    details.correctionTrial = 1;
    try
    details.startTone=lastRec.stimDetails.startTone;
    details.endTone=lastRec.stimDetails.endTone;
    end

    targetPorts = lastRec.targetPorts;
    text = 'Regular correction trial!';  
elseif tooBiased
    details.correctionTrial = 2;
    if rand<(abs(biaspct)+.5)
        targetPorts = unBiasedPort;
        text = 'Bias correction trial!';
    else
        targetPorts = biasedPort;
        text = 'Reverse Bias correction trial!';
    end
else
    details.correctionTrial = 0;
    targetPorts = responsePorts(ceil(rand*length(responsePorts)));
    text = '';
end

distractorPorts = setdiff(responsePorts,targetPorts);
end