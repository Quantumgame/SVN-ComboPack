function expLogEvents=E2GetEvents(experfilename, triggerPos_rising, triggerPos_falling, spikePos, soundcardtriggerPos)

% Creates an events structure to be stored in the complete experiment
% log/structure. Puts there all the stimuli from 'experfilename,' together
% with their corresponding position (taken from 'triggerPos'). Also puts
% there all the spikes (positions of) from spikePos.
%
%
%adding support for soundcard triggers (delivered on one of the soundcard
%channels) %mw 12-11-08
%
% Input:
%       experfilename       -   exper structure file name
%       triggerPos_rising   -   positions of triggers (rising edge)(in samples)
%       triggerPos_falling  -   positions of triggers (falling edge)(in samples)
%       spikePos            -   positions of spikes (in samples)
%       soundcardtriggerPos -   positions of soundcard triggers (rising edge) (in samples)
% Output:
%       expLogEvents        -   resulting events structure
%
global pref
if isempty(pref) Prefs; end

expLogEvents=[];

if nargin<1 || isempty(experfilename)
    return;
end

if nargin<2
    triggerPos_rising=[];
end

if nargin<3
    spikePos=[];
end

% load exper structure
try
    exper=load(experfilename);
catch
    disp(['Can''t load Exper file ' experfilename]);
    return;
end

fields=fieldnames(exper);           % partial exper structures have names like exper_001,
exper=eval(['exper.' fields{1}]);   % so to make sure that they are all called exper, we do it this way

% First, take care of stimuli (and triggers)
expLogTriggerEvents=[];
% I need to report the trial number(s) that are missing the
% triggerPos_rising and triggerPos_falling fields
if ~isempty(triggerPos_rising) && ~isempty(triggerPos_falling);
    stimuli=exper.stimulusczar.param.stimuli.value;
    if length(triggerPos_rising)~=length(triggerPos_falling)
         warning(sprintf('\nFile: %s\nHardware triggers are faulty, Pos_rising ~= Pos_falling!!!',experfilename));
    end
    nTriggers=min([length(triggerPos_rising) length(triggerPos_falling)]);
    [expLogTriggerEvents(1:nTriggers).Type]=deal('');   % types will be read from the stimuli structure
    if nTriggers<=length(stimuli) %mw hacking my way out of one too many triggers than stimuli
%         This won't exactly solve problems, because if there is a double
%         sc trigger and then a missing sc trigger it'll balance out and
%         won't be seen. But, it'll be messing with the data!
%         mak 102110
%         Also, this doesn't account for files with holdcmds!!!
       m=0; % soundcard triggers
        for n=1:nTriggers
            expLogTriggerEvents(n).Type=stimuli{n}.type;
            expLogTriggerEvents(n).Position=triggerPos_falling(n); %default is falling since that triggers DAQ
            expLogTriggerEvents(n).Position_rising=triggerPos_rising(n);
            expLogTriggerEvents(n).Param=stimuli{n}.param;
            %what kind of trigger is this (sound, ao, visual?)
            typeidx=strcmp(pref.stimulitypes(:,1),stimuli{n}.type); 
            typetrg=pref.stimulitypes(typeidx,3);
            %if it's a sound, also log the soundcardtriggerPos
            if ~isempty(soundcardtriggerPos) %maybe soundcardtriggers didn't work for some reason, e.g. a file before I found the faulty BNC cable, or before they were even implemented
                if strcmp(typetrg, 'sound')
                    m=m+1;
                    if m<=length(soundcardtriggerPos)
                        expLogTriggerEvents(n).soundcardtriggerPos=soundcardtriggerPos(m);
                    end
                end            
            end
        end
    else fprintf('\n more triggers than stimuli !?!?')
        error('more triggers than stimuli !?!?')
    end %mw
    if nTriggers~=length(stimuli) %|| nTriggers~=length(soundcardtriggerPos)
        warning(sprintf('The number of stimuli don''t equal triggers!?!?!?\nNOTIFY MIKE OR MICHAEL ASAP!!!\nFile: %s \nStimuli=%d\nHardware triggers=%d\nSoundcard triggers=%d',experfilename,length(stimuli),nTriggers,length(soundcardtriggerPos)))
        currentdir=pwd;
        fid=fopen('SC_HW_triggermismatch.txt','at+');
        fprintf(fid,'\n   Stimuli=%d\n   Hardware triggers=%d\n   Soundcard triggers=%d',length(stimuli),nTriggers,length(soundcardtriggerPos));
        cd(currentdir);
    end
end

% %to verify that triggers match stimuli, you could use this code snippet
% figure
% daqfilename=%need to grab daqfilename from caller function E2ProcessDaqFile using dbup 
% stim=daqread(daqfilename,'Channel',stimchannel,'DataFormat','native');
% for n=1:nTriggers
% plot(stim(triggerPos(n)-1000:triggerPos(n)+1000))
% title(sprintf('trig%d, %s',n,    stimuli{n}.type));
% pause
% end

% Second, record the spikes
expLogSpikeEvents=[];
if ~isempty(spikePos)
    nSpikes=length(spikePos);
    [expLogSpikeEvents(1:nSpikes).Type]=deal('spike');
    for n=1:nSpikes
        expLogSpikeEvents(n).Position=spikePos(n);
        expLogSpikeEvents(n).Param=[];
    end
end

% put it all together and return
expLogEvents=[expLogTriggerEvents expLogSpikeEvents];
