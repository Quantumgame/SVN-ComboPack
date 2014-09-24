function MakeNSHoldCmdProtocol(start, ramp, potentials, initial_potential)
% Makes a Voltage Clamp command protocol and incorporate a previously
% created "natural sound" protocol.
% "natural sounds" are a class of stimuli that load a soundfile from disk
% rather than generating a synthetic stimulus on the fly. They could be
% pretty much anything from recordings of speech or animal vocalizations
% or environmental sounds to synthesized speech noise stimuli.
% Actually you could use any kind of sound protocol with this function, the
% real difference from MakeTCHoldCmdProtocol is that here we do no
% repeats or randomization (see note below)
%
% usage: MakeNSHoldCmdProtocol(start, ramp, potentials, initial_potential)
% inputs:
%  start    - delay to the start of the ramp after the trigger (ms)
%  ramp     - ramp duration (ms)
%  potentials: the hold command potentials
%  initial_potential - where you want to start the first ramp FROM   (usually -70)
%
%  a dialog box opens the stimulus you want to incorporate
% outputs:
%   creates a suitably named stimulus protocol in exper2.2\protocols\Voltage Clamp protocols
%
%example call:
% MakeNSHoldCmdProtocol(100, 1000, [-90 20], -70)
%
%note: we don't specify repeats in this protocol. If you want repeats, just
%turn on repeat in StimulusProtocol. Or you could create a source stimulus
%that has repeats built into it.
%note: we don't randomize stimuli or holding potentials. For example, for 2 holding potentials, We go to the first
%potential, play the first stimulus, go to the second potential, play the same
%stimulus again, go to the first potential, play the second stimulus, go
%the the second potential, play the second stimulus again, etc.

if nargin==0 fprintf('\nno input');return;end
global pref
Prefs
cd(pref.stimuli)
cd ('Tuning Curve protocols')
[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose sound protocol to incorporate into Voltage Clamp protocol:');
if isequal(tcfilename,0) || isequal(tcpathname,0)
    disp('User pressed cancel')
    return
else
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
end
tc=load(fullfile(tcpathname, tcfilename));
numtones=length(tc.stimuli)-1;
cmdsequence=repmat(potentials, 1, numtones);

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('TCHoldCmd, ramp%dms/%s/%s', ramp, int2str(potentials), tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('HoldCmd, start: %dms, ramp: %dms, potentials: %s, init_potential: %d, %s',start, ramp, int2str(potentials), initial_potential,tc.stimuli(1).param.description);
filename=sprintf('TCholdcmd-%dms-hd-%s-%s', ramp, int2str(potentials),tcfilename);

n=1;
tone_idx=1;
cmd_idx=0;
for i=1:numtones
    for j=1:length(potentials)
        n=n+1;
        stimuli(n).type='holdcmd';
        stimuli(n).param.start=start;
        stimuli(n).param.ramp=ramp;
        stimuli(n).param.holdduration=2000; %this acts as a equilibration pause before presenting tones. actual hold duration is controlled by elapsed_tc comparison
        stimuli(n).param.duration=2000+ramp+start;
        cmd_idx=cmd_idx+1;
        if n==2 stimuli(n).param.holdcmd_from=initial_potential;
        else
            stimuli(n).param.holdcmd_from=cmdsequence(cmd_idx-1);
        end
        stimuli(n).param.holdcmd_to=cmdsequence(cmd_idx);
        %hard coding params for series pulses.
        stimuli(n).param.pulse_start= 10;
        stimuli(n).param.pulse_width= 50;
        stimuli(n).param.pulse_height= -10;
        stimuli(n).param.npulses= 10;
        stimuli(n).param.pulse_isi= 50;
        stimuli(n).param.pulseduration= 970;
        n=n+1;
        tone_idx=i+1;
        tone=tc.stimuli(tone_idx);
        
        if isfield(tone, 'description')
            tone=rmfield(tone, 'description');
        end
        stimuli(n)=tone;
        
    end
end

n=n+1;
% These 3 lines added by mak 5jan2011 to ensure that the VCstimuli protocol
% ends at the most negative value to avoid needlessly stressing the cell.
lowest_potential=sort(potentials); % in case the user doesn't put the lowest holdcmd first in the list
stimuli(n).param.holdcmd_to=lowest_potential(1);

stimuli(n).type='holdcmd';
stimuli(n).param.start=start;
stimuli(n).param.ramp=ramp;
stimuli(n).param.holdduration=2000; %this acts as a equilibration pause before presenting tones. actual hold duration is controlled by elapsed_tc comparison
stimuli(n).param.duration=2000+ramp+start;
stimuli(n).param.holdcmd_from=cmdsequence(end);

stimuli(n).param.holdcmd_to=initial_potential;

%hard coding params for series pulses.
% stimuli(n).param.pulse_start= 10;
% stimuli(n).param.pulse_width= 50;
% stimuli(n).param.pulse_height= -10;
% stimuli(n).param.npulses= 10;
% stimuli(n).param.pulse_isi= 50;
% stimuli(n).param.pulseduration= 970;

cd(pref.stimuli) %where stimulus protocols are saved
cd('Voltage Clamp protocols')
save(filename, 'stimuli')
fprintf('\nwrote file %s in directory %s\n', filename, pwd)



