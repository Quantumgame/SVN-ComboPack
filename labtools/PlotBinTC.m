function PlotBinTC(varargin)
%
%usage: PlotBinTC(expdate, session, filename)
%PlotBinTC(expdate, session, filename, xlimits)
%PlotBinTC(expdate, session, filename, xlimits, ylimits)
%
%plots a binaural tuning curve
%
%now uses soundcardtriggerPos if available %mw 12-11-08
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

lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip
if     strcmp(expdate,'061411') && strcmp(session,'004') && strcmp(filenum,'001')
    lostat1=1.595e6;
% elseif     strcmp(expdate,'MMDDYY') && strcmp(session,'00') && strcmp(filenum,'00')
%     lostat1=1.595e6;
end
[D E S]=gogetdata(expdate,session,filenum);

event=E.event;
if isempty(event) fprintf('\nno tones\n'); return; end
stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S

fprintf('\ncomputing tuning curve...');

samprate=1e4;
if lostat1==-1 lostat1=length(scaledtrace);end
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
    if strcmp(event(i).Type, 'bintone') | strcmp(event(i).Type, 'binwhitenoise')
        j=j+1;
        allRamps(j)=event(i).Param.Ramplitude;
        allLamps(j)=event(i).Param.Lamplitude;
        alldurs(j)=event(i).Param.duration;
        if strcmp(event(i).Type, 'bintone')
            allfreqs(j)=event(i).Param.frequency;
        elseif strcmp(event(i).Type, 'binwhitenoise')
            allfreqs(j)=-1;
        end

    end
end
freqs=unique(allfreqs);
Ramps=unique(allRamps);
Lamps=unique(allLamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(Ramps); %assuming num Ramps and num Lamps are the same
numdurs=length(durs);

M1=[];
nreps=zeros(numfreqs, numamps, numamps, numdurs);

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'bintone') | strcmp(event(i).Type, 'binwhitenoise')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) &~isempty(event(i).Position_rising)
                pos=event(i).Position_rising;
            end
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
                switch event(i).Type
                    case 'bintone'
                        freq=event(i).Param.frequency;
                    case 'binwhitenoise'
                        freq=-1;
                end

                Ramp=event(i).Param.Ramplitude;
                Lamp=event(i).Param.Lamplitude;
                dur=event(i).Param.duration;
                findex= find(freqs==freq);
                Raindex= find(Ramps==Ramp);
                Laindex= find(Lamps==Lamp);
                dindex= find(durs==dur);
                nreps(findex, Raindex, Laindex, dindex)=nreps(findex, Raindex, Laindex, dindex)+1;
                M1(findex,Raindex, Laindex,dindex, nreps(findex, Raindex, Laindex, dindex),:)=scaledtrace(region);
                M1stim(findex,Raindex, Laindex,dindex, nreps(findex, Raindex, Laindex, dindex),:)=stim1(region);
            end
        end
    end
end

traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,:,traces_to_keep,:), 5);
else
    for Raindex=1:numamps
        for Laindex=1:numamps
            for findex=1:numfreqs
                for dindex=1:numdurs
                    mM1(findex, Raindex, Laindex, dindex,:)=mean(M1(findex, Raindex, Laindex, dindex, 1:nreps(findex, Raindex, Laindex, dindex),:), 5);
                    mM1stim(findex, Raindex, Laindex, dindex,:)=mean(M1stim(findex, Raindex, Laindex, dindex, 1:nreps(findex, Raindex, Laindex, dindex),:), 5);
                end
            end
        end
    end
end


%find optimal axis limits
if ylimits<0
    for Raindex=[numamps:-1:1]
        for Laindex=[numamps:-1:1]
            for findex=1:numfreqs
                trace1=squeeze(mM1(findex, Raindex, Laindex, dindex, :));
                trace1=trace1-mean(trace1(1:100));
                if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
                if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
            end
        end
    end
end


%plot the mean tuning curve
for dindex=[1:numdurs]
    for findex=1:numfreqs
        figure
        p=0;
        subplot1( numamps,numamps)
        for Raindex=[numamps:-1:1]
            for Laindex=[1:numamps]

                p=p+1;
                subplot1( p)
                trace1=squeeze(mM1(findex, Raindex, Laindex, dindex, :));
                trace1=trace1-mean(trace1(1:100));
                stimtrace=squeeze(mM1stim(findex, Raindex, Laindex, dindex,  :));
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
        %     subplot1(ceil(numfreqs/3))
        subplot1(1)
        h=title(sprintf('%s-%s-%s %.1f kHz dur: %dms', expdate,session, filenum, freqs(findex)/1000, durs(dindex)));
        set(h, 'HorizontalAlignment', 'left')


        %label amps and freqs
        p=0;
        for Raindex=[numamps:-1:1]
            for Laindex=1:numamps
                p=p+1;
                subplot1(p)
                if Laindex==1
                    if Ramps(Raindex)==-1000
                        text(xlimits(1), mean(ylimits), 'silence', 'HorizontalAlignment', 'center');
                    else
                        text(xlimits(1), mean(ylimits), int2str(Ramps(Raindex)))
                    end
                end
                if Raindex==1
                    vpos=ylimits(1)-.1*diff(ylimits);
                    if Lamps(Laindex)==-1000
                        text(mean(xlimits), vpos, 'silence','HorizontalAlignment', 'center');
                    else
                        text(mean(xlimits), vpos, int2str(Lamps(Laindex)))
                    end
                end

                if Laindex==1 & Raindex==floor(numamps/2)
                    vpos=mean(ylimits);
                    T=text(xlimits(1)-.2*diff(xlimits), vpos, 'Contralateral','rotation', 90,'HorizontalAlignment', 'center');
                end
                if Laindex==floor(numamps/2) & Raindex==1
                    vpos=ylimits(1)-.3*diff(ylimits);
                    T=text(mean(xlimits), vpos, 'Ipsilateral','HorizontalAlignment', 'center');
                end
                axis off
            end
        end

    end
end


fprintf('\ndone\n\n')


