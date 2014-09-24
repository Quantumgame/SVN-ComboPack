function MakeArchProtocol(pre, width, isi)

%% RETIRED.

% usage: MakeArchProtocol(pre, width, isi)
%Create Arch Protocol and incorporate a previously
% created tuning curve protocol
%
% This function creates a protocol designed for the Arch mice. A dialog 
% box will allow you to select a stimulus protocol such as a tuning curve. Each sound
% stimulus from that protocol is then embedded in an AO pulse that will deliver an LED flash. 
% MakeArchProtocol(pre, width, isi)
% inputs:
%   pre  -  delay from the start of the flash to sound onset (ms)
%   width    -  duration of flash (ms)
%   isi    -  delay between end of flash and onset of next flash (ms)
%   note: isi from the tuning curve (or other stimulus protocol) is ignored
%   note: actual "pre" will be ~100 ms longer than requested due to
%       soundcard latency, so adjust and test "pre" to get your desired value 
%       ("pre" can be 0 but not negative)
%   % outputs:
%   creates a suitably named stimulus protocol in
%   D:\wehr\exper2.2\protocols\Arch Protocols
%
%example call:
% MakeArchProtocol(50, 300, 5000)

fprintf('\nThis function is no longer in use! Use MakeArchLaserProtocol().\n\n')
return

if nargin==0 fprintf('\nno input');return;end
global pref
Prefs
cd(pref.stimuli)
cd ('Tuning Curve protocols')
[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into Arch protocol:');
if isequal(tcfilename,0) || isequal(tcpathname,0)
    disp('User pressed cancel')
    return
else
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
end
tc=load(fullfile(tcpathname, tcfilename));

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('Arch, pre%dms/width%dms/isi%dms/%s', pre, width, isi, tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('Arch, pre: %dms, width: %d, isi: %dms, %s',pre, width, isi,tc.stimuli(1).param.description);
filename=sprintf('Arch-%d-%d-%d-%s', pre, width, isi,tcfilename);

channel=1;
for c=1:length(pref.ao_channels)
    if strcmp(pref.ao_channels(c).name, 'ledchannel')
        channel=c;
    end
end
jj=0;
for nn=2:length(tc.stimuli)
    stimuli(nn+jj).type='aopulse';
    stimuli(nn+jj).param.start=0;
    tone_dur=tc.stimuli(jj+2).param.duration;
    stimuli(nn+jj).param.width=width;
    stimuli(nn+jj).param.height=5; % in V???
    stimuli(nn+jj).param.isi=0; %ignore; refers to pulse train isi
    stimuli(nn+jj).param.channel=channel;
    stimuli(nn+jj).param.npulses=1;
    stimuli(nn+jj).param.duration=width; %200 is a hack! mw 11-19-10
%    stimuli(nn+jj).param.duration=stimuli(nn+jj).param.width+200; %200 is a hack! mw 11-19-10
    stimuli(nn+jj).param.next=pre-width;
    
    
    %insert tones
    jj=jj+1;
    tone=tc.stimuli(jj+1);
    tone.param.next=pre+isi;
    stimuli(nn+jj)=tone;
end



cd(pref.stimuli) %where stimulus protocols are saved
cd('Arch Protocols')
save(filename, 'stimuli')
fprintf('\nwrote file %s in directory %s', filename, pwd)







