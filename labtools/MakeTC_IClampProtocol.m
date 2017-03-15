function MakeTC_IClampProtocol(isi, pulse_height, pulse_width, npulses)

% specify a Current Clamp (not I=0!) command protocol and incorporate a previously
% created tuning curve protocol
% creates only pulses, not DC holding commands
% usage: MakeTC_IClampProtocol(isi, pulse_height, pulse_width, npulses)
% inputs:
%   isi   -  delay to the start of the pulse after the trigger (ms), and
%       in between pulse and tones
%   pulse_height: describes current pulse, pA
%   pulse_width: describes current pulse, ms
%   npulses: num pulses for each repeat
%   dialog box opens the tuning curve you want to incorporate; press cancel
%       for no tones (pulses only)
% outputs:
%   creates a suitably named stimulus protocol in exper2.2\protocols
%
%example call:
% MakeTC_IClampProtocol(500, -10, 100, 10)
% 
% 
% note: this stimulus would actually work fine in either voltage clamp or
% current clamp, the only difference is the units used in the description
% and filename

global pref
Prefs
cd(pref.stimuli)
cd ('Tuning Curve protocols')
[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into Voltage Clamp protocol (press cancel for pulses only):');
if isequal(tcfilename,0) || isequal(tcpathname,0)
    disp('User pressed cancel: no tones inserted')
    tc.stimuli(1).param.name='no_tones';
    tc.stimuli(1).param.description='no_tones'
    tcfilename='';
    tonesperrepeat=0;
else
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
    tc=load(fullfile(tcpathname, tcfilename));

    %get repeatlength by tabulating freqs/amps
    j=0;allisis=[];
    for i=2:length(tc.stimuli)
        if strcmp(tc.stimuli(i).type, '2tone') | strcmp(tc.stimuli(i).type, 'tone')
            j=j+1;
            allfreqs(j)=tc.stimuli(i).param.frequency;
            allamps(j)=tc.stimuli(i).param.amplitude;
            alldurs(j)=tc.stimuli(i).param.duration;
            if isfield(tc.stimuli(i).param, 'next')
            end
        elseif strcmp(tc.stimuli(i).type, 'whitenoise') | strcmp(tc.stimuli(i).type, 'clicktrain')
            j=j+1;
            allfreqs(j)=-1;
            allamps(j)=tc.stimuli(i).param.amplitude;
            alldurs(j)=tc.stimuli(i).param.duration;
            allisis(j)=tc.stimuli(i).param.next;
        end
    end
    freqs=unique(allfreqs);
    amps=unique(allamps);
    durs=unique(alldurs);
    tone_isi=unique(allisis);
    numfreqs=length(freqs);
    numamps=length(amps);
    numdurs=length(durs);

    tonesperrepeat=numfreqs*numamps;
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('TC_IClamp, isi:%d/ph:%d/pw:%d/np:%d/%s', isi, pulse_height, pulse_width,npulses, tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('TC_IClamp, isi: %dms, pulse_height: %dpA, pulse_width: %d ms, %s',isi,pulse_height, pulse_width,tc.stimuli(1).param.description);
filename=sprintf('TC_IClamp-%dms-%dpA-%dms-%s', isi, pulse_height, pulse_width, tcfilename);

pulses_duration=(npulses+1)*(pulse_width+isi);
stimuli(2).type='pulse';
stimuli(2).param.start=isi;
stimuli(2).param.duration=pulses_duration;
stimuli(2).param.width= pulse_width;
stimuli(2).param.height= pulse_height;
stimuli(2).param.npulses= npulses;
stimuli(2).param.isi= isi;


%insert tones
jj=2;
for n=1:tonesperrepeat
    jj=jj+1;
%     if (jj)>length(tc.stimuli)
%         error('\nran out of tones after %d potentials (%d reps)', nn, floor(nn/length(potentials)))
%     else
        tone=tc.stimuli(n+1);
        stimuli(jj)=tone;
%    end
end

cd(pref.stimuli) %where stimulus protocols are saved
cd('IClamp protocols')
save(filename, 'stimuli')



