function PlotITD(varargin)
%
% usage: PlotITD('expdate','session','filename')
% PlotITD('expdate','session','filename', [xlimits])
% PlotITD('expdate','session','filename', [xlimits], [ylimits])
% 
% default xlimits = [0 200]; ylimits = [-2 -1]
% Adapted from PlotTC by mak 29dec2010 


if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
%     durs=getdurs(expdate, session, filenum);
%     dur=max([durs 100]);
    xlimits=[0 200]; %x limits for axis
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

[D E S]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event); fprintf('\nno tones\n'); return; end
stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S

fprintf('\ncomputing tuning curve...');

samprate=1e4;
if lostat1==-1; lostat1=length(scaledtrace);end


%get itds/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'itdwhitenoise') 
        j=j+1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allitds(j)=event(i).Param.itd;
    else 
         error('this file is not an itd tuning curve');
    end
end
itds=unique(allitds);
amps=unique(allamps);
durs=unique(alldurs);
numitds=length(itds);
numamps=length(amps);
numdurs=length(durs);

M1=[];
nreps=zeros(numitds, numamps, numdurs);

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
     if strcmp(event(i).Type, 'itdwhitenoise')
          if isfield(event(i), 'soundcardtriggerPos')
               pos=event(i).soundcardtriggerPos;
          else
               pos=event(i).Position_rising;
          end
          start=(pos+xlimits(1)*1e-3*samprate);
          stop=(pos+xlimits(2)*1e-3*samprate)-1;
          region=start:stop;
          if isempty(find(region<0)) %(disallow negative start times)
               if stop>lostat1
                    fprintf('\ndiscarding trace')
               else
                    itd=event(i).Param.itd;
                    amp=event(i).Param.amplitude;
                    dur=event(i).Param.duration;
                    iindex= find(itds==itd);
                    aindex= find(amps==amp);
                    dindex= find(durs==dur);
                    nreps(iindex, aindex, dindex)=nreps(iindex, aindex, dindex)+1;
                    M1(iindex,aindex,dindex, nreps(iindex, aindex, dindex),:)=scaledtrace(region);
                    M1stim(iindex,aindex,dindex, nreps(iindex, aindex, dindex),:)=stim1(region);
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
        for iindex=1:numitds
            for dindex=1:numdurs
                mM1(iindex, aindex, dindex,:)=mean(M1(iindex, aindex, dindex, 1:nreps(iindex, aindex, dindex),:), 4);
                mM1stim(iindex, aindex, dindex,:)=mean(M1stim(iindex, aindex, dindex, 1:nreps(iindex, aindex, dindex),:), 4);
            end
        end
    end
end


%find optimal axis limits
if ylimits<0
    for aindex=numamps:-1:1
        for iindex=1:numitds
            trace1=squeeze(mM1(iindex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            if min(trace1)<ylimits(1); ylimits(1)=min(trace1);end
            if max(trace1)>ylimits(2); ylimits(2)=max(trace1);end
        end
    end
end


%plot the mean tuning curve
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numitds)
    for aindex=numamps:-1:1
        for iindex=1:numitds
            p=p+1;
            subplot1(p)
            trace1=squeeze(mM1(iindex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            stimtrace=squeeze(mM1stim(iindex, aindex, dindex, :));
            stimtrace=stimtrace-mean(stimtrace(1:100));
            stimtrace=stimtrace./max(abs(stimtrace));
            stimtrace=stimtrace*.1*diff(ylimits);
            stimtrace=stimtrace+ylimits(1);

            t=1:length(trace1);
            t=t/10;
            plot(t, trace1, 'b', t, stimtrace, 'm');
            ylim(ylimits)
%             xlim(xlimits)
            axis off
        end
    end
    %     subplot1(ceil(numfreqs/3))
    subplot1(1)
    h=title(sprintf('%s-%s-%s dur: %dms', expdate,session, filenum, durs(dindex)));
    set(h, 'HorizontalAlignment', 'left')


    %label amps and freqs
    p=0;
    for aindex=numamps:-1:1
        for iindex=1:numitds
            p=p+1;
            subplot1(p)
            if iindex==1
                 text(-200, mean(ylimits), sprintf('%d dB SPL',amps(aindex)))
%                 text(-200, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(iindex,2) % odd freq
%                      vpos=ylimits(1);
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos/2.5, sprintf('%.1f', itds(iindex)))
            end
        end
    end
end


fprintf('\n\n');
labtools;