function PlotAOpulse(varargin)
%
%plots individual trials for responses to an AO pulse
%(such as a laser/LED pulse)
%usage:
%PlotAOpulse(expdate, session, filename)
%PlotAOpulse(expdate, session, filename, xlimits)
%PlotAOpulse(expdate, session, filename, xlimits, ylimits)
%PlotAOpulse(expdate, session, filename, [xlimits], [ylimits], [trials])
%
%optional argument [trials] is a vector of trials to plot, defaults to all
%
trials=[];
tracelength=-1;
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=[];
    ylimits=[];
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=[];
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
    trials=varargin{6};
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



lostat1=[];

global pref
if isempty(pref) Prefs; end
username=pref.username;

[D E S]=gogetdata(expdate,session,filenum)

event=E.event;
stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
scaledtrace2=[];
try scaledtrace2=D2.nativeScaling*double(D2.trace) +D2.nativeOffset;
end
clear D E S D2

%optional highpass filter
% high_pass_cutoff=300; %Hz
% fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
% [b,a]=butter(1, high_pass_cutoff/(1e4/2), 'high');
% scaledtrace=filtfilt(b,a,scaledtrace);


fprintf('\ncomputing tuning curve...');



%get durs
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'aopulse')  strcmp(event(i).Type, 'led') %led is an old pulse type used in MakeAOpulseProtocol
        j=j+1;
        alldurs(j)=event(i).Param.width;
    elseif strcmp(event(i).Type, 'led') %led is an old pulse type used in MakeAOpulseProtocol
        j=j+1;
        alldurs(j)=event(i).Param.duration;
    end
end
durs=unique(alldurs);
numdurs=length(durs);
if isempty(xlimits)
    xlimits=[-.5*max(durs) 1.5*max(durs)]; %x limits for axis
end

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

M1=[];
nreps=zeros(numdurs);

%extract the traces into a big matrix M
j=0;
cont=1;
for i=1:length(event)
    if (cont)
    if strcmp(event(i).Type, 'aopulse') | strcmp(event(i).Type, 'led')
            
            pos=event(i).Position_rising;
            
            
            start=(pos-baseline*1e-3*samprate);
            stop=(start+tracelength*1e-3*samprate)-1;
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                if stop>lostat1
                    fprintf('\ndiscarding trace')
                else
                    if strcmp(event(i).Type, 'aopulse') 
                        dur=event(i).Param.width;
                    elseif strcmp(event(i).Type, 'led') 
                        dur=event(i).Param.duration;
                    end
                    dindex= find(durs==dur);
                    nreps(dindex)=nreps(dindex)+1;
                    M1(dindex, nreps(dindex),:)=scaledtrace(region);
                    if ~isempty(scaledtrace2)
                        M2(dindex, nreps(dindex),:)=scaledtrace2(region);
                    end
                    M1stim(dindex, nreps(dindex),:)=stim(region);
                end
                if ~isempty(trials)
                    if max(nreps)>max(trials)
                        cont=0;%stop extracting
                        fprintf('\nstopped computing after %d trials', max(nreps))
                    end
                end
            end
        end
    end
end



if ~isempty(trials)
    fprintf('\n using only traces %d-%d, discarding others', trials(1), trials(end));
    mM1=mean(M1(:,trials,:), 2);
    if ~isempty(scaledtrace2)
        mM2=mean(M2(:,trials,:), 2);
    end
    mM1stim=mean(M1stim(:,trials,:), 2);
else
    for dindex=1:numdurs
        mM1(dindex,:)=mean(M1(dindex, 1:nreps(dindex),:), 2);
        if ~isempty(scaledtrace2)
            mM2(dindex,:)=mean(M2(dindex, 1:nreps(dindex),:), 2);
        end
        mM1stim(dindex,:)=mean(M1stim(dindex, 1:nreps(dindex),:), 2);
    end
end

if ~isempty(trials)
 trialstring=sprintf('%d-%d', trials(1), trials(end));
else
    trials=1:min(min(min(min(nreps))));
  trialstring=sprintf(' all trials (%d-%d)', trials(1), trials(end));
end

find optimal axis limits
if isempty(ylimits) |  ylimits<0
    ylimits=[0 0]
    for dindex=1:numdurs
        trace1=squeeze(mM1(dindex, :));
        trace1=trace1-mean(trace1(1:100));
        if min([trace1])<ylimits(1) 
            ylimits(1)=min([trace1]);end
        if max([trace1])>ylimits(2) 
            ylimits(2)=max([trace1]);end
    end
end

% plot the mean tuning curve
figure
p=0;
subplot1(numdurs, 1)
for dindex=[1:numdurs]
    subplot1( numdurs)
    p=p+1;
    subplot1( p)
    trace1=squeeze(mM1(dindex, :));
    trace1=trace1-mean(trace1(1:100));
    trace2=0.*trace1;
    if ~isempty(scaledtrace2)
        trace2=squeeze(mM2(dindex, :));
        trace2=trace2-mean(trace2(1:100));
        trace2=trace2./max(abs(trace2));
        trace2=trace2*.1*diff(ylimits);
        trace2=trace2+ylimits(1);
    end
%     stimtrace=squeeze(mM1stim(dindex,  :));
%     stimtrace=stimtrace-mean(stimtrace(1:100));
%     stimtrace=stimtrace./max(abs(stimtrace));
%     stimtrace=stimtrace*.1*diff(ylimits);
%     stimtrace=stimtrace+ylimits(1);
%     stimtrace=stimtrace+.05*diff(ylimits);
    
    t=1:length(trace1);
    t=t/10;
    t=t-baseline;
    %plot(t, trace1, 'b', t, stimtrace, 'm',t, trace2,'c');
    plot(t, trace1, 'b',t, trace2,'c');
%     ylim(ylimits)
    xlim(xlimits)
    axis off
end



subplot1(1)
title(sprintf('Mean across trials %s. %s-%s-%s ',trialstring, expdate,session, filenum))
subplot1(p)
axis on




%plot all trials of tuning curve
figure
offset_increment=diff(ylimits);

for dindex=[1:numdurs]
    
    
    hold on
    offset=0;
    for rep=trials
        trace1=squeeze(M1(dindex,rep, :));
        trace1=trace1-mean(trace1(1:100));
        trace1=trace1+offset;
        trace2=0.*trace1;
        if ~isempty(scaledtrace2)
            trace2=squeeze(M2(dindex,rep, :));
            trace2=trace2-mean(trace2(1:100));
            trace2=trace2./max(abs(trace2));
            trace2=trace2*.2*diff(ylimits);
            trace2=trace2+offset;
        end
        clippedtrace=clipspikes(trace1);%include an overplot of spikes-removed trace
        stimtrace=squeeze(mM1stim(dindex,  :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits);
        stimtrace=stimtrace+ylimits(1);
        stimtrace=stimtrace+.05*diff(ylimits);
        
        t=1:length(trace1);
        t=t/10;
        t=t-baseline;
        plot(t, trace1,'b',t, trace2,'c')
        %                 plot(t, clippedtrace, 'r');
        
        
        offset=offset+offset_increment;
        %             axis off
    end
    plot(t, stimtrace, 'm');
    ylim([ylimits(1) offset+ylimits(2)])
    xlim(xlimits)
    title(sprintf('trials %s. %s-%s-%s ',trialstring, expdate,session, filenum))
    vpos=ylimits(1)-.1*diff(ylimits);
    
    set(gcf, 'pos', [560   122   550   817])
end

fprintf('\ndone')
