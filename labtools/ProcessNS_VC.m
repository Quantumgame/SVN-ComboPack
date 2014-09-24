function ProcessNS_VC(varargin)
%Process Voltage Clamp responses to natural sound stimuli (speech, etc.)
% (data with a holding command protocol)
%usage: ProcessNS_VC(expdate, session, filename, Vout, [xlimits)
%saves output to outfile
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=[]; %x limits for axis
    Vout=0;
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    Vout=0;
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    Vout=varargin{5}; 
else
    error('wrong number of arguments'); % If you get any other number of arguments...
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nload file: ')
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
[D E S]=gogetdata(expdate,session,filenum);
durs=getdurs(expdate,session,filenum);
durs=max(durs);
if isempty(xlimits)
    xlimits=[-1000 durs+1000];
end
stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
event=E.event;
if isempty(event); fprintf('\nno tones\n'); return; end

clear D E S

lostatfilename=sprintf('lostat-%s-%s-%s.mat',expdate,session,filenum);
if exist(lostatfilename,'file')
    load(lostatfilename)
    if length(lostat)==1
        lostat=[1 lostat];
        save(lostatfilename,'lostat')
    end
else
    lostat=[1 length(scaledtrace)];
end
fprintf('\nfound lostat file. using lostat %d %d',lostat );


%downsample to speed up processing of long files
%set dsfac to 1 for no downsampling, 10 for speed
dsfac=1;
fprintf('\ndownsampling data by a factor of %d...', dsfac);
scaledtrace=decimate(scaledtrace, dsfac);

fprintf('\ncomputing tuning curve...');

samprate=1e4;
samprate=samprate/dsfac;

fprintf('\ntotal duration %d s (%.1f min)', round(length(scaledtrace)/samprate), round(length(scaledtrace)/samprate)/60)

%note: we assume only one dur, and multiple epochs
%get number of epochs
%note: we correct numepochs below to actual number of epochs in data set, for truncated recordings -mw 07.18.2013
j=0;
for i=1:length(event) %
    if strcmp(event(i).Type, 'naturalsound')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        pos=pos/dsfac;
        start=round(pos+xlimits(1)*1e-3*samprate);
        stop=round(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat(2)
            elseif start<lostat(1)
            else
                j=j+1;
                alldurs(j)=event(i).Param.duration;
                allisis(j)=event(i).Param.next;
                allfilenames{j}=event(i).Param.file;
            end
        end
    end
end

numepochs=length(unique(allfilenames));
epochfilenames=(unique(allfilenames));
dur=unique(alldurs);
% if dur~=durs(2)
%     error('What''s wrong with durs??? Get Michael!')
% end
isi=unique(allisis);
if length(dur)~=1 error('cannot handle multiple durs');end
if length(isi)~=1 error('cannot handle multiple isis');end

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
        if last_pulse_offset>lostat(2)
        elseif first_pulse_onset<lostat(1)
        else
            for k=0:npulses-1
                onset=first_pulse_onset+(samprate/1000)*(pulse_width+pulse_isi)*k;
                %                 figure
                %                 hold on
                %                 plot(scaledtrace)
                %                 plot(onset, scaledtrace(onset), 'k*')
                
                
                % Get the baseline.
                baseline_region = round(onset-10*(samprate/1000)):round(onset-1) ;
                Baseline = mean( scaledtrace( baseline_region ) );
                %plot(baseline_region, scaledtrace(baseline_region), 'r')
                
                % Look for peak in +/- 1 ms around pulse onset.
                peak_region = round(onset-1*(samprate/1000)) : round(onset+1*(samprate/1000));
                Peak = sign(pulse_height) * max( sign(pulse_height) * scaledtrace( peak_region ) );
                Peak = Peak - Baseline;
                %plot(peak_region, scaledtrace(peak_region), 'g')
                
                % Look for tail in last 10 ms of pulse.
                offset=pulse_width*(samprate/1000)+onset;
                tail_region =  round(offset-10*(samprate/1000)) : round(offset-2)  ;
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
% figure
% plot(squeeze(mean(mean(Rs_pulses))))
% yl=ylim;
% text(100, yl(1)+.8*diff(ylim), sprintf('Rs: %.1f\nRt: %.1f\nRin: %.1f', median(median(Rs)),median(median(Rt)),median(median(Rin)) ))
% fprintf('  Rs: %.1f\tRt: %.1f\tRin: %.1f', median(median(Rs)),median(median(Rt)),median(median(Rin)) )
potentials=unique(holdcmd_to);
numpotentials=length(potentials);

expectednumreps=length(event)/(2*numepochs);

M1=zeros(numepochs, numpotentials, expectednumreps,diff(xlimits*samprate*.001));
M1stim=M1;
nreps=zeros(numepochs, numpotentials);

%extract the traces into a big matrix M
j=0;
fprintf('\nextracting traces from %d events:\n', length(event));
current_potential=[];
lostin_counter=[];
lostat_counter=[];
for i=1:length(event)
    fprintf('.');
    if ~mod(i,10)    
        fprintf('%d\n',i);
    end
    if strcmp(event(i).Type, 'holdcmd')
        current_potential=event(i).Param.holdcmd_to;
    end
    
    if strcmp(event(i).Type, 'naturalsound')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        pos=pos/dsfac;
        start=round(pos+xlimits(1)*1e-3*samprate);
        stop=round(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat(2)
                lostat_counter=[lostat_counter i];
            elseif start<lostat(1)
                lostin_counter=[lostin_counter i];
            else
                switch event(i).Type
                    case 'naturalsound'
                        epochfile=event(i).Param.file;
                end
                
                dur=event(i).Param.duration;
                epochnum=find(strcmp(epochfilenames, epochfile));
                pindex= find(potentials==current_potential);
                
                nreps(epochnum, pindex)=nreps(epochnum, pindex)+1;
                M1(epochnum, pindex, nreps(epochnum, pindex),:)=scaledtrace(region);
                M1stim(epochnum, pindex, nreps(epochnum, pindex),:)=stim1(region);
                sequences(epochnum,pindex, nreps(epochnum, pindex),:)=event(i).Param.sequence;
            end
        end
    end
    
end
if ~isempty(lostat_counter) || ~isempty(lostin_counter)
    skipped_events=[lostat_counter lostin_counter];
    fprintf('\n%d/%d events skipped due to lostat or incomplete file\n',length(skipped_events),i)
end
traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:, pindex ,traces_to_keep,:), 3);
else
    for eindex=1:size(M1,1)
    for pindex=1:numpotentials
        mM1(eindex, pindex,1, :)=mean(M1(eindex, pindex, 1:nreps(eindex, pindex),:), 3);
        mM1stim(eindex, pindex,1,:)=mean(M1stim(eindex, pindex, 1:nreps(eindex, pindex),:), 3);
    end
    end
end
mM1=squeeze(mM1);
mM1stim=squeeze(mM1stim);


%subtract Vout and liquid junction potential
liquid_junction_potential=12;
corrected_potentials=potentials-Vout-liquid_junction_potential;
fprintf('\nsubtracted %d mV and %d mV from command potentials', Vout, liquid_junction_potential);

numepochs=size(M1, 1); %actual numepochs in dataset
sequences(find(sequences==0))=nan; %convert missing seq entries to nans

%assign outputs
out.scaledtrace=scaledtrace;
out.downsamplefactor=dsfac;
out.M1=M1;
out.M1stim=M1stim;
out.mM1stim=mM1stim;
out.mM1=mM1;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
out.datafile=datafile;
out.eventsfile=eventsfile;
out.stimfile=stimfile;
out.nreps=nreps;
out.traces_to_keep=traces_to_keep;
out.event=event;
out.xlimits=xlimits;
out.samprate=samprate;
out.epochfilenames=epochfilenames;
out.numepochs=numepochs;
out.sequences=sequences;
out.dur=dur;
out.isi=isi;
out.potentials=potentials;
out.corrected_potentials=corrected_potentials;
out.Rs=Rs;
out.Vout=Vout;
out.Rin=Rin;
out.Rt=Rt;
out.meanrin=median(median(Rin));
out.meanrs=median(median(Rs));
out.Rs_pulses=Rs_pulses;
out.meanpulse=squeeze(mean(mean(Rs_pulses)));
out.lostat=lostat;

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum)
save (outfilename, 'out')
fprintf('\n saved to %s\n', outfilename)

