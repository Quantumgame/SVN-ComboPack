% E2 white noise train script

expdate='042406';
session='001';
filenum='002';
area='ABR';
loadit=1;

%lostat=2.4918e+006; %discard data after this position (in samples)

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
fprintf('\ncomputing averaged response...');

samprate=1e4;
scaledtrace=nativeScaling*double(trace);
t=1:length(scaledtrace);
t=1000*t/samprate;
tracelength=event(1).Param.duration; %in ms
baseline=100; %in ms

figure
hold on
%first look at WN response
j=0;
Mwn=[];
for i=1:length(event)
    if strcmp(event(i).Type, 'clicktrain')
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





%extract clicks from WN Train into new matrix M
%note: samprate is in Hz (i.e. 10000)
figure
p=0;
      
for i=1:length(event)

    nclicks=event(i).Param.nclicks;
    isi=event(i).Param.isi;
    start=event(i).Param.start;
    clickduration=event(i).Param.clickduration;
    tracelength=50; %ms
    for j=1:nclicks
        p=p+1;
        onset=(start+(i-1)*(clickduration+isi))*samprate/1000;
        region=(onset+1-50):onset+tracelength*samprate/1000;
        trace=squeeze(Mwn(i,  region));
        Mc(p,:)=trace;
    end
end

t=1:size(Mc, 2);
t=t*1000/samprate
plot(t, mean(Mc)-mean(Mc(:,1:10)))
title(sprintf('ABR, mean of %d clicks', size(Mc, 1)));
shg

 







