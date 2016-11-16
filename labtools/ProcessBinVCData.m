function ProcessBinVCData(expdate, session, filenum, Vout, varargin)
% load voltage clamp data (with a holding command protocol)
% and sort into matrices
%
% usage: ProcessBinVCData('expdate', 'session', 'filenum', Vout, [xlimits],filterspikes,[nstd])
% xlimits are optional, default = [0 300]
% filterspikes default is 0, to filter out escaped spikes, filterspikes=1
% nstd default is 10, can also use absolute thresh in pA [-1 pA]
% saves output as an outfile
% last updated by mak 10mar2011 to filter out escaped spikes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


spikecounter=0;
trialsremoved=0;
global pref
if isempty(pref); Prefs; end
username=pref.username;

if nargin==4
    xlimits=[0 300]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
    filterspikes=0;
    nstd=10; % or use and absolute threshold [-1 pAthreshold]
elseif nargin==5
    xlimits=varargin{1};
        if length(xlimits)~=2
    xlimits=[0 300]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
        end
    filterspikes=0;
    nstd=10; % or use and absolute threshold [-1 pAthreshold]
elseif nargin==6
    xlimits=varargin{1};
        if length(xlimits)~=2
    xlimits=[0 300]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
        end
    filterspikes=varargin{2};
    nstd=10; % or use and absolute threshold [-1 pAthreshold]
elseif nargin==7
        xlimits=varargin{1};
        if length(xlimits)~=2
    xlimits=[0 300]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
        end
    filterspikes=varargin{2};
    nstd=varargin{3}; % or use and absolute threshold [-1 pAthreshold]
else error('ProcessBinVCData: wrong number of arguments');
end
fprintf('\nProcessBinVCData: using xlimits [%d %d]', xlimits)

lostat1=-1; %discard data after this position (in samples), -1 to skip
if     strcmp(expdate, '033010') && strcmp(session, '002') && strcmp(filenum, '001') %noted in cell_list
    lostat1=2.653e6;
elseif strcmp(expdate, '040610') && strcmp(session, '002') && strcmp(filenum, '001') %noted in cell_list
    lostat1=7.84e6;
elseif strcmp(expdate, '060910') && strcmp(session, '001') && strcmp(filenum, '002') %noted in cell_list
    lostat1=6.0027e6;
elseif strcmp(expdate, '071410') && strcmp(session, '001') && strcmp(filenum, '002') %noted in cell_list
    lostat1=2.3149e6;
elseif strcmp(expdate, '071910') && strcmp(session, '001') && strcmp(filenum, '002') %noted in cell_list
    lostat1=5.5461e6;
elseif strcmp(expdate, '072110') && strcmp(session, '002') && strcmp(filenum, '002') %cell in cell_list due to poor recording
    lostat1=4.0134e6;
elseif strcmp(expdate, '072710') && strcmp(session, '001') && strcmp(filenum, '001') %noted in cell_list
    lostat1=4.1319e6;
elseif strcmp(expdate, '072710') && strcmp(session, '002') && strcmp(filenum, '001') %noted in cell_list
    lostat1=1.9136e6;
elseif strcmp(expdate, '072910') && strcmp(session, '002') && strcmp(filenum, '001') %noted in cell_list
    lostat1=4.7627e6;
elseif strcmp(expdate, '080210') && strcmp(session, '002') && strcmp(filenum, '001') %noted in cell_list
    lostat1=4.508e6;
elseif strcmp(expdate, '080210') && strcmp(session, '004') && strcmp(filenum, '001') %noted in cell_list
    lostat1=3.614e6;
elseif strcmp(expdate, '080210') && strcmp(session, '006') && strcmp(filenum, '001') %noted in cell_list
    lostat1=3.74e6;
elseif strcmp(expdate, '081210') && strcmp(session, '003') && strcmp(filenum, '005') %noted in cell_list
    lostat1=5.171e6;
elseif strcmp(expdate, '092710') && strcmp(session, '001') && strcmp(filenum, '001') %noted in cell_list
    lostat1=3.444e6;
elseif strcmp(expdate, '101110') && strcmp(session, '002') && strcmp(filenum, '001') %noted in cell_list
    lostat1=2.748e6;
elseif strcmp(expdate, '102710') && strcmp(session, '003') && strcmp(filenum, '001') %noted in cell_list
    lostat1=4.079e6;
elseif strcmp(expdate, '121910') && strcmp(session, '002') && strcmp(filenum, '002') %noted in cell_list
    lostat1=4.213e6;
elseif strcmp(expdate, '011911') && strcmp(session, '002') && strcmp(filenum, '003') %noted in cell_list
    lostat1=2.5766e6;
elseif strcmp(expdate, '011911') && strcmp(session, '003') && strcmp(filenum, '003') %noted in cell_list
    lostat1=4.343e6;
elseif strcmp(expdate, '021111') && strcmp(session, '004') && strcmp(filenum, '003') %noted in cell_list
    lostat1=3.9134e6;
elseif strcmp(expdate, '040311') && strcmp(session, '004') && strcmp(filenum, '003') %noted in cell_list
    lostat1=4.054e6;
elseif strcmp(expdate, '040311') && strcmp(session, '003') && strcmp(filenum, '005') %NOT noted in cell_list b/c I removed it, terrible cell mak 23Jun2011
    lostat1=2.267e6;
elseif strcmp(expdate, '040411') && strcmp(session, '001') && strcmp(filenum, '004') %noted in cell_list
    lostat1=3.861e6;
elseif strcmp(expdate, '051211') && strcmp(session, '007') && strcmp(filenum, '004') %noted in cell_list
    lostat1=2.348e6;
elseif strcmp(expdate, '061711') && strcmp(session, '002') && strcmp(filenum, '002') %noted in cell_list
    lostat1=2.595e6;
elseif strcmp(expdate, '062711') && strcmp(session, '004') && strcmp(filenum, '002') %noted in cell_list
    lostat1=3.866e6;
elseif strcmp(expdate, '011411') && strcmp(session, '004') && strcmp(filenum, '002') 
    lostat1=3.1411e6;
% elseif strcmp(expdate, 'expdate') && strcmp(session, 'session') && strcmp(filenum, 'filenum') 
%     lostat1=e6;
end

% For filtering spikes of specific files
if     strcmp(expdate,'080410') && strcmp(session,'004') && strcmp(filenum,'001')
    filterspikes=1; nstd=10;
elseif strcmp(expdate,'080410') && strcmp(session,'001') && strcmp(filenum,'001')
    filterspikes=1; nstd=10;
elseif strcmp(expdate,'081210') && strcmp(session,'003') && strcmp(filenum,'001')
    filterspikes=1; nstd=10;
elseif strcmp(expdate,'120810') && strcmp(session,'003') && strcmp(filenum,'003')
    filterspikes=1; nstd=10;
elseif strcmp(expdate,'120810') && strcmp(session,'005') && strcmp(filenum,'002')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'120810') && strcmp(session,'005') && strcmp(filenum,'006')
    filterspikes=1; nstd=15;
elseif strcmp(expdate,'012811') && strcmp(session,'002') && strcmp(filenum,'003')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'031611') && strcmp(session,'003') && strcmp(filenum,'004')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'041711') && strcmp(session,'002') && strcmp(filenum,'003')
    filterspikes=1; nstd=15;
elseif strcmp(expdate,'041711') && strcmp(session,'003') && strcmp(filenum,'004')
    filterspikes=1; nstd=10;
elseif strcmp(expdate,'042711') && strcmp(session,'004') && strcmp(filenum,'002')
    filterspikes=1; nstd=8;
elseif strcmp(expdate,'051211') && strcmp(session,'002') && strcmp(filenum,'005')
    filterspikes=1; nstd=15;
elseif strcmp(expdate,'052511') && strcmp(session,'005') && strcmp(filenum,'003')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'040411') && strcmp(session,'002') && strcmp(filenum,'003')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'062411') && strcmp(session,'003') && strcmp(filenum,'002')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'062711') && strcmp(session,'002') && strcmp(filenum,'002')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'062711') && strcmp(session,'005') && strcmp(filenum,'002')
    filterspikes=1; nstd=7;
elseif strcmp(expdate,'071511') && strcmp(session,'003') && strcmp(filenum,'004')
    filterspikes=1; nstd=5;
elseif strcmp(expdate,'061711') && strcmp(session,'003') && strcmp(filenum,'002')
    filterspikes=1; nstd=10;
elseif strcmp(expdate,'061411') && strcmp(session,'005') && strcmp(filenum,'002')
    filterspikes=1; nstd=5;
% elseif strcmp(expdate,'expdate') && strcmp(session,'00') && strcmp(filenum,'00')
%     filterspikes=1; nstd=7;
end
[D E S]=gogetdata(expdate,session,filenum);
event=E.event;

stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
fprintf('done.');
clear D E S

samprate=1e4;
if lostat1==-1
    lostat1=length(scaledtrace);
end


% to filter out unwanted trials with escaped spikes
if filterspikes==1
    high_pass_cutoff=300; %Hz
    fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
    [b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
    filteredtrace=filtfilt(b,a,scaledtrace);
    if length(nstd)==2
        if nstd(1)==-1
            thresh=nstd(2);
            fprintf('\nusing absolute spike detection threshold of %.1f pA (%.1f sd)', thresh, thresh/std(filteredtrace));
        end
    else
        thresh=nstd*std(filteredtrace);
        fprintf('\nusing spike detection threshold of %.1f pA (%g sd)', thresh, nstd);
    end
    refract=5;
    fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
    spikes=find(abs(filteredtrace)>thresh);
    dspikes=spikes(1+find(diff(spikes)>refract));
    dspikes=[spikes(1) dspikes'];
end


fprintf('\ntotal duration %d s', round(length(scaledtrace)/samprate))

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'bintone') | strcmp(event(i).Type, 'binwhitenoise')
        j=j+1;
        allRamps(j)=event(i).Param.Ramplitude;
        allLamps(j)=event(i).Param.Lamplitude;
        alldurs(j)=event(i).Param.duration;
        allramps(j)=event(i).Param.ramp;
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
ramps=unique(allramps);

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
        
        if strcmp(expdate,'020411') && strcmp(session,'002') && strcmp(filenum,'003') %Matlab had issues and is all wonky
            if j==1  % This is due to a bug in matlab during this recording, see notebook for whining.
                holdcmd_from(j)=-70;
                holdcmd_to(j)=0;
            elseif j==2
                holdcmd_from(j)=0;
                holdcmd_to(j)=-90;
            elseif j==3
                holdcmd_from(j)=-90;
                holdcmd_to(j)=0;
            elseif j==4
                holdcmd_from(j)=0;
                holdcmd_to(j)=-90;
            elseif j==5
                holdcmd_from(j)=-90;
                holdcmd_to(j)=0;
            end
        end
        
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
title(sprintf('%s-%s-%s-%s',expdate,username,session,filenum));

%expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
expectednumrepeats=1; %growing matrix to avoid zero trials when expectations not met
M1=zeros(numfreqs, numamps, numamps, numdurs, numpotentials,expectednumrepeats, (diff(xlimits))*samprate/1000);
M1spikes=zeros(numfreqs, numamps, numamps, numdurs, numpotentials,expectednumrepeats, (diff(xlimits))*samprate/1000);
nreps=zeros(numfreqs, numamps, numamps, numdurs, numpotentials);

%extract the traces into a big matrix M
fprintf('\nextracting traces...');
current_potential=[];
for i=1:length(event)
    if strcmp(expdate, '081210') && strcmp(session, '003') && strcmp(filenum, '005') && i>=720
%         this is a catch due to a missed soundcard trigger on this file
%         that prevents processing b/c pos, stop, & region are empty
%         mak23feb2011
    elseif strcmp(expdate, '081910') && strcmp(session, '002') && strcmp(filenum, '001') && i>=723
    elseif strcmp(expdate, '011411') && strcmp(session, '004') && strcmp(filenum, '002') && i>=500
    else
        if strcmp(event(i).Type, 'holdcmd')
            current_potential=event(i).Param.holdcmd_to;
            if strcmp(expdate,'020411') && strcmp(session,'002') && strcmp(filenum,'003') %Matlab had issues and is all wonky
                if i==1  % This is due to a bug in matlab during this recording, see notebook for whining.
                    current_potential=0;
                elseif i==182
                    current_potential=-90;
                elseif i==363
                    current_potential=0;
                elseif i==544
                    current_potential=-90;
                elseif i==725
                    current_potential=0;
                end
            end

        end
        if strcmp(event(i).Type, 'bintone') | strcmp(event(i).Type, 'binwhitenoise')
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
                    fprintf('\ndiscarding trace, ')
                elseif isempty(current_potential)
                    fprintf('\ndiscarding trace, undefined holdcmd potential')
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
                    
                    pindex= find(potentials==current_potential);
                    if filterspikes==1
                        aa=dspikes>=start;
                        bb=dspikes<=stop;
                        cc=aa+bb;
                        dd=sum(cc==2); %cc==1
                    else
                        dd=0;
                    end
                    
                    nreps(findex, Raindex, Laindex, dindex, pindex)=nreps(findex, Raindex, Laindex, dindex, pindex)+1;
                    if dd>0 % at least one spike escaped during that trial. Add it to this matrix
                        M1spikes(findex,Raindex, Laindex,dindex, pindex, nreps(findex, Raindex, Laindex, dindex, pindex),:)=scaledtrace(region);
                        spikecounter=spikecounter+dd;
                        trialsremoved=trialsremoved+1;
                        fprintf('\n%d spike(s) removed from findex %d, Raindex %d, Laindex %d, dindex %d, pindex %d, rep %d',dd,findex,Raindex, Laindex,dindex, pindex, nreps(findex, Raindex, Laindex, dindex, pindex));
                    else % no spikes detected, add it to this matrix
                        M1(findex,Raindex, Laindex,dindex, pindex, nreps(findex, Raindex, Laindex, dindex, pindex),:)=scaledtrace(region);
                        TrialRemainingAfter(findex,Raindex, Laindex,dindex, pindex, nreps(findex, Raindex, Laindex, dindex, pindex),:)=1;
                    end
                    M1stim(findex,Raindex, Laindex,dindex, pindex, nreps(findex, Raindex, Laindex, dindex, pindex),:)=stim(region);
                    
                end
            end
        end
    end
end

fprintf('\n%d spike(s) from %d trial(s) removed from this file',spikecounter,trialsremoved);
%mM1=mean(M1, 4);
%mM=mean(M(:,:,:,21:38,:), 4);

for dindex=1:numdurs
    for Raindex=1:numamps
        for Laindex=1:numamps
            for findex=1:numfreqs
                for pindex=1:numpotentials
                    nr=nreps(findex, Raindex, Laindex,dindex, pindex);
                    mM1spikes(findex, Raindex, Laindex,dindex, pindex, 1, :)=mean(M1(findex, Raindex, Laindex,dindex, pindex, 1:nr, :), 6);
                    mM1(findex, Raindex, Laindex,dindex, pindex, 1, :)=mean(M1(findex, Raindex, Laindex,dindex, pindex, 1:nr, :), 6);
                end
            end
        end
    end
end

%subtract Vout and liquid junction potential
liquid_junction_potential=12;
corrected_potentials=potentials-Vout-liquid_junction_potential;
fprintf('\nsubtracted %d mV and %d mV from command potentials', Vout, liquid_junction_potential);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data trace (code stolen from getlostat1)
figure
hold on
plot(scaledtrace)
hh=get(gca,'ylim');
if lostat1==length(scaledtrace)
    title(sprintf('%s-%s-%s-%s',expdate,username,session,filenum));
elseif lostat1~=length(scaledtrace)
    line([lostat1 lostat1],[hh(1) hh(2)],'linewidth',2,'linestyle',':','color','k');
    title(sprintf('%s-%s-%s-%s, dotted line = lostat1',expdate,username,session,filenum));    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%assign outputs
out.TrialRemainingAfter=TrialRemainingAfter;
out.M1=M1;
out.mM1=mM1;
out.M1stim=M1stim;
out.nreps=nreps;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.Ramps=Ramps;
out.Lamps=Lamps;
out.durs=durs;
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

out.filterspikes=filterspikes;
out.nstd=nstd;
out.M1spikes=M1spikes;
out.mM1spikes=mM1spikes;
out.spikecounter=spikecounter;
out.trialsremoved=trialsremoved;

try godatadir(expdate, session, filenum)    
catch
    godatadirbak(expdate, session, filenum)
end

outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
% fprintf('\n\nDATA NOT SAVED TO ALLOW BINANALYSIS TO RUN!\n', outfilename)
fprintf('\nsaved in %s...', outfilename)
save(outfilename, 'out');
fprintf('\n');



