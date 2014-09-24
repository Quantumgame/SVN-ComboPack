 function MakeSpNoiseProtocol_WithShuffle(varargin)
%usage: MakeSpNoiseProtocol([amplitude], [start], [duration], [isi], [bands], nreps)
%
%creates an exper2 stimulus protocol file that plays SP_Noise stimuli
%these are speech-envelope filtered noise stimuli developed by Stephen
%David and colleagues
% inputs:
% amplitude: peak instantaneous amplitude in dB SPL, defaults to pref.maxSPL
% start (in seconds): length of silent period at start, (defaults to zero)
%  duration (in seconds): duration of speech to put in each epoch. Total
%  speech set will be divided into epochs of this length, for example if
%  you want hold command segments of 30s.
%
%   (defaults to total duration of the speech stimuli = 180s + 60*isi)
%isi (in seconds): interval between 3s sentences (defaults to 1s)
%   (note isi is added at start and end of each sentence, so there is a
%   2*isi gap of silence between sentences
%bands: matrix of frequency bands, defaults to 1 wideband
% e.g. 1 band: [1e3 64e3]
%      2 bands: [1e3 8e3; 8e3 64e3]
%      3 bands: [1e3 4e3; 4e3 16e3; 16e3 64e3]
%      4 bands: [1e3 2828; 2828 8e3; 8e3 22627; 22627 64e3]
%      6 bands: [1e3 2e3; 2e3 4e3; 4e3 8e3; 8e3 16e3; 16e3 32e3; 32e3 64e3]
%nreps: number of repetitions, defaults to 1
%
% outputs:
% creates a suitably named stimulus protocol in
% exper2.2\protocols\soundfiles
%
%example call: MakeSpNoiseProtocol(80, 1, [], .25, [1e3 64e3], 1)
%
%details: there are 30 (for 1 band) or 60 sentences (for >1 band) which are
%concatenated, separated by silence of length isi. One sentence (currently
%the first one) is "high-rep", i.e. every 6th sentence is the first one
%repeated. The idea here is to balance high reps for a single sentence (to
%assess reliability), with single reps for a wide range of stimuli (to
%maximize the span of stimulus space). The sequence is stored along with
%the stimuli in the stimulus directory.
%
%
global pref
if isempty(pref) Prefs;end

if nargin==0
    amp=pref.maxSPL;
    duration=[];
    start=0;
    isi=[];
    bands= [1e3 64e3];
    nreps=1;
elseif nargin==1
    amp=varargin{1};
    start=0;
    duration=[];
    isi=[];
    bands= [1e3 64e3];
    nreps=1;
elseif nargin==2
    amp=varargin{1};
    start=varargin{2};
    duration=[];
    isi=[];
    bands= [1e3 64e3];
    nreps=1;
elseif nargin==3
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=duration/2;
    bands= [1e3 64e3];
    nreps=1;
elseif nargin==4
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    bands= [1e3 64e3];
    nreps=1;
elseif nargin==5
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    bands=varargin{5};
    nreps=1;
elseif nargin==6
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    bands=varargin{5};
    nreps=varargin{6};
else error('makeSPNoiseProtocol: wrong number of arguments')
end

if isempty(amp)
    amp=pref.maxSPL;
end
if isempty(start)
    start=0;
end
if isempty(isi)
    isi=1;
end
if isempty(bands)
    bands= [1e3 64e3];
end
nbands=size(bands, 1);
bandstr=['[',sprintf('%g-%g;',.1*round(bands'/100))];
bandstr=bandstr(1:end-1);
bandstr(end+1)=']';
fullbandstr=['[',sprintf('%g-%g;',bands')];
fullbandstr=fullbandstr(1:end-1);
fullbandstr(end+1)=']';
if isempty(nreps)
    nreps=1;
end


%here is where we read in the wav file as s
SamplingRate=192000;
EnvSamplingRate=200; %difference between these two sampling rates?
PreStimSilence=isi; %probably want to change this
[WavSet,EnvSet, sequence, newSamplingRate]= MakeSPNoise(SamplingRate, EnvSamplingRate, bands, PreStimSilence);
s=WavSet;
totaldur=length(s)/newSamplingRate;
s=resample(s, pref.SoundFs , newSamplingRate); %resample to soundcard samprate
SoundFs=pref.SoundFs;

%normalize and set to requested SPL;
s=s./max(abs(s));
amplitude=1*(10.^((amp-pref.maxSPL)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
s=amplitude.*s;

% cut into epochs
if isempty(duration)
    duration=length(s)/SoundFs;
end
dsamp=duration*SoundFs;
if dsamp>length(s)
    duration=length(s)/SoundFs;
    fprintf('\nrequested epoch duration longer than sound, using 1 epoch of duration %.1f s', duration)
    nepochs=1;
elseif dsamp==length(s)
    duration=length(s)/SoundFs;
    fprintf('\nusing 1 epoch of duration %.1f s', duration)
    nepochs=1;
elseif dsamp<length(s)
    nsentences=round(duration/(3+2*isi));
    nepochs=ceil(length(sequence)/(nsentences));
    duration=nsentences*(3+2*isi); %adjust duration to fit sound better
    fprintf('\nputting %d sentences in each epoch', nsentences)
    fprintf('\nadjusting epoch duration to %.1f s to fit evenly', duration)
    dsamp=floor(duration*SoundFs);
    dsampEnv=ceil(duration*EnvSamplingRate);
    fprintf('\nusing %d epochs', nepochs)
end

ss=zeros(nepochs, dsamp);
Env=zeros(nepochs, dsampEnv);
seq=nan*zeros(nepochs, nsentences);

for ne=1:nepochs
    if dsamp*ne<length(s)
        ss(ne,:)=s(dsamp*(ne-1)+1:dsamp*ne);
        Env(ne,:)=EnvSet(dsampEnv*(ne-1)+1:dsampEnv*ne);
        seq(ne,:)=sequence((ne-1)*nsentences+1:ne*nsentences);
    else
        tail=s(dsamp*(ne-1)+1:end);
        ss(ne,1:length(tail))=tail;
        tailEnv=EnvSet(dsampEnv*(ne-1)+1:end);
        Env(ne,1:length(tailEnv))=tailEnv;
        tailseq=sequence((ne-1)*nsentences+1:end);
        seq(ne,1:length(tailseq))=tailseq;
    end
end

%put into stimuli structure
cd (pref.stimuli)
if ~exist('soundfiles', 'dir')
    mkdir('soundfiles')
end
cd ('soundfiles')
if ~exist('sourcefiles', 'dir')
    mkdir('sourcefiles')
end
cd sourcefiles

sample.param.description='SPNoise stimulus';
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('SPNoise_%ddB_%.1fs_isi%dms_%db%s_n%d', amp, duration, 1000*isi, nbands, bandstr, nreps);
stimuli(1).param.description= sprintf('SPNoise %ddB epoch duration=%.1fs isi=%dms nbands=%d:%s, %.1fs of speech divided into %d epochs, %dreps', amp, duration, 1000*isi, nbands,fullbandstr, totaldur, nepochs, nreps);


outfilename=sprintf('SPNoise_protocol_%ddB_%.1fs_%db%s_isi%dms_%de_n%d.mat', amp, duration, nbands,bandstr, 1000*isi, nepochs, nreps);

for nr=1:nreps
    for ne=1:nepochs
        n=(nr-1)*nepochs+ne+1;
        fprintf('\nnr%d, ne%d, n%d', nr, ne, n')
        stimuli(n).type='naturalsound';
        sample.sample=ss(ne,:);
        env=Env(ne,:);
        sourcefilename=sprintf('SPNoise_sourcefile_%ddB_%.1fs_%db%s_isi%dms_start%d_%de_n%d.mat', amp, duration, nbands,bandstr, 1000*isi, start, ne, nreps);
        envfilename=sprintf('SPNoise_envfile_%ddB_%.1fs_%db%s_isi%dms_start%d_%de_n%d.mat', amp, duration, nbands,bandstr, 1000*isi,start, ne, nreps);
        save(sourcefilename, 'sample');
        save(envfilename, 'env', 'EnvSet', 'sequence', 'EnvSamplingRate', 'SoundFs');
        
        stimuli(n).param.file=['soundfiles\sourcefiles\',sourcefilename];
        stimuli(n).param.duration=duration*1e3; %in ms
        stimuli(n).param.amplitude=amp; %
        stimuli(n).param.next=isi*1000;
        stimuli(n).param.sequence=seq(ne,:);
    end
end


cd ('..')
save(outfilename, 'stimuli');

fprintf('\nwrote files %s \nand %s \nin directory %s',outfilename,sourcefilename,pwd )


function [WavSet,EnvSet, sequence, newSamplingRate]= MakeSPNoise(SamplingRate, EnvSamplingRate, Bands, PreStimSilence)
% modified from spnoise_example.m
% generates two matrices:
%   WavSet :  Time X Sample matrix of SpNoise waveforms.  Current settings
%             generate 60 waveforms of 4-sec duration.  First and last
%             500 ms are silence.  Two bands (500-1000 Hz and 2000-4000 Hz)
%             modulated by envelopes taken from the TIMIT database.
%             10% (ie, the last 6 waveforms) have coherent envelopes,
%             meaning that noise in both bands is modulated by the same
%             envelope.  Samples 1-54 have incoherent envelopes.  Sampled
%             at 100000 Hz
%   EnvSet :  Envelopes for each band from each waveform, sampled at 200 Hz

% basic important parameters
% SamplingRate=100000;
%SamplingRate=44100;
% EnvSamplingRate=200;
numbands=size(Bands, 1);
% Band1=[1000 2000];
% Band2=[2000 4000];
%Band3=[4000 8000];
CoherentFraction=0;  % fraction of waveforms with coherent envelopes
ShuffleOnset=2;  % if 2, shuffle times of the different streams
                 % if 0, don't shuffle

% generate waveforms using SpNoise object
s=SpNoise;

s=set(s,'PreStimSilence',PreStimSilence);
s=set(s,'PostStimSilence',PreStimSilence);
s=set(s,'Duration',3); %This has to be 3 or shorter, or waveform breaks
s=set(s,'SamplingRate',SamplingRate);
s=set(s,'LowFreq',Bands(:,1)');
s=set(s,'HighFreq',Bands(:,2)');
% s=set(s,'LowFreq',[Band1(1) Band2(1) Band3(1)]);
% s=set(s,'HighFreq',[Band1(2) Band2(2) Band3(2)]);
s=set(s,'CoherentFrac',CoherentFraction);
s=set(s,'ShuffleOnset',ShuffleOnset);

newSamplingRate=get(s, 'SamplingRate');
totalsec=get(s,'PreStimSilence')+get(s,'Duration')+...
    get(s,'PostStimSilence');
totalbins=totalsec.*newSamplingRate;
envbins=totalsec.*EnvSamplingRate;

MaxIndex=get(s,'MaxIndex');
% WavSet=zeros(totalbins,MaxIndex);
% EnvSet=zeros(envbins,numbands,MaxIndex);
WavSet=[];
EnvSet=[];
fprintf('Generating waveforms and envelopes ');
for bandindex=1:numbands
    f1 = Bands(bandindex,1)/newSamplingRate*2;
    f2 = Bands(bandindex,2)/newSamplingRate*2;
    [b,a] = ellip(4,.5,20,[f1 f2]);
    FilterParams(bandindex).a=a;
    FilterParams(bandindex).b=b;
    % f1 = Band2(1)/SamplingRate*2;
    % f2 = Band2(2)/SamplingRate*2;
    % [b,a] = ellip(4,.5,20,[f1 f2]);
    % FilterParams2 = [b;a];
    % f1 = Band3(1)/SamplingRate*2;
    % f2 = Band3(2)/SamplingRate*2;
    % [b,a] = ellip(4,.5,20,[f1 f2]);
    % FilterParams3 = [b;a];
end

hi_rep_2use=1; %use this sentence for hi rep
sequence=[]; %sequence stores the order in which the speech waveforms are concatenated
wb=waitbar(0,'Generating waveforms and envelopes');
for ii=1:MaxIndex,
%     fprintf('.');
    waitbar(ii/MaxIndex, wb);
    if ~mod(ii,3) %every 6th sentence is the first one, for high reps
        sequence=[sequence hi_rep_2use];
        wf=waveform(s,hi_rep_2use)./5.01;
        WavSet=[WavSet; wf]; %
        tenv=zeros(length(wf),numbands);
        %        tenv=zeros(totalbins,numbands);
        for bandindex=1:numbands
            a=FilterParams(bandindex).a;
            b=FilterParams(bandindex).b;
            tenv(:,bandindex)=filtfilt(b,a,wf);
        end
        decrementstep=newSamplingRate./EnvSamplingRate;
        smfilt=ones(ceil(decrementstep),1)./ceil(decrementstep);
        tenv=conv2(abs(tenv),smfilt,'same').*2;
        %        EnvSet=[EnvSet; tenv(round(decrementstep./2:decrementstep:totalbins),:)];
        EnvSet=[EnvSet; tenv(round(decrementstep./2:decrementstep:length(wf)),:)];
        
    end
    
    sequence=[sequence ii];
    
    %WavSet(:,ii)=waveform(s,ii)./5.01; %this makes a big matrix
    wf=waveform(s,ii)./5.01;
    WavSet=[WavSet; wf]; %instead I am concatenating here
    
    %    tenv=zeros(totalbins,numbands);
    tenv=zeros(length(wf),numbands);
    for bandindex=1:numbands
        a=FilterParams(bandindex).a;
        b=FilterParams(bandindex).b;
        tenv(:,bandindex)=filtfilt(b,a,wf);
        %    tenv(:,2)=filtfilt(FilterParams2(1,:),FilterParams2(2,:),WavSet(:,ii));
    end
    decrementstep=newSamplingRate./EnvSamplingRate;
    smfilt=ones(ceil(decrementstep),1)./ceil(decrementstep);
    tenv=conv2(abs(tenv),smfilt,'same').*2;
    %        EnvSet=[EnvSet; tenv(round(decrementstep./2:decrementstep:totalbins),:)];
    EnvSet=[EnvSet; tenv(round(decrementstep./2:decrementstep:length(wf)),:)];
    
end
close(wb)
fprintf('\n');
%SpNoise object can force sampling rate if less than 4*highest frequency


% ttwav=(1:totalbins)'./SamplingRate;
% ttenv=(1:envbins)'./EnvSamplingRate;

% plot examples
ex_dur=30;

wf1=WavSet(1:newSamplingRate*ex_dur);
wf2=WavSet(end-newSamplingRate*ex_dur+1:end);
env1=EnvSet(1:EnvSamplingRate*ex_dur,:);
env2=EnvSet(end-EnvSamplingRate*ex_dur+1:end,:);
ttwav=(1:length(wf1))./newSamplingRate;
ttenv=(1:length(env1))./EnvSamplingRate;

figure;
subplot(2,1,1);
exampleidx=1;
%plot(ttwav,WavSet(:,exampleidx),'k');
plot(ttwav,wf1,'w');
hold on;
%plot(ttenv,EnvSet(:,:,exampleidx),'LineWidth',2);
plot(ttenv,env1,'LineWidth',2);
hold off;
%legend('Waveform','Band 1 Env','Band 2 Env');
title(sprintf('Example first %d s',ex_dur));

subplot(2,1,2);
exampleidx=MaxIndex;
% plot(ttwav,WavSet(:,exampleidx),'k');
plot(ttwav,wf2,'k');
hold on;
%plot(ttenv,EnvSet(:,:,exampleidx),'LineWidth',2);
plot(ttenv,env2,'LineWidth',2);
hold off;
%legend('Waveform','Band 1 Env','Band 2 Env');
title(sprintf('Example last %d s',ex_dur));

figure
subplot(2,1,1);
exampleidx=1;

spectrogram(wf1, [1024],[], 512, newSamplingRate,'yaxis');%ylim([0 20e3]);shg

subplot(2,1,2);
exampleidx=MaxIndex;
spectrogram(wf2, [1024],[], 512, newSamplingRate,'yaxis');%ylim([0 20e3]);shg

