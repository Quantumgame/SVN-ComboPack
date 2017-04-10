function ProcessToneTrain(expdate, session, filenum, varargin)
%usage: ProcessToneTrain(expdate, session, filenum, [xlimits])
%  processes raw tone train data, saves output in an outfile
%  xlimits refer to the data surrounding each individual tone/click
%  (xlimits are optional, defaults to +- 50% of tone/click duration)
%
%  to look at it, use PlotToneTrain(expdate, session, filenum)
%
% data channel is set manually inside the function
% this function is meant to replace ProcessToneTrain_A1 since you can now specify
% xlimits
%

%lostat=2.4918e+006; %discard data after this position (in samples)

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    xlimits=-1; %use  +- 50% of tone/click duration)
elseif  nargin==4
    xlimits=varargin{1}
    if isempty(xlimits)
        xlimits=-1; %use  +- 50% of tone/click duration)
    end
else
    help ProcessToneTrain
    error('ProcessToneTrain: wrong number of arguments')
end

datachan='1';
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum, datachan);
try
    fprintf('\ntrying to load %s...', datafile)
    godatadir(expdate, session, filenum)
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf('done.');
catch
    fprintf('failed')
end

fprintf('\ncomputing averaged response...');
event=E.event;

samprate=1e4;
scaledtrace=D.nativeScaling*double(D.trace)+D.nativeOffset;
stim=S.nativeScalingStim*double(S.stim);
clear D E S
% Ttraceength and Tbaseline are for first sorting full trains into a matrix
Ttracelength=event(1).Param.duration; %in ms
Tbaseline=25; %in ms


%first concatenate the sequence of trains into a matrix Mt
j=0;
%preallocate Mt and Ms
Mt=zeros(length(event),Ttracelength*1e-3*samprate+1 );%trains
Ms=Mt;%stimulus record
for i=1:length(event)
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain')
         
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        elseif isfield(event(i), 'Position_rising')
            pos=event(i).Position_rising;
        else
            pos=event(i).Position;
        end
        start=(pos-Tbaseline*1e-3*samprate);
        %start=(pos);
        stop=(start+Ttracelength*1e-3*samprate);
        region=start:stop;
        if isempty(find(region<0)) & stop<length(scaledtrace) %(disallow negative start times and don't exceed end)
            %         tr=1:length(region);tr=1000*tr/samprate;
            %         plot(tr, scaledtrace(region))
            %         drawnow

            if(0)%             manually align to stimulus
                s=stim(region);
                s=s-mean(s(1:100));
                s=s/max(s);
                thresh=4*std(s(1:1000));
                s1=find(abs(s)>thresh);
                newpos=s1(1);
                start=pos + newpos-samprate*1e-3*event(i).Param.start;
                stop=(start+tracelength*1e-3*samprate);
                region=start:stop;
            end

            j=j+1;
            Mt(j,:)=scaledtrace(region);
            Ms(j,:)=stim(region);
        end
    end
end
numevents=j;




%extract tones from Tone Train matrix Mt into new matrix of individual clicks Mc
%note: samprate is in Hz (i.e. 10000)
%
p=0;

%get freqs/amps
j=0;
for i=1:numevents
    if strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    end
end
freqs1=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs1);
numamps=length(amps);
numdurs=length(durs);

nreps=zeros(numfreqs, numamps);
switch event(1).Type
    case 'tonetrain'
        ntones=event(1).Param.ntones;
    case 'clicktrain'
        ntones=event(1).Param.nclicks;
end

% figure out xlimits
if xlimits==-1
    switch event(i).Type
        case 'tonetrain'
            dur=event(i).Param.toneduration;
        case 'clicktrain'
            dur=event(i).Param.clickduration;
    end
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
else 
    switch event(i).Type
        case 'tonetrain'
            dur=event(i).Param.toneduration;
        case 'clicktrain'
            dur=event(i).Param.clickduration;
    end

end
tracelength=diff(xlimits); %in ms
if xlimits(1)<0
    baseline=abs(xlimits(1));
else
    baseline=0;
end

% % preallocate Mc and MCs;
Mc=zeros(numfreqs, numamps, ceil(numevents*ntones/(numfreqs*numamps)), 1+tracelength*samprate/1000);
Mcs=Mc;

wb=waitbar(0, 'sorting into tone matrix');
for i=1:numevents
    waitbar(i/numevents,wb);
    switch event(i).Type
        case 'tonetrain'
            ntones=event(i).Param.ntones;
            toneduration=event(i).Param.toneduration;
            freq=event(i).Param.frequency;
        case 'clicktrain'
            ntones=event(i).Param.nclicks;
            toneduration=event(i).Param.clickduration;
            freq=-1;
    end
    isi=event(i).Param.isi;
    start=event(i).Param.start;
    amp=event(i).Param.amplitude;
    findex= find(freqs1==freq);
    aindex= find(amps==amp);


    for k=1:ntones
        %        p=p+1;
        %        onset=(start+(i-1)*(toneduration+isi))*samprate/1000;
        onset=(Tbaseline+start+(k-1)*(isi))*samprate/1000;
        regionstart=(onset+1-baseline*samprate/1000);
        region=regionstart:regionstart+tracelength*samprate/1000;
        trace=squeeze(Mt(i,  region));
        trace_stim=squeeze(Ms(i,  region));
        nr=nreps(findex, aindex);
        Mc(findex, aindex, k+ntones*nr,:)=trace; %p= repetitions
        Mcs(findex, aindex, k+ntones*nr,:)=trace_stim; %stimulus matrix
    end
    nreps(findex, aindex)=nreps(findex, aindex)+1;
end
close(wb)
wb2=waitbar(.5, 'saving...');
mMc=mean(Mc, 3);
mMcs=mean(Mcs, 3);

outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
save(outfilename, 'dur', 'Ms', 'Mcs' ,'Mc', 'Mt', 'baseline', 'expdate', 'session', 'filenum', 'numevents', 'numfreqs', 'numamps', 'freqs1', 'amps', 'isi', 'xlimits')
close(wb2)

return

%examine trial-by-trial
figure;hold on
offset=max(max(max(max(Mc))));
%findex=numfreqs;
findex=1;
aindex=1;
t=1:samprate*(tracelength+baseline)/1000;t=t*1000/samprate;
for i=1:size(Mc,3)
    trace=squeeze(Mc(findex, aindex, i, :));
    plot(t, trace + offset*i)
end

figure;
hold on;
for i=1:size(Mt,1)
    plot(Mt(i,1:3800)+15*i);
    plot(Ms(i,1:3800)+15*i, 'r');
end

% keyboard

