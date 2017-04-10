function MakeASRProtocol(prepulsedurs, prepulseamps, pulsedur, pulseamp, soa, soaflag, ...
     ramp, isi, isi_var, nrepeats)
% usage MakeASRProtocol(prepulsedurs, prepulseamps, pulsedur, pulseamp, soa, ...
%      ramp, isi, isi_var, nrepeats)
%
% creates an exper2 stimulus protocol file for ASR (acoustic startle
% response). Now using multiple prepulseamps and variable ISI.
% mw 070507
%
%recent edits: 
%  -added soaflag to specify whether soa is 'soa' or 'isi'

% inputs:
% prepulsedur: duration of the pre-pulse in ms
% prepulseamps: vector of pre-pulse amplitudes (in dB SPL), use 1 or more
% pre-pulse amplitudes in a vector, e.g. 50, or [50 60], or [50 60 70]
% pulsedur: duration of the startle pulse in ms
% pulseamp: amplitude of the startle pulse in dB SPL
% soa: Stimulus Onset Asynchrony in ms = time between masker onset and
%       probe tone onset
% soaflag: can be either 'soa' (default), in which case soa value specifies the time
% between the onset of the prepulse and the onset of the startle, or else 'isi',
% in which case soa specifies the time between offset of the prepulse and startle
% onset. If anything other than 'isi' it will default to 'soa'.
% ramp: on-off ramp duration in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% isi_var: fractional variability of isi. Use 0 for fixed isi, or e.g. 0.1 to have isi vary by up to +-10%  
% nrepeats: number of repetitions (different pseudorandom orders)
%
% outputs:
% creates a suitably named stimulus protocol in D:\lab\exper2.2\protocols\ASR Protocols
%
%example calls: 
%single prepulse amplitude, fixed isi of 10 seconds:
%MakeASRProtocol(25, 50, 25, 80, 100, 2, 10e3, 0, 5)
%
%three prepulse amplitudes, isi ranging from 30 s to 90s (60 s on average)
%MakeASRProtocol(25, [40 60 80], 25, 80, 100, 2, 60e3, .5, 5)
%
%For combined Acoustic Startle and Pre-pulse inhibition
%9 ppa, isi ranging from 10-20s (15 on average)
%MakeASRProtocol(25, [-1000 0 10 20 30 40 50 60 70], 25, 80, 100, 2, 15e3, .33, 20)
%
%MakeASRProtocol(25, [-1000 80], 10, 100, 60, 2, 15e3, .33, 10); ideally we
%could have vector input for prepulse duration. This would also require
%addition of ISI versus SOA.
%
%      prepulsedurs=[0 1 2 4 8 16 32 64 128]; prepulseamps=40; pulsedur=25; pulseamp=100; soa=50; soaflag='isi';
%      ramp=0; iti=1000; iti_var=.33; nrepeats=10;
%      MakeASRProtocol(prepulsedurs, prepulseamps, pulsedur, pulseamp, soa, soaflag, ramp, iti, iti_var, nrepeats)

global pref

if nargin~=10 error('\MakeASRProtocol: wrong number of arguments.'); end

if ~strcmp(soaflag, 'isi')
    soaflag='soa';
    fprintf('\nusing soa of %d ms', soa)
else
    fprintf('\nusing isi of %d ms', soa)
end

if strcmp(soaflag, 'soa')
    if any(prepulsedurs>soa)
        fprintf('\n\n!!!!!!!\n\n')
        warning('at least one prepulse duration exceeds the soa, so that prepulse duration will be invalid (will be interrupted by startle during the prepulse)')
    end
end


numprepulseamps=length(prepulseamps);
numprepulsedurs=length(prepulsedurs);

prepulsedursstring='';
for i=1:numprepulsedurs
    prepulsedursstring=[prepulsedursstring, sprintf('%g-', prepulsedurs(i))];
end
prepulsedursstring=prepulsedursstring(1:end-1); %remove trailing -

prepulseampsstring='';
for i=1:numprepulseamps
    prepulseampsstring=[prepulseampsstring, sprintf('%d-', prepulseamps(i))];
end
prepulseampsstring=prepulseampsstring(1:end-1); %remove trailing -

% for nn=1:nrepeats
%     neworder=randperm( numprepulseamps);
%     rand_prepulseamps( prod(size(prepulseamps))*(nn-1) + (1:prod(size(prepulseamps))) ) = prepulseamps( neworder );
% end

[PrepulsedurGrid,PrepulseampGrid]=meshgrid( prepulsedurs , prepulseamps);
neworder=randperm( numprepulseamps * numprepulsedurs);
rand_prepulsedurs=zeros(size(neworder*nrepeats));
rand_prepulseamps=zeros(size(neworder*nrepeats));

for nn=1:nrepeats
neworder=randperm( numprepulseamps * numprepulsedurs);
    rand_prepulsedurs( prod(size(PrepulsedurGrid))*(nn-1) + (1:prod(size(PrepulsedurGrid))) ) = PrepulsedurGrid( neworder );
    rand_prepulseamps( prod(size(PrepulseampGrid))*(nn-1) + (1:prod(size(PrepulseampGrid))) ) = PrepulseampGrid( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('ASR-ppd%sms-ppa%sdb-pd%dms-pa%ddb-soa%dms(%s)-r%d-isi%-isivar%d-%dreps.mat',...
    prepulsedursstring, prepulseampsstring, pulsedur, pulseamp, soa, soaflag, round(ramp), isi,round(100*isi_var), nrepeats);

stimuli(1).param.description=sprintf('Acoustic Startle Response stimulus protocol pre-pulse duration(s):%sms pre-pulse amplitude:%sdb pulse duration%dms pulse amplitude:%ddb SOA:%dms (%s) ramp:%dms isi:%dms isi-var: %.1f %drepeats',...
    prepulsedursstring, prepulseampsstring, pulsedur, pulseamp, soa, soaflag, round(ramp), isi, isi_var, nrepeats);
filename=stimuli(1).param.name;


for nn=1:length(rand_prepulseamps)
    stimuli(nn+1).type='ASR';
    stimuli(nn+1).param.prepulsedur=rand_prepulsedurs(nn);
    stimuli(nn+1).param.prepulseamp=rand_prepulseamps(nn);
    stimuli(nn+1).param.pulsedur=pulsedur;
    stimuli(nn+1).param.pulseamp=pulseamp;
    stimuli(nn+1).param.ramp=ramp;
    stimuli(nn+1).param.next=round(isi+isi*isi_var*(2*rand(1)-1));
    stimuli(nn+1).param.soa=soa;
    stimuli(nn+1).param.soaflag=soaflag;
    stimuli(nn+1).param.duration=rand_prepulsedurs(nn)+soa+pulsedur;
    
end


try
if isfield(pref, 'stimuli')
cd(pref.stimuli) %where stimulus protocols are saved
else
    cd('c:\lab\exper2.2\protocols')
end
warning off MATLAB:MKDIR:DirectoryExists
mkdir('ASR Protocols')
cd('ASR Protocols')
save(filename, 'stimuli')
fprintf('\n wrote %s \nin %s',filename, pwd) 
catch
    fprintf('\nfailed to write file')
end
%  keyboard