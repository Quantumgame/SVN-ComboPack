function PlotASR(expdate,session,filenum )

%usage: PlotASR(expdate,session,filenum )
%
% E2 tuning curve script
%plot ASR
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%xlimits=[700 900]; %x limits for axis
xlimits=[0 500]; %x limits for axis

lostat1=-1; %discard data after this position (in samples), -1 to skip

% [datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
%     godatadir(expdate, session, filenum)
%   
% fprintf('\nload file: ')
%     fprintf('\ntrying to load %s...', datafile)
%     D=load(datafile);
%     E=load(eventsfile);
%     S=load(stimfile);
% 
% fprintf('done.');

[D E S]=gogetdata(expdate,session,filenum);

event=E.event;
stim=S.nativeScalingStim*double(S.stim);
scaledtrace1=D.nativeScaling*double(D.trace) + D.nativeOffset;
clear D E S

fprintf('\ncomputing tuning curve...');

samprate=1e4;
if lostat1==-1 lostat1=length(scaledtrace1);end
%t=1:length(scaledtrace1);
%t=1000*t/samprate;
tracelength=1000; %in ms
baseline=100; %in ms

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'ASR')
        j=j+1;
        allprepulseamps(j)=event(i).Param.prepulseamp;
    end
end
M1=[];
prepulseamps=unique(allprepulseamps);
numprepulseamps=length(prepulseamps);
nreps1=zeros(1, numprepulseamps);

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'ASR')
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
                prepulseamp=event(i).Param.prepulseamp;
                ppaindex= find(prepulseamp==prepulseamps);
                nreps1(ppaindex)=nreps1(ppaindex)+1;
                M1(ppaindex, nreps1(ppaindex),:)=scaledtrace1(region);
                M1stim(ppaindex, nreps1(ppaindex),:)=stim(region);
            end
        end
    end
end
% temp_mk_asr; %this is a debugging script investigating the actual isi by comparing all sc trigs
%     mk 21jun2012

dindex=1;
traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,traces_to_keep,:), 2);
else
    mM1=mean(M1, 2);
end





%find optimal axis limits
axmax=[0 0];
% for ppaindex=[1:numprepulseamps]
%         trace1=squeeze(mM1(ppaindex,:));
%         trace1=trace1-mean(trace1(1:100));
% %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
%         if min([trace1])<axmax(1) axmax(1)=min([trace1]);end
%         if max([trace1])>axmax(2) axmax(2)=max([trace1]);end
% end
axmax(1)=min(min(min(M1)));
axmax(2)=max(max(max(M1)));
%axmax(2)=.2;

%plot trials and mean
figure;hold on
p=0;
subplot1(numprepulseamps, 1)
for ppaindex=[1:numprepulseamps]
    p=p+1;
    subplot1( p)
    hold on
    for i=1:nreps1
        trace1=squeeze(M1(ppaindex,i,:));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1, 'b');
    end
    stimtrace=squeeze(M1stim(ppaindex, 1, :));
    stimtrace=stimtrace-mean(stimtrace(1:100));
    stimtrace=stimtrace./max(abs(stimtrace));
    stimtrace=stimtrace*.1*diff(axmax);
%     stimtrace=stimtrace+axmax(1);
    stimtrace=stimtrace-axmax(1)*.1;
    trace1=squeeze(mM1(ppaindex,:));
    trace1=trace1-mean(trace1(1:100));
    r=plot(t, trace1, 'r');
    set(r, 'linewidth', 2)
    plot(t, stimtrace, 'm' );
%     ylim(1.25*axmax);
%     ylim([-axmax(2) axmax(2)]);
    %xlim([250 400])
    xlim(xlimits)
    %         axis off
end
subplot1(1)
title(sprintf('%s-%s-%s', expdate,session, filenum))

%label amps and freqs
p=0;
for ppaindex=[1:numprepulseamps]
    p=p+1;
    subplot1(p)

    text(400, 1.25*mean(axmax), [int2str(prepulseamps(ppaindex)), ' dB'])

end
fprintf('\n');

