function ProcessTC(varargin)
%sorts processed data (e.g. Axopatch-Data) into a big response matrix
%for LFP, WC, or other continuous data (i.e. does not extract spikes)
%usage: ProcessTC(expdate, session, filename, thresh, [xlimits], [ylimits])
%saves output in an outfile

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    thresh=5;
    xlimits=[0 500]; %x limits for axis
    ylimits=[-.1 .2];
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
       xlimits=[0 500]; %x limits for axis
    ylimits=[-.1 .2];
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=[-.1 .2];
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
thresh=5; 

%fprintf('\nfound lostat file. using lostat %d %d',lostat );
%lostat=getlostat(expdate,session, filenum); %discard data after this position (in samples), [] to skip
%getgotat(expdate,session, filenum); %discard data before this position (in samples), [] to skip
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
[D E S]=gogetdata(expdate,session,filenum);
fprintf('\nload file 1: ')
try
    fprintf('\ntrying to load %s...', datafile)
    godatadir(expdate, session, filenum)
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf('done.');
catch
    fprintf('failed. Could not find data')
end

event=E.event;
stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
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

%if isempty(lostat) lostat=length(scaledtrace);end
%if isempty(gotat1) gotat1=1;end
%scaledtrace=scaledtrace(1:lostat); %truncate to lostat
% cannot do scaledtrace(gotat:lostat) because event.Position will be wrong
clear D E S

fprintf('\ncomputing tuning curve...');

samprate=1e4;
%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, '2tone') |strcmp(event(i).Type, 'tone') ...
            |strcmp(event(i).Type, 'fmtone') | strcmp(event(i).Type, 'whitenoise')| strcmp(event(i).Type, 'grating')
        j=j+1;
        alldurs(j)=event(i).Param.duration;
        if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, '2tone')
            allamps(j)=event(i).Param.amplitude;
            allfreqs(j)=event(i).Param.frequency;
        elseif strcmp(event(i).Type, 'whitenoise')
            allamps(j)=event(i).Param.amplitude;
            allfreqs(j)=-1;
        elseif strcmp(event(i).Type, 'fmtone')
            allamps(j)=event(i).Param.amplitude;
            allfreqs(j)=event(i).Param.carrier_frequency;
        elseif strcmp(event(i).Type, 'grating')
            allfreqs(j)=event(i).Param.angle*1000;
            allamps(j)=event(i).Param.spatialfrequency;
        end
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

M1=[];
nreps=zeros(numfreqs, numamps, numdurs);

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'whitenoise') | ...
            strcmp(event(i).Type, 'fmtone') | strcmp(event(i).Type, '2tone')| strcmp(event(i).Type, 'grating')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat
                fprintf('\ndiscarding trace (after lostat)')
            %elseif start<gotat1
             %   fprintf('\ndiscarding trace (before gotat)') commented out
             %   by ira 09-05-2013
            else
                switch event(i).Type
                    case {'tone', '2tone'}
                        freq=event(i).Param.frequency;
                        amp=event(i).Param.amplitude;
                    case 'fmtone'
                        freq=event(i).Param.carrier_frequency;
                        amp=event(i).Param.amplitude;
                    case 'whitenoise'
                        freq=-1;
                        amp=event(i).Param.amplitude;
                    case 'grating'
                        amp=event(i).Param.spatialfrequency;
                        freq=event(i).Param.angle*1000;
                end


                dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps(findex, aindex, dindex),:)=scaledtrace(region);
                M1stim(findex,aindex,dindex, nreps(findex, aindex, dindex),:)=stim1(region);
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
        for findex=1:numfreqs
            for dindex=1:numdurs
                if nreps(findex, aindex, dindex)>0
                    mM1(findex, aindex, dindex,:)=mean(M1(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
                    mM1stim(findex, aindex, dindex,:)=mean(M1stim(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
                else %no reps for this stim, since rep=0
                    mM1(findex, aindex, dindex,:)=zeros(size(region));
                    mM1stim(findex, aindex, dindex,:)=zeros(size(region));
                end
            end
        end
    end
end



%find optimal axis ylimits
if ylimits<0
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            trace=mM1(findex, aindex, dindex,:);
            ylimits(1)=min(ylimits(1), min(trace));
            ylimits(2)=max(ylimits(2), max(trace));
        end
    end
end

%%
% added by ira 09-17-13
% this way there is only one outfile that can be used for PlotTC and
% PlotTC_psth
% high_pass_cutoff=300; %Hz
%     fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
%     [b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
%     filteredtrace=filtfilt(b,a,scaledtrace);
%             
%             nstd=thresh/std(filteredtrace);
%             fprintf('\nusing absolute spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
%         thresh=nstd*std(filteredtrace);
%         if thresh>1
%             fprintf('\nusing spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
%         elseif thresh<=1
%             fprintf('\nusing spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
%         end
%         refract=15;
%     fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
%     spikes=find(abs(filteredtrace)>thresh);
%     dspikes=spikes(1+find(diff(spikes)>refract));
%     try dspikes=[spikes(1) dspikes'];
%     catch
%         fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high\n. Ingore if plotting LFPs');
%         
%     end
    

%%
%assign outputs
out.scaledtrace=scaledtrace;
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
out.lostat=lostat;
out.freqs=freqs;
out.amps=amps;
out.durs=durs;
out.nreps=nreps;
out.numfreqs=numfreqs;
out.numamps=numamps;
out.numdurs=numdurs;
out.traces_to_keep=traces_to_keep;
out.event=event;
out.xlimits=xlimits;
out.ylimits=ylimits;
out.samprate=samprate;
% out.nstd=nstd;
% out.thresh=thresh;
% out.dspikes=dspikes;
% out.filteredtrace=filteredtrace;

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum);
save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)

