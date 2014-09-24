function VCPulseScript
%script for looking at response to a VC pulse

expdate='101806';
session='001';
filenum='001';
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
    if strcmp(event(i).Type, 'pulse') 
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





figure;
hold on;
for i=1:size(Mt,1)
    plot(Mt(i,1:3800)+1.5e3*i);
    plot(1e3*Ms(i,1:3800)+1.5e3*i, 'r');
end

keyboard

