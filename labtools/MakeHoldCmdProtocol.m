function MakeHoldCmdProtocol(start, ramp, holdduration, potentials, nrepeats)

% usage: MakeHoldCmdProtocol(start, ramp, duration, potentials, nrepeats)
% inputs:
%   start   -  delay to the start of the ramp after the trigger (ms)
%   ramp   -   ramp duration (ms)
%   holdduration-    duration of the holding command after ramp (ms)
%   potentials - the set of holding potentials
%   nrepeats - the number of repetitions (different pseudorandom orders)
% outputs:
%   creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%example call:
% MakeHoldCmdProtocol(100, 2000, 4000, [-50 -70 -90], 10)
Prefs
global pref

neworder=randperm( length(potentials) );
cmdsequence=zeros(1,length(potentials)*nrepeats);
cd(pref.stimuli)
cd ('soundfiles')
[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into Voltage Clamp protocol (press cancel for pulses only):');
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
    tc=load(fullfile(tcpathname, tcfilename));
for nn=1:nrepeats
    neworder=randperm( length(potentials) );
    cmdsequence( prod(size(potentials))*(nn-1) + (1:prod(size(potentials))) ) = potentials( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('HoldCmd, ramp%dms/holdduration%dms/%s', ramp, holdduration, int2str(potentials));
stimuli(1).param.description=sprintf('HoldCmd, start: %dms, nrepeats: %d, ramp: %dms, holdduration: %dms, potentials: %s',start, nrepeats, ramp, holdduration, int2str(potentials));
filename=sprintf('holdcmd-%dms-%s', ramp, int2str(potentials));

for nn=2:length(cmdsequence+1)
    stimuli(nn).type='holdcmd';
    stimuli(nn).param.start=start;
    stimuli(nn).param.ramp=ramp;
    stimuli(nn).param.holdduration=holdduration;
    stimuli(nn).param.duration=holdduration+ramp+start;
    if nn==2 stimuli(nn).param.holdcmd_from=-70;
    else
        stimuli(nn).param.holdcmd_from=cmdsequence(nn-2);
    end
    stimuli(nn).param.holdcmd_to=cmdsequence(nn-1);
end
cd(pref.stimuli) %where stimulus protocols are saved
save(filename, 'stimuli')


