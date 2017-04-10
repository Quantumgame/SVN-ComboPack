function PlotNS_IC(varargin)
%Plot membrane potential responses to natural sound stimuli (speech, etc.)
%usage: PlotNS_IC(expdate, session, filename)
%PlotNS_IC(expdate, session, filename, xlimits)
%PlotNS_IC(expdate, session, filename, xlimits, ylimits)

username=whoami;
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=[]; %x limits for axis
    ylimits=[];
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=[];
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
else
    error('wrong number of arguments'); % If you get any other number of arguments...
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
try godatadir(expdate, session, filenum)
    load(outfilename);
catch
%     try godatadirbak(expdate, session, filenum)
%         load(outfilename);
%         
%     catch
        ProcessNS_IC(expdate, session, filenum)
        godatadir(expdate, session, filenum)
        load(outfilename);
%     end
end


%extract variables from outfile
M1=out.M1; %matrix of Vm traces, trial-by-trial
mM1=out.mM1; %matrix of mean Vm traces across trials
dur=out.dur;
isi=out.isi;
nreps=out.nreps;
numepochs=out.numepochs;
mM1stim=out.mM1stim;
M1stim=out.M1stim;
samprate=out.samprate;
sequences=out.sequences;
scaledtrace=out.scaledtrace;
lostat=out.lostat;

%find optimal axis limits
if isempty(ylimits)
    ylimits=[0 0];
    for eindex=1:numepochs
        trace1=squeeze(mM1(eindex, :));
        trace1=trace1-mean(trace1(1:100));
        if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
        if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
    end
end
if isempty(xlimits)
    xlimits=out.xlimits;
end

%plot segments of raw data throughout recording for checking on cell
%quality and health edited by ira 09-25-2013

figure; hold on
if lostat~=length(scaledtrace);
L=lostat;
else 
     L=length(scaledtrace);
 end
t1=1:L;
t2=1:length(scaledtrace);
L1=length(scaledtrace);
winsize=1e4;
region=1:winsize;
scaledtracefixed=scaledtrace(t1);
if lostat~=length(scaledtrace);
for i=1:10*winsize:L1
    try region=i:i+winsize;
plot(t2(region)-.88*i, scaledtrace(region),'r')
plot(t1(region)-.88*i, scaledtracefixed(region),'b')
    end
end
else
    for i=1:10*winsize:L1
    try region=i:i+winsize;
    plot(t2(region)-.88*i, scaledtrace(region),'b')
    end
    end
end
if lostat~=length(scaledtrace);
legend('lost trace due to poor quality','remaining trace')
else
    legend('membrane potential trace')
end
title(sprintf('raw trace for %s-%s-%s (%.1fs segments throughout recording)',expdate,session, filenum, winsize/samprate))

%plot the mean Vm traces
figure
p=0;
subplot1(numepochs, 1)
%add 10% ylim space for stimulus
ylimits(1)=ylimits(1)-.1*diff(ylimits);
% for eindex=1:numepochs-1 %ira
for eindex=1:numepochs
    p=p+1;
    subplot1( p)
    trace1=squeeze(mM1(eindex, :));
    trace1=trace1-mean(trace1(1:100));
    stimtrace=squeeze(mM1stim(eindex,  :));
    stimtrace=stimtrace-mean(stimtrace(1:100));
    stimtrace=stimtrace./max(abs(stimtrace));
    stimtrace=stimtrace*.1*diff(ylimits);
    stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
    
    t=1:length(trace1);
    t=1000*t/samprate; %convert to ms
    t=t+out.xlimits(1);
    plot(t, trace1, 'b', t, stimtrace, 'm');
    ylim(ylimits)
    xlim(xlimits)
    axis off
end
set(gca, 'xticklabel', get(gca, 'xtick')/1000)
xlabel('time, s')

subplot1(1)
if length(unique(nreps))==1
    nrepsstr=sprintf('Mean of %d reps', unique(nreps));
else
    nrepsstr=sprintf('Mean of %d-%d  reps', min(nreps), max(nreps));
end
h=title(sprintf('%s-%s-%s %s', expdate,session, filenum, nrepsstr));
set(h, 'HorizontalAlignment', 'left')


%label epochs
p=0;
for eindex=1:numepochs
    p=p+1;
    subplot1(p)
    text(xlimits(1)-.1*diff(xlimits), mean(ylimits), sprintf('epoch%d', eindex))
end
subplot1(numepochs)
axis on
orient landscape

%plot all trials of Vm response
figure
p=0;
subplot1(numepochs, 1)
%add 10% ylim space for stimulus
ylimits(1)=ylimits(1)-.1*diff(ylimits);
offset=diff(ylimits);
%for eindex=1:numepochs-1 %ira
for eindex=1:numepochs
    p=p+1;
    stimtrace=squeeze(mM1stim(eindex,  :));
    stimtrace=stimtrace-mean(stimtrace(1:100));
    stimtrace=stimtrace./max(abs(stimtrace));
    stimtrace=stimtrace*.5*diff(ylimits);
    stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
    t=1:length(stimtrace);
    t=1000*t/samprate;
    t=t+out.xlimits(1);
    subplot1( p)
    hold on
    for rep=1:nreps(eindex)
        trace1=squeeze(M1(eindex, rep,:));
        trace1=trace1-mean(trace1(1:100));
        offset=rep*range(trace1);
        plot(t, trace1+offset, 'b')
    end
    
    plot( t, stimtrace, 'm');
    %    ylim(ylimits)
    xlim(xlimits)
    axis off
end

set(gca, 'xticklabel', get(gca, 'xtick')/1000)
xlabel('time, s')

subplot1(numepochs)
axis on

subplot1(1)
h=title(sprintf('%s-%s-%s all trials', expdate,session, filenum));
set(h, 'HorizontalAlignment', 'left')


%label epochs
p=0;
for eindex=1:numepochs
    p=p+1;
    subplot1(p)
    text(xlimits(1)-.1*diff(xlimits), mean(ylimits), sprintf('epoch%d', eindex))
end
orient landscape


%plot all reps of high-rep stimuli
fig=figure;
hold on
offset=0;
start=100;
rep2=0;

%pulls useful information from cell list and adds it to the graph in a
%textbox; ira 09-23-2013
% i=0;
% j=0;
% k=0;
% cells = cell_list_ira;
%     for i=1:length(cells)
%     if strcmp(cells(i).expdate, expdate)& strcmp(cells(i).session, session)
% expdate=cells(i).expdate;
% session=cells(i).session;
% filenum1=cells(i).filenum;
%         for j=1:size(filenum1,1)
%             depth= cells(i).depth;
%             CF= cells(i).CF;
%             A1= cells(i).A1;
%             Stim00=cells(i).description;
%         if strcmp(cells(i).filenum(j,:), filenum)== 1;
%             k=j;
%             StimUsed= char(Stim00(k));
%         end
%         end
%     end
% end
% 
% try
%     infoTextBox={'depth=' depth 'CF (Hz)=' CF 'A1=' A1 'Stimulus=' StimUsed};
%     annotation('textbox', [.8 .7 .1 .1], 'String',  infoTextBox, 'background', [1 1 1]);
% end

%highrepper=mode(sequences(:)); %the most frequent set member
highrepper=1;
for rep=1:max(nreps)
    for eindex=1:numepochs
        seq=sequences(eindex, rep,:);
        for sent=1:length(seq)
            if sent==1
                start=out.isi;
                stimtrace=squeeze(M1stim(eindex,rep,  :));
                stimtrace=stimtrace(-xlimits(1)*samprate*.001+1:end);
                stimtrace=stimtrace-mean(stimtrace(1:100));
                stimtrace=stimtrace./max(abs(stimtrace));

            end
            
            stop=start+3000;
            regionms=start:stop;
            startsamp=round(start*.001*samprate+1);
            stopsamp=round(stop*.001*samprate);
            %             fprintf('\n%d-%d', start, stop)
            %             fprintf('\t%d %d %d %d ', sent, seq(sent), eindex, rep)
            
             
            start=stop+2*out.isi;
            if seq(sent)==highrepper
                offset=offset+3;
                stimseg=stimtrace(startsamp:stopsamp+1000);
                trace1=squeeze(M1(eindex, rep,startsamp:stopsamp+1000));
                trace1=trace1-mean(trace1(1:100));
                t=1:length(trace1);
                t=1000*t/samprate;
                plot(t, trace1+offset+2,'b',t, stimseg+offset,'m') 
                rep2=rep2+1;
                M2(rep2,:)=trace1;
                M2stim(rep2,:)=stimseg;
            end
        end
    end
end
p=plot(t, stimseg-.1*diff(ylimits), 'm',t, trace1+offset+2,'b', t, squeeze(mean(M2)), 'r', 'linewidth', 2);

legend(p,'stimulus trace','membrane potentials', 'mean of all repetitions'); 

out.M2=M2;
out.M2stim=M2stim;
outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum)
save (outfilename, 'out')
xlabel('time (ms)')
ylabel('voltage ( \muV), all trials')
title(sprintf('%s-%s-%s one 3s sentence segment, %d reps', expdate,session, filenum, sum(squeeze(sequences(:)==highrepper))))
orient portrait

