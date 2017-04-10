function allMousePlot
%Plot all mouse daily success rate 


cd('/Users/Jonny/Dropbox/Lab Self/inFormants/Behavior Data/');
d=dir(sprintf('%s*',mouseid));
load(d.name)

%some mice ran phonemediscrim first, then speechdiscrim second
%filter irrelevant data -JLS030316
if length(compiledDetails)>1
    if strcmp(compiledDetails(1).className,'speechDiscrim')
        compiledDetails = compiledDetails(1);
    elseif strcmp(compiledDetails(2).className,'speechDiscrim')
        compiledDetails=compiledDetails(2);
    end
    start = length(compiledTrialRecords.trialNumber)-length(compiledDetails.trialNums)+1;
    wasFucked = 1;
else
    if ~isempty(compiledDetails.bailedTrialNums)
        start = max(compiledDetails.bailedTrialNums)+1;
    else
        start = 1;
    end
    wasFucked = 0;
end
last = length(compiledDetails.records.toneFreq);

if ~strmatch(compiledDetails.className, 'speechDiscrim')
error('not speech discrim data')
end

%Extract to variables
toneFreq = compiledDetails.records.toneFreq(1,:); %toneFreq in SpeechDiscrim is a vector w/ 4 values, first is consonant
correctionTrials = compiledDetails.records.correctionTrial(:);
correct = compiledTrialRecords.correct(start:end);
response = compiledTrialRecords.response(start:end);
step=compiledTrialRecords.step(start:end);
session=compiledTrialRecords.sessionNumber(start:end);
dates = compiledTrialRecords.date(start:end);
steps = compiledTrialRecords.step(start:end);
targets = compiledTrialRecords.targetPorts(start:end);

%Take out toneFreqs w/ unfinished trials
%This is a dumb way to do this. ok for nDays but will get seriously off if
%used for an all data plot
if length(toneFreq) > length(correct)
    toneFreq = toneFreq((length(toneFreq)-length(correct)+1):end);
end


