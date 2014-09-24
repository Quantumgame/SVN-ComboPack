function PlotVC_WNTrain2(expdate, session, filenum, varargin)
% usage: PlotVC_WNTrain2(expdate, session, filenum, [Vout])
% plots a VCTC for WNTrain2 stimuli
%(these are WN trains at various isis but with fixed train duration)
%processed data is saved in an outfile.

if nargin==0
    fprintf('\nnoinput\n')
    return
elseif nargin==3
    Vout=0;
elseif nargin==4
    Vout=varargin{1};
else
    error('PlotVC_WNTrain2: wrong number of arguments');
end
fprintf('\nusing Vout=%g\n', Vout)

godatadir(expdate, session, filenum)
outfilename=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
if exist(outfilename)==2
    load(outfilename);
else
    generate_outfile(expdate, session, filenum, Vout); %subfunction
    load(outfilename);
end

%extract variables from outfile
scaledtrace=out.scaledtrace;
Mt=out.Mt;
Ms=out.Ms;
mMt=out.mMt;
mMs=out.mMs;
lostat=out.lostat;
freqs1=out.freqs;
isis=out.isis;
numisis=out.numisis;
amps=out.amps;
durs=out.durs;
nreps=out.nreps;
event=out.event;
xlimits=out.xlimits;
corrected_potentials=out.corrected_potentials;
Rs=out.Rs;
Vout=out.Vout;
Rin=out.Rin;
Rt=out.Rt;
meanrin=out.meanrin;
meanrs=out.meanrs;
Rs_pulses=out.Rs_pulses;
meanpulse=out.meanpulse;
potentials=out.potentials;
numpotentials=length(potentials);
samprate=out.samprate;

figure
plot(squeeze(mean(mean(Rs_pulses))))
yl=ylim;
text(100, yl(1)+.8*diff(ylim), sprintf('Rs: %.1f\nRt: %.1f\nRin: %.1f', median(median(Rs)),median(median(Rt)),median(median(Rin)) ))


%plot stimuli to check for any glitches
offset_incr=2*max(max(max(max(abs(Ms)))));
figure
p=0;
subplot1(numisis, 1)
for isiindex=[1:numisis]
    p=p+1;
    subplot1( p)
    offset=0;
    for pindex=1:numpotentials
        for rep=1: nreps(isiindex, pindex)
            trace_stim=squeeze(Ms(isiindex, pindex,rep, :));
            trace_stim=trace_stim-median(trace_stim(1:100));
            trace_stim=trace_stim+offset;
            offset=offset+offset_incr;
            hold on
            plot(trace_stim, 'r');
        end
    end
end
subplot1(1)
title(sprintf('%s-%s-%s', expdate,session, filenum))
set(gcf, 'pos', [ 63          72        1488         887])

%find optimal axis limits
ylimits=[0 0];
for isiindex=[1:numisis]
    for pindex=1:numpotentials
        trace1=squeeze(mMt(isiindex, pindex, :));
        if length(trace1)>xlimits(2)*samprate/1000
            trace1=trace1(1:xlimits(2)*samprate/1000);
        end
        trace1=trace1-mean(trace1(1:100));
        if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
        if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
    end
end

%plot VC for each trial
if (1) %set to 0 if you don't want these plots
 %       p=0;
    c='bmgryc';
%    subplot1(numisis, 1)
    for isiindex=[1:numisis]
  %      p=p+1;
   %     subplot1( p)
    
   
  figure
    for pindex=1:numpotentials
        reps=1: nreps(isiindex, pindex);

        %manually exclude individual trials from plot
%          if isiindex==1 & pindex==1 
%              rep2exclude=5;
%              reps=setdiff(reps, rep2exclude);
%              fprintf('\nmanually excluding isi %d potential %d rep %d from plot', isiindex, pindex, rep2exclude)
%         end
%          if isiindex==2 & pindex==1
%              rep2exclude=5;
%              reps=setdiff(reps, rep2exclude);
%              fprintf('\nmanually excluding isi %d potential %d rep %d from plot', isiindex, pindex, rep2exclude)
%          end
%          if isiindex==3 & pindex==1 
%              rep2exclude=5;
%              reps=setdiff(reps, rep2exclude);
%              fprintf('\nmanually excluding isi %d potential %d rep %d from plot', isiindex, pindex, rep2exclude)
%          end
%         if isiindex==4 & pindex==1 
%              rep2exclude=5;
%              reps=setdiff(reps, rep2exclude);
%              fprintf('\nmanually excluding isi %d potential %d rep %d from plot', isiindex, pindex, rep2exclude)
%         end
%         if isiindex==5 & pindex==1 
%              rep2exclude=5;
%              reps=setdiff(reps, rep2exclude);
%              fprintf('\nmanually excluding isi %d potential %d rep %d from plot', isiindex, pindex, rep2exclude)
%         end
%         if isiindex==6 & pindex==1 
%              rep2exclude=5;
%              reps=setdiff(reps, rep2exclude);
%              fprintf('\nmanually excluding isi %d potential %d rep %d from plot', isiindex, pindex, rep2exclude)
%         end
%         if isiindex==7 & pindex==1 
%              rep2exclude=5;
%              reps=setdiff(reps, rep2exclude);
%              fprintf('\nmanually excluding isi %d potential %d rep %d from plot', isiindex, pindex, rep2exclude)
%         end
            for rep=reps
                trace1=squeeze(Mt(isiindex, pindex, rep, :));
                trace1=trace1-median(trace1(1:100));
                if pindex==numpotentials
                trace1=trace1+.1*diff(ylimits); %nudge the outward currents up just a bit
                end
                trace_stim=squeeze(mMs(isiindex, pindex, :));
                trace_stim=trace_stim-median(trace_stim(1:100));
                trace_stim=trace_stim/max(trace_stim); %normalize stim
                trace_stim=trace_stim*.05*diff(ylimits);
                trace_stim=trace_stim+ylimits(1);
                t=1:length(trace1);
                offset=.5*diff(ylimits);
                t=t/10;
                hold on
                plot(t, trace1+offset*(2*rep-1), c(pindex), t, trace_stim, 'r');%spaces e&i trial sets
                xpos=xlimits(1)+.7*diff(xlimits);
                ypos=ylimits(1)+.2*diff(ylimits);
                text(xpos, ypos,sprintf('isi %dms, %d reps', isis(isiindex),nreps(isiindex)))
            end
            %ylim(ylimits);
            xlim(xlimits);
        end
    end
    subplot1(1)
    title(sprintf('%s-%s-%s', expdate,session, filenum))
    shg
    refresh
    orient tall
end

%plot the mean VC tuning curves
figure
p=0;
c='bmgryc';
subplot1(numisis, 1)
for isiindex=[1:numisis]
    p=p+1;
    subplot1( p)
    for pindex=1:numpotentials
        trace1=squeeze(mMt(isiindex, pindex, :));
        trace1=trace1-median(trace1);
        trace_stim=squeeze(mMs(isiindex, pindex, :));
        trace_stim=trace_stim-median(trace_stim(1:100));
        trace_stim=trace_stim/max(trace_stim); %normalize stim
        trace_stim=trace_stim*.05*diff(ylimits);
        trace_stim=trace_stim+ylimits(1);
        t=1:length(trace1);
        t=t/10;
        hold on
        plot(t, trace1, c(pindex), t, trace_stim, 'r');
                xpos=xlimits(1)+.7*diff(xlimits);
                ypos=ylimits(1)+.2*diff(ylimits);
                text(xpos, ypos,sprintf('isi %dms, %d reps', isis(isiindex),nreps(isiindex)))
        ylim(ylimits);
        xlim(xlimits);
    end
end

subplot1(1)
title(sprintf('%s-%s-%s', expdate,session, filenum))
set(gcf, 'pos', [784    87   520   900])
shg
refresh
orient tall

%get nclicks
for i=1:length(event)
    if strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'pulsetrain')
isi=event(i).Param.isi;
isiindex=find(isis==isi);
nclicks(isiindex)=event(i).Param.nclicks;
    end
end

%get "start" (first onset)
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'pulsetrain')
j=j+1;
start(j)=event(i).Param.start;
    end
end
if length(unique(start))>1 error ('more than one start time???');end
start=unique(start);

%plot cycle averages (using 2 cycles for readibility, a la gilles)
figure
yl1=[0];
yl2=[0];
subplot1(numisis, 1)
for pindex=1:numpotentials
    for isiindex=[1:numisis]
        isi=isis(isiindex);
        onsets=floor(isi*(0:nclicks(isiindex)-1)); %in ms
        %     trace_stim=squeeze(mMs(isiindex, :));
        %     t=1:length(trace_stim);
        %     t=t/10;
        %     plot(t, trace_stim,'r', onsets, zeros(size(onsets)), '.')
        trace=mMt(isiindex,pindex,:);
        startpos= .001*samprate*(start-xlimits(1)); % first click onset in samples
        trace=trace-mean(trace(1:startpos)); %subtract baseline
        ctrace=zeros(length(onsets)-1,2*isi*.001*samprate+1);
        for o=1:length(onsets)-1
            startpos= .001*samprate*(onsets(o)+start-xlimits(1)); % first click onset in samples
            endpos=startpos+2*isi*.001*samprate; %a full isi after final click, in samples
            
            ctrace(o,:)=trace(startpos:endpos);
        end
        subplot1(isiindex)
        t=1:2*isi*.001*samprate+1;
        t=t/max(t); t=t*2*pi;
        %plot(t, mean(ctrace, 1),c(pindex))
        %detrending for autoscaling purposes
        plot(t, detrend(mean(ctrace, 1),'constant'),c(pindex))
        yl2=max(yl2, ylim);
        yl1=min(yl1, ylim);
        xlim([0 2*pi])
    end
end
%for now I am leaving ylimits autoscaled,
% or else the high-isi plots are always flat lines
% for isiindex=[1:numisis]
%     subplot1(isiindex)
%     ylim([min(yl1) max(yl2)])
% end
xlabel('phase')
subplot1(1)
title(sprintf('cycle-averaged Isyn  %s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
set(gcf, 'pos', [800    87   520   900])

%plot cycle averages, but as a function of time instead of phase
figure
yl1=[0];
yl2=[0];
subplot1(numisis, 1)
for pindex=1:numpotentials
    for isiindex=[1:numisis]
        isi=isis(isiindex);
        onsets=floor(isi*(0:nclicks(isiindex)-1)); %in ms
        %     trace_stim=squeeze(mMs(isiindex, :));
        %     t=1:length(trace_stim);
        %     t=t/10;
        %     plot(t, trace_stim,'r', onsets, zeros(size(onsets)), '.')
        trace=mMt(isiindex,pindex,:);
        startpos= .001*samprate*(start-xlimits(1)); % first click onset in samples
        trace=trace-mean(trace(1:startpos)); %subtract baseline
        ctrace=zeros(length(onsets)-1,2*isi*.001*samprate+1);
        for o=1:length(onsets)-1
            startpos= .001*samprate*(onsets(o)+start-xlimits(1)); % first click onset in samples
            endpos=startpos+2*isi*.001*samprate; %a full isi after final click, in samples
            
            ctrace(o,:)=trace(startpos:endpos);
        end
        subplot1(isiindex)
        t=1:2*isi*.001*samprate+1;
        t=t/10; %ms
        if isiindex<=3 t=10*t;text(350, 0, '10x time');end
        %plot(t, mean(ctrace, 1),c(pindex))
        %detrending for autoscaling purposes
        plot(t, detrend(mean(ctrace, 1),'constant'),c(pindex))
        yl2=max(yl2, ylim);
        yl1=min(yl1, ylim);
        xlim([-10 2*max(isis)])
    end
end
%for now I am leaving ylimits autoscaled,
% or else the high-isi plots are always flat lines
% for isiindex=[1:numisis]
%     subplot1(isiindex)
%     ylim([min(yl1) max(yl2)])
% end
xlabel('time, ms')
subplot1(1)
title(sprintf('cycle-averaged Isyn  %s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
set(gcf, 'pos', [820    87   520   900])


%plot cross-covariance between E and I 
figure
subplot1(numisis, 1, 'XTickL', 'All', 'Gap', [.01 .02])
    for isiindex=[1:numisis]
        isi=isis(isiindex);
        onsets=isi*(0:nclicks(isiindex)-1); %in ms
        %     trace_stim=squeeze(mMs(isiindex, :));
        %     t=1:length(trace_stim);
        %     t=t/10;
        %     plot(t, trace_stim,'r', onsets, zeros(size(onsets)), '.')
  
        subplot1(isiindex)
        maxlag=40*isi;
[xc, lags]=xcov(squeeze(mMt(isiindex,2,:)), squeeze(mMt(isiindex,1,:)), maxlag);
lags=lags/10;%to ms
        plot(lags,xc)
set(gca, 'xtick', [-4*isi:isi:4*isi])
grid on
    end

xlabel('lag, ms')
subplot1(1)
title(sprintf('E-I xcorr %s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
set(gcf, 'pos', [800    87   520   900])


function     generate_outfile(expdate, session, filenum, Vout); %subfunction

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
outfile=sprintf('out%s-%s-%s',expdate,session, filenum);
[D E S]=gogetdata(expdate,session,filenum);

samprate=1e4;
scaledtrace=D.nativeScaling*double(D.trace);
stim=S.nativeScalingStim*double(S.stim);
event=E.event;
numevents=length(event);
clear D E S
xlimits=[-100 event(1).Param.duration+100]; %in ms


lostat=length(scaledtrace);
% lostat=   2.8399e+05;
%discard data after this position (in samples)

allfreqs=0;
j=0;
for i=1:numevents
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'pulsetrain')
        j=j+1;
        allisis(j)=event(i).Param.isi;
        alldurs(j)=event(i).Param.duration;
        if isfield(event(i).Param, 'frequency')
            allfreqs(j)=event(i).Param.frequency;
        end
        allamps(j)=event(i).Param.amplitude;
    end
end
isis=unique(allisis);
durs=unique(alldurs);
freqs1=unique(allfreqs);
amps=unique(allamps);
numisis=length(isis);
if length(durs)>1 error('can''t handle multiple durations'), end
if length(freqs1)>1 error('can''t handle multiple frequencies'), end
if length(amps)>1 error('can''t handle multiple amplitudes'), end

for i=1:length(event)
    if  strcmp(event(i).Type, 'tonetrain')
        for j=1:length(event)
            if  strcmp(event(j).Type, 'clicktrain')
                error('can''t handle both tonetrain and clicktrain in same file yet')
            end
        end
    end
end

%get potentials and series
fprintf('\ncomputing series...');
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'holdcmd')
        j=j+1;
        %         note: we don't use soundcardtriggerPos here, because the event is not a sound
        %        pos=event(i).Position_rising;
        pos=event(i).Position;
        cmdstart(j)=event(i).Param.start;
        ramp(j)=event(i).Param.ramp;
        holdduration(j)=event(i).Param.holdduration;
        duration(j)=event(i).Param.duration;
        holdcmd_from(j)=event(i).Param.holdcmd_from;
        holdcmd_to(j)=event(i).Param.holdcmd_to;
        pulse_start(j)=event(i).Param.pulse_start;
        pulse_width=event(i).Param.pulse_width;
        pulse_height=event(i).Param.pulse_height;
        npulses=event(i).Param.npulses;
        pulse_isi(j)=event(i).Param.pulse_isi;
        pulseduration(j)=event(i).Param.pulseduration;


        first_pulse_onset=pos+(samprate/1000)*(cmdstart(j)+ramp(j)+holdduration(j)-pulseduration(j)+pulse_start(j));
        last_pulse_offset=first_pulse_onset+(samprate/1000)*pulseduration(j);
        if last_pulse_offset<lostat
            for k=0:npulses-1
                onset=first_pulse_onset+(samprate/1000)*(pulse_width+pulse_isi)*k;
                %                 figure
                %                 hold on
                %                 plot(scaledtrace)
                %                 plot(onset, scaledtrace(onset), 'k*')


                % Get the baseline.
                baseline_region = onset-10*(samprate/1000):onset-1 ;
                Baseline = mean( scaledtrace( baseline_region ) );
                %plot(baseline_region, scaledtrace(baseline_region), 'r')

                % Look for peak in +/- 1 ms around pulse onset.
                peak_region = onset-1*(samprate/1000) : onset+1*(samprate/1000);
                Peak = sign(pulse_height) * max( sign(pulse_height) * scaledtrace( peak_region ) );
                Peak = Peak - Baseline;
                %plot(peak_region, scaledtrace(peak_region), 'g')

                % Look for tail in last 10 ms of pulse.
                offset=pulse_width*(samprate/1000)+onset;
                tail_region =  offset-10*(samprate/1000) : offset-2  ;
                Tail=median(scaledtrace(tail_region));
                Tail = Tail - Baseline;
                Rs_pulses(j,k+1,:)=scaledtrace( onset-100:offset+100 );

                % ph in mV, current in pA and resistance in MOhm.
                if (Peak~=0) & (Tail~=0)
                    Rs(j,k+1)=(pulse_height * 1e-3)/( Peak * 1e-12) / (1e6);
                    Rt(j,k+1)=(pulse_height * 1e-3)/( Tail * 1e-12) / (1e6);
                    Rin(j,k+1)=Rt(j,k+1)-Rs(j,k+1);
                else
                    Rs(j,k+1)=inf;Rt(j,k+1)=inf;Rin(j,k+1)=inf;
                end
            end
        end

    end
end
potentials=unique(holdcmd_to);
numpotentials=length(potentials);

% Mt: matrix with each complete train
% Ms: stimulus matrix in same format as Mt

%first concatenate the sequence of trains into a matrix Mt
%preallocate Mt and Ms
Mt=zeros(numisis, numpotentials, 1,diff(xlimits)*1e-3*samprate );%trains
Ms=Mt;%stimulus record
nreps=zeros(numisis, numpotentials);
fprintf('\nextracting traces...');
j=0;
current_potential=[];
for i=1:length(event)
    if strcmp(event(i).Type, 'holdcmd')
        current_potential=event(i).Param.holdcmd_to;
    end
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'pulsetrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if pos>lostat
            fprintf('discarding trace')
        elseif isempty(current_potential)
            fprintf('\ndiscarding trace, undefined holdcmd potential')
        elseif isempty(find(region<0)) & stop<length(scaledtrace) %(disallow negative start times and don't exceed end)
            pindex= find(potentials==current_potential);
            isi=event(i).Param.isi;
            isiindex=find(isi==isis);
            nreps(isiindex, pindex)=nreps(isiindex, pindex)+1;
            Mt(isiindex, pindex,nreps(isiindex, pindex),:)=scaledtrace(region);
            Ms(isiindex, pindex,nreps(isiindex, pindex),:)=stim(region);
        end
    end
end

nreps

for isiindex=[1:numisis]
    for pindex=1:numpotentials
        mMt(isiindex, pindex,:)=mean(Mt(isiindex, pindex, 1:nreps(isiindex),:), 3);
        mMs(isiindex, pindex,:)=mean(Ms(isiindex, pindex, 1:nreps(isiindex),:), 3);
    end
end

%subtract Vout and liquid junction potential
liquid_junction_potential=12;
corrected_potentials=potentials-Vout-liquid_junction_potential;
fprintf('\nsubtracted %d mV and %d mV from command potentials\n', Vout, liquid_junction_potential);
 

%assign outputs
out.scaledtrace=scaledtrace;
out.Mt=Mt;
out.Ms=Ms;
out.mMt=mMt;
out.mMs=mMs;
out.username=whoami;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
out.lostat=lostat;
out.freqs=freqs1;
out.isis=isis;
out.numisis=numisis;
out.amps=amps;
out.durs=durs;
out.nreps=nreps;
out.event=event;
out.xlimits=xlimits;
out.corrected_potentials=corrected_potentials;
out.Rs=Rs;
out.Vout=Vout;
out.Rin=Rin;
out.Rt=Rt;
out.meanrin=median(median(Rin));
out.meanrs=median(median(Rs));
out.Rs_pulses=Rs_pulses;
out.meanpulse=squeeze(mean(mean(Rs_pulses)));
out.potentials=potentials;
out.samprate=samprate;
out.outfilegeneratedby='PlotVC_WNTrain2';
godatadir(expdate, session, filenum);
save (outfile, 'out')
fprintf('\n saved to %s', outfile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generate outfile subfunction

