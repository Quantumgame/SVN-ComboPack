function MakeGPIASProtocol(noiseamp, noisefreq, noisebandwidth, gapdurs, gapdelay, post_startle_duration, pulsedur, pulseamps, soa, soaflag, ...
    ramp, isi, isi_var, nrepeats)
% usage MakeGPIASProtocol(noiseamp, noisefreq, noisebandwidth, gapdurs,
% gapdelay, post_startle_duration, 
% pulsedur, pulseamps, soa, soaflag, ramp, iti, iti_var, nrepeats)
%
% creates an exper2 stimulus protocol file for GPIAS (gap-induced pre-pulse inhibition of acoustic startle
% response). can use multiple gap durations, gap is silent
% using variable ITI.
% mw 071307
%recent edits: 
%  -added soaflag to specify whether soa is 'soa' or 'isi'
%  -changed gapdelay to specify time to gap offset instead of gap onset (so
%   that ppalaser comes on relative to gap offset in the 'isi' case) (note:
%   this is actually implemented in MakeGPIAS)
%   mw 06.09.2014
%
%NOTE: bandwidth now specified in octaves mw061109
% inputs:
% noiseamp: amplitude of the continuous narrowband noise, in dB SPL
% noisefreq: center frequency of the continuous narrowband noise, in Hz
% noisebandwidth: bandwidth of the continuous narrowband noise, in Octaves
% gapdurs: durations of the pre-pulse gap, in ms, in a vector, e.g. 50, or [0 50]
% gapdelay: delay from start of continuous noise to gap OFFSET, in ms
% post_startle_duration: duration of noise to play after the startle
%       stimulus has finished. We added this Oct 14, 2013 to allow extra time
%       for laser be on after the startle. 
% pulsedur: duration of the startle pulse in ms (can be 0 for no startle)
% pulseamps: amplitudes of the startle pulse in dB SPL, in a vector, e.g. 95, or [90 95 100]
% soa: Stimulus Onset Asynchrony in ms = time between gap onset and
%       startle pulse tone onset
% soaflag: can be either 'soa' (default), in which case soa value specifies the time
% between the onset of the gap and the onset of the startle, or else 'isi',
% in which case soa specifies the time between gap offset and startle
% onset. If anything other than 'isi' it will default to 'soa'.
% ramp: on-off ramp duration in ms
% iti: inter trial interval (onset-to-onset) in ms
% iti_var: fractional variability of iti. Use 0 for fixed iti, or e.g. 0.1 to have iti vary by up to +-10%
% nrepeats: number of repetitions (different pseudorandom orders)
%
% outputs:
% creates a suitably named stimulus protocol in D:\lab\exper2.2\protocols\ASR Protocols
%
%example calls:
% fixed iti of 10 seconds:
%MakeGPIASProtocol(80, 8000, 6, [0 2 4 6], 1000, 1000, 25, 100, 60, 'soa', 0, 10e3, 0, 5)
%
% iti ranging from 10s to 20s (15 s on average)
%
%brief variable duration gaps, 60ms SOA
%MakeGPIASProtocol(80, 8000, 6, [0 2 4 6], 1000, 1000, 25, 100, 60, 'soa', 0, 15e3, .33, 15)
%
%brief gap, no startle, ability to deliver a long (1sec) laser pulse beyond
%startle offset time
%MakeGPIASProtocol(80, 8000, 6, [10], 1000, 1000, 0, 100, 60, 'soa', 0, 15e3, .33, 20)

%note: still using the variable isi for inter-trial interval, AKA iti

if ~strcmp(soaflag, 'isi')
    soaflag='soa';
    fprintf('\nusing soa of %d ms', soa)
else
    fprintf('\nusing isi of %d ms', soa)
end

if strcmp(soaflag, 'soa')
    if any(gapdurs>soa)
        fprintf('\n\n!!!!!!!\n\n')
        warning('at least one gap duration exceeds the soa, so that gap duration will be invalid (will be interrupted by startle during the gap)')
    end
end

%if post_startle_duration==0 error('please use a finite post_startle_duration');end

global pref
if isempty(pref) Prefs;end
if nargin~=14 error('\MakeGPIASProtocol: wrong number of arguments.'); end

numgapdurs=length(gapdurs);
numpulseamps=length(pulseamps);

gapdursstring='';
for i=1:numgapdurs
    gapdursstring=[gapdursstring, sprintf('%g-', gapdurs(i))];
end
gapdursstring=gapdursstring(1:end-1); %remove trailing -

pulseampsstring='';
for i=1:numpulseamps
    pulseampsstring=[pulseampsstring, sprintf('%d-', pulseamps(i))];
end
pulseampsstring=pulseampsstring(1:end-1); %remove trailing -

bandwidthstring=strrep(sprintf('%.2f',noisebandwidth), '.','');

[GapdurGrid,PulseampGrid]=meshgrid( gapdurs , pulseamps);
neworder=randperm( numpulseamps * numgapdurs);
rand_gapdurs=zeros(size(neworder*nrepeats));
rand_pulseamps=zeros(size(neworder*nrepeats));

for nn=1:nrepeats
    neworder=randperm( numpulseamps*numgapdurs);
    rand_gapdurs( prod(size(GapdurGrid))*(nn-1) + (1:prod(size(GapdurGrid))) ) = GapdurGrid( neworder );
    rand_pulseamps( prod(size(PulseampGrid))*(nn-1) + (1:prod(size(PulseampGrid))) ) = PulseampGrid( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('GPIAS-na%ddB-nf%dHz-nbw-%soct-gd%sms-pd%dms-pa%sdb-soa%dms(%s)-r%d-iti%d-itivar%d-%dreps.mat',...
    noiseamp, noisefreq, bandwidthstring, gapdursstring, round(pulsedur), pulseampsstring, soa,soaflag, round(ramp), isi,round(100*isi_var), nrepeats);

stimuli(1).param.description=sprintf('Gap Induced Pre-Pulse Inhibition of Startle Response stimulus protocol noise amplitude:%ddB, noise center frequency: %dHz, noise bandwidth %soct, gap duration: %sms, gapdelay: %dms, pulse duration%dms pulse amplitude:%sdb SOA:%dms (%s) ramp:%dms iti:%dms iti-var: %.1f %drepeats',...
    noiseamp, noisefreq, bandwidthstring, gapdursstring, gapdelay, pulsedur, pulseampsstring, soa, soaflag, ramp, isi,round(100*isi_var), nrepeats);
filename=stimuli(1).param.name;

nn=1;

gpias_duration=gapdelay+max(rand_gapdurs)+soa+pulsedur+post_startle_duration; %actual duration

%note: for seamless playing of sounds, all buffers must be identical in
%length. So we are making short noise segments and using variable numbers
%of them

%next=-2000;%totally empirical value that allows psychportaudio rescheduling to work seamlessly
%was -1000, trying new values to get it working on Rig 2
next = -gapdelay/2;%testing mw 032410
%next = -.9*gapdelay;%testing mw 06.11.2014

this_isi_ms=round(isi+isi*isi_var*(2*rand(1)-1));
num_noises=round(this_isi_ms/gpias_duration);
for noisenum=1:num_noises

    nn=nn+1;

    stimuli(nn).type='noise';
    stimuli(nn).param.amplitude=noiseamp;
    stimuli(nn).param.filter_operation='bandpass';
    stimuli(nn).param.center_frequency=noisefreq;
    stimuli(nn).param.lower_frequency=noisefreq/2^(noisebandwidth/2);
    stimuli(nn).param.upper_frequency=noisefreq*2^(noisebandwidth/2);
    stimuli(nn).param.ramp=ramp;
    %     stimuli(nn).param.next=round(isi+isi*isi_var*(2*rand(1)-1));
    %     stimuli(nn).param.soa=soa;
    stimuli(nn).param.loop_flg=0;
    stimuli(nn).param.seamless=1;
    %     stimuli(nn).param.duration=500;
    stimuli(nn).param.duration=gpias_duration;
    stimuli(nn).param.next=next; %totally empirical value that allows psychportaudio rescheduling to work seamlessly
end

for kk=1:length(rand_gapdurs)

    nn=nn+1;
    stimuli(nn).type='GPIAS';
    stimuli(nn).param.amplitude=noiseamp;
    stimuli(nn).param.filter_operation='bandpass';
    stimuli(nn).param.center_frequency=noisefreq;
    stimuli(nn).param.lower_frequency=noisefreq/2^(noisebandwidth/2);
    stimuli(nn).param.upper_frequency=noisefreq*2^(noisebandwidth/2);
    stimuli(nn).param.ramp=ramp;
    %    stimuli(nn).param.next=gapdelay+max(rand_gapdurs)+soa+pulsedur;
    stimuli(nn).param.soa=soa;
    stimuli(nn).param.soaflag=soaflag;
    stimuli(nn).param.loop_flg=0;
    stimuli(nn).param.seamless=1;
    %    stimuli(nn).param.duration=gapdelay+rand_gapdurs(kk)+soa+pulsedur;
    stimuli(nn).param.duration=gpias_duration;
    stimuli(nn).param.next=next; %totally empirical value that allows psychportaudio rescheduling to work seamlessly
    stimuli(nn).param.gapdelay=gapdelay;
    stimuli(nn).param.gapdur=rand_gapdurs(kk);
    stimuli(nn).param.pulsedur=pulsedur;
    stimuli(nn).param.pulseamp=rand_pulseamps(kk);
    %
    this_isi_ms=round(isi+isi*isi_var*(2*rand(1)-1));
    num_noises=round(this_isi_ms/gpias_duration);
    for noisenum=1:num_noises
        nn=nn+1;
        stimuli(nn).type='noise';
        stimuli(nn).param.amplitude=noiseamp;
        stimuli(nn).param.filter_operation='bandpass';
        stimuli(nn).param.center_frequency=noisefreq;
        stimuli(nn).param.lower_frequency=noisefreq/2^(noisebandwidth/2);
        stimuli(nn).param.upper_frequency=noisefreq*2^(noisebandwidth/2);
        stimuli(nn).param.ramp=ramp;
        %     stimuli(nn).param.next=round(isi+isi*isi_var*(2*rand(1)-1));
        %     stimuli(nn).param.soa=soa;
        stimuli(nn).param.loop_flg=0;
        stimuli(nn).param.seamless=1;
        %stimuli(nn).param.duration=isi;
        %     stimuli(nn).param.duration=500;
        stimuli(nn).param.duration=gpias_duration; %trying to set to same dur as gpias
        stimuli(nn).param.next=next; %totally empirical value that allows psychportaudio rescheduling to work seamlessly
    end

end

if isfield(pref, 'stimuli')
    cd(pref.stimuli) %where stimulus protocols are saved
else
    cd('c:\lab\exper2.2\protocols')
end
cd('Gap In Noise Protocols')
save(filename, 'stimuli')

fprintf('\nwrote file %s \n in directory %s', filename, pwd)

%  keyboard