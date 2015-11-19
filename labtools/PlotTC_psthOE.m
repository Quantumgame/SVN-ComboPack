function PlotTC_psthOE(expdate, session, filenum, channel, varargin)
% plots psth tuning curve for spike data from Open Ephys/SimpleClust
%
% usage: PlotTC_psthOE(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth], cell)
% (xlimits, ylimits, binwidth are optional)
%
%  defaults: binwidth=5ms, axes autoscaled
%  note there is no thresh because spikes were already cut in SimpleClust
%  plots mean spike rate (in Hz) averaged across trials

% mw 020814
% mw 06.11.2014 - added MClust capability
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sorter='MClust'; %can be either 'MClust' or 'simpleclust'
rasters=1;
location='D:\lab\Somatostatin_project_shared_folder\MK_data_SomArch\LongWN';
save_outfile=1;
% %sorter='simpleclust';
% recordings = cell_list_ira_som_OE;
% for i=1:length(recordings)
%     if strcmp(recordings(i).expdate, expdate) && strcmp(recordings(i).session, session) && strcmp(recordings(i).filenum, filenum)
%     sorter=recordings(i).sorter;
%     end
% end
if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=5;
    promt=('please enter channel number: ');
    channel=input(promt,'s')
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    cell=[];
elseif nargin==4
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=5;
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    cell=[];
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=-1;
    binwidth=5;
    cell=[];
elseif nargin==6
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=5;
    cell=[];
elseif nargin==7
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
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
    cell=[];
elseif nargin==8
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
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
    cell=varargin{4};
else
    error('Wrong number of arguments.');
end


fs=10; %fontsize

gogetdata(expdate, session, filenum);
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
godatadir(expdate,session,filenum);
try
    load(OEeventsfile);
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end
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
%         fprintf('\ntrying to load %s... ',OEdatafile)
%         load(OEdatafile)
%         fprintf('success')
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
%                     fprintf('success')
%         else
%             fprintf('failed\ncould not find exper structure. Cannot get OE file info.')
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
%     load(OEdatafile)
%     fprintf('success')
%
% end

%find OE data directory
try
    oepathname=getOEdatapath(expdate, session, filenum);
    cd(oepathname);
catch
    cd('C:\Program Files\Open Ephys')
    switch sorter
        case 'MClust'
            [OEdatafile, oepathname] = uigetfile('*.t', 'pick an MClust output file (*.t)');
            if isequal(OEdatafile,0) || isequal(oepathname,0)
                return;
            else
                cd(oepathname)
            end
        case 'simpleclust'
            [OEdatafile, oepathname] = uigetfile('*simpleclust.mat', 'pick a simpleclust.mat file');
    end
end

first_sample_timestamp=OEget_first_sample_timestamp(oepathname); %in s

%load spiketimes from clustered data
switch sorter
    case 'simpleclust'
        OEdatafile=sprintf('ch%s_simpleclust.mat', channel);
        load(OEdatafile);
        Nclusters=features.Nclusters;
        for n=1:Nclusters
            spikeidx(n).spikeidx=find(features.clusters==n);%list of indexes for spikes in each cluster
            nspikes(n)=length(spikeidx(n).spikeidx);
            spiketimes(n).spiketimes=features.ts(spikeidx(n).spikeidx); %list of spiketimes in sec
            spiketimes(n).spiketimes=spiketimes(n).spiketimes-first_sample_timestamp;
        end
    case 'MClust'
        %MClust spiketime files are of the form simpleclustfname_1.t
        %there is one for each cluster
        basefn=sprintf(sprintf('ch%s_simpleclust_*.t', channel));
        d=dir(basefn);
        numclusters=size(d, 1);
        if numclusters==0 error('PlotMClustTC: no cluster files found');end
        for clustnum=1:numclusters
            if clustnum<10
                fn=sprintf('ch%s_simpleclust_0%d.t', channel, clustnum);
            else
                fn=sprintf('ch%s_simpleclust_%d.t', channel, clustnum);
            end
            fprintf('\nreading MClust output file %s cluster %d', fn, clustnum)
            spiketimes(clustnum).spiketimes=read_MClust_output(fn)'/10000;
            %correct for OE start time, so that time starts at 0
            spiketimes(clustnum).spiketimes=spiketimes(clustnum).spiketimes-first_sample_timestamp;
            
            totalnumspikes(clustnum)=length(spiketimes(clustnum).spiketimes);
        end
        fprintf('\nsuccessfully loaded MClust spike data')
        Nclusters=numclusters;
end

try
    samprate=OEget_samplerate(oepathname);
catch
    fprintf('\ncould not load sampling rate. Assuming samprate=30000');
    samprate=30000;
end

if isempty(event); fprintf('\nno tones\n'); return; end


fprintf('\ncomputing tuning curve...');
%


fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));


%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'fmtone')
        j=j+1;
        allfreqs(j)=event(i).Param.carrier_frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.toneduration;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'grating')
        j=j+1;
        allfreqs(j)=event(i).Param.angle*1000;
        allamps(j)=event(i).Param.spatialfrequency;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.clickduration; %        alldurs(j)=event(i).Param.duration; gives trial duration not tone duration
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
M1=[];
nreps=zeros(numfreqs, numamps, numdurs);

inRange=zeros(1, Nclusters);
%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos/samprate;
            if isempty(pos) & ~isempty(event(i).Position)
                pos=event(i).Position;
                fprintf('\nWARNING! Missing a soundcard trigger. Using hardware trigger instead.')
                
            end
        else
            pos=event(i).Position; %in sec
        end
        
        start=(pos+xlimits(1)*1e-3); %in sec
        stop=(pos+xlimits(2)*1e-3); %in sec
        if start>0 %(disallow negative start times)
            if strcmp(event(i).Type, 'tone')
                freq=event(i).Param.frequency;
                dur=event(i).Param.duration;
            elseif strcmp(event(i).Type, 'fmtone')
                freq=event(i).Param.carrier_frequency;
                dur=event1(i).Param.duration;
            elseif  strcmp(event(i).Type, 'tonetrain')
                freq=event(i).Param.frequency;
                dur=event(i).Param.toneduration;
            elseif  strcmp(event(i).Type, 'grating')
                freq=event(i).Param.angle*1000;
                dur=event(i).Param.duration;
            elseif strcmp(event(i).Type, 'whitenoise')
                dur=event(i).Param.duration;
                freq=-1;
            elseif strcmp(event(i).Type, 'clicktrain')
                dur=event(i).Param.clickduration;
                freq=-1;
            end
            try
                amp=event(i).Param.amplitude;
            catch
                amp=event(i).Param.spatialfrequency;
            end
            %                 dur=event(i).Param.duration;
            findex= find(freqs==freq);
            aindex= find(amps==amp);
            dindex= find(durs==dur);
            nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
            for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                st=spiketimes(clust).spiketimes;
                spiketimes1=st(st>start & st<stop); % spiketimes in region
                inRange(clust)=inRange(clust)+ length(spiketimes1);
                spiketimes1=(spiketimes1-pos)*1000;%covert to ms after tone onset
                M1(clust, findex,aindex,dindex, nreps(findex, aindex, dindex)).spiketimes=spiketimes1;
            end
            
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))
for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ntotal num spikes: %d', length(spiketimes(clust).spiketimes))
    fprintf('\nIn range: %d', inRange(clust))
end
mM1=[];
%accumulate across trials
for dindex=[1:numdurs]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            for clust=1:Nclusters
                spiketimes1=[];
                for rep=1:nreps(findex, aindex, dindex)
                    spiketimes1=[spiketimes1 M1(clust, findex, aindex, dindex, rep).spiketimes];
                end
                mM1(clust, findex, aindex, dindex).spiketimes=spiketimes1;
            end
        end
    end
end

dindex=1;

%find axis limits

if ylimits==-1
    for clust=1:Nclusters
        ymax=0;
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                st=mM1(clust, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(st, X);
                N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                ymax= max(ymax,max(N));
            end
        end
        ylimits1(clust,:)=[-.3 ymax];
    end
else
    for clust=1:Nclusters
        ylimits1(clust, :)=[ylimits];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i=1:length(recordings)
%     if strcmp(recordings(i).expdate, expdate) && strcmp(recordings(i).session, session) && strcmp(recordings(i).filenum, filenum)
%     for j=1:size(recordings(i).tetrode)
%         for k=1:size(recordings(i).tetrode(j,:).cluster)
%         clust1(k,:)=recordings(i).tetrode(j,:).cluster(k,:).number;
%         end
%     end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot ch1

if ~isempty(cell)
    clust=str2num(cell);
    figure; p=0;
        if numdurs==1
            subplot1(numamps,numfreqs)
        else
            subplot1(numdurs, numamps)
        end
        for dindex=[1:numdurs]
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                        p=p+1;
                subplot1(p)
                hold on
                spiketimes1=mM1(clust, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes1, X);
                N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                offset=0;
                yl=ylimits1(clust,:);
                inc=(yl(2))/max(max(max(nreps)));
                if rasters==1
                    for n=1:nreps(findex, aindex, dindex)
                        spiketimes2=M1(clust, findex, aindex, dindex, n).spiketimes;
                        offset=offset+inc;
                        
                        h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                        
                    end
                end
                bar(x, N,1);
                line([0 0+durs(dindex)], [-.2 -.2], 'color', 'm', 'linewidth', 4)
                line(xlimits, [0 0], 'color', 'k')
                ylimits2(clust,2)=ylimits1(clust,2)*3;
                ylimits2(clust,1)=-2;
                ylim(ylimits2(clust,:))
                
                xlim(xlimits)
                set(gca, 'fontsize', fs)
                set(gca, 'xticklabel', '')
                set(gca, 'yticklabel', '')
            end
        end
        
        %label amps and freqs
        flabel=0;
        alabel=0;
        if numdurs==1
            p=0;
        end
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                if numdurs==1
                        p=p+1;
                    end
                subplot1(p)
                if findex==1 && aindex==numamps;
                    T=text(xlimits(1)-diff(xlimits)/2, mean(ylimits), int2str(amps(aindex)));
                    set(T, 'HorizontalAlignment', 'right')
                    flabel=1;
                        if numdurs==1
                            ylabel(sprintf('%.1f dB, FR (Hz)', amps(aindex)));
                        else
                            ylabel(sprintf('%.1f ms', durs(dindex)));
                        end
                    set(gca, 'YTickLabelMode','auto');
                    set(gca, 'XTickLabelMode','auto');
                else
                    set(gca, 'xticklabel', '')
                end
                set(gca, 'xtickmode', 'auto')
                grid off
                if aindex==1 && alabel==0 && dindex==numdurs;
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/20;
                    text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                else
                    set(gca, 'yticklabel', '')
                end
            end
        end
        subplot1(ceil(numfreqs/3))
        
        title(sprintf('%s-%s-%s, tetrode %s,  cell %d, dur=%d, %d ms bins, %d spikes',expdate,session, filenum, channel, clust, durs(dindex), binwidth, inRange(clust)))
    end
else
    
    for clust=1:Nclusters
        figure; p=0;
        
        if numdurs==1
            subplot1(numamps,numfreqs)
        else
            subplot1(numdurs, numamps)
        end
        for dindex=[1:numdurs]
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                        p=p+1;
                    subplot1(p)
                    hold on
                    spiketimes1=mM1(clust, findex, aindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    offset=0;
                    yl=ylimits1(clust,:);
                    inc=(yl(2))/max(max(max(nreps)));
                    if rasters==1
                        for n=1:nreps(findex, aindex, dindex)
                            spiketimes2=M1(clust, findex, aindex, dindex, n).spiketimes;
                            offset=offset+inc;
                            h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                            
                        end
                    end
                    
                    b=bar(x, N,1);
                    line([0 0+durs(dindex)], [-.2 -.2], 'color', 'm', 'linewidth', 4)
                    line(xlimits, [0 0], 'color', 'k')
                    ylimits2(clust,2)=ylimits1(clust,2)*3;
                    
                    ylim(ylimits2(clust,:))
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                    set(gca, 'xticklabel', '')
                    set(gca, 'yticklabel', '')
                    axis on
                end
            end
            
            %label amps and freqs
            if numdurs==1;
                p=0;
            end
            flabel=0;
            alabel=0;
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    if numdurs==1
                        p=p+1;
                    end
                    subplot1(p)
                    if findex==1 && aindex==numamps;
                        T=text(xlimits(1)-diff(xlimits)/2, mean(ylimits), int2str(amps(aindex)));
                        set(T, 'HorizontalAlignment', 'right')
                        flabel=1;set(gca, 'XTickLabelMode','auto');
                        set(gca, 'YTickLabelMode','auto');
                        if numdurs==1
                            ylabel(sprintf('%.1f dB, FR (Hz)', amps(aindex)));
                        else
                            ylabel(sprintf('%.1f ms', durs(dindex)));
                        end
                    else
                        set(gca, 'xticklabel', '')
                    end
                    set(gca, 'xtickmode', 'auto')
                    if aindex==1 && alabel==0;
                        vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/20;
                        text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                    else
                        set(gca, 'yticklabel', '')
                    end
                end
            end
            subplot1(ceil(numfreqs/3))
            if numdurs==1
                title(sprintf('%s-%s-%s tetrode %s, cell %d, dur=%d, %d ms bins, %d spikes',expdate,session, filenum, channel, clust, durs(dindex), binwidth, inRange(clust)))
            else
                if dindex==1
                    title(sprintf('%s-%s-%s tetrode %s, cell %d,, %d ms bins, %d spikes',expdate,session, filenum, channel, clust, binwidth, inRange(clust)))
                end
            end
        end %for clust
    end %for dindex
end %cell
set(gcf,'Position',[100 100 800 900]);

if save_outfile==1
    clust=str2num(cell);
    out.cell=cell;
    out.M1=squeeze(M1(clust,:,:,:,:));
    out.mM1=squeeze(mM1(clust,:));
    out.expdate=expdate;
    out.filenum=filenum;
    out.session=session;
    out.datafile=datafile;
    out.eventsfile=eventsfile;
    out.stimfile=stimfile;
    out.freqs=freqs;
    out.amps=amps;
    out.durs=durs;
    out.nreps=nreps;
    out.numfreqs=numfreqs;
    out.numamps=numamps;
    out.numdurs=numdurs;
    out.event=event;
    out.xlimits=xlimits;
    out.ylimits=ylimits;
    out.samprate=samprate;
    out.channel=channel;
    out.Nclusters=Nclusters;
    out.nreps=nreps;
    out.expdate=expdate;
    out.session=session;
    out.filenum=filenum;
    out.quality=3;
    try
        out.isrecording=isrecording;
    end
    try
        out.oepathname=oepathname;
    end
    cd(location);
    outfilename=sprintf('outTCOE%s_%s-%s-%s_%s',channel, expdate, session, filenum, cell);
    save(outfilename, 'out');
else
    out.M1=M1;
    out.mM1=mM1;
    out.expdate=expdate;
    out.filenum=filenum;
    out.session=session;
    out.datafile=datafile;
    out.eventsfile=eventsfile;
    out.stimfile=stimfile;
    out.freqs=freqs;
    out.amps=amps;
    out.durs=durs;
    out.nreps=nreps;
    out.numfreqs=numfreqs;
    out.numamps=numamps;
    out.numdurs=numdurs;
    out.event=event;
    out.xlimits=xlimits;
    out.ylimits=ylimits;
    out.samprate=samprate;
    out.channel=channel;
    out.Nclusters=Nclusters;
    out.nreps=nreps;
    out.expdate=expdate;
    out.session=session;
    out.filenum=filenum;
    try
        out.isrecording=isrecording;
    end
    try
        out.oepathname=oepathname;
    end
end

outfilename=sprintf('outTCOE%s_%s-%s-%s_%s',channel, expdate, session, filenum, cell);

godatadir(expdate, session, filenum);
save (outfilename, 'out')
fprintf('\n\n')

