function MakeNB_ASRProtocol(prepulsedur, prepulseamps, prepulsefreq,prepulsebandwidth,...
    pulsedur, pulseamp, soa, ramp, isi, isi_var, nrepeats)

%modified from MakeASRProtocol to use a narrow band pre-pulse
% give the params for the prepulse using a center frequency and bandwidth
%
% usage MakeNB_ASRProtocol(prepulsedur, prepulseamps, prepulsefreq,prepulsebandwidth, ...
%  pulsedur, pulseamp, soa, ramp, isi, isi_var, nrepeats)
%
% creates an exper2 stimulus protocol file for ASR (acoustic startle
% response). Now using multiple prepulseamps and variable ISI.
% mw 070507
%
% inputs:
% prepulsedur: duration of the pre-pulse in ms
% prepulseamps: vector of pre-pulse amplitudes (in dB SPL), use 1 or more
%   pre-pulse amplitudes in a vector, e.g. 50, or [50 60], or [50 60 70]
% prepulsefreq: center frequency of the prepulse (narrowband noise), in Hz
% prepulsebandwidth: bandwidth of the prepulse (narrowband noise), in octaves
% pulsedur: duration of the startle pulse in ms
% pulseamp: amplitude of the startle pulse in dB SPL
% soa: Stimulus Onset Asynchrony in ms = time between masker onset and
%       probe tone onset
% ramp: on-off ramp duration in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% isi_var: fractional variability of isi. Use 0 for fixed isi, or e.g. 0.1 to have isi vary by up to +-10%
% nrepeats: number of repetitions (different pseudorandom orders)
%
% outputs:
% creates a suitably named stimulus protocol in D:\lab\exper2.2\protocols\ASR Protocols
%
%
%example calls:
%single prepulse amplitude, 1/3 octave bandwidth, fixed isi of 5 seconds:
%MakeNB_ASRProtocol(25, 75, 6000, 1/3, 25, 100, 100, 2, 5e3, 0, 5)
%
%three prepulse amplitudes, isi ranging from 30 s to 90s (60 s on average)
%MakeNB_ASRProtocol(25, [40 60 80], 12000, 1/3, 25, 80, 100, 2, 60e3, .5, 5)

global pref
if nargin~=11 error('\MakeNB_ASRProtocol: wrong number of arguments.'); end

numprepulseamps=length(prepulseamps);

prepulseampsstring='';
for i=1:numprepulseamps
    prepulseampsstring=[prepulseampsstring, sprintf('%d-', prepulseamps(i))];
end
prepulseampsstring=prepulseampsstring(1:end-1); %remove trailing -

bandwidthstring=strrep(sprintf('%.2f',prepulsebandwidth), '.','');

for nn=1:nrepeats
    neworder=randperm( numprepulseamps);
    rand_prepulseamps( prod(size(prepulseamps))*(nn-1) + (1:prod(size(prepulseamps))) ) = prepulseamps( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('NBASR-ppd%dms-ppa%sdb-%dppf-%sppbw-pd%dms-pa%ddb-soa%dms-r%d-isi%d-isivar%d-%dreps.mat',...
    prepulsedur, prepulseampsstring, prepulsefreq,bandwidthstring, pulsedur, pulseamp, soa, ramp, isi,round(100*isi_var), nrepeats);

stimuli(1).param.description=sprintf('Acoustic Startle Response stimulus protocol pre-pulse duration(s):%dms pre-pulse amplitude:%sdb pre-pulse center freq:%dHz pre-pulse bandwidth: %s oct, pulse duration%dms pulse amplitude:%ddb SOA:%dms ramp:%dms isi:%dms isi-var: %.1f %drepeats',...
    prepulsedur, prepulseampsstring, prepulsefreq,bandwidthstring, pulsedur, pulseamp, soa, ramp, isi, isi_var, nrepeats);
filename=stimuli(1).param.name;

nn=1;

for nn=1:length(rand_prepulseamps)
    stimuli(nn+1).type='NBASR';
    stimuli(nn+1).param.prepulsedur=prepulsedur;
    stimuli(nn+1).param.prepulseamp=rand_prepulseamps(nn);
    stimuli(nn+1).param.prepulsefreq=prepulsefreq;
    stimuli(nn+1).param.prepulsebandwidth=prepulsebandwidth;
    stimuli(nn+1).param.pulsedur=pulsedur;
    stimuli(nn+1).param.pulseamp=pulseamp;
    stimuli(nn+1).param.ramp=ramp;
    stimuli(nn+1).param.next=round(isi+isi*isi_var*(2*rand(1)-1));
    stimuli(nn+1).param.soa=soa;
    stimuli(nn+1).param.duration=prepulsedur+soa+pulsedur;

end



if isfield(pref, 'stimuli')
    cd(pref.stimuli) %where stimulus protocols are saved
else
    cd('c:\lab\exper2.2\protocols')
end
cd('ASR Protocols')
save(filename, 'stimuli')


%  keyboard