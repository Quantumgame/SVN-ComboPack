function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT=LUTparams.compiledLUT;

nAFCindex = find(strcmp(LUTparams.compiledLUT,'nAFC'));
if isempty(nAFCindex) || (~isempty(nAFCindex) && ~all([basicRecords.trialManagerClass]==nAFCindex))
    warning('only works for nAFC trial manager')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];
        [out.correctionTrial newLUT] = extractFieldAndEnsure(stimDetails,{'correctionTrial'},'scalar',newLUT);
        %[out.pctCorrectionTrials newLUT] = extractFieldAndEnsure(stimDetails,{'pctCorrectionTrials'},'scalar',newLUT);
        
        [out.amp newLUT] = extractFieldAndEnsure(stimDetails,{'amplitude'},'scalar',newLUT);
        [out.toneFreq newLUT] = extractFieldAndEnsure(stimDetails,{'toneFreq'},'equalLengthVects',newLUT);
        [out.responseTime newLUT] = extractFieldAndEnsure(stimDetails,{'responseTime'},'scalar',newLUT);
        [out.soundONTime newLUT] = extractFieldAndEnsure(stimDetails,{'soundONTime'},'scalar',newLUT);
        % 12/16/08 - this stuff might be common to many stims
        % should correctionTrial be here in compiledDetails (whereas it was originally in compiledTrialRecords)
        % or should extractBasicRecs be allowed to access stimDetails to get correctionTrial?
        
    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return
    end

end
%verifyAllFieldsNCols(out,length(trialRecords));
end