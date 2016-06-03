function [phoVects] = phoVectToScalar(phoMat,names,map)
%Need to be able to match toneFreq vector representation of phoneme
%recordings to the scalar list that phoMats and similarity matrices use. 
%
%Arguments:
%phoMat - a phoMat made with makeSpeechStruct
%names, map - the names and map used in calcStim to present phonemes

%Fill in phoVects line by line
phoVects = zeros(length(phoMat),4);
for i = 1:length(phoMat)
    phoChar = char(sstx(i).phoneme);
    
    if strmatch(phoChar(1),'g')
        phoVects(i,1) = 1;
    elseif strmatch(phoChar(1),'b')
        phoVects(i,1) = 2;
    end
    
    
    
end