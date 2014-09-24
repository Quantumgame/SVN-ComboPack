function PlotNS_IC_psth(varargin)
%Plot spikes to natural sound stimuli (speech, etc.)
%usage: PlotNS_IC(expdate, session, filename)
%
%PlotNS_IC_psth(expdate, session, filename, thresh, xlimits, ylimits, binwidth)
%taken from PlotNS_IC; edited by ira 04.15.14
dbstop if error

username=whoami;
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=7;
    xlimits=[]; %x limits for axis
    ylimits=[];
    binwidth=[];
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=[];
    ylimits=[];
    binwidth=[];
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=varargin{5};
    ylimits=[];
    binwidth=[];
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=varargin{5};
    ylimits=varargin{6};
    binwidth=[];
elseif nargin==7
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=varargin{5};
    ylimits=varargin{6};
    binwidth=varargin{7};
else
    error('wrong number of arguments'); % If you get any other number of arguments...
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% varargin defaults
if ~exist('nstd','var'); nstd=7; end
if isempty(nstd); nstd=7; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end
if ~exist('monitor','var'); monitor=0; end
if isempty(monitor); monitor=1; end

tic;
refract=15;
fs=12; %fontsize for figures
global pref
if isempty(pref); Prefs; end
username=pref.username;

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
try godatadir(expdate, session, filenum)
    load(outfilename);
catch
%     try godatadirbak(expdate, session, filenum)
%         load(outfilename);
%         
%     catch
        ProcessNS_IC_psth(expdate, session, filenum, nstd, xlimits, ylimits, binwidth)
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
thresh=out.thresh;
if isempty(xlimits)
xlimits=out.xlimits;
end
nstd=out.nstd;
dspikes=out.dspikes;
filteredtrace=out.filteredtrace;
isi=out.isi;

%find optimal axis limits
if ylimits==-1; ylimits=[0 .5]; end
for eindex=1:numepochs
    spiketimes=mM1(eindex, :).spiketimes;
    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
    [N,x]=hist(spiketimes,X);
    N=N./nreps(eindex); %normalize to spike rate averaged across trials
    N=1000*N./binwidth;
    ylimits(2)=max(ylimits(2), max(N));
end


%plot the mean of all reps
figure
hold on
p=0;
subplot1(numepochs, 1)
%add 10% ylim space for stimulus
ylimits(1)=ylimits(1)-.1*diff(ylimits);
for eindex=1:numepochs
    p=p+1;
    subplot1( p)
    spiketimes1=mM1(eindex, :).spiketimes;
    if xlimits(1)<0 %to align spikes with stimulus trace when xlimits(1)~=0 ira 06.04.14
        start=abs(xlimits(1));
        spiketimes1=spiketimes1+start;
    end
    if xlimits(1)>0
        start=xlimits(1);
        spiketimes1=spiketimes1-start;
    end
    X=xlimits(1):binwidth:xlimits(2);
    [N, x]=hist(spiketimes1, X);
    N=N./nreps(eindex);
    N=1000*N./binwidth;
    bar(x, N,1);
    
    stimtrace=squeeze(mM1stim(eindex,  :));
    stimtrace=stimtrace-mean(stimtrace(1:100));
    stimtrace=stimtrace./max(abs(stimtrace));
    stimtrace=stimtrace*.1*diff(ylimits);
    stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
    
    
    t=1:length(stimtrace);
    t=1000*t/samprate;
    plot(t, stimtrace, 'm');
    ylim(ylimits)
    xlim(xlimits)
    set(gca, 'fontsize', fs)
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
hold off



%plot all reps of high-rep stimuli
fig=figure;
hold on
offset=0;
start=100;
rep2=0;

% pulls useful information from cell list and adds it to the graph in a
% textbox; ira 09-23-2013
i=0;
j=0;
k=0;
try
    cells = cell_list_ira;
    for i=1:length(cells)
        if strcmp(cells(i).expdate, expdate)& strcmp(cells(i).session, session)
            expdate=cells(i).expdate;
            session=cells(i).session;
            filenum1=cells(i).filenum;
            for j=1:size(filenum1,1)
                depth= cells(i).depth;
                CF= cells(i).CF;
                A1= cells(i).A1;
                Stim00=cells(i).description;
                if strcmp(cells(i).filenum(j,:), filenum)== 1;
                    k=j;
                    StimUsed= char(Stim00(k));
                end
            end
        end
    end
    
    try
        infoTextBox={'depth=' depth 'CF (Hz)=' CF 'A1=' A1 'Stimulus=' StimUsed};
        annotation('textbox', [.8 .7 .1 .1], 'String',  infoTextBox, 'background', [1 1 1]);
    end
catch
    fprintf('Could not find this cell in the cell list');
end
dspikes=out.dspikes;
p=0;
%highrepper=mode(sequences(:)); %the most frequent set member
highrepper=1;
times_repeated=find(sequences(:)==highrepper);
times_repeated=length(times_repeated);
%subplot1(times_repeated+1, 1);
i=0;
for eindex=1:numepochs
    for rep=1:max(nreps)
        seq=sequences(eindex, rep,:);
        for sent=1:length(seq)
            if sent==1
                start=isi;
                stimtrace=squeeze(M1stim(eindex,rep,  :));
                stimtrace=stimtrace(-xlimits(1)*samprate*.001+1:end);
                stimtrace=stimtrace-mean(stimtrace(1:100));
                stimtrace=stimtrace./max(abs(stimtrace));
                
            end
            stop=start+3000;
            regionms=start:stop;
            startsamp=round(start*.001*samprate+1);
            stopsamp=round(stop*.001*samprate);
            
            if seq(sent)==highrepper
                p=p+5;
                i=i+1;
                offset=offset+5;
                stimseg=stimtrace(startsamp:stopsamp);
                %                 spiketimes1=dspikes(dspikes>startsamp &dspikes<stopsamp+1000);
                %                 spiketimes1=(spiketimes1)*1000/samprate; % ms
                spiketimes1=M1(eindex,rep).spiketimes;
                spiketimes1=spiketimes1(spiketimes1>start & spiketimes1<stop);
                spiketimes1=spiketimes1-start;
                spiketimes2(i).spiketimes=spiketimes1;
                %subplot1(p);
                ylimits1=ylimits(2)/4;
                try
                    h= plot(spiketimes1, ylimits1+p,'k.');
                catch
                    fprintf('\nno spikes on %d epoch, %d rep', eindex, rep);
                end
                t=1:length(stimseg);
                t=1000*t/samprate;
                plot(t, stimseg+offset,'m')
                rep2=rep2+1;
                M2stim(rep2,:)=stimseg;
                p=p+1;
                
            end
            start=stop+2*isi;
        end
    end
end

dbstop if error
X=xlimits(1):binwidth:3000;
[N, x]=hist(spiketimes2.spiketimes, X);
N=N./nreps(eindex);
N=1000*N./binwidth;

%xlim(xlimits(1), 3000);
ylimits(2)=ylimits(2)/2;
ylim(ylimits)
legend(p,'spikes');

out.highrepper=highrepper;

xlabel('time (ms)')
ylabel('spikes, all trials')
title(sprintf('%s-%s-%s one 3s sentence segment, %d reps', expdate,session, filenum, sum(squeeze(sequences(:)==highrepper))))
orient portrait

