function PlotStim(varargin)
%
%plots individual trials of stimulus traces as a sanity check

%usage:
%PlotStim(expdate, session, filename)
%PlotStim(expdate, session, filename, xlimits)
%PlotStim(expdate, session, filename, xlimits, ylimits)

%
tracelength=-1;
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    ylimits=[-2 -1];
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=[-2 -1];
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



lostat1=getlostat(expdate, session, filenum);

global pref
if isempty(pref) Prefs; end
username=pref.username;

datafile=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate,username, session, filenum);
eventsfile=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate,username, session, filenum);
stimfile=sprintf('%s-%s-%s-%s-stim.mat', expdate, username, session, filenum);

try
    fprintf('\ntrying to load %s...', datafile)
    godatadir(expdate, session, filenum)
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
        fprintf('\nfound and loaded data.');
catch
    try
        fprintf('\ntrying to load %s...', datafile)
        fprintf('\n trying backup server...');
        godatadirbak(expdate, session, filenum)
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);
        fprintf('\nfound and loaded data.');
    catch
        fprintf('failed. Could not find data')
    end
end

event=E.event;
stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S

fprintf('\ncomputing tuning curve...');

samprate=1e4;
if isempty(lostat1) lostat1=length(scaledtrace);end
t=1:length(scaledtrace);
t=1000*t/samprate;
tracelength=diff(xlimits); %in ms
if xlimits(1)<0
    baseline=abs(xlimits(1));
else
    baseline=0;
end

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, '2tone') |strcmp(event(i).Type, 'tone') |strcmp(event(i).Type, 'naturalsound')|strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'fmtone')
        j=j+1;
        if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, '2tone')
            allfreqs(j)=event(i).Param.frequency;
            allamps(j)=event(i).Param.amplitude;
            alldurs(j)=event(i).Param.duration;

        elseif strcmp(event(i).Type, 'fmtone')
            allfreqs(j)=event(i).Param.carrier_frequency;
            allamps(j)=event(i).Param.amplitude;
            alldurs(j)=event(i).Param.duration;
        elseif strcmp(event(i).Type, 'whitenoise')
            allfreqs(j)=-1;
            allamps(j)=event(i).Param.amplitude;
            alldurs(j)=event(i).Param.duration;
        elseif strcmp(event(i).Type, 'naturalsound')
            allfreqs(j)=0;
            if isfield(event(i).Param, 'amplitude')
                allamps(j)=event(i).Param.amplitude;
            else
                allamps(j)=-1;
            end
            alldurs(j)=event(i).Param.duration;
        elseif strcmp(event(i).Type, 'grating')
            allfreqs(j)=event(i).Param.angle*1000;
            allamps(j)=event(i).Param.spatialfrequency;
            alldurs(j)=event(i).Param.duration;
        end
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
    if strcmp(event(i).Type, '2tone') | strcmp(event(i).Type, 'tone') |strcmp(event(i).Type, 'naturalsound') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'fmtone') | strcmp(event(i).Type, 'grating')
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
                if strcmp(event(i).Type, '2tone') | strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    amp=event(i).Param.amplitude;
                elseif strcmp(event(i).Type, 'fmtone')
                    freq=event(i).Param.carrier_frequency;
                    amp=event(i).Param.amplitude;
                elseif strcmp(event(i).Type, 'whitenoise')
                    freq=-1;
                    amp=event(i).Param.amplitude;
                elseif strcmp(event(i).Type, 'naturalsound')
                    dur=event(i).Param.duration;
                    freq=0;
                            if isfield(event(i).Param, 'amplitude')
                    amp=event(i).Param.amplitude;
        else
                    amp=-1;
        end

                elseif strcmp(event(i).Type, 'grating')
                    amp=event(i).Param.spatialfrequency;
                    freq=event(i).Param.angle*1000;
                end
                dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps1(findex, aindex, dindex),:)=scaledtrace(region);
                M1stim(findex,aindex,dindex, nreps1(findex,aindex, dindex),:)=stim(region);
            end
        end
    end
end

traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
else
    for aindex=1:numamps
        for findex=1:numfreqs
            for dindex=1:numdurs
                mM1(findex, aindex, dindex,:)=mean(M1(findex, aindex, dindex, 1:nreps1(findex, aindex, dindex),:), 4);
                mM1stim(findex, aindex, dindex,:)=mean(M1stim(findex, aindex, dindex, 1:nreps1(findex, aindex, dindex),:), 4);
            end
        end
    end
end

%mM=mean(M(:,:,:,21:38,:), 4);




%find optimal axis limits
if ylimits<0
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            trace1=squeeze(mM1(findex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
            if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
        end
    end
end

%plot the mean tuning curve
for dindex=[1:numdurs]
    figure
    p=0;
    subplot1( numamps,numfreqs)
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1( p)
            trace1=squeeze(mM1(findex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            stimtrace=squeeze(mM1stim(findex, aindex, dindex,  :));
            stimtrace=stimtrace-mean(stimtrace(1:100));
            stimtrace=stimtrace./max(abs(stimtrace));
            stimtrace=stimtrace*.1*diff(ylimits);
            stimtrace=stimtrace+ylimits(1);

            t=1:length(trace1);
            t=t/10;
            t=t-baseline;
            plot(t, trace1, 'b', t, stimtrace, 'm');
            ylim(ylimits)
            xlim(xlimits)
            axis off
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('Mean across trials. %s-%s-%s dur: %dms', expdate,session, filenum, durs(dindex)))
subplot1(p)
axis on

    %label amps and freqs
    p=0;
    for aindex=[1:numamps]
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
        end
    end
end

%plot all trials of tuning curve

for dindex=[1:numdurs]

    offset_increment=diff(ylimits);

    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            figure
            if isunix & gcf>15 keyboard, end
            hold on
            offset=0;
            for rep=1:nreps1(findex, aindex, dindex)
                trace1=squeeze(M1(findex, aindex, dindex,rep, :));
                trace1=trace1-mean(trace1(1:100));
                trace1=trace1+offset;
                clippedtrace=clipspikes(trace1);%include an overplot of spikes-removed trace
                stimtrace=squeeze(mM1stim(findex, aindex, dindex,  :));
                stimtrace=stimtrace-mean(stimtrace(1:100));
                stimtrace=stimtrace./max(abs(stimtrace));
                stimtrace=stimtrace*.1*diff(ylimits);
                stimtrace=stimtrace+ylimits(1);

                t=1:length(trace1);
                t=t/10;
                t=t-baseline;
                plot(t, trace1,'b')
%                 plot(t, clippedtrace, 'r');

                ylim([ylimits(1) offset+ylimits(2)])
                xlim(xlimits)
                offset=offset+offset_increment;
                %             axis off
            end
            plot(t, stimtrace, 'm');
            title(sprintf('%s-%s-%s dur: %dms', expdate,session, filenum, durs(dindex)))
            vpos=ylimits(1)-.1*diff(ylimits);
            text(mean(xlimits), vpos, sprintf('%.1f(%d)', freqs(findex)/1000, findex))
            text(xlimits(1)-.1*diff(xlimits), mean(ylimits), int2str(amps(aindex)))


            set(gcf, 'pos', [560   122   550   817])
        end
    end


end

%plot all trials of tuning curve

for dindex=[1:numdurs]

    offset_increment=diff(ylimits);

    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            figure
            if isunix & gcf>15 keyboard, end
            hold on
            offset=0;
            offset=offset+offset_increment;
            trace1=trace1+offset;
            trace1=squeeze(mM1(findex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            trace1=trace1./max(abs(trace1));
            plot(t, trace1++offset+ylimits(1), 'b');
            offset=offset+offset_increment;

            for rep=1:nreps1(findex, aindex, dindex)
%                 trace1=squeeze(M1(findex, aindex, dindex,rep, :));
%                 trace1=trace1-mean(trace1(1:100));
%                 trace1=trace1+offset;
%                 clippedtrace=clipspikes(trace1);%include an overplot of spikes-removed trace
                stimtrace=squeeze(mM1stim(findex, aindex, dindex,  :));
                stimtrace=stimtrace-mean(stimtrace(1:100));
                stimtrace=stimtrace./max(abs(stimtrace));
                stimtrace=stimtrace*1*diff(ylimits);
                stimtrace=stimtrace+ylimits(1);
                 stimtrace=stimtrace+offset;

                t=1:length(stimtrace);
                t=t/10;
                t=t-baseline;
                plot(t, stimtrace,'m')
%                 plot(t, clippedtrace, 'r');

                ylim([ylimits(1) offset+ylimits(2)])
                xlim(xlimits)
                offset=offset+offset_increment;
                %             axis off
            end
            title(sprintf('%s-%s-%s dur: %dms', expdate,session, filenum, durs(dindex)))
            vpos=ylimits(1)-.1*diff(ylimits);
            text(mean(xlimits), vpos, sprintf('%.1f(%d)', freqs(findex)/1000, findex))
            text(xlimits(1)-.1*diff(xlimits), mean(ylimits), int2str(amps(aindex)))


            set(gcf, 'pos', [560   122   550   817])
        end
    end


end

fprintf('\ndone')
