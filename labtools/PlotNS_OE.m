function  PlotNS_OE(expdate, session, filenum, channel, varargin )
%This is a plotting function for SPNoise stimuli recorded with an Open
%Ephys system.
%usage: PlotNS_OE(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth])
% (xlimits, ylimits, binwidth are optional)
%
% spiketimes are in ms, stimulus trace is extracted from exper with an
% assumption that sampling rate remains 10e3.
%
% ira 07.15.14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sorter='MClust'; %can be either 'MClust' or 'simpleclust', this is also in ProcessNS_OE
%sorter='simpleclust';
dbstop if error
if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-1000 dur+1000]; %x limits for axis
    binwidth=5;
    promt=('please enter tetrode number: ');
    channel=input(promt,'s')
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
elseif nargin==4
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-1000 dur+1000]; %x limits for axis
    binwidth=5;
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-1000 dur+1000]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=-1;
    binwidth=5;
elseif nargin==6
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-1000 dur+1000]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=5;
elseif nargin==7
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-1000 dur+1000]; %x limits for axis
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    binwidth=varargin{3};
    if isempty(binwidth)
        binwidth=5;
    end
else
    error('Wrong number of arguments.');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gogetdata(expdate, session, filenum)
outfilename=sprintf('outNSOE%s_%s-%s-%s.mat', channel, expdate, session, filenum);
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
fprintf('\nload file: ')
godatadir(expdate,session,filenum);
try
    load(OEeventsfile);
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try
%     gorawdatadir(expdate, session, filenum)
%     expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filenum);
%     expstructurename=sprintf('exper_%s', filenum);
%     if exist(expfilename)==2 %try current directory
%         load(expfilename)
%         exp=eval(expstructurename);
%         isrecording=exp.openephyslinker.param.isrecording.value;
%         oepathname=exp.openephyslinker.param.oepathname.value;
%         cd(oepathname)
%         OEdatafile=sprintf('ch%s_simpleclust.mat', channel);
%         load(OEdatafile)
%     else %try data directory
%         cd ../../..
%         try
%             cd(sprintf('Data-%s-backup',user))
%             cd(sprintf('%s-%s',expdate,user))
%             cd(sprintf('%s-%s-%s',expdate,user, session))
%         end
%         if exist(expfilename)==2
%             load(expfilename)
%             exp=eval(expstructurename);
%             isrecording=exp.openephyslinker.param.isrecording.value;
%             oepathname=exp.openephyslinker.param.oepathname.value;
%             cd(oepathname);
%             OEdatafile=spintf('ch%s_simpleclust.mat', channel);
%             load(OEdatafile);
%         else
%             fprintf('\ncould not find exper structure. Cannot get OE file info.')
%         end
%     end
% catch
%     cd('C:\Program Files\Open Ephys')
%     [OEdatafile, oepathname] = uigetfile('*simpleclust.mat', 'pick a simpleclust.mat file');
%     if isequal(OEdatafile,0) || isequal(oepathname,0)
%         return;
%     else
%         cd(oepathname)
%     end
%     try
%         E=load(OEeventsfile);
%     catch
%         OEgetEvents(expdate, session, filenum);
%         E=load(OEeventsfile);
%     end
%
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find OE data directory
% try
%     oepathname=getOEdatapath(expdate, session, filenum);
%     cd(oepathname);
% catch
%     cd('C:\Program Files\Open Ephys')
%     switch sorter
%         case 'MClust'
%             [OEdatafile, oepathname] = uigetfile('*.t', 'pick an MClust output file (*.t)');
%             if isequal(OEdatafile,0) || isequal(oepathname,0)
%                 return;
%             else
%                 cd(oepathname)
%             end
%         case 'simpleclust'
%             [OEdatafile, oepathname] = uigetfile('*simpleclust.mat', 'pick a simpleclust.mat file');
%     end
% end
%
% first_sample_timestamp=OEget_first_sample_timestamp(oepathname); %in s

outfilename=sprintf('outNSOE%s_%s-%s-%s', channel, expdate, session, filenum);
try godatadir(expdate, session, filenum)
    load(outfilename);
catch
    ProcessNS_OE(expdate, session, filenum, channel, xlimits, ylimits, binwidth)
    godatadir(expdate, session, filenum)
    load(outfilename);
end
%extract variables from outfile
M1=out.M1; %matrix, trial-by-trial
mM1=out.mM1; %matrix of mean across trials
dur=out.dur;
isi=out.isi;
nreps=out.nreps;
numepochs=out.numepochs;
mM1stim=out.mM1stim;
M1stim=out.M1stim;
samprate=out.samprate;
sequences=out.sequences;
epochfilenames=out.epochfilenames;
numepochs=out.numepochs;
sequences=out.sequences;
dur=out.dur;
isi=out.isi;
if isempty(xlimits)
    xlimits=out.xlimits;
end
Nclusters=out.Nclusters;
datafile=out.datafile;
eventsfile=out.eventsfile;
stimfile=out.stimfile;
event=out.event; %event data file from open ephys
event1=out.event1; %event datafile from exper
try
    isrecording=out.isrecording;
end
try
    oepathname=out.oepathname;
end


%find optimal axis limits
if ylimits==-1; ylimits=[0 .5]; end
for clust=1:Nclusters
    for eindex=1:numepochs
        spiketimes=mM1(clust,eindex, :).spiketimes;
        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
        [N,x]=hist(spiketimes,X);
        N=N./nreps(eindex); %normalize to spike rate averaged across trials
        N=1000*N./binwidth;
        ylimits(2)=max(ylimits(2), max(N));
    end
end

fs=12;
%plot the mean of all reps
for clust=1:Nclusters
    figure
    hold on
    p=0;
    subplot1(numepochs, 1)
    %add 10% ylim space for stimulus
    ylimits(1)=ylimits(1)-.1*diff(ylimits);
    for eindex=1:numepochs
        p=p+1;
        subplot1( p)
        spiketimes1=mM1(clust,eindex).spiketimes; %in ms
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
        
        stimtrace=squeeze(mM1stim(clust, eindex,  :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits);
        stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
        
        
        t=1:length(stimtrace);
        t=1000*t/10e3; %sampling rate hard coded from exper
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
    h=title(sprintf('%s-%s-%s %s Cell # %d', expdate,session, filenum, nrepsstr, clust));
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
end %clust


%plot all reps of high-rep stimuli


% pulls useful information from cell list and adds it to the graph in a
% textbox; ira 09-23-2013
% i=0;
% j=0;
% k=0;
% try
%     cells = cell_list_ira;
%     for i=1:length(cells)
%         if strcmp(cells(i).expdate, expdate)& strcmp(cells(i).session, session)
%             expdate=cells(i).expdate;
%             session=cells(i).session;
%             filenum1=cells(i).filenum;
%             for j=1:size(filenum1,1)
%                 depth= cells(i).depth;
%                 CF= cells(i).CF;
%                 A1= cells(i).A1;
%                 Stim00=cells(i).description;
%                 if strcmp(cells(i).filenum(j,:), filenum)== 1;
%                     k=j;
%                     StimUsed= char(Stim00(k));
%                 end
%             end
%         end
%     end
%
%     try
%         infoTextBox={'depth=' depth 'CF (Hz)=' CF 'A1=' A1 'Stimulus=' StimUsed};
%         annotation('textbox', [.8 .7 .1 .1], 'String',  infoTextBox, 'background', [1 1 1]);
%     end
% catch
%     fprintf('Could not find this cell in the cell list');
% end
p=0;
%highrepper=mode(sequences(:)); %the most frequent set member
highrepper=1;
times_repeated=find(sequences(:)==highrepper);
times_repeated=length(times_repeated);
%subplot1(times_repeated+1, 1);
i=0;
dbstop if error
for clust=1:Nclusters
    fig=figure;
    hold on
    offset=0;
    start=100;
    rep2=0;
    for rep=1:max(nreps)
        for eindex=1:numepochs
            
            seq=sequences(clust, eindex, rep,:);
            for sent=1:length(seq)
                if sent==1
                    start=isi;
                    stimtrace=squeeze(M1stim(clust,eindex,rep,  :));
                    if xlimits(1)<0
                        stimtrace=stimtrace(1:end);
                    else
                    stimtrace=stimtrace(-xlimits(1)*samprate*.001+1:end);
                    end
                    stimtrace=stimtrace-mean(stimtrace(1:100));
                    stimtrace=stimtrace./max(abs(stimtrace));
                    
                end
                stop=start+3000;
                regionms=start:stop;
                startsamp=round(start*.001*10e3+1); %stimulus trace is in sampling rate that exper records
                stopsamp=round(stop*.001*10e3);
                
                
                if seq(sent)==highrepper
                    p=p+5;
                    i=i+1;
                    offset=offset+5;
                    stimseg=stimtrace(startsamp:stopsamp);
                    %                 spiketimes1=dspikes(dspikes>startsamp &dspikes<stopsamp+1000);
                    %                 spiketimes1=(spiketimes1)*1000/samprate; % ms
                    spiketimes1=M1(clust,eindex,rep).spiketimes;
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
                    t=1000*t/10e3; %sampling rate is 10e3 from exper
                    plot(t, stimseg+offset,'m')
                    rep2=rep2+1;
                    M2stim(rep2,:)=stimseg;
                    p=p+1;
                    
                end
                start=stop+2*isi;
            end
        end
    end
    
    
    X=xlimits(1):binwidth:3000;
    try
    [N, x]=hist(spiketimes2.spiketimes, X);
    
    N=N./nreps(eindex);
    N=1000*N./binwidth;
    end
    
    %xlim(xlimits(1), 3000);
    ylimits(2)=ylimits(2)/2;
    %ylim(ylimits)
    legend(p,'spikes');
    
    out.highrepper=highrepper;
    
    xlabel('time (ms)')
    ylabel('spikes, all trials')
    title(sprintf('%s-%s-%s one 3s sentence segment, %d reps, cell # %d', expdate,session, filenum, sum(squeeze(sequences(:)==highrepper)), clust))
    orient portrait
end
end


