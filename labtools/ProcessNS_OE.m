function ProcessNS_OE(varargin)
%usage: ProcessTC_OE(expdate, session, filename, [xlimits], [ylimits], [channel])
%creates OE axopatch datafile
%extracts spikes from simple_clust file
%ira 03-24-14
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=[]; %x limits for axis
    ylimits=-1;
    prompt=('Please enter tetrode number: ');
    channel=input(prompt,'s') ;
    binwidth=5;
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    channel=varargin{4};
    xlimits=[];
    ylimits=-1;
    prompt=('Please enter tetrode number: ');
    channel=input(prompt,'s') ;
    binwidth=5;
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    channel=varargin{4};
    xlimits=varargin{5};
    ylimits=-1;
    prompt=('Please enter tetrode number: ');
    channel=input(prompt,'s') ;
    binwidth=5;
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    channel=varargin{4};
    xlimits=varargin{5};
    ylimits=varargin{6};
    binwidth=5;
elseif nargin==7
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    channel=varargin{4};
    xlimits=varargin{5};
    ylimits=varargin{6};
    binwidth=varargin{7};
    
    
else
    error('wrong number of arguments');
end
[D E S]=gogetdata(expdate,session,filenum);
stim1=S.nativeScalingStim*double(S.stim);
event1=E.event;
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
% load(OEeventsfile);
% clear D E S

try
    gorawdatadir(expdate, session, filenum)
    expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filenum);
    expstructurename=sprintf('exper_%s', filenum);
    if exist(expfilename)==2 %try current directory
        load(expfilename)
        exp=eval(expstructurename);
        isrecording=exp.openephyslinker.param.isrecording.value;
        oepathname=exp.openephyslinker.param.oepathname.value;
        cd(oepathname)
        OEdatafile=sprintf('ch%s_simpleclust.mat', channel);
        load(OEdatafile)
    else %try data directory
        cd ../../..
        try
            cd(sprintf('Data-%s-backup',user))
            cd(sprintf('%s-%s',expdate,user))
            cd(sprintf('%s-%s-%s',expdate,user, session))
        end
        if exist(expfilename)==2
            load(expfilename)
            exp=eval(expstructurename);
            isrecording=exp.openephyslinker.param.isrecording.value;
            oepathname=exp.openephyslinker.param.oepathname.value;
            cd(oepathname);
            OEdatafile=spintf('ch%s_simpleclust.mat', channel);
            load(OEdatafile);
        else
            fprintf('\ncould not find exper structure. Cannot get OE file info.')
        end
    end
catch
    cd('C:\Program Files\Open Ephys')
    [OEdatafile, oepathname] = uigetfile('*simpleclust.mat', 'pick a simpleclust.mat file');
    if isequal(OEdatafile,0) || isequal(oepathname,0)
        return;
    else
        cd(oepathname)
    end
    load(OEdatafile)
end

%try to get samprate and stim ID
% new variables: stimid, timestamps
filename='all_channels.events';
[data, alltimestamps, info] = load_open_ephys_data(filename);
try
    E=load(OEeventsfile);
catch
    OEgetEvents(expdate, session, filenum);
        E=load(OEeventsfile);
end
event=E.event;
try
    samprate=info.header.sampleRate;
catch
    fprintf('\ncould not load sampling rate. Assuming samprate=30000');
    samprate=30000;
end
alltimestamps=double(round2(alltimestamps, 0.01));
uniqueTimestamps=unique(alltimestamps);
j=0;timestamps=[];
for i=1:length(uniqueTimestamps)
    [idx, val]= find(alltimestamps==uniqueTimestamps(i));
    bv=data(idx);
    bv=sort(bv);
    on=unique(info.eventId(idx));
    if length(on)>1
        warning('stimulus bit turned on and off at the same time??? dropping stimulus');
    else
        bv2=bv(2:end)-1; %strip off trigger line
        bv3=sum(2.^bv2); %convert to decimal stimid
        if on
            j=j+1;
            stimid(j)=bv3;
            timestamps(j)=uniqueTimestamps(i);
        end
    end
end

Nclusters=features.Nclusters;
for n=1:Nclusters
    spikeidx(n).spikeidx=find(features.clusters==n);%list of indexes for spikes in each cluster
    nspikes(n)=length(spikeidx(n).spikeidx);
    spiketimes(n).spiketimes=features.ts(spikeidx(n).spikeidx); %list of spiketimes in sec
end

if isempty(event); fprintf('\nno tones\n'); return; end
j=0;
for i=1:length(event) %
    if strcmp(event(i).Type, 'naturalsound')
        j=j+1;
        alldurs(j)=event(i).Param.duration;
        allisis(j)=event(i).Param.next;
        allfilenames{j}=event(i).Param.file;
    end
end

numepochs=length(unique(allfilenames));
epochfilenames=(unique(allfilenames));
dur=unique(alldurs);
isi=unique(allisis);
if length(dur)~=1 error('cannot handle multiple durs');end
if length(isi)~=1 error('cannot handle multiple isis');end
if isempty(xlimits)
    xlimits=[-1000 dur+1000];
end


M1=[];
nreps=zeros(1, numepochs);
lostin_counter=[];
lostat_counter=[];
inRange=zeros(1, Nclusters);
for i=1:length(event)
    if strcmp(event(i).Type, 'naturalsound')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if strcmp(event1(i).Type, 'naturalsound')
            pos1= event1(i).soundcardtriggerPos ;
            end
        else
            pos=event(i).Position;
            if strcmp(event1(i).Type, 'naturalsound')
            pos1=event1(i).Position;
            end
        end
        %ira 07-14-14
        start=(pos/samprate+xlimits(1)*1e-3);%spiketimes are in seconds, so region for spikes is in seconds
        start1=(pos1+xlimits(1)*1e-3*10e3); %stimulus is in exper sampling rate, which is 10e3
        stop=(pos/samprate+xlimits(2)*1e-3)-1;
        stop1=(pos1+(xlimits(2)*1e-3)*10e3)-1;
        region=start:stop;
        region1=start1:stop1;
        
        if isempty(find(region<0)) %(disallow negative start times)
%             if stop>lostat(2)
%                 lostat_counter=[lostat_counter i];
%             elseif start<lostat(1)
%                 lostin_counter=[lostin_counter i];
%             else
                switch event(i).Type
                    case 'naturalsound'
                        epochfile=event(i).Param.file;
                end
                try
                    amp=event(i).Param.amplitude;
                catch
                    amp=event(i).Param.spatialfrequency;
                end
                
                findex= 1;
                aindex= 1;
                dindex= 1;
                dur=event(i).Param.duration;
                epochnum=find(strcmp(epochfilenames, epochfile));
                nreps(epochnum)=nreps(epochnum)+1;
                for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                    st=spiketimes(clust).spiketimes;
                    spiketimes1=st(st>start & st<stop); % spiketimes in region
                    inRange(clust)=inRange(clust)+ length(spiketimes1);
                    spiketimes1=(spiketimes1-pos/samprate)*1000;%covert to ms after tone onset
                    M1(clust, epochnum, nreps(epochnum)).spiketimes=spiketimes1;
                    M1stim(clust,epochnum, nreps(epochnum),:)=stim1(region1);
                    sequences(clust,epochnum,nreps(epochnum),:)=event(i).Param.sequence;
                end
           
        end
    end
end

%accumulate across trials

for clust=1:Nclusters
    for epochind=1:epochnum
        spiketimes1=[];
        for rep=1:nreps(epochind)
            spiketimes1=[M1(clust, epochind, rep).spiketimes spiketimes1 ];
        end
        mM1(clust, epochind).spiketimes=spiketimes1;
        mM1stim(clust, epochind,:)=mean(M1stim(clust, epochind, 1:nreps(epochind),:), 3);
    end
end


%save to outfile
out.M1=M1;
out.xlimits=xlimits;
out.mM1=mM1;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
out.datafile=datafile;
out.eventsfile=eventsfile;
out.stimfile=stimfile;
out.nreps=nreps;
out.event=event;
out.samprate=samprate;
out.epochfilenames=epochfilenames;
out.numepochs=numepochs;
out.sequences=sequences;
out.dur=dur;
out.isi=isi;
out.mM1stim=mM1stim;
out.M1stim=M1stim;
out.Nclusters=Nclusters;
out.event1=event1;
try
out.isrecording=isrecording;
end
try
out.oepathname=oepathname;
end
out.channel=channel;
out.info=info;

outfilename=sprintf('outNSOE%s_%s-%s-%s',channel, expdate, session, filenum);
godatadir(expdate, session, filenum);
save (outfilename, 'out')
try
fprintf('\nOE recording was %d for this file', out.isrecording)
end
fprintf('\n saved to %s', outfilename)

end

