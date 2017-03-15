function PlotTC_edit_trials(expdate1, session1, filenum1)
%E2 tuning curve script
%plot tuning curve
%data needs to be COPIED into data-backup first
%PlotTC_edit_trials(expdate1, session1, filenum1)
%eg. PlotTC_edit_trials('032607','001','001')
%can now handle multiple durations mw 013108
%optimized to plot selected trials, e.g. for
%an unstable recording. mw 041608
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0 fprintf('\nno input\n'); return; end
xlimits=[00 550]; %x limits for axis

loadit=1;
monitor=0;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

global pref
if isempty(pref) Prefs; end
username=pref.username;

godatadir(expdate1, session1, filenum1)
datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate1,username, session1, filenum1);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate1,username, session1, filenum1);
stimfile1=sprintf('%s-%s-%s-%s-stim.mat', expdate1, username, session1, filenum1);

fprintf('\nload file 1: ')
fprintf('\ntrying to load %s...', datafile1)
L=load(datafile1);
E=load(eventsfile1);
S=load(stimfile1);

fprintf('done.');
event1=E.event;
trace1=L.trace;
nativeOffset1=L.nativeOffset;
nativeScaling1=L.nativeScaling;
stim1=S.nativeScalingStim*double(S.stim);

clear E L S


fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1)+nativeOffset1;
if lostat1==-1 lostat1=length(scaledtrace1);end
t=1:length(scaledtrace1);
t=1000*t/samprate;
fprintf('\ntotal duration %d s', round(max(t)/1000))
tracelength=700; %in ms
baseline=100; %in ms

figure
plot(scaledtrace1)
hold on
zoom xon
cont=1;
G=ones(size(scaledtrace1));
p=plot(G, 'r');
fprintf('\n')
while (cont)
    r=input('enter 1 to edit, 0 to finish');
    switch r
        case 1
            fprintf('\n\nclick twice to define ranges of data to exclude\n')
            [x, y]=ginput(2);
            if x(1)<1 x(1)=1;end
            if x(2)>length(G) x(2)=length(G);end

            G(round(x(1)):round(x(2)))=0;
            set(p, 'visible', 'off')
            p=plot(G, 'r');

        case 0
            cont=0;
        otherwise
    end



end

%get freqs/amps
j=0;
for i=1:length(event1)
    %    if strcmp(event1(i).Type, '2tone') |strcmp(event1(i).Type, 'tone')
    if strcmp(event1(i).Type, '2tone') |strcmp(event1(i).Type, 'tone') | strcmp(event1(i).Type, 'whitenoise')%mw020807
        j=j+1;
        if strcmp(event1(i).Type, 'tone')
            allfreqs(j)=event1(i).Param.frequency;
        elseif strcmp(event1(i).Type, 'whitenoise')
            allfreqs(j)=-1;
        end
        % allfreqs(j)=event1(i).Param.frequency;%mw020807
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    end
end
freqs1=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs1);
numamps=length(amps);
numdurs=length(durs);

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
nreps1=zeros(numfreqs, numamps, numdurs);

%extract the traces into a big matrix M
j=0;
for i=1:length(event1)
    %    if strcmp(event1(i).Type, '2tone') | strcmp(event1(i).Type,    'tone')%mw020807
    if strcmp(event1(i).Type, '2tone') | strcmp(event1(i).Type, 'tone') | strcmp(event1(i).Type, 'whitenoise')%mw020807
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
            elseif G(region)
                %freq=event1(i).Param.frequency;%mw020807
                if strcmp(event1(i).Type, 'tone')
                    freq=event1(i).Param.frequency;
                elseif strcmp(event1(i).Type, 'whitenoise')
                    freq=-1;
                end
                amp=event1(i).Param.amplitude;
                dur=event1(i).Param.duration;
                findex= find(freqs1==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps1(findex, aindex, dindex),:)=scaledtrace1(region);
                M1stim(findex,aindex,dindex, nreps1(findex,aindex, dindex),:)=stim1(region);
            else
                %G must have a zero, exclude trace
                fprintf('\nexcluding trace')
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
%axmax=[-1 1];
%axmax=1;


%plot all trials of the tuning curve
offset=5;
for dindex=1:numdurs;
    figure
    p=0;
    subplot1( numamps,numfreqs)
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1( p)
            hold on
            nreps=nreps1( findex, aindex, dindex);
            for i=1:nreps
                trace1=squeeze(M1(findex, aindex, dindex,i, :));
                %trace1=trace1-mean(trace1(1:100));
                %             stimtrace=squeeze(M1stim(findex, aindex, dindex, 1, :));
                %             stimtrace=stimtrace-mean(stimtrace(1:100));
                %             stimtrace=stimtrace./max(abs(stimtrace));
                %             stimtrace=stimtrace*.1*diff(axmax);
                %             stimtrace=stimtrace+axmax(1);
                t=1:length(trace1);
                t=t/10;
                plot(t, trace1+i+offset, 'b' );
                %            plot(t, trace1, 'b', t, stimtrace, 'm' );

                ylim([-60 60]);
                xlim(xlimits)
            end
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s dur: %dms', expdate1,session1, filenum1, durs(dindex)))
end

% find resting Vm
vrest=mean(M1(:,:,:,:,1:100), 5);
vrest=mean(mean(mean(mean(vrest))));


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
            trace1=trace1-vrest;
            stimtrace=squeeze(M1stim(findex, aindex, dindex, 1, :));
            stimtrace=stimtrace-mean(stimtrace(1:100));
            stimtrace=stimtrace./max(abs(stimtrace));
            stimtrace=stimtrace*.1*diff(axmax);
            stimtrace=stimtrace+axmax(1);
            t=1:length(trace1);
            t=t/10;
            plot(t, trace1, 'b', t, stimtrace, 'm' );
            ylim(axmax);
            %ylim([-100 400]);
            xlim(xlimits)
            axis off
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s dur: %dms', expdate1,session1, filenum1, durs(dindex)))

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
                text(xlimits(1), vpos, sprintf('%.1f', freqs1(findex)/1000))
            end
        end
    end
end

outfile=sprintf('out%s-%s-%s', expdate1, session1, filenum1);
save(outfile)
