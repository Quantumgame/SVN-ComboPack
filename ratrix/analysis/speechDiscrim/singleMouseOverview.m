function singleMouseOverview(mouseid)
%Plot the overview of a single mouse. Input mouseid as string, mapping
%function below will find the file. Assumes nesting function has already CD
%to the compiledTrialDetails location

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

