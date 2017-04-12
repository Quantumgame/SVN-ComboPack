function CheckPerformanceSpeech_Silent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Makes 3 plots, windowed pct correct on the left, bias/stim specific
%responses in the middle, and daily averages on the right.
%
%you'll need to manually mount ratrix computers and have 'scrollsubplot'
%somewhere in the matlab path. You can download it here:
%http://www.mathworks.com/matlabcentral/fileexchange/7730-scrollsubplot
%
%JLS-031116:
%Since Matlab doesn't let lines have transparency (whatever), correction
%trial transparency is done with Patchline:
%http://www.mathworks.com/matlabcentral/fileexchange/36953-patchline/content/patchline.m
%
%JLS-042016:
%Added level-up markers
%
%Color scheme to implement 3.4.16
%{
-Black for % correct control
-Cyan for % correct laser
-Grey for bias
-Blue/Red for left/right
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ff = figure;
p=1;
%DJ NooMice
%Grouping by date started, not rig #
if ispc
    cd('C:\Users\lab\Documents\speechData')
else
    cd('~/Documents/speechData')
end
% name='6900';
% go(name,p)
% name='6924';p=p+3;
% go(name,p)
% name='6960';p=p+3;
% go(name,p)
% %Third batch o fresh meat
% name='6964';p=p+3;
% go(name,p)
% name='6965';p=p+3;
% go(name,p) 
% name='6966';p=p+3;
% go(name,p)
% name='6967';p=p+3;
% go(name,p)
name='7007';
go(name,p)
name='7012';p=p+3;
go(name,p)
name='7058';p=p+3;
go(name,p)
name='7105';p=p+3;
go(name,p)
name='7116';p=p+3;
go(name,p)
name='7118';p=p+3;
go(name,p)
name='7120';p=p+3;
go(name,p)
name='7244';p=p+3;
go(name,p)
name='7251';p=p+3;
go(name,p)
name='7265';p=p+3;
go(name,p)
name='7281';p=p+3;
go(name,p)
name='7285';p=p+3;
go(name,p)
name='7320';p=p+3;
go(name,p)
name='7328';p=p+3;
go(name,p)
name='7330';p=p+3;
go(name,p)
name='7334';p=p+3;
go(name,p)
name='7428';p=p+3;
go(name,p)
name='7473';p=p+3;
go(name,p)
name='7475';p=p+3;
go(name,p)
name='7324';p=p+3;
go(name,p)
name='7610';p=p+3;
go(name,p)
name='7570';p=p+3;
go(name,p)
name='7477';p=p+3;
go(name,p)
name='7568';p=p+3;
go(name,p)
name='7639';p=p+3;
go(name,p)
name='7321';p=p+3;
go(name,p)
name='7268';p=p+3;
go(name,p)


if ispc
    save_fig = strcat('C:\Users\lab\Documents\speechPlots\speech_performance_',datestr(now,'mmddyy_hhMM'),'.fig');
else
    save_fig = strcat('~/Documents/speechPlots/speech_performance_',datestr(now,'mmddyy_hhMM'),'.fig');
end
fprintf(1,'Saving Figure... \n');
savefig(ff,save_fig);
close(ff);
function go(name,p)
if p == 1
    mousenum = 1;
else
    mousenum = (p+2)/3;
end
fprintf(1,'Processing Mouse %d \n',mousenum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%How many days back you want?
ndays = 10;
% wantDate = addtodate(datenum(now),-ndays,'day');

%Geddat dat data
csvfile = [name,'.csv'];
csvimport = csvread(csvfile,1);

uqdates = unique(round(csvimport(:,2)));
try
    wantDate = uqdates(end-ndays+1);
catch
    wantDate = uqdates(1);
end
start = find(csvimport(:,2)>=wantDate,1);
    
    

%Extract to variables
freq = csvimport(start:end,5);
cons = csvimport(start:end,7);
correct = csvimport(start:end,13);
response = csvimport(start:end,11);
step=csvimport(start:end,4);
session=csvimport(start:end,3);
dates = csvimport(start:end,2);
steps = csvimport(start:end,4);
targets = csvimport(start:end,12);


nansI = find(isnan(correct));
correct(nansI) = []; %need to do this due to interruptions from erroring
freq(nansI)= [];
cons(nansI) = [];%and nans are annoying
response(nansI)= [];
step(nansI)= [];
session(nansI)=[];
dates(nansI)=[];
targets(nansI)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 1: pct correct
z = scrollsubplot(7,3,p);
hold on

if length(correct) == 0
    return
elseif length(correct) > 75
    winSize = 75; %%%size of window for %correct averaging
else
    winSize = length(correct);
end
    
    
if p==1 title(['winSize=', int2str(winSize)]);end

%Get sliding window average of correct trials
last = length(correct);
win50=[];
for i = winSize:last
    win50(i)=(sum(correct(i+1-winSize:i)))/winSize;
end

%the binofit provides confidence limits, but is slow
%Took binofit out of winSize loop b/c can just feed in win50 as vector
%-JLS031116
%[~, winconf(i, :)]=binofit(sum(correct(i+1-winSize:i)), winSize); %keeping
%this around in case I fuck up
winconf = [];
winSizeVec = [];
winSizeVec(1:length(win50)) = winSize;
[~,winconf]=binofit(ceil(win50.*winSize), winSizeVec,.05);

win50(isnan(win50))=[]; %last 9 values are nans because there aren't enough trials

%Plot windowed correct avg.
plot(1:length(win50),win50)
xlim([1 length(win50)])
confplot=plot(winconf, ':');
set(confplot, 'color', [.7 .7 .7])
line(xlim, [.5 .5])
line(xlim, [.75 .75], 'linestyle',':', 'color',[0,0,.7])
line(xlim, [.25 .25], 'linestyle',':', 'color',[0,0,.7])
ylabel(sprintf('%s', name))

%Crawl around to get those steps
i = 1; %We'll end the function within the function, we don't know how many times the step changes exactly (unique don't tell u that), but we'll know when we're at the end.
nextstep = 1;
%stepchanges = [1, istep]; %will be our mat (positions in "steps",step #s) that are the first of a changed step
while i ~= 0 %but lol really we just need to call break
    h = line([nextstep,nextstep],[0,1]);
    text(nextstep,.9,num2str(step(nextstep)));
    set(h, 'color', [1 0 0]);
    nextstep = nextstep+find((step(nextstep+1:end) ~= step(nextstep)),1);
    
    if isempty(nextstep) % will be empty if there aren't any more step changes
        break
    end
end 


%Make date divider
sessionNum=[];
sss=unique(session);

for i=sss(1):sss(end)
    try
        sessionNum(i)=find(session==i, 1);
    catch
        sprintf('Missing session %d for %s',i,name);
        continue
    end
    sessionDate=datestr(dates(sessionNum(i)),6);
    h=line([sessionNum(i) sessionNum(i)], [0 1]);
    text(sessionNum(i),.1, sprintf('%s', sessionDate));
    set(h, 'LineStyle', ':' )
    set(h, 'color', [.8 .8 .8] )
end


hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 2: Bias/Stim specific responses
plotnum = p+1;
z2 = scrollsubplot(7,3,plotnum);
hold on

if p==1 title('r = % right correct, b = % left correct, g = % response l/r');end

%response1 = find(response == 1);
response(response==1)=0;
%response3 = find(response == 3);
response(response==3)=1;

targets(targets==1)=0;
targets(targets==3)=1;

bCorrect = [];
gCorrect = [];
%Split phonemes

allb=find((cons == 1) | (freq == 4000));
allg=find((cons == 2) | (freq == 13000));

%Get corrects
bCorrect = correct(allb);
gCorrect = correct(allg);
%Get responses

%Need to remove nans again b/c had to re-extract to preserve position in
%original struct
%nansI= find(isnan(bCorrect));
%bCorrect(nansI)=[];
%nansI= find(isnan(gCorrect));
%gCorrect(nansI)=[];

%Windowed average of b/g corrects
bwin50=[];
gwin50=[];
resp50=[];
if winSize<min(length(bCorrect),length(gCorrect))
    for i = winSize:length(bCorrect)
    bwin50(i)=(sum(bCorrect(i+1-winSize:i)))/winSize;
    end
    for i = winSize:length(gCorrect)
    gwin50(i)=(sum(gCorrect(i+1-winSize:i)))/winSize;
    end
    for i = winSize:length(response)
    resp50(i)=(sum(response(i+1-winSize:i)))/winSize;
    end
    for i = winSize:length(targets)
    targ50(i)=(sum(targets(i+1-winSize:i)))/winSize;
    end
else
    bwin50(1:length(bCorrect)) = mean(bCorrect);
    gwin50(1:length(gCorrect)) = mean(gCorrect);
    resp50(1:length(response)) = mean(response);
    targ50(1:length(targets)) = mean(targets);
end


    

%Plot windowed averages
bp = plot(allb,bwin50);
set(bp,'color',[0 0 1]);
gp = plot(allg,gwin50);
set(gp,'color',[1 0 0]);
rp = plot(1:length(resp50),resp50);
set(rp,'color',[0 1 0]);
tg = plot(1:length(targ50),targ50);
set(tg,'color',[.3 .3 .3]);
ylabel(sprintf('%s', name))
xlim([1 length(response)])
line(xlim, [.5 .5])
line(xlim, [.75 .75], 'linestyle',':', 'color',[0,0,.7])
line(xlim, [.25 .25], 'linestyle',':', 'color',[0,0,.7])


%Shade correction trials, takes a shitload of time so if you're in a
%hurry/can think of a better way.....
%{
if length(response)>3000
    for i = winSize:last
        if correctionTrials(i)==1
            patchline([i i], [0 1],'edgecolor','r','edgealpha',0.02);
        end
    end
else
    for i = winSize:last
        if correctionTrials(i)==1
            patchline([i i], [0 1],'edgecolor','r','edgealpha',0.1);
        end
    end
end
%}
    

%Make date lines again
sessionNum=[];
sss=unique(session);
for  i=sss(1):sss(end) 
    try
        sessionNum(i)=find(session==i, 1);
    catch
        sprintf('Missing session %d for %s',i,name);
        continue
    end
    sessionDate=datestr(dates(sessionNum(i)),6);
    h=line([sessionNum(i) sessionNum(i)], [0 1]);
    text(sessionNum(i),.1, sprintf('%s', sessionDate));
    set(h, 'LineStyle', ':' )
    set(h, 'color', [.8 .8 .8] )
end


hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 3: Full day averages
plotnum = p+2;
z3 = scrollsubplot(7,3,plotnum);
hold on



%Since we pretend like any sessions prior to the ones we want never
%happened, make a vector with the first session = 1


%Get session means
sessionMeans = [];
sessionSums = [];
sessionNumTrials = [];
plotdates = [];
seshcount = 1;
for  i=1:length(sss)
    sessionNum=[];
    sessionScores=[];
    sessionNum=find(session==sss(i));
    sessionScores=correct(sessionNum);
    sessionMeans(seshcount)=mean(sessionScores);
    sessionSums(seshcount)=sum(sessionScores);
    sessionNumTrials(seshcount)=length(sessionScores); %Get these for the binofit
    sessionDate(seshcount,:)=datestr(dates(sessionNum(1)),6);
    seshcount = seshcount+1;
end


%Because session changes are triggered during code troubleshooting, take out 0 means. 
%The mice aren't /that/ dumb. 
sessionNegs = find(sessionMeans == 0 | sessionNumTrials<50); %grab this for date plot later on
sessionMeans(sessionNegs) = [];
sessionSums(sessionNegs) = [];
sessionNumTrials(sessionNegs) =[];

%Get the binofit
[~,sessionError]=binofit(sessionSums, sessionNumTrials,.05);

%Plotting
plot(sessionMeans)
confplot=plot(sessionError, ':');
if max(sessionMeans) < .6
    ylim([.25 .75])
    textht = .3;
else
    ylim([0 1])
    textht = .15;
end

if length(sessionMeans) > 1
    xlim([1 length(sessionMeans)])
end

ylabel(sprintf('%s', name))
line(xlim, [.5 .5], 'Color','r')
line(xlim, [.75 .75], 'linestyle',':')
line(xlim, [.25 .25], 'linestyle',':')

%Date dividers
for i = 1:size(sessionDate,1)
    text(i,textht, sprintf('%s', sessionDate(i,:)));
end

%Label shit good god
%These damn kids run multiple trials in a day and expect me just to clean
%it up.
%{
dates = unique(dates);
if length(dates) ~= length(sessionMeans)
    dates = [];
    j = 1;
    hold on
    for i = unique(session);
        seshts = find(compiledTrialRecords.sessionNumber == i);
        dates =  unique(datestr(compiledTrialRecords.date(seshts),6),'rows');
        if ~ismember(i,sessionNegs) %Again, don't plot dates where we've removed a session
            text(j,textht, sprintf('%s', dates))
            j = j+1;
        end
    end
    hold off
else
    dates = unique(datestr(compiledTrialRecords.date(start:end),6),'rows');
    hold on
    for i = 1:length(dates)
%        text(i,textht, sprintf('%s', dates(i,:)))
    end
    hold off
end
%}
%Print last session mean
text(length(sessionMeans)-.5,sessionMeans(end)+.1,sprintf('%.2f',sessionMeans(end)))
hold off







