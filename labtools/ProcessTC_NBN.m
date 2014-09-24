function ProcessTC_NBN(expdate, session, filenum, varargin)
% processes tuning curve (LFP or Vm data)
%for narrow-band noise tuning curve
%
% usage: ProcessTC_NBN(expdate, session, filenum, [xlimits])
% (xlimits is optional)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
elseif nargin==4
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    
else
    error('wrong number of arguments');
end

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);

fprintf('\nload file : ')
try
    fprintf('\ntrying to load %s...', datafile)
    global pref
    if pref.usebak
        godatadirbak(expdate, session, filenum)
    else
        godatadir(expdate, session, filenum)
    end
    L=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf('done.');
catch
    try
        if pref.usebak
            ProcessData_singlebak(expdate, session, filenum)
        else
            ProcessData_single(expdate, session, filenum)
        end
        L=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);
        fprintf('done.');
    catch
        fprintf('\nProcessed data: %s not found. \nDid you copy into Backup?', datafile)
    end
end

event=E.event;
if isempty(event) fprintf('\nno tones\n'); return; end
scaledtrace=L.nativeScaling*double(L.trace)+ L.nativeOffset;
stim=S.nativeScalingStim*double(S.stim)+ S.nativeOffsetStim;
clear E L


fprintf('\ncomputing tuning curve...');

samprate=1e4;
lostat=-1;
if lostat==-1 lostat=length(scaledtrace);end
fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));





%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=inf;
    elseif strcmp(event(i).Type, 'noise')
        j=j+1;
        allfreqs(j)=event(i).Param.center_frequency;
        allbws(j)=event(i).Param.bandwidthOct;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
bws=unique(allbws);
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

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
M1=[];
nreps=zeros(numfreqs, numamps, numbws);


%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')  | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'noise')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) &~isempty(event(i).Position_rising)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat
                fprintf('\ndiscarding trace')
            else
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.duration;
                    bw=0;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                    bw=inf;
                elseif strcmp(event(i).Type, 'noise')
                    dur=event(i).Param.duration;
                    freq=event(i).Param.center_frequency;
                    bw=event(i).Param.bandwidthOct;
                end
                
                amp=event(i).Param.amplitude;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                %Note: not using dindex since MakeNBNProtocol is contrained to a single duration
                bwindex=find(bws==bw);
                nreps(findex, aindex, bwindex)=nreps(findex, aindex, bwindex)+1;
                M1stim(findex,aindex,bwindex, nreps(findex, aindex, bwindex),:)=stim(region);
                M1(findex,aindex,bwindex, nreps(findex, aindex, bwindex),:)=scaledtrace(region);
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))


%accumulate across trials
for bwindex=[1:numbws]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            mM1(findex, aindex, bwindex,:)=mean(M1(findex, aindex, bwindex, 1:nreps(findex, aindex, bwindex),:), 4);
            mM1stim(findex, aindex, bwindex,:)=mean(M1stim(findex, aindex, bwindex, 1:nreps(findex, aindex, bwindex),:), 4);
        end
    end
end

out.M1=M1; %traces, i.e. lfp, trial by trial
out.mM1=mM1; %traces averaged across trials
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.amps=amps;
out.samprate=samprate;
out.nreps=nreps;
out.M1stim=M1stim;
out.mM1stim=mM1stim;
out.durs=durs;
out.bws=bws;
out.xlimits=xlimits;
outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
godatadir(expdate, session, filenum)
save (outfile, 'out')
fprintf('\n saved to %s', outfile)



fprintf('\n\n')

