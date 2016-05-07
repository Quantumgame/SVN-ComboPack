function t=decache(t)
    t.trialManager=decache(t.trialManager);
    if strmatch(class(t.stimManager),'struct')
        if strmatch('correctStim',fieldnames(t.stimManager))
            s.correctStim=[];
        end
    else
        t.stimManager=decache(t.stimManager);
    end
    