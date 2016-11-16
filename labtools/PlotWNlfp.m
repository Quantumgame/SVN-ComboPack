% E2 tuning curve script
%plot tuning curve
%data needs to be COPIED into data-backup first
%
expdate1='092107';
session1='001';
filenum1='001';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loadit=1;

lostat1=-1; %discard data after this position (in samples), -1 to skip

raw_data_dir1=sprintf('D:\\lab\\Data-backup\\%s-lab', expdate1);
processed_data_dir1=sprintf('D:\\lab\\Data-processed\\%s-lab', expdate1);
processed_data_session_dir1=sprintf('%s-lab-%s', expdate1, session1);
datafile1=sprintf('%s-lab-%s-%s-AxopatchData1-trace.mat', expdate1, session1, filenum1);
eventsfile1=sprintf('%s-lab-%s-%s-AxopatchData1-events.mat', expdate1, session1, filenum1);

if loadit
    fprintf('\nload file 1: ')
    try
        fprintf('\ntrying to load %s...', datafile1)
        cd(processed_data_dir1)
        cd(processed_data_session_dir1)
        load(datafile1);
        load(eventsfile1);
    catch
        fprintf('failed')
        fprintf('\ntrying to process raw data in %s...', raw_data_dir1)
        E2ProcessSession(raw_data_dir1, 1, processed_data_dir1)
        cd(processed_data_dir1)
        cd(processed_data_session_dir1)
        fprintf('done\ntrying to load %s...', datafile1)
        load(datafile1);
        load(eventsfile1);
    end
    fprintf('done.');
end
event1=event;
trace1=trace;
nativeOffset1=nativeOffset;
nativeScaling1=nativeScaling;



fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1); %what about nativeOffset???????????????????????
if lostat1==-1 lostat1=length(scaledtrace1);end
t=1:length(scaledtrace1);
t=1000*t/samprate;
tracelength=500; %in ms
baseline=50; %in ms

%get freqs/amps
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'whitenoise') |strcmp(event1(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
nreps1=zeros(numfreqs, numamps, numdurs);

%extract the traces into a big matrix M
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'whitenoise') |strcmp(event1(i).Type, 'clicktrain')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
        else
            pos=event1(i).Position_rising;
        end

        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                freq=-1;
                amp=event1(i).Param.amplitude;
                dur=event1(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps1(findex, aindex, dindex),:)=scaledtrace1(region);
            end
        end
    end
end





 



dindex=1;
traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
else
    mM1=mean(M1, 4);
end

%mM=mean(M(:,:,:,21:38,:), 4);




%find optimal axis limits
axmax=[0 0];
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        trace1=squeeze(mM1(findex, aindex, dindex, :));
        trace1=trace1-mean(trace1(1:100));
        %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
        if min([trace1])<axmax(1) axmax(1)=min([trace1]);end
        if max([trace1])>axmax(2) axmax(2)=max([trace1]);end
    end
end

if axmax==[0 0]
    axmax=[-1 1];
end
%axmax(2)=10;

%plot the mean tuning curves for pre and post
figure
p=0;
subplot1( numamps,numfreqs)
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        p=p+1;
        subplot1( p)
        trace1=squeeze(mM1(findex, aindex, dindex, :));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1, 'b');
        ylim(axmax);
%         axis off
    end
end

title(sprintf('%s-%s-%s', expdate1,session1, filenum1))

%label amps and freqs
p=0;
for aindex=[1:numamps]
    for findex=1:numfreqs
        p=p+1;
        subplot1(p)
        if findex==1
            text(-400, mean(axmax), int2str(amps(aindex)))
        end
        if aindex==numamps
            if mod(findex,2) %odd freq
                vpos=axmax(1);
            else
                vpos=axmax(1)-mean(axmax);
            end
            text(0, vpos, sprintf('%.1f', freqs(findex)/1000))
        end
    end
end
