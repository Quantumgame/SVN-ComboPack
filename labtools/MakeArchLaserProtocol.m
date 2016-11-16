function MakeArchLaserProtocol(pre, width, isi, numtones)
% usage: MakeArchLaserProtocol(pre, width, isi, numtones)
% Create Arch Protocol and incorporate a previously
% created tuning curve protocol.
% --------------------------------------------------------
% UPDATE: I've changed the way that this functions to no longer be
% interleaved when numtones==1 (i.e. for a CF RLF). In this situation the
% stimulus following the laser-embeded is different. I've done this to
% avoid order effects that may inadvertently lower the FR following the
% laser and may actually have nothing to do with the laser increasing the
% FR. For numtones>1, this function behaves exactly like
% MakeInterleavedArchProtocol. mak 28Jan2013 (see lines 82, 145, 157-163)
% --------------------------------------------------------
%
% If you request impossible parameters, you will get warnings but the
% protocol file will still be written; how exper will handle such a protocol
% is unclear. Pay attention to the warnings. If there are no warnings a
% "stimulus OK" message will be printed.
%
% inputs:
%   pre  -  delay from the start of the flash to first sound onset (ms)
%   width    -  duration of flash (ms)
%   isi    -  delay between end of flash and onset of next flash (ms)
%   	NOTE: this does not work especially for tones that are really long.
%   	For example, when using 400ms tones from a tuning curve with 500 ms
%   	isi, the onset of the long tones are about 900 ms apart. But when
%   	using the laser with 500 ms isi, non-laser:Laser isis are ~1100, but
%   	laser to non-laser isi ~650. So I will attempt to correct this.
%   	Ideally the laser will come on when we say and the stimuli will be
%   	spaced according to isi, meaning isi+dur. Thus a 100 ms tone with
%   	500 isi means tones will be at least 600 ms apart (they are always
%   	more for some reason...) mak 29Jan2013
%           **I think changing line 152 should have done the trick.
%   numtones - number of tones from the tuning curve to embed within each
%       pulse/non-pulse epoch. The inter-tone interval within each epoch is
%       set by the isi from the tuning curve. Use -1 to put in as many
%       tones as will fit within the width of flash (leaving enough room
%       for at least one inter-tone interval before end of flash)
%   Notes --
%   For AOsound users: actual "pre" will be ~100 ms longer than requested due to
%       soundcard latency, so adjust and test "pre" to get your desired value
%       ("pre" can be 0 but not negative)
%   For PPAlaser users: ppalaser (module) will override these parameters.
%   Use this to create an ArchLaser protocol with your pulse pre/dur/isi of choice, 
%   but make sure to enable ppalaser using those params *and* record a copy of the laser trigger
%   on the DAQ board!
%
%   % outputs:
%   creates a suitably named stimulus protocol in
%   exper2.2\protocols\Arch Protocols
%
% Calls check_IL_Archprotocol at the end to visually inspect the sequence stimuli
%
% example call:
 
% MakeArchLaserProtocol(25, 100, 500, 1)

% MakeArchLaserProtocol(25, 100, 500, 1)
% MakeArchLaserProtocol(500, 20000, 5000, 38) %if TCisi=500, 38*500=19000
%
% Same as MakeArchProtocol (retired), but interleaves AOPulse-embedded stimuli with
% non-embedded stimuli. Each numtones stimuli in the stimulus protocol are played
% twice in succession, one group embedded and one not.
%
% This function creates a protocol designed for the Arch mice. A dialog
% box will allow you to select a stimulus protocol such as a tuning curve. Each sound
% stimulus from that protocol is then embedded in an AO pulse that will deliver an LED flash.
% (each stimulus is then repeated without the AO pulse)
% MakeArchLaserProtocol(pre, width, isi)
 

fprintf('\nThis function is no longer in use! Use MakePpaLaserProtocol().\n')
% return

numtones=1;

dbstop if error
if nargin==0; fprintf('\nno input');return;end
global pref
Prefs
cd(pref.stimuli)
if strcmp(pref.username,'mak')
%     cd ('Bin Tuning Curve protocols')
% else
    cd ('Tuning Curve protocols')
end
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
pulse_n=0; %ao pulse number index
tc_n=1; %TC tone index
st_n=1; %output stimuli index
rev_tc_n=length(tc.stimuli)+1; %to get rid of order effects with numtones==1, since in this 
% the laser and non-laser trials are back-to-back. 
while tc_n+numtones<=length(tc.stimuli)
    pulse_n=pulse_n+1;
    st_n=st_n+1;
    stimuli(st_n).type='aopulse';
    stimuli(st_n).param.start=0;
    %     tone_dur=tc.stimuli(tc_n).param.duration;
    stimuli(st_n).param.width=width;
    stimuli(st_n).param.height=5; % in V???
    stimuli(st_n).param.isi=0; %ignore; refers to pulse train isi
    stimuli(st_n).param.channel=channel;
    stimuli(st_n).param.npulses=1;
    stimuli(st_n).param.duration=width; %200 is a hack! mw 11-19-10
    %    stimuli(nn+jj).param.duration=stimuli(nn+jj).param.width+200; %200 is a hack! mw 11-19-10
    stimuli(st_n).param.next=pre-width;
    
    if numtones==-1
        %figure out how many tones will fit
        %here we assume that the first n tone durations and isis are
        %representative of the entire tuning curve
        edur=pre;
        nt=0;
        next=0;dur=0;
        while edur<width-next-dur
            nt=nt+1;
            if nt>=length(tc.stimuli)-1
                numtones=nt;
                break
            end
            tone=tc.stimuli(nt+1);
            edur=edur+tone.param.duration+tone.param.next;
            next=tone.param.next;
            dur=tone.param.duration;
        end
        numtones=nt;
        fprintf('\nusing %d tones in each pulse', numtones)
        
    end
    
    %insert embedded tones
    start_tc_n=tc_n; %store starting tc_n to do pulse-off repeat of tones
    edur=0;
    for ntone=1:numtones
        tc_n=tc_n+1;
        st_n=st_n+1;
        tone=tc.stimuli(tc_n);
        stimuli(st_n)=tone;
        stimuli(st_n).param.AOPulseOn=1;
        edur=edur+tone.param.duration+tone.param.next;
        %    tone.param.next=tc.stimuli(nn).next
        %tone.param.next=width-pre+isi;
    end
    
    % wait isi after the pulse before starting tones again
    time2endofpulse=width-edur-pre+tone.param.next;
    if time2endofpulse<tone.param.next 
%         warning(sprintf('AOpulse is not long enough for %d tones, only %d ms left in pulse after %d tones', numtones, time2endofpulse, numtones))
        stimOK=0;
    end
%     stimuli(st_n).param.next=time2endofpulse+isi;
    stimuli(st_n).param.next=isi; %mak 29Jan2013
    
    %insert non-embedded tones
    if numtones~=1 % this added in to deal with order effects when the laser and non-laser 
        % trials are played back-to-back. To randomize the order, I'm simply reversing the
        % order of the tones. mak 28Jan2013
        % When numtones ~= 1 this is not as big of a deal and so I won't mess with it
        tc_n=start_tc_n; %reset tone index
        for ntone=1:numtones
            tc_n=tc_n+1;
            st_n=st_n+1;
            tone=tc.stimuli(tc_n);
            stimuli(st_n)=tone;
            stimuli(st_n).param.AOPulseOn=0;
        end
    else % this code will reverse the order
        rev_tc_n=rev_tc_n-1;
        st_n=st_n+1;
        tone=tc.stimuli(rev_tc_n);
        stimuli(st_n)=tone;
        stimuli(st_n).param.AOPulseOn=0;
    end
    
    
    %    %insert non-embedded tone
    %     jj=jj+1;
    %     tone=tc.stimuli(jj+1);
    %    tone.param.next=isi;
    %    stimuli(nn+jj)=tone;
    %    stimuli(nn+jj).param.AOPulseOn=0;
    
end

%put into stimuli structure
if numtones==1
    fn='Laser';
    fn2='laser';
else
    fn='IL';
    fn2='interleaved';
end
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('Arch, %s, pre%dms/width%dms/isi%dms/%dtones/%s', fn2, pre, width, isi, numtones, tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('Arch, %s, pre: %dms, width: %d, isi: %dms, %d tones/pulse, %s', fn2, pre, width, isi, numtones, tc.stimuli(1).param.description);
filename=sprintf('Arch-%s-%d-%d-%d-%d-%s',fn, pre, width, isi, numtones, tcfilename);


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




