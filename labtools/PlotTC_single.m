function PlotTC_single(expdate, session, filenum)
%E2 tuning curve script
%plot tuning curve
%data needs to be COPIED into data-backup first
%PlotTC_single(expdate1, session1, filenum1)
%eg. PlotTC_single('032607','001','001')
%can now handle multiple durations mw 013108
%now uses soundcardtriggerPos if available %mw 12-11-08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
Prefs
if nargin==0 fprintf('\nno input'); return; end
% expdate1='032607';
% session1='001';
% filenum1='001';
xlimits=[-25 350]; %x limits for axis


loadit=-1;
lostat1=-1;
%lostat1=2e6; %discard data after this position (in samples), -1 to skip
global pref
if isempty(pref) Prefs; end
username=pref.username;
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);

if loadit
    fprintf('\nload file 1: ')
    try
        fprintf('\ntrying to load %s...', datafile)
        godatadir(username, expdate,  session, filenum);
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);

    catch
        fprintf('failed')
        fprintf('\ntrying to process raw data ')
%         %        E2ProcessSession(raw_data_dir1, 1, processed_data_dir1)
% 
%         expType='unknown';
%         saveit=1;
%         outputdir=sprintf('%s\\%s', processed_data_dir1, processed_data_session_dir1);
%         spikeMethod='skip'; %don't detect spikes
%         cd(raw_data_dir1)
%         raw_data_session_dir=sprintf('%s-lab-%s', expdate1, session1);
%         cd(raw_data_session_dir)
%         daqfilename=sprintf('%s-lab-%s-%s.daq', expdate1,session1, filenum1);
%         expLogDataSingle=E2ProcessDAQFile(daqfilename, expType, saveit, outputdir, spikeMethod);     % and process a single file
%         cd(processed_data_dir1)
%         cd(processed_data_session_dir1)
%         fprintf('done\ntrying to load %s...', datafile1)
ProcessData_single(expdate,  session, filenum)
        godatadir(username, expdate,  session, filenum);
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);

    end
    fprintf('done.');
end
event=E.event;
stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace)+D.nativeOffset;
clear D S E


fprintf('\ncomputing tuning curve...');

samprate=1e4;
if lostat1==-1 lostat1=length(scaledtrace);end
t=1:length(scaledtrace);
t=1000*t/samprate;
fprintf('\ntotal duration %d s', round(max(t)/1000))
tracelength=250; %in ms
baseline=100; %in ms

% %mw 052908 getting a new error for first time
% ??? Attempt to reference field of non-structure array.
% a particular event unexpectedly has two stimuli stored in it as a cell array
% exper is not delivering the first stimulus, nor a trigger, it is just skipped
% the second stimulus is delivered
% solution: scour events for multiple stimuli in a cell array, and crop to the last
% for i=1:length(event)
%     if iscell(event(i).Type)
%         Etemp=event(i);
%         event(i).Type=Etemp.Type{2};
%         event(i).Param=Etemp.Param{2};
%         %pos is OK
%         fprintf('Warning: Weird skipped stimulus error?!?!?!')
%     end
% end

%get freqs/amps
j=0;
for i=1:length(event)
    %    if strcmp(event(i).Type, '2tone') |strcmp(event(i).Type, 'tone')
    if strcmp(event(i).Type, '2tone') |strcmp(event(i).Type, 'tone') ...
            | strcmp(event(i).Type, 'fmtone') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'grating')%mw020807
        j=j+1;
        if strcmp(event(i).Type, 'tone')
            allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        elseif strcmp(event(i).Type, 'whitenoise')
            allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        elseif strcmp(event(i).Type, 'fmtone')
            allfreqs(j)=event(i).Param.carrier_frequency;
        allamps(j)=event(i).Param.amplitude;
        elseif strcmp(event(i).Type, 'grating')
            j=j+1;
            allfreqs(j)=event(i).Param.angle*1000;
            allamps(j)=event(i).Param.spatialfrequency;
        end
        % allfreqs(j)=event(i).Param.frequency;%mw020807
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
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
nreps1=zeros(numfreqs, numamps, numdurs);

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    %    if strcmp(event(i).Type, '2tone') | strcmp(event(i).Type,    'tone')%mw020807
    if strcmp(event(i).Type, '2tone') | strcmp(event(i).Type, 'tone') ...
            | strcmp(event(i).Type, 'fmtone') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'grating')%mw020807
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                %freq=event(i).Param.frequency;%mw020807
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    amp=event(i).Param.amplitude;
                elseif strcmp(event(i).Type, 'whitenoise')
                    freq=-1;
                    amp=event(i).Param.amplitude;
                elseif strcmp(event(i).Type, 'fmtone')
                    freq=event(i).Param.carrier_frequency;
                    amp=event(i).Param.amplitude;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    amp=event(i).Param.spatialfrequency;
                end
                dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps1(findex, aindex, dindex),:)=scaledtrace(region);
                M1stim(findex,aindex,dindex, nreps1(findex,aindex, dindex),:)=stim1(region);
            end
        end
    end
end

% nreps1

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
for dindex=[1:numdurs]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            trace1=squeeze(mM1(findex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
            if min([trace1])<axmax(1) axmax(1)=min([trace1]);end
            if max([trace1])>axmax(2) axmax(2)=max([trace1]);end
        end
    end
end
%axmax(2)=0.1;
%axmax=[-1 3];
%axmax=1;

%plot the mean tuning curves for pre and post
for dindex=1:numdurs;
    figure
    p=0;
    subplot1( numamps,numfreqs)
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1( p)
            trace1=squeeze(mM1(findex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            stimtrace=squeeze(M1stim(findex, aindex, dindex, 1, :));
            stimtrace=stimtrace-mean(stimtrace(1:100));
            stimtrace=stimtrace./max(abs(stimtrace));
            stimtrace=stimtrace*.2*diff(axmax);
            stimtrace=stimtrace+axmax(1);
            t=1:length(trace1);
            t=t/10;
            plot( t, stimtrace, 'm',t, trace1, 'b' );
            ylim(axmax);
            %ylim([-100 400]);
            xlim(xlimits)
            axis off
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s dur: %dms', expdate,session, filenum, durs(dindex)))

    %label amps and freqs
    p=0;
    ylimits=axmax;
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(xlimits(1)-diff(xlimits), mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-.1*diff(ylimits);
                else
                    vpos=ylimits(1)-.3*diff(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
        end
    end
end