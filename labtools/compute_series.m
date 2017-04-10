function p=compute_series(p)
%get series resistance

% if ~isempty(series) %if series exists as a persistent variable ...
%     if ~(strcmp(series{5}, p.expdate) & strcmp(series{6}, p.filename)) %but doesn't match currently loaded data ...
%         series=[]; %clear it
%     end
% end


onset=p.v_onset;
if (1)%isempty(series)
    fprintf('\ncomputing series resistance...')
    for i=p.sweeps
        [rs1(i,:), rt1(i,:), rin1(i,:), mpulse(i,:)]= SeriesResistanceAdapt(p.data(i).r, p); 
%        [rs1(i,:), rt1(i,:), rin1(i,:), mpulse(i,:)]= SeriesResistanceAdapt(p.data(i).r, p, 'plot'); 
        %[rs1(i,:), rt1(i,:), rin1(i,:)]= seriesresistance(sweep(i), p.mode, 'plot'); 
    end
    switch p.mode
    case { 'V-Clamp' }
        numpulses=10;   %number of series resistance pulses
    case { 'I=0','I-Clamp Normal','I-Clamp Fast' }    
        numpulses=3;
    end
    
    p.rs=reshape(rs1(p.sweeps,:)', numpulses*length(p.sweeps), 1);
    p.rsmat=rs1;
    p.sweeprs=median(rs1');
    p.rinmat=rin1;
    p.sweeprin=median(rin1');
    p.rin=reshape(rin1(p.sweeps,:)', numpulses*length(p.sweeps), 1);
    p.rt=reshape(rt1(p.sweeps,:)', numpulses*length(p.sweeps), 1);
    p.meanrs=median(p.rs);
    p.meanrin=median(p.rin);
    p.meanrt=median(p.rt);
    %average meanpulses across potentials
    p.meanpulse=zeros(length(p.potentials), size(mpulse, 2));
    for pindex=1:p.npotentials
        pindices=find(p.cmdseq(p.sweeps)==p.potentials(pindex));
        if length(pindices)>1
            p.meanpulse(pindex,:)=mean(mpulse(pindices,:));
        elseif length(pindices)==1
            p.meanpulse(pindex,:)=(mpulse(pindices,:));           
        end
    end
    series={p.rs, p.rin, p.meanrs, p.meanrin, p.expdate, p.filename, p.meanpulse, p.rinmat, p.sweeprin};
    fprintf('done\n')    
else %if series is not empty, meaning it was previously computed    
    p.rs=series{1};
    p.rin=series{2};
    p.meanrs=series{3};    
    p.meanrin=series{4};
    p.meanpulse=series{7};
    p.rinmat=series{8};
    p.sweeprin=series{9};
    p.prin=zeros(size(p.potentials));
    for pindex=1:p.npotentials
        p.prin(pindex)=mean(p.sweeprin(find(p.cmdseq(p.sweeps)==p.potentials(pindex))));
    end
    fprintf('\nusing previously computed series resistance')    
    
    if ~(strcmp(series{5}, p.expdate) & strcmp(series{6}, p.filename))
        string=sprintf('input argument from %s %s does not match \ncurrently loaded data from %s %s', ...     
            series{5}, series{6}, p.expdate, p.filename);
        error(string);
    end
end


function [Rs, Rt, Rin, meanpulse]=SeriesResistanceAdapt(varargin)
%[Rs, Rt, Rin]=SeriesResistance(sweep, p)
%[Rs, Rt, Rin]=SeriesResistance(sweep, mode, 'plot') to include plots of
%                peak (red), tail (green), and baseline (blue) regions
%
%[Rs, Rt, Rin]=SeriesResistance(sweep, mode, onset) to assign first pulse onset (default 1000ms)
%calculates series, total, and input resistances from 10 voltage pulses 
%mode should be the mode for the sweep ('I=0', 'I-Clamp Normal', 'V-Clamp',...) 
%now works for voltage or current clamp
%assumes pulse onset is at one ISI, 10 pulses for VClamp, 3 pulses for IClamp
%mw 102401, 011602

trace=varargin{1};
p=varargin{2};
%first_pulse_onset=1000; %this might need to be set for older data sets, like before I 
%had a v_onset parameter or something? not sure ...
if nargin==2   
    doplot=0;
elseif nargin==3 & strcmp(varargin{3}, 'plot')   
    doplot=1;
elseif nargin==3 & ~ischar(varargin{3})   
    first_pulse_onset=varargin{3};
    doplot=0;
else 
    help seriesresistance
    error ('wrong number of inputs');
end
samprate=p.samprate;
time=1:length(trace);
time=time/samprate;
first_pulse_onset=p.v_onset;

switch p.mode
case { 'V-Clamp' }
    
    numpulses=10;
    pw=p.v_width;
    ph=p.v_height;
    if doplot
        figure
        subplot(2,1,1)
        plot(time, trace)
        hold on
    end
    for i=0:numpulses-1
        %pulse onset
        %onset=ISI+2*pw*i;
        onset=first_pulse_onset+2*pw*i;  
        
        % Get the baseline.
        baseline_region = find( (time  > onset-10) & (time  < onset ));
        %the first stim is a blank, pulse follows it
        Baseline = mean( trace( baseline_region ) );
        
        % Look for peak in +/- 1 ms around pulse onset.        
        peak_region = find( ( time > onset-1 ) &   ( time < onset+1) );
        %the first stim is a blank, pulse follows it
        Peak = sign(ph) * max( sign(ph) * trace( peak_region ) );
        Peak = Peak - Baseline;
        
        % Look for tail in last 1 ms of pulse.
        offset=pw+first_pulse_onset+2*pw*i;
        tail_region = find( ( time > offset-1 ) & ( time < offset  ) );
        Tail=mean(trace(tail_region));
        Tail = Tail - Baseline;
        
        % ph in mV, current in pA and resistance in MOhm.
        if (Peak~=0) & (Tail~=0)
            Rs(i+1)=(ph * 1e-3)/( Peak * 1e-12) / (1e6);
            Rt(i+1)=(ph * 1e-3)/( Tail * 1e-12) / (1e6);
            Rin(i+1)=Rt(i+1)-Rs(i+1);
        else 
            Rs(i+1)=inf;Rt(i+1)=inf;Rin(i+1)=inf;
        end
        
        if doplot
            hold on
            plot(time((peak_region)), trace((peak_region)), 'ro')
            plot(time((tail_region)), trace((tail_region)), 'go')
            plot(time((baseline_region)), trace((baseline_region)), 'co')
            set(gca, 'xlim', [first_pulse_onset-2*pw first_pulse_onset+numpulses*2*pw+pw])
            title(['Rs: ', int2str(round(Rs)), ', median: ', int2str(round(median(Rs)))])
        end
        
    end %for i=1:numpulses
case { 'I=0','I-Clamp Normal','I-Clamp Fast' }    
    numpulses=3;
    pw=p.i_width;
    ph=p.i_height;
    if doplot
        figure
        subplot(2,1,1)
        plot(time, trace)
        hold on
    end
    for i=0:numpulses-1
        %pulse onset
        onset=first_pulse_onset+2*pw*i;  
        
        % Get the baseline.
        baseline_region = find( (time  > onset-10) & (time  < onset ));
        %the first stim is a blank, pulse follows it
        Baseline = mean( trace( baseline_region ) );
        
        % Find time index that pulse started and look +/- 1 ms for steepness.
        start_region = find( ( time > onset-1 ) &   ( time < onset+5) );
        %the first stim is a blank, pulse follows it
        [dum,onset_index]=max( sign(ph)*diff( trace( start_region ) ) );
        Onset=trace( start_region(onset_index + 1 ));
        Onset = Onset - Baseline;
        
        % Look for peak charging in +/- 1 ms around pulse termination.
        offset=pw+first_pulse_onset+2*pw*i;
        peak_region = find( ( time > offset-10 ) & ( time < offset  ) );
        Peak = sign(ph) * max( sign(ph) * mean(trace( peak_region ) ));
        Peak = Peak - Baseline;
        
        
        % ph in mV, current in pA and resistance in MOhm.
        if (Peak~=0) & (Onset~=0)
            Rs(i+1)=( Onset * (1e-3 ) ) / ( ph * (1e-12) ) / (1e6);;
            Rt(i+1)=( Peak * (1e-3) ) / ( ph * (1e-12) ) / (1e6);
            Rin(i+1)=Rt(i+1)-Rs(i+1);
        else 
            Rs(i+1)=inf;Rt(i+1)=inf;Rin(i+1)=inf;
        end
        
        if doplot
            hold on
%            plot(time((start_region)), trace((start_region)), 'ro')
            plot(time(start_region(onset_index+1)), trace(start_region(onset_index+1)), 'ro')  
            plot(time((peak_region(1))), mean(trace((peak_region))), 'ro')
            plot(time((baseline_region(1))), Baseline, 'ro')
            set(gca, 'xlim', [first_pulse_onset-pw first_pulse_onset+numpulses*2*pw])
            title(['Rs: ', int2str(round(Rs)), ', median: ', int2str(round(median(Rs)))])
%             plot(time(start_region), trace(start_region)-trace(start_region(1)))
%             hold on;plot(time(start_region(2:end)), sign(ph)*diff( trace( start_region ) ), 'ro-')
%              grid on
        end
        
    end %for i=1:numpulses
otherwise
    error([Mode, ': unrecognized mode'])
end
    
for i=0:numpulses-1
    onset=first_pulse_onset+2*pw*i;
    pulse_region=find( ( time > onset-10 ) & ( time < (onset+pw+10)  ) );
    pulse(i+1,:)=trace(pulse_region)';
end
meanpulse=mean(pulse);
if doplot
%figure
subplot(2,1,2)
    plot(mean(pulse));
    title(['mean pulse'])
end