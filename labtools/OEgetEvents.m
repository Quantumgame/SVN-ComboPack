function OEgetEvents(expdate, session, filenum)
% extracts stimulus events from exper file, and calls read_stimIDs to
% get timestamps and stimIDs from an Open Ephys 'all_channels.events' file.
%usage:  OEgetEvents(expdate, session, filenum)
% if 'all_channels.events' file is not found in data directory then a
% dialog box will open for you to select the right one
%writes output as a standard exper events file
global pref

% first get timestamps and stimIDs
if nargin==0
    fprintf('\nno input');
    return
end
godatadir(expdate,session,filenum);
try
    [timestamps stimid]=OEread_stimIDs(expdate, session, filenum);
catch
    try
        gorawdatadir(expdate,session,filenum);
        [timestamps stimid]=OEread_stimIDs(expdate, session, filenum);
    catch
        [timestamps stimid]=OEread_stimIDs;
    end
end

%correct for OE start time, so that time starts at 0
oepathname=getOEdatapath(expdate, session, filenum);
oepathname(1)='d';
fprintf('\n changing drive from c to d in oepathname. the data has been moved\n');
first_sample_timestamp=OEget_first_sample_timestamp(oepathname); %in s
timestamps=timestamps-first_sample_timestamp;

nevents=length(timestamps);

soundcardtriggerPos=OEread_soundcardtriggers(expdate, session, filenum);

if nevents==0 %probably forgot to plug in stimID/hardware trig cable
    fprintf('\nNo OE hardware triggers found, substituting soundcardtriggers for those')
    nevents=length(soundcardtriggerPos);
end

gorawdatadir(expdate, session, filenum)
expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filenum);
expstructurename=sprintf('exper_%s', filenum);
if exist(expfilename)==2 %try current directory
    load(expfilename)
    exp=eval(expstructurename);
    stimuli=exp.stimulusczar.param.stimuli.value;
else %try data directory
    cd ../../..
    try
        cd(sprintf('Data-%s-backup',user))
        cd(sprintf('%s-%s',expdate,user))
        cd(sprintf('%s-%s-%s',expdate,user, session))
    end
    if exist(expfilename)==2
        load(expfilename)
        exp=eval(expstructurename);
        stimuli=exp.stimulusczar.param.stimuli.value;
    else
        stimuli=[];
        fprintf('\ncould not find exper structure. Cannot find stimuli.')
    end
end

ignorefname=sprintf('soundcardtrigs_to_ignore-%s-%s-%s.txt', expdate, session, filenum);
 godatadir(expdate, session, filenum)
if exist(ignorefname, 'file')
    fprintf('\nfound file %s', ignorefname)
    fprintf('\nremoving soundcardtriggers ')
    sctrigs_to_ignore=load(ignorefname);
    fprintf('%d ', sctrigs_to_ignore)
    soundcardtriggerPos(sctrigs_to_ignore)=nan;
    soundcardtriggerPos=soundcardtriggerPos(~isnan(soundcardtriggerPos));
end 
if nevents~= length(stimuli)
   fprintf('\nfound %d OE stimID events, but %d stimuli in exper structure',nevents,length(stimuli) )
   fprintf('\n events doesnt match n stimuli')

%    if length(stimuli)>nevents
%    triggers_missing=length(stimuli)-nevents;
%    end
%    soundcardtriggerPos1=diff(soundcardtriggerPos);
%    for i=1:length(triggers_missing)
%        trig_mis(i,:)=find(max(soundcardtriggerPos1))
%        soundcardtriggerPos1(find(max(soundcardtriggerPos1)))=NaN;
%    end
%    
       
end

%modified from E2GetEvents
expLogTriggerEvents=[];
[expLogTriggerEvents(1:nevents).Type]=deal('');   % types will be read from the stimuli structure
m=0; % soundcard triggers
for n=1:nevents
    expLogTriggerEvents(n).Type=stimuli{n}.type;
    expLogTriggerEvents(n).Position=timestamps(n); %stimulus trigger recorded on intan board
    expLogTriggerEvents(n).Param=stimuli{n}.param;
    %what kind of trigger is this (sound, ao, visual?)
    typeidx=strcmp(pref.stimulitypes(:,1),stimuli{n}.type);
    typetrg=pref.stimulitypes(typeidx,3);
    
%     if length(soundcardtriggerPos)<length(timestamps)
%         
%         number_of_missed_triggers= length(timestamps)-length(soundcardtriggerPos);
%         warning(sprintf('Missing %d sound card trigger(s)!', number_of_missed_triggers));
%         for i=1:number_of_missed_triggers
%             lost_trigger=find(max(diff(soundcardtriggerPos))==diff(soundcardtriggerPos))
%             remaining_triggers=soundcardtriggerPos(lost_trigger+1:end);
%             soundcardtriggerPos(lost_trigger+1)=NaN;
%             for lost_idx=lost_trigger+1:nevents
%                 soundcardtriggerPos(lost_idx+1)=remaining_triggers(lost_idx);
%             end
%             soundcardtriggerPos(lost_trigger+1)=NaN;
%             
%         end
%         
%     end
%commented out -mw 06.11.2014

% if it's a sound, also log the soundcardtriggerPos from those recorded on the intan ADC
    if ~isempty(soundcardtriggerPos) %maybe soundcardtriggers didn't work for some reason, e.g. a file before I found the faulty BNC cable, or before they were even implemented
        if strcmp(typetrg, 'sound')
            m=m+1;
            if m<=length(soundcardtriggerPos)
                expLogTriggerEvents(n).soundcardtriggerPos=soundcardtriggerPos(m);
            end
        end
    end
end
daqEventsName=[expdate, '-', whoami, '-', session, '-', filenum, '-', 'OE', '-events'];
event=expLogTriggerEvents;
godatadir(expdate, session, filenum)
save(daqEventsName,'event');

