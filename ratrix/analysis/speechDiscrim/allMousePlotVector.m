function sm = allMousePlotVector
%Get vector of session means adjusted by training step and write to a csv
%so can be plotted in another program

cd \\WEHR-RATRIX3\Users\nlab\Desktop\laserData\CompiledTrialRecords
p=0;
sm = cell(2);
name='6901';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='rt.100';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX4\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='lt.100';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
%DJ NooMice
%Grouping by date started, not rig #
cd \\WEHR-RATRIX3\Users\nlab\Desktop\laserData\CompiledTrialRecords 
name='6924';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='6927';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX4\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6925';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='6928';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX5\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6926';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
%Third batch o fresh meat
cd \\WEHR-RATRIX1\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6896';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX2\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6897';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX3\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6898';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX4\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6899';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX5\Users\nlab\Desktop\laserData\CompiledTrialRecords 
name='6900';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='6960';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='6961';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX1\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6962';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX2\Users\nlab\Desktop\laserData\CompiledTrialRecords 
name='6963';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX4\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6975';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='6977';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX3\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6979';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
cd \\WEHR-RATRIX5\Users\nlab\Desktop\laserData\CompiledTrialRecords 
name='6982';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='6983';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
name='6984';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
try
cd \\WEHR-RATRIX3\Users\nlab\Desktop\laserData\CompiledTrialRecords 
name='6964';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
end
try
cd \\WEHR-RATRIX4\Users\nlab\Desktop\laserData\CompiledTrialRecords
name='6965';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
end
try
cd \\WEHR-RATRIX5\Users\nlab\Desktop\laserData\CompiledTrialRecords 
name='6966';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
end
try
name='6967';p=p+1;
smt = go(name);
sm(1,p) = {name};
sm(2:length(smt)+1,p) = mat2cell(smt',ones(length(smt),1));
end

%Save to a CSV
dname = uigetdir;
filename = strcat(dname,'/sessionMeans.csv');
fid = fopen(filename,'w');
fprintf(fid, '%s,', sm{1,1:end-1});
fprintf(fid, '%s\n', sm{1,end});
fclose(fid);

dlmwrite(filename,sm(2:end,:), '-append');


function [sessionMeans] = go(mouseid)
%Returns a vector of the allMousePlot to use with another plotting program
%like ggPlot
%Plot all mouse daily success rate 

% Load and Clean Data
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

%Remove Nans
nansI = find(isnan(correct));
correct(nansI) = []; %need to do this due to interruptions from erroring
toneFreq(nansI)= []; %and nans are annoying
response(nansI)= [];
step(nansI)= [];
session(nansI)=[];
correctionTrials(nansI)=[];
dates(nansI)=[];
targets(nansI)=[];

% Make Plot Data
% We assume the figure was set in the nesting function, and add to it.

%Get session means
sessionMeans = [];
sessionSums = [];
sessionNumTrials = [];
sessionSteps = [];
plotdates = [];
seshcount = 1;
sss=unique(session);
for i=sss
    sessionNum=[];
    sessionScores=[];
    sessionNum=find(session==i);
    sessionScores=correct(sessionNum);
    sessionStepTemp=step(sessionNum);
    sessionMeans(seshcount)=mean(sessionScores);
    sessionSums(seshcount)=sum(sessionScores);
    sessionNumTrials(seshcount)=length(sessionScores); %Get these for the binofit
    sessionDate(seshcount,:)=datestr(dates(sessionNum(1)),6);
    sessionSteps(seshcount) = round(mean(sessionStepTemp));
    seshcount = seshcount+1;
end

%Because session changes are triggered during code troubleshooting, take out 0 means. 
%The mice aren't /that/ dumb. 
sessionNegs = find(sessionMeans == 0 | sessionNumTrials<50); %grab this for date plot later on
sessionMeans(sessionNegs) = [];
sessionSums(sessionNegs) = [];
sessionNumTrials(sessionNegs) =[];
sessionSteps(sessionNegs) = [];

%Get the binofit
%[~,sessionError]=binofit(sessionSums, sessionNumTrials,.05);

%Adjust Means by Step Number
for i = 1:length(sessionMeans)
    switch sessionSteps(i)
        case {1,2}
            sessionMeans(i) = 0;
        case {3}
            %First level we want data from, leave it at 0-1
        case {4}
            sessionMeans(i) = sessionMeans(i)+1;
        case {5,6}
            sessionMeans(i) = sessionMeans(i)+2;
        case {7,8}
            sessionMeans(i) = sessionMeans(i)+3;
        case {9,10}
            sessionMeans(i) = sessionMeans(i)+4;
        case {11,12}
            sessionMeans(i) = sessionMeans(i)+5;
        case {13}
            sessionMeans(i) = sessionMeans(i)+6;
        otherwise
            sessionMeans(i) = [];
    end
end


end
end
