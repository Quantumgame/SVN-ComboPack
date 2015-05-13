function MakePseudoGapShockProtocol(pre, width, isi)
% usage: MakePseudoGapShockProtocol(pre, width, isi)
%Create Pseduo Gap Shock Protocol and incorporate a previously
% created GPIAS protocol
%
%This protocol is for pseudo conditioning, AKA explicitly unpaired
%presentations of gaps and shocks. When used with MakeGPIASProtocol and PPALaser, a 0ms
%gap results in delivery of the shock (output from AI3). No shock is
%delivered for any non-0ms gaps. 

%note we removed the duplication of "embedded trials" so we get half the
%number of trials we did before today
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
% MakePseudoGapShockProtocol(250, 700, 1500)
% MakePseudoGapShockProtocol(500, 20000, 5000)
% MakePseudoGapShockProtocol(250, 700, 1500)
%

% Same as MakeArchProtocol, but interleaves AOPulse-embedded stimuli with
% non-embedded stimuli. Each numtones stimuli in the stimulus protocol are played
% twice in succession, one group embedded and one not.
%


if nargin==0 fprintf('\nno input');return;end
global pref
Prefs
cd(pref.stimuli)
cd ('Gap In Noise Protocols')

[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into Arch protocol:');
if isequal(tcfilename,0) || isequal(tcpathname,0)
    disp('User pressed cancel')
    return
else
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
end
tc=load(fullfile(tcpathname, tcfilename));



tc_n=1; %TC tone index
st_n=1; %output stimuli index
while tc_n+1<=length(tc.stimuli)
    
    
    
    %insert embedded tones
    start_tc_n=tc_n; %store starting tc_n to do pulse-off repeat of tones
    edur=0;
    tc_n=tc_n+1;
    st_n=st_n+1;
    tone=tc.stimuli(tc_n);
    while ~strcmp(tone.type, 'GPIAS') %cycle through BG noise stimuli with laser off
        
        stimuli(st_n)=tone;
        stimuli(st_n).param.AOPulseOn=0;
        
        tc_n=tc_n+1;
        st_n=st_n+1;
        if tc_n>length(tc.stimuli)
            break
        end
        tone=tc.stimuli(tc_n);
    end
    %then add the GPIAS with laser on
    if strcmp(tone.type, 'GPIAS')
        stimuli(st_n)=tone;
        if tone.param.gapdur==10 %This is where we assign shock to a specific gap duration.
            stimuli(st_n).param.AOPulseOn=1;
        else
            stimuli(st_n).param.AOPulseOn=0;
        end
    else
        %hit end of tc.stimuli, just move on
    end
    
    
%     %insert non-embedded tones
%     %note: these are just a redundant copy of the same stimuli, we're just
%     %leaving them in for backwards-compatibility with expected number of repetitions
%     tc_n=start_tc_n; %reset tone index
%     
%     tc_n=tc_n+1;
%     st_n=st_n+1;
%     tone=tc.stimuli(tc_n);
%     while ~strcmp(tone.type, 'GPIAS') %cycle through BG noise stimuli with laser off
%         
%         stimuli(st_n)=tone;
%         stimuli(st_n).param.AOPulseOn=0;
%         tc_n=tc_n+1;
%         st_n=st_n+1;
%         if tc_n>length(tc.stimuli)
%             break
%         end
%         tone=tc.stimuli(tc_n);
%     end
%     %then add the GPIAS with laser still off
%     if strcmp(tone.type, 'GPIAS')
%         stimuli(st_n)=tone;
%         if tone.param.gapdur==0
%             stimuli(st_n).param.AOPulseOn=1;
%         else
%             stimuli(st_n).param.AOPulseOn=0;
%         end
%     end
%     %this is what Aldis changed, from "0"
%     %use 1 to deliver pulse on every trial, i.e. for driving a shock for fear conditioning
%     %use 0 if you want interleaved pulses, like driving a laser for optogenetics
%     %you should leave this set to 1, and instead use
%     %MakeInterleavedArchGPIASProtocol if you want an interleaved laser
%     %protocol
    
    
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('PseudoGapShockProtocol, pre%dms/width%dms/isi%dms/%s', pre, width, isi, tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('PseudoGapShockProtoco, pre%dms/width%dms/isi%dms/%s', pre, width, isi, tc.stimuli(1).param.description);
filename=sprintf('PseudoGapShockProtocol-%d-%d-%d-%s', pre, width, isi, tcfilename);

%put into stimuli structure
%stimuli(1).type='exper2 stimulus protocol';
%stimuli(1).param.name= sprintf('GapShockProtocol Gaps0-25 Shocks on 10, pre%dms/width%dms/isi%dms/%s', pre, width, isi, tc.stimuli(1).param.name);
%stimuli(1).param.description=sprintf('GapShockProtocol Gaps0-25 Shocks on 10, pre%dms/width%dms/isi%dms/%s', pre, width, isi, tc.stimuli(1).param.description);
%filename=sprintf('GapShockProtocol Gaps0-25 Shocks on 10,-%d-%d-%d-%s', pre, width, isi, tcfilename);


cd(pref.stimuli) %where stimulus protocols are saved
cd('Gap In Noise Protocols')
save(filename, 'stimuli')
fprintf('\nwrote file %s \nin directory %s', filename, pwd)
fprintf('\n')

fprintf('\n')



%'PseudoGapShockProtocol, pre%dms/width%dms/isi%dms/%s'
%'PseudoGapShockProtocol-%d-%d-%d-%s'