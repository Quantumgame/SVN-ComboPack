function E2ProcessToneTrainScript
% E2 tone train script

expdate='101806';
session='001';
filenum='001';
area='ABR';
loadit=1;

%lostat=2.4918e+006; %discard data after this position (in samples)

raw_data_dir=sprintf('D:\\lab\\Data-backup\\%s-lab', expdate);
processed_data_dir=sprintf('D:\\lab\\Data-processed\\%s-lab', expdate);
processed_data_session_dir=sprintf('%s-lab-%s', expdate, session);
datafile=sprintf('%s-lab-%s-%s-AxopatchData1-trace.mat', expdate, session, filenum);
eventsfile=sprintf('%s-lab-%s-%s-AxopatchData1-events.mat', expdate, session, filenum);
stimfile=sprintf('%s-lab-%s-%s-stim.mat', expdate, session, filenum);

if loadit
    try
        fprintf('\ntrying to load %s...', datafile)
        cd(processed_data_dir)
        cd(processed_data_session_dir)
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);
    catch
        fprintf('failed')
        fprintf('\ntrying to process raw data in %s...', raw_data_dir)
        E2ProcessSession(raw_data_dir, 1, processed_data_dir)
        cd(processed_data_dir)
        cd(processed_data_session_dir)
        fprintf('done\ntrying to load %s...', datafile)
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);
    end
    fprintf('done.');
end
fprintf('\ncomputing averaged response...');
event=E.event;

samprate=1e4;
scaledtrace=D.nativeScaling*double(D.trace);
stim=S.nativeScalingStim*double(S.stim);
t=1:length(scaledtrace);
t=1000*t/samprate;
tracelength=event(1).Param.duration; %in ms
baseline=0; %in ms

%figure
hold on
%first look at train response
j=0;
Mt=[];%trains
Ms=[];%stimulus record
for i=1:length(event)
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain')
        pos=event(i).Position;
%         start=(pos-baseline*1e-3*samprate);
        start=(pos-500);
        stop=(start+tracelength*1e-3*samprate);
        region=start:stop;
        if isempty(find(region<0)) & stop<length(scaledtrace) %(disallow negative start times and don't exceed end)
            %         tr=1:length(region);tr=1000*tr/samprate;
            %         plot(tr, scaledtrace(region))
            %         drawnow
            j=j+1;
            Mt(j,:)=scaledtrace(region);
            Ms(j,:)=stim(region);
        end
    end
end
numevents=j;




%extract tones from Tone Train into new matrix M
%note: samprate is in Hz (i.e. 10000)
figure
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
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

nreps=zeros(numfreqs, numamps);

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
    findex= find(freqs==freq);
    aindex= find(amps==amp);

    tracelength=100;%25; %ms
    for k=1:ntones
%        p=p+1;
%        onset=(start+(i-1)*(toneduration+isi))*samprate/1000;
        onset=(start+(k-1)*(isi))*samprate/1000;
        region=(onset+1-baseline*samprate/1000):onset+tracelength*samprate/1000;
        trace=squeeze(Mt(i,  region));
        nr=nreps(findex, aindex);
        Mc(findex, aindex, k+ntones*nr,:)=trace; %p= repetitions
    end
        nreps(findex, aindex)=nreps(findex, aindex)+1;
end
close(wb)
mMc=mean(Mc, 3);

%plot the mean tuning curves for pre and post
figure
p=0;
subplot1( numamps,numfreqs)
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        p=p+1;
        subplot1( p)
        trace1=squeeze(mMc(findex, aindex, :));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1, 'b');
        %axis([0 100 -0.010    0.010])
%        axis off
xlabel(sprintf('%.1fkHz', freqs(findex)))
    end
end
subplot1(ceil(numfreqs/3))
title(sprintf('%s-%s-%s, ABR, mean of %d tones', expdate,session, filenum, size(Mc, 3)))
shg

outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
save(outfilename, 'Mc', 'Mt', 'expdate', 'session', 'filenum', 'numevents', 'numfreqs', 'numamps')


%examine trial-by-trial
figure;hold on
offset=max(max(max(max(Mc))));
findex=numfreqs;
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

keyboard

