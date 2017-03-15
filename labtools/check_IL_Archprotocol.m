function check_IL_Archprotocol(protocol)
% function to look at an interleaved arch stimulus protocol, for development/troubleshooting
%     (might work for other protocols as well, I guess)
%plots AOPulse in blue and tones in red
%labels tones with amp, freq, and whether AOPulse is ON or OFF

%plotting is with ms resolution

global pref
Prefs
cd(pref.stimuli)
cd('Arch Protocols')
if nargin==0
    [protocol, tcpathname] = uigetfile('*.mat', 'Choose Arch protocol to check:');
    if isequal(protocol,0) || isequal(tcpathname,0)
        disp('User pressed cancel')
        return
    else
        disp(['User selected ', fullfile(tcpathname, protocol)])
    end
end

load(protocol)
fprintf('\ntotal number of stimuli: %d', length(stimuli)-1 )

name=(stimuli(1).param.name);
descr=(stimuli(1).param.description);
fprintf('\nstimulus name:\n%s', name)
fprintf('\nstimulus description:\n%s', descr)
fprintf('\n')

figure
set(gcf, 'pos', [72         525        1578         420])
hold on

chunksize=30000;
start=1;
t=1:chunksize;
tone=zeros(size(t));
pulse=tone;
for n=2:length(stimuli)
    
    type=stimuli(n).type;
    dur=stimuli(n).param.duration;
    next=stimuli(n).param.next;
    
    %note: next is the period from offset to onset
    
    if isfield(stimuli(n).param, 'AOPulseOn')
        AOPulseOn=stimuli(n).param.AOPulseOn;
    end
    
    switch type
        case 'aopulse'
            stop=start+dur;
            pulse(start:stop)=1;
            %            pulse=[pulse zeros(size(stop:next))];
            start=stop+next;   
        case 'aopulsetrain'
            stop=start+dur;
            npulses=stimuli(n).param.npulses;
            isi=stimuli(n).param.isi; %pulse isi
            pulsedur=stimuli(n).param.pulseduration; %
            for pn=1:npulses
            pulse(1+start+(pn-1)*isi:start+(pn-1)*isi+pulsedur)=1;
            end
            %            pulse=[pulse zeros(size(stop:next))];
            start=stop+next;
            
        case 'tone'
            amp=stimuli(n).param.amplitude;
            freq=stimuli(n).param.frequency;
            
            stop=start+dur;
            tone(start:stop)=1.1;
            text(start, 1.2, {amp, round(freq/1000), AOPulseOn})
            start=stop+next;
        case 'whitenoise'
            amp=stimuli(n).param.amplitude;
            
            stop=start+dur;
            tone(start:stop)=1.1;
            text(start, 1.2, {amp, 'WN', AOPulseOn})
            start=stop+next;
    end
    
    
    if max(length(pulse), length(tone))>length(t)
        t=1:max(length(pulse), length(tone))+chunksize;
        z=zeros(size(t));
        p=pulse;
        pulse=z;
        pulse(1:length(p))=p;
        tn=tone;
        tone=z;
        tone(1:length(tn))=tn;
    end
    
    if start>65e3
        fprintf('\n\n\n%s: stopped plotting after %d stimuli, \nedit %s if you want to see more', mfilename, n, mfilename)
        break
    end
    
    
end

plot(t, pulse, 'c', t, tone, 'r')
xlabel('time, ms')
drawnow














