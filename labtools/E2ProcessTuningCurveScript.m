% E2 tuning curve script

expdate='051606';
session='001';
filenum='0010';
area='AC';
loadit=1;

lostat=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

raw_data_dir=sprintf('D:\\wehr\\Data-backup\\%s-mw', expdate);
processed_data_dir=sprintf('D:\\wehr\\Data-processed\\%s-mw', expdate);
processed_data_session_dir=sprintf('%s-mw-%s', expdate, session);
datafile=sprintf('%s-mw-%s-%s-AxopatchData1-trace.mat', expdate, session, filenum);
eventsfile=sprintf('%s-mw-%s-%s-AxopatchData1-events.mat', expdate, session, filenum);

if loadit
    try
        fprintf('\ntrying to load %s...', datafile)
        cd(processed_data_dir)
        cd(processed_data_session_dir)
        load(datafile);
        load(eventsfile);
    catch
        fprintf('failed')
        fprintf('\ntrying to process raw data in %s...', raw_data_dir)
        E2ProcessSession(raw_data_dir, 1, processed_data_dir)
        cd(processed_data_dir)
        cd(processed_data_session_dir)
        fprintf('done\ntrying to load %s...', datafile)
        load(datafile);
        load(eventsfile);
    end
    fprintf('done.');
end
if lostat==-1 lostat=length(trace);end

fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace=nativeScaling*double(trace);
t=1:length(scaledtrace);
t=1000*t/samprate;
tracelength=300; %in ms
baseline=100; %in ms

figure
hold on
%first look at WN response
j=0;
Mwn=[];
for i=1:length(event)
    if strcmp(event(i).Type, 'whitenoise')
        pos=event(i).Position;
        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate);
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            %         tr=1:length(region);tr=1000*tr/samprate;
            %         plot(tr, scaledtrace(region))
            %         drawnow
            j=j+1;
            Mwn(j,:)=scaledtrace(region);
        end
    end
end

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
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

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
M=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
nreps=zeros(numfreqs, numamps, numdurs);

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        pos=event(i).Position;
        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat
                fprintf('\ndiscarding trace')
            else
                freq=event(i).Param.frequency;
                amp=event(i).Param.amplitude;
                dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                M(findex,aindex,dindex, nreps(findex, aindex, dindex),:)=scaledtrace(region);
            end
        end
    end
end

dindex=1;
mM=mean(M, 4);
%mM=mean(M(:,:,:,21:38,:), 4);

%plot the mean tuning curve
figure
p=0;
subplot1( numamps,numfreqs)
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        p=p+1;

        subplot1( p)
        trace1=squeeze(mM(findex, aindex, dindex, :));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1);
                 ylim([-2 8])
%        ylim([-1 1])
        axis off

    end
end








