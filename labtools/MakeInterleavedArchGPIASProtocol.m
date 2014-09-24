function MakeInterleavedArchGPIASProtocol(pre, width, isi)
% usage: MakeInterleavedArchGPIASProtocol(pre, width, isi)
%Create Arch Protocol and incorporate a previously
% created GPIAS protocol
%note: same as MakeInterleavedArchProtocol but ignores the continuous
%background noise stimuli in a GPIAS protocol
%
%note: numtones is fixed at 1 (was a variable in MakeInterleavedArchProtocol)
%if you request impossible parameters, you will get warnings but the
%protocol file will still be written; how exper will handle such a protocol
%is unclear. Pay attention to the warnings. If there are no warnings a
%"stimulus OK" message will be printed.
%
% inputs:
%   pre  -  delay from the start of the flash to first sound onset (ms)
%   width    -  duration of flash (ms)
%   isi    -  delay between end of flash and onset of next flash (ms)
%   note: actual "pre" will be ~100 ms longer than requested due to
%       soundcard latency, so adjust and test "pre" to get your desired value
%       ("pre" can be 0 but not negative)
%   % outputs:
%   creates a suitably named stimulus protocol in
%   exper2.2\protocols\Arch Protocols
%
% Calls check_IL_Archprotocol at the end to visually inspect the sequence stimuli
%
%example call:
% MakeInterleavedArchProtocol(250, 700, 1500)
% MakeInterleavedArchProtocol(500, 20000, 5000)
% MakeInterleavedArchGPIASProtocol(250, 700, 1500)
%

% Same as MakeArchProtocol, but interleaves AOPulse-embedded stimuli with
% non-embedded stimuli. Each numtones stimuli in the stimulus protocol are played
% twice in succession, one group embedded and one not.
%
% This function creates a protocol designed for the Arch mice. A dialog
% box will allow you to select a stimulus protocol such as a tuning curve. Each sound
% stimulus from that protocol is then embedded in an AO pulse that will deliver an LED flash.
% (each stimulus is then repeated without the AO pulse)
% MakeInterleavedArchProtocol(pre, width, isi)

% %removed aopulse stimuli; they are obsolete since we now only use PPALaser to drive the laser
% %mw 061114

if nargin==0 fprintf('\nno input');return;end
global pref
Prefs
cd(pref.stimuli)
cd ('ASR Protocols')

[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into Arch protocol:');
if isequal(tcfilename,0) || isequal(tcpathname,0)
    disp('User pressed cancel')
    return
else
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
end
tc=load(fullfile(tcpathname, tcfilename));

stimOK=1;


channel=1;
for c=1:length(pref.ao_channels)
    if strcmp(pref.ao_channels(c).name, 'ledchannel')
        channel=c;
    end
end
tc_n=1; %TC tone index
st_n=1; %output stimuli index
while tc_n+1<=length(tc.stimuli)
 %   st_n=st_n+1;
% %     stimuli(st_n).type='aopulse';
% %     stimuli(st_n).param.start=0;
% %     %     tone_dur=tc.stimuli(tc_n).param.duration;
% %     stimuli(st_n).param.width=width;
% %     stimuli(st_n).param.height=5; % in V???
% %     stimuli(st_n).param.isi=0; %ignore; refers to pulse train isi
% %     stimuli(st_n).param.channel=channel;
% %     stimuli(st_n).param.npulses=1;
% %     stimuli(st_n).param.duration=width; %200 is a hack! mw 11-19-10
% %     %    stimuli(nn+jj).param.duration=stimuli(nn+jj).param.width+200; %200 is a hack! mw 11-19-10
% %     stimuli(st_n).param.next=pre-width;
% %removed aopulse stimuli; they are obsolete since we now only use PPALaser to drive the laser
% %mw 061114
    %     if numtones==-1
    %         %figure out how many tones will fit
    %         %here we assume that the first n tone durations and isis are
    %         %representative of the entire tuning curve
    %         edur=pre;
    %         nt=0;
    %         next=0;dur=0;
    %         while edur<width-next-dur
    %             nt=nt+1;
    %             if nt>=length(tc.stimuli)-1
    %                 numtones=nt;
    %                 break
    %             end
    %             tone=tc.stimuli(nt+1);
    %             edur=edur+tone.param.duration+tone.param.next;
    %             next=tone.param.next;
    %             dur=tone.param.duration;
    %         end
    %         numtones=nt;
    %         fprintf('\nusing %d tones in each pulse', numtones)
    %
    %     end
    
    %         while ~strcmp(tone.type, 'GPIAS')
    
    
    %insert embedded tones
    start_tc_n=tc_n; %store starting tc_n to do pulse-off repeat of tones
    edur=0;
    tc_n=tc_n+1;
    st_n=st_n+1;
    tone=tc.stimuli(tc_n);
    while ~strcmp(tone.type, 'GPIAS') %cycle through BG noise stimuli with laser off
        
        stimuli(st_n)=tone;
        stimuli(st_n).param.AOPulseOn=0;    
        edur=edur+tone.param.duration+tone.param.next;
        tc_n=tc_n+1;
        st_n=st_n+1;
        if tc_n>length(tc.stimuli)
            break
        end
        tone=tc.stimuli(tc_n);
    end
    %then add the GPIAS with laser on
    stimuli(st_n)=tone;
    
    stimuli(st_n).param.AOPulseOn=1;
    %     edur=edur+tone.param.duration+tone.param.next;
    
    
    % wait isi after the pulse before starting tones again
    %     time2endofpulse=width-edur-pre+tone.param.next;
    %     if time2endofpulse<tone.param.next
    % %         warning(sprintf('AOpulse is not long enough for %d tones, only %d ms left in pulse after %d tones', numtones, time2endofpulse, numtones))
    %         stimOK=0;
    %     end
    %     stimuli(st_n).param.next=time2endofpulse+isi;
    %
    %insert non-embedded tones
    tc_n=start_tc_n; %reset tone index
    
    tc_n=tc_n+1;
    st_n=st_n+1;
    tone=tc.stimuli(tc_n);
    while ~strcmp(tone.type, 'GPIAS') %cycle through BG noise stimuli with laser off
        
        stimuli(st_n)=tone;
        stimuli(st_n).param.AOPulseOn=0;
        %         edur=edur+tone.param.duration+tone.param.next;
        tc_n=tc_n+1;
        st_n=st_n+1;
        if tc_n>length(tc.stimuli)
            break
        end
        tone=tc.stimuli(tc_n);
    end
    %then add the GPIAS with laser still off
    
    stimuli(st_n)=tone;
    stimuli(st_n).param.AOPulseOn=0; %this is what Aldis changed, from "0"
        %use 1 to deliver pulse on every trial, i.e. for driving a shock for fear conditioning
    %use 0 if you want interleaved pulses, like driving a laser for optogenetics
    %you should leave this set to 0, and instead use
    %MakeGaqpShockProtocol if you want a fear conditioning protocol

    
    
    %    %insert non-embedded tone
    %     jj=jj+1;
    %     tone=tc.stimuli(jj+1);
    %    tone.param.next=isi;
    %    stimuli(nn+jj)=tone;
    %    stimuli(nn+jj).param.AOPulseOn=0;
    
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('Arch, interleaved, pre%dms/width%dms/isi%dms/%s', pre, width, isi, tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('Arch, interleaved, pre: %dms, width: %d, isi: %dms, pulse, %s',pre, width, isi, tc.stimuli(1).param.description);
filename=sprintf('Arch-IL-%d-%d-%d-%s', pre, width, isi, tcfilename);


cd(pref.stimuli) %where stimulus protocols are saved
cd('Arch Protocols')
save(filename, 'stimuli')
fprintf('\nwrote file %s \nin directory %s', filename, pwd)
fprintf('\n')
if stimOK
    fprintf('\nstimulus protocol is OK')
else
    %     fprintf('\nerror in stimulus parameters, see above warnings!')
end
if ~(strcmp(pref.username,'apw') || strcmp(pref.username,'mak'))
    check_IL_Archprotocol(filename)
end
fprintf('\n')




