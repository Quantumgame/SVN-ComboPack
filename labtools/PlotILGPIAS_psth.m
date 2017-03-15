function PlotILGPIAS_psth(expdate,session,filenum,varargin)
% PlotILGPIAS_psth(expdate,session,filenum,[thresh],[xlimits],[ylimits],[binwidth])
% y = Binned spike counts / # trials.
% 6/3/13 AKH

% Last edits:
% 7.2.13 AKH -- saves psth to .txt file for Aldis

refract=15;
fs=12; %fontsize for figures
global pref
if isempty(pref); Prefs; end

if nargin==0
    fprintf('\nNo input'); return;
elseif nargin==3
elseif nargin==4
    nstd=varargin{1};
elseif nargin==5
    nstd=varargin{1};
    xlimits=varargin{2};
elseif nargin==6
    nstd=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
elseif nargin==7
    nstd=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
    binwidth=varargin{4};
elseif nargin==8
    nstd=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
    binwidth=varargin{4};
    monitor=varargin{5};
else
    fprintf('\nWrong number of arguments'); return;
end
% varargin defaults
if ~exist('nstd','var'); nstd=7; end
if isempty(nstd); nstd=7; end
if ~exist('xlimits','var'); xlimits=[0 100]; end
if isempty(xlimits); xlimits=[0 100]; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end
if ~exist('monitor','var'); monitor=0; end
if isempty(monitor); monitor=0; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


outfile_exists=0;


if ~outfile_exists
    lostat1=-1; %discard data after this position (in samples), -1 to skip
    [D E S]=gogetdata(expdate,session,filenum);
    event=E.event;
    if isempty(event); fprintf('\nevent is empty\n'); return; end
    scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
    stim=S.nativeScalingStim*double(S.stim);
    clear D E S
    samprate=1e4;
    if lostat1==-1; lostat=length(scaledtrace);end
else
end

% Filtering step (filteredtrace, thresh, nstd, spikes, dspikes)
    fprintf('\ncomputing tuning curve...');
    high_pass_cutoff=600; %Hz
    fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
    [b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
    filteredtrace=filtfilt(b,a,scaledtrace);
    if length(nstd)==2
        if nstd(1)==-1
            thresh=nstd(2);
            nstd=thresh/std(filteredtrace);
            fprintf('\nusing absolute spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
        end
    else
        thresh=nstd*std(filteredtrace);
        if thresh>1
            fprintf('\nusing spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
        elseif thresh<=1
            fprintf('\nusing spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
        end
    end
    fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
    spikes=find(abs(filteredtrace)>thresh);
    dspikes=spikes(1+find(diff(spikes)>refract));
    try dspikes=[spikes(1) dspikes'];
    catch
        fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high\n');
        return
    end


%get freqs/amps
if ~outfile_exists
    j=0;
    for i=1:length(event)
        if strcmp(event(i).Type, 'GPIAS') 
            j=j+1;
            allsoas(j)=event(i).Param.soa;
            allgapdurs(j)=event(i).Param.gapdur;
            allgapdelays(j)=event(i).Param.gapdelay;
            allnoisefreqs(j)=event(i).Param.center_frequency;
            allpulseamps(j)=event(i).Param.pulseamp;
            allpulsedurs(j)=event(i).Param.pulsedur;
            allnoiseamps(j)=event(i).Param.amplitude;
            allnoiselower_frequencies(j)=event(i).Param.lower_frequency;
            allnoiseupper_frequencies(j)=event(i).Param.upper_frequency;
        end
    end
    
    for i=1:length(event)
        if strcmp(event(i).Type, 'gapinnoise')
            j=j+1;
            allsoas(j)=event(i).Param.soa;
            allgapdurs(j)=event(i).Param.gapdur;
            allgapdelays(j)=event(i).Param.gapdelay;
            allnoisefreqs(j)=event(i).Param.center_frequency;
            allpulseamps(j)=event(i).Param.pulseamp;
            allpulsedurs(j)=event(i).Param.pulsedur;
            allnoiseamps(j)=event(i).Param.amplitude;
            allnoiselower_frequencies(j)=event(i).Param.lower_frequency;
            allnoiseupper_frequencies(j)=event(i).Param.upper_frequency;
        end
    end
    
    M1=[];
    gapdurs=unique(allgapdurs);
    pulsedurs=unique(allpulsedurs);
    soas=unique(allsoas);
    gapdelays=unique(allgapdelays);
    pulseamps=unique(allpulseamps);
    pulsedurs=unique(allpulsedurs);
    noisefreqs=unique(allnoisefreqs);
    noiseamps=unique(allnoiseamps);
    noiselower_frequencies=unique(allnoiselower_frequencies);
    noiseupper_frequencies=unique(allnoiseupper_frequencies);
    numgapdurs=length(gapdurs);
    numpulseamps=length(pulseamps);
    nreps=zeros( numgapdurs, numpulseamps);
    
    if length(noisefreqs)~=1
        error('not able to handle multiple noisefreqs')
    end
    if length(noiselower_frequencies)~=1
        error('not able to handle multiple noiselower_frequencies')
    end
    if length(noiseupper_frequencies)~=1
        error('not able to handle multiple noiseupper_frequencies')
    end
    if length(noiseamps)~=1
        error('not able to handle multiple noiseamps')
    end
    if length(gapdelays)~=1
        error('not able to handle multiple gapdelays')
    end
    if length(pulsedurs)~=1
        error('not able to handle multiple pulsedurs')
    end
    if length(soas)~=1
        error('not able to handle multiple soas')
    end
    
    noiseamp=noiseamps;
    soa=soas;
    pulsedur=pulsedurs;
    gapdelay=gapdelays;
    noisefreq=noisefreqs;
    noiseupper_frequency=noiseupper_frequencies;
    noiselower_frequency=noiselower_frequencies;
    noiseBW=log2(noiseupper_frequency/noiselower_frequency);
    
    M1ONtc=[];
    M2ONtc=[];
    M1ONtcstim=[];
    M1OFFtc=[];
    M2OFFtc=[];
    M1OFFtcstim=[];
    
    mM1ONtc=[];
    mM2ONtc=[];
    mM1ONtcstim=[];
    mM1OFFtc=[];
    mM2OFFtc=[];
    mM1OFFtcstim=[];
    
    medM1ONtc=[];
    medM2ONtc=[];
    medM1ONtcstim=[];
    medM1OFFtc=[];
    medM2OFFtc=[];
    medM1OFFtcstim=[];
    
    rsM1ONtc=[];
    rsM2ONtc=[];
    rsM1ONtcstim=[];
    rsM1OFFtc=[];
    rsM2OFFtc=[];
    rsM1OFFtcstim=[];
    
    nrepsON=zeros(numgapdurs, numpulseamps);
    nrepsOFF=zeros(numgapdurs, numpulseamps);
    
end

%extract the traces into a big matrix M
if ~outfile_exists
    for i=1:length(event)
    if i==361
        %keyboard
    end
%     if any(i==(restarts))
%         numrestarts=numrestarts+1;
%         fprintf('\ndiscarding event %d due to PPA restart', i)
%     end
%     waitbar( i/length(event), wb);
    if strcmp(event(i).Type, 'GPIAS') 
        
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            pr=event(i).Position_rising;
            Delta(i)=pos-pr;
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+(xlimits(1)+gapdelay)*1e-3*samprate);
        stop=(pos+(xlimits(2)+gapdelay)*1e-3*samprate)-1;
        
        region=start:stop;
        if isempty(find(region<0)) % disallow negative start times
            gapdur=event(i).Param.gapdur;
            gdindex= find(gapdur==gapdurs);
            pulseamp=event(i).Param.pulseamp;
            paindex= find(pulseamp==pulseamps);
            aopulseon=event(i).Param.AOPulseOn;
            
            spiketimes1=dspikes(dspikes>start & dspikes<stop);
            spiketimes1=(spiketimes1-pos)/(samprate*1e-3);
            
            if aopulseon
                nrepsON(gdindex, paindex)=nrepsON(gdindex, paindex)+1;
                M1ONtc(gdindex, paindex, nrepsON(gdindex, paindex)).spiketimes=spiketimes1; % STILL IN SAMPLES
                M1ONtcstim(gdindex, paindex, nrepsON(gdindex, paindex),:)=stim(region);
            else
                nrepsOFF(gdindex, paindex)=nrepsOFF(gdindex, paindex)+1;
                M1OFFtc(gdindex, paindex, nrepsOFF(gdindex, paindex)).spiketimes=spiketimes1;
                M1OFFtcstim(gdindex, paindex, nrepsOFF(gdindex, paindex),:)=stim(region);
            end
        end
    end
    end
end

    %accumulate across trials ON
    for paindex=1:numpulseamps
        for gdindex=1:numgapdurs

                spiketimes1=[];
                for rep=1:nrepsON(gdindex,paindex)
                    spiketimes1=[spiketimes1 M1ONtc(gdindex,paindex, rep).spiketimes];
                end
                mM1ONtc(gdindex,paindex).spiketimes=spiketimes1;

        end
    end
    
    %accumulate across trials OFF
    for paindex=1:numpulseamps
        for gdindex=1:numgapdurs

                spiketimes1=[];
                for rep=1:nrepsOFF(gdindex,paindex)
                    spiketimes1=[spiketimes1 M1OFFtc(gdindex,paindex, rep).spiketimes];
                end
                mM1OFFtc(gdindex,paindex).spiketimes=spiketimes1;

        end
    end
    
    for paindex=1:numpulseamps;
        for gdindex=1:numgapdurs;
            mM1ONtcstim(gdindex, paindex,:)=mean(M1ONtcstim(gdindex, paindex, 1:nrepsON(gdindex, paindex),:), 3);
            mM1OFFtcstim(gdindex, paindex,:)=mean(M1OFFtcstim(gdindex, paindex, 1:nrepsOFF(gdindex, paindex),:), 3);
        end
    end

    
ylimmax=.0001;    
for paindex=1:numpulseamps
    for gdindex=1:numgapdurs
        spiketimes1=mM1ONtc(gdindex,paindex).spiketimes;
        X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
        [N, x]=hist(spiketimes1, X);
        N=N./nrepsON(gdindex,paindex); % averaged across trials
        if max(N)>ylimmax
            ylimmax=max(N);
        end
    end
end

    
    
% Plotpsth ON
figure
for paindex=1:numpulseamps
        p=0;
        subplot1(numgapdurs,1)
        
        for gdindex=1:numgapdurs
            p=p+1;
            subplot1(p)
            hold on
            
            if p==1
                title(sprintf('%s-%s-%s, Green=Laser ON; Black=Laser OFF',expdate,session,filenum))
            end
            
            ONcounts=[M1ONtc(gdindex,paindex,:).spiketimes];
            OFFcounts=[M1OFFtc(gdindex,paindex,:).spiketimes];
            [h,pvalues]=ttest2(ONcounts,OFFcounts);
            if pvalues<0.05
                if mean(ONcounts)>mean(OFFcounts)
                    fprintf('\n%.1f ms gap: p = %f; ON > OFF',gapdurs(gdindex),pvalues)
                else
                    fprintf('\n%.1f ms gap: p = %f; OFF > ON',gapdurs(gdindex),pvalues)
                end
            else
                fprintf('\n%.1f ms gap: p = %f',gapdurs(gdindex),pvalues)
            end
            
            % plot off psth
            spiketimes1=mM1OFFtc(gdindex,paindex).spiketimes;
            X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
            [N, x]=hist(spiketimes1, X);
            N=N./nrepsOFF(gdindex,paindex); % averaged across trials
            bar(x, N,1,'facecolor',[0 0 0]);
           
            
            
            % plot on psth
            spiketimes1=mM1ONtc(gdindex,paindex).spiketimes;
            X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
            [N, x]=hist(spiketimes1, X);
            N=N./nrepsON(gdindex,paindex); % averaged across trials
            bar(x, N,1,'facecolor','none','edgecolor',[0 .8 0]);
            
            
            stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
            stim=stim-median(stim(1:(length(stim))));
            stim=stim./max(abs(stim));
            
            t=1:length(stim);
            t=t/10;
            t=t+xlimits(1)+gapdelay;
            hold on; plot(t, (stim*(ylimmax/2)), 'm');
            
            
            
            if gapdurs(gdindex)>0
                line([gapdelay gapdelay],[-100 100],'color','m')
                line([(gapdelay+gapdurs(gdindex)) (gapdelay+gapdurs(gdindex))],[-100 100],'color','m')
            end
            
            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
            ylim([0 (1.25*ylimmax)])
            ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
            
        end    
end

xlabel('ms')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save values to .txt file.
txtfilename=sprintf('ForAldis_ILGPIAS_psth');
yn=input(sprintf('\n\nDo you want to save this to the text file %s? y=1,n=0\n\n',txtfilename));

if yn==1

cd('c:\lab\labtools')
fid=fopen(txtfilename, 'a'); %'a'=open or create file for writing; append data to end of file

fprintf(fid, '\n%s-%s-%s\n****************************',expdate,session,filenum);
fprintf(fid, '\nspike threshold = %.2f mV (%.2f SD)', thresh, nstd);

% PRINT HIST VALUES TO TXT FILE (if 'y', print to)...
% --------------------------------------------------------
%     bin centers (x)
%     note: XOFF, XON computed using passed xlimits.

    fprintf(fid, '\nBin Centers\n');
    for index=xlimits(1):binwidth:xlimits(2)
        fprintf(fid, '\t%d',index); % +50 b/c the laser onset preceeds sound onset by 50 ms
    end

% %     OFF trials
%     
%     for paindex=1:numpulseamps
%         for gdindex=1:numgapdurs
%             fprintf(fid, '\n%.0f ms GAP: OFF Trials, n=%.0f\n',gapdurs(gdindex),nrepsOFF(gdindex,paindex));
%             for rep=1:nrepsOFF(gdindex,paindex)
%                 
%                 fprintf(fid, '\nTrial # %.0f\n',rep);
%                 spikes=M1OFFtc(gdindex,paindex, rep).spiketimes;
%                 
%                 [N, x]=hist(spikes, X);
%                 
%                 for index=1:length(N)
%                     fprintf(fid, '\t%.3f', (N(index)));
%                 end
%
%                 fprintf(fid,'\n')
%             end
%         end
%     end

% OFF
for paindex=1:numpulseamps
    for gdindex=1:numgapdurs

        fprintf(fid, '\n\n%.0f ms Gap: Mean OFF Trials (%.0f)\n',gapdurs(gdindex),nrepsOFF(gdindex,paindex));
        
        for rep=1:nrepsOFF(gdindex,paindex)
            fprintf(fid,'\n');
            spiketimes1=M1OFFtc(gdindex,paindex, rep).spiketimes;
            X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
            [N, x]=hist(spiketimes1, X);
            fprintf(fid,'\t%.0f', N);
        end
    end
end

% Mean ON
for paindex=1:numpulseamps
    for gdindex=1:numgapdurs
        
        fprintf(fid, '\n%.0f ms Gap: Mean ON Trials (%.0f)\n',gapdurs(gdindex),nrepsON(gdindex,paindex));
        
        for rep=1:nrepsON(gdindex,paindex)
            fprintf(fid,'\n');
            spiketimes1=M1ONtc(gdindex,paindex, rep).spiketimes;
            X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
            [N, x]=hist(spiketimes1, X);
            fprintf(fid,'\t%.0f', N);
        end
        
    end
end

if yn
    fprintf(fid, '\n');
    fprintf(fid, '\n');
    fclose(fid);
end
end
end