% E2 tuning curve script

expdate='031606';
session='001';
filenum='001';
area='LGN';
loadit=1;

lostat=2.4918e+006; %discard data after this position (in samples)

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
    
    cd D:\wehr\stimuli\vanHatteren
load ts001.txt;
s=ts001(1:(1200*20));
s=resample(s, 10e3, 1200); %resample from 1200 Hz to 10kHz
s=20*s/max(s);
    fprintf('done.');
end
fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace=nativeScaling*double(trace);
t=1:length(scaledtrace);
t=1000*t/samprate;
tracelength=300; %in ms
baseline=100; %in ms

%first look at VH response
j=0;
Mvh=[];
for i=1:length(event)
    if isfield(event(i).Param, 'file')
        if strcmp(event(i).Param.file, 'vanHatteren_sourcefile_ts001_20s')
            tracelength=event(i).Param.duration;
            pos=event(i).Position;
            start=(pos-baseline*1e-3*samprate); %in samples
            stop=(start+tracelength*1e-3*samprate)-1;
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                %         tr=1:length(region);tr=1000*tr/samprate;
                %         plot(tr, scaledtrace(region))
                %         drawnow
                j=j+1;
                Mvh(j,:)=scaledtrace(region);
            end
        end
    end
end
c='brgkmybrgkmy';
t=1:length(Mvh);
t=1000*t/samprate;
figure
hold on
plot(t, s+min(min(Mvh))-20, 'r')
for i=1:size(Mvh, 1);
    plot(t, Mvh(i,:), c(i))
end

% look at VH-wn response
j=0;
Mwn=[];
for i=1:length(event)
    if isfield(event(i).Param, 'file')
        if strcmp(event(i).Param.file, 'vanHatteren_WN_sourcefile_ts001_20s')
            tracelength=event(i).Param.duration;
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
end
c='brgkmybrgkmy';
t=1:length(Mwn);
t=1000*t/samprate;
figure
hold on
for i=1:size(Mwn, 1);
    plot(t, Mwn(i,:), c(i))
end
plot(t, mean(Mwn)-10, 'linewidth', 2)

figure
hold on
for i=1:size(Mwn, 1);
    plot(t, Mwn(i,:)+10*i)
end


figure
hold on
% look at sine wave response
j=0;
Ms=[];
for i=1:length(event)
    if isfield(event(i).Param, 'file')
        if strcmp(event(i).Param.file, 'LEDsin_sourcefile_2_100_2000')
            tracelength=event(i).Param.duration;
            pos=event(i).Position;
            start=(pos-baseline*1e-3*samprate);
            stop=(start+tracelength*1e-3*samprate);
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                %         tr=1:length(region);tr=1000*tr/samprate;
                %         plot(tr, scaledtrace(region))
                %         drawnow
                j=j+1;
                Ms(j,:)=scaledtrace(region);
            end
        end
    end
end
c='brgkmybrgkmy';
t=1:length(Ms);
t=1000*t/samprate;
for i=1:size(Ms, 1);
    plot(t, Ms(i,:), c(i))
end


figure
hold on
% look at sine wave response
j=0;
Ms1=[];
for i=1:length(event)
    if isfield(event(i).Param, 'file')
        if strcmp(event(i).Param.file, 'LEDsin_sourcefile_1_100_2000')
            tracelength=event(i).Param.duration;
            pos=event(i).Position;
            start=(pos-baseline*1e-3*samprate);
            stop=(start+tracelength*1e-3*samprate);
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                %         tr=1:length(region);tr=1000*tr/samprate;
                %         plot(tr, scaledtrace(region))
                %         drawnow
                j=j+1;
                Ms1(j,:)=scaledtrace(region);
            end
        end
    end
end
c='brgkmybrgkmy';
t=1:length(Ms1);
t=1000*t/samprate;
for i=1:size(Ms1, 1);
    plot(t, Ms1(i,:), c(i))
end

