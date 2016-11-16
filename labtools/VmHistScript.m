expdate='012107';
session='006';
filenum='003';
area='thalamus';
loadit=1;
% 
% expdate='022406';
% session='002';
% filenum='001';
% area='visual cortex';
% load=1;

raw_data_dir=sprintf('D:\\lab\\Data-backup\\%s-lab', expdate);
processed_data_dir=sprintf('D:\\lab\\Data-processed\\%s-lab', expdate);
processed_data_session_dir=sprintf('%s-lab-%s', expdate, session);
datafile=sprintf('%s-lab-%s-%s-AxopatchData1-trace.mat', expdate, session, filenum)

if loadit
    try
        fprintf('\ntrying to load %s...', datafile)
        cd(processed_data_dir)
        cd(processed_data_session_dir)
        load(datafile);
    catch
        fprintf('failed')
        fprintf('\ntrying to process raw data in %s...', raw_data_dir)
        E2ProcessSession(raw_data_dir, 1, processed_data_dir)
        cd(processed_data_dir)
        cd(processed_data_session_dir)
        fprintf('done\ntrying to load %s...', datafile)
        load(datafile);
    end
    fprintf('done.');
end
fprintf('\nhistogramming...');


samprate=1e4;

scaledtrace=nativeScaling*double(trace);
dtrace=decimate(scaledtrace, 10);
dt=1:length(dtrace);dt=dt/1e3;

close all

%zoom in of trace
figure
region=round(length(dt)/2)+ (1:samprate);
plot(dt(region), dtrace(region))
xlabel('time, s')
set(gcf, 'pos', [14         703        1552         414])
ylim([-70 0])
title(sprintf(' %s-%s-%s %s', expdate, session, filenum, area))

%total cumulative histogram
region=(500*samprate:1000*samprate);
[n, x]=hist(scaledtrace(region), 500);
figure
plot(x, n, 'k')
xlim([-70 -20])
%title(sprintf(' %s-%s-%s %s', expdate, session, filenum, area))


%color-coded entire trace
numwindows=floor((length(scaledtrace)/samprate)/100);
J=jet(numwindows);
figure
hold on
for i=1:numwindows
    region=(10*(i-1)*samprate+1:10*(i)*samprate);
    plot(dt(region), dtrace(region), 'color', J(i,:))
end
ylim([-70 0])
xlabel('time, s')
set(gcf, 'pos', [14         703        1552         414])
%title(sprintf(' %s-%s-%s %s', expdate, session, filenum, area))

%color-coded sliding histogram
figure;
hold on
for i=1:numwindows
    region=(100*(i-1)*samprate+1:100*(i)*samprate);
%    fprintf('\n%d : %d', min(region), max(region))
    [n, x]=hist(scaledtrace(region), 500);
    n=n/max(n);
    plot(x, n, 'color', J(i,:))
    xlim([-70 -20])
end
set(gcf, 'pos', [976   143   560   420])
%title(sprintf(' %s-%s-%s %s', expdate, session, filenum, area))

combplot(1:4, [4 1])
orient tall
