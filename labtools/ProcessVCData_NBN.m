function ProcessVCData_NBN(expdate, session, filenum, Vout, varargin)
% load voltage clamp data (with a holding command protocol)
% and sort into matrices
%
% specifically for NBN (narrow-band noise) tuning curve protocols
%
% usage: ProcessVCData_NBN(expdate, session, filenum, Vout, [xlimits])
%   xlimits are optional, default is -.5*dur:1.5*dur
% saves output as an outfile
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
if isempty(pref) Prefs; end
username=pref.username;

if nargin==4
    xlimits=[-50 250]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
elseif nargin==5
    xlimits=varargin{1};
    if length(xlimits)~=2
    xlimits=[-50 250]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
    end
else error('ProcessVCData: wrong number of arguments');
end

lostat1=-1; %discard data after this position (in samples), -1 to skip
if strcmp(expdate, '012008') & strcmp(session, '002') & strcmp(filenum, '005')
    lostat1=1.27e6;
elseif strcmp(expdate, '101007') & strcmp(session, '003') & strcmp(filenum, '003')
    lostat1=1.55e6;
end


[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
if pref.usebak
    godatadirbak(expdate, session, filenum)
else
    godatadir(expdate, session, filenum)
end

fprintf('\nload file: ')
try
    fprintf('\ntrying to load %s...', datafile)
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf('done.');
    
catch
    fprintf('failed. Could not find data')
    return
end

event=E.event;

stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
fprintf('done.');
clear D E S

samprate=1e4;
if lostat1==-1 lostat1=length(scaledtrace);end

%%%%%%%%%%%%%%%crop to second half of file%%%%%%%%%%%%%%%%%%%
% warning('cropping to second half of file')
% L=length(event);
% event=event(round(L/2):L);
% %
% warning('cropping to first half of file')
% L=length(event);
% event=event(1:round(L/2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('\ntotal duration %d s', round(length(scaledtrace)/samprate))

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
%         fprintf('Warning: Wierd skipped stimulus error?!?!?!')
%     end
% end


%get freqs/amps
allisis=[];
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allramps(j)=event(i).Param.ramp;
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allramps(j)=event(i).Param.ramp;
        allbws(j)=inf;
    elseif strcmp(event(i).Type, 'noise')
        j=j+1;
        allfreqs(j)=-1;
        allfreqs(j)=event(i).Param.center_frequency;
        allbws(j)=event(i).Param.bandwidthOct;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allramps(j)=event(i).Param.ramp;
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
bws=unique(allbws);
ramps=unique(allramps);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);
numbws=length(bws);

fprintf('\n frequencies:')
fprintf('%.1f  ', freqs/1000)
fprintf('\n amplitudes:')
fprintf('%d  ', round(amps))
fprintf('\n bandwidths:')
fprintf('%.1f  ', bws)
fprintf('\n durations:')
fprintf('%d  ', durs)

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
        if last_pulse_offset<lostat1
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
figure
plot(squeeze(mean(mean(Rs_pulses))))
yl=ylim;
text(100, yl(1)+.8*diff(ylim), sprintf('Rs: %.1f\nRt: %.1f\nRin: %.1f', median(median(Rs)),median(median(Rt)),median(median(Rin)) ))
potentials=unique(holdcmd_to);
numpotentials=length(potentials);

%expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
expectednumrepeats=1; %growing matrix to avoid zero trials when expectations not met
M1=zeros(numfreqs, numamps, numbws, numpotentials,expectednumrepeats, diff(xlimits)*samprate/1000);
nreps1=zeros(numfreqs, numamps, numbws, numpotentials);

%extract the traces into a big matrix M
fprintf('\nextracting traces...');
j=0;
current_potential=[];
for i=1:length(event)
    if strcmp(event(i).Type, 'holdcmd')
        current_potential=event(i).Param.holdcmd_to;
        
    end
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'noise') | strcmp(event(i).Type, 'whitenoise')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negativestart times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            elseif isempty(current_potential)
                fprintf('\ndiscarding trace, undefined holdcmd potential')
            else
                switch event(i).Type
                    case 'tone'
                        freq=event(i).Param.frequency;
                        dur=event(i).Param.duration;
                        dindex= find(durs==dur);
                        bw=0;
                    case { 'whitenoise'}
                        freq=-1;
                        dur=event(i).Param.duration;
                        dindex= find(durs==dur);
                        bw=inf;
                    case {'noise'}
                        dur=event(i).Param.duration;
                        freq=event(i).Param.center_frequency;
                        bw=event(i).Param.bandwidthOct;
                        
                end
                amp=event(i).Param.amplitude;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                bwindex=find(bws==bw);
                
                pindex= find(potentials==current_potential);
                %Note: not using dindex since MakeNBNProtocol is contrained to a single duration
                
                nreps1(findex, aindex,bwindex, pindex)=nreps1(findex, aindex, bwindex, pindex)+1;
                M1(findex,aindex,bwindex, pindex, nreps1(findex,aindex,bwindex, pindex),:)=scaledtrace(region);
                M1stim(findex,aindex,bwindex,pindex, nreps1(findex,aindex,bwindex, pindex),:)=stim(region);
            end
        end
    end
end

%mM1=mean(M1, 4);
%mM=mean(M(:,:,:,21:38,:), 4);

for bwindex=[1:numbws]
    for aindex=1:numamps
        for findex=1:numfreqs
            for pindex=1:numpotentials
                nr=nreps1(findex, aindex,bwindex, pindex);
                if nr>0
                    mM1(findex, aindex,bwindex, pindex, 1, :)=mean(M1(findex, aindex,bwindex, pindex, 1:nr, :), 5);
                end
            end
        end
    end
end

%subtract Vout and liquid junction potential
liquid_junction_potential=12;
corrected_potentials=potentials-Vout-liquid_junction_potential;
fprintf('\nsubtracted %d mV and %d mV from command potentials', Vout, liquid_junction_potential);

outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
godatadir(expdate, session, filenum)
if exist(outfilename, 'file')
    load (outfilename);
    if isfield(out, 'GE')
        fprintf('\n%s exists and has ge/gi data, loading and saving it...', outfilename)
    end
end
%assign outputs
out.M1=M1;
out.M1stim=M1stim;
out.mM1=mM1;
out.nreps=nreps1;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.amps=amps;
out.durs=durs;
out.bws=bws;
out.potentials=potentials;
out.samprate=samprate;
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
out.ramps=ramps;

save(outfilename, 'out');
fprintf('\nsaved in %s...', outfilename)