function MergeDataFiles(expdate1, session1, filenum1,...
    expdate2, session2, filenum2,...
    newexpdate, newsession, newfilenum)
%usage: MergeDataFiles('expdate1','session1','filenum1','expdate2','session2','filenum2','newexpdate','newsession','newfilenum')
%
%merges two datafiles into one new datafile
%does the same for eventsfile and stimfile, too
%concatenates second after first
%
%useful if you want to use a stimulus protocol that lasts longer than the
%longest data acquisition possible on your machine (control module is called
%recordingtime): acquire as 2 separate
%files and then merge them
%mw052209

% added second axopatch channel if it's needed as specified by Prefs
% see ~line 107
% mak 26jun2012

global pref
if isempty(pref) Prefs; end
username=pref.username;
numchannels=pref.numchannels;

% Make Axopatch1
[datafile1, eventsfile1, stimfile1]=getfilenames(expdate1, session1, filenum1);
[datafile2, eventsfile2, stimfile2]=getfilenames(expdate2, session2, filenum2);
[newdatafile, neweventsfile, newstimfile]=getfilenames(newexpdate, newsession, newfilenum);

try godatadir(newexpdate, newsession, newfilenum)
catch
    godatadirbak(newexpdate, newsession, newfilenum)
end
if exist(newdatafile)==2
    error(sprintf('%s already exists', newdatafile))
end
if exist(neweventsfile)==2
    error(sprintf('%s already exists', neweventsfile))
end
if exist(newstimfile)==2
    error(sprintf('%s already exists', newstimfile))
end

% load first data file
try godatadir(expdate1, session1, filenum1)
    D1=load(datafile1);
    E1=load(eventsfile1);
catch
    godatadirbak(expdate1, session1, filenum1)
    D1=load(datafile1);
    E1=load(eventsfile1);
end


% load second data file
try godatadir(expdate2, session2, filenum2)
    D2=load(datafile2);
    E2=load(eventsfile2);
catch
    godatadirbak(expdate2, session2, filenum2)
    D2=load(datafile2);
    E2=load(eventsfile2);
end


if D1.nativeScaling~=D2.nativeScaling | D1.nativeOffset~=D2.nativeOffset
    error('nativeScaling/nativeOffset do not match')
end

try godatadir(newexpdate, newsession, newfilenum)
catch
    godatadirbak(newexpdate, newsession, newfilenum)
end

nativeScaling=D1.nativeScaling;
nativeOffset=D1.nativeOffset;
trace=[D1.trace; D2.trace];

merge=sprintf('this file was created by merging %s and %s', datafile1, datafile2);
save(newdatafile, 'trace', 'nativeScaling', 'nativeOffset', 'merge');

event1=E1.event;
event2=E2.event;
for i=1:length(event2)
    event2(i).Position=event2(i).Position+length(D1.trace);
    event2(i).Position_rising=event2(i).Position_rising+length(D1.trace);
    if isfield(event2(i), 'soundcardtriggerPos')
        event2(i).soundcardtriggerPos=event2(i).soundcardtriggerPos+length(D1.trace);
    end
end
event(1:length(event1))=event1;
event(length(event1)+1:length(event1)+length(event2))=event2;
merge=sprintf('this file was created by merging %s and %s', eventsfile1, eventsfile2);
save(neweventsfile, 'event', 'merge');

clear E1 E2 D1 D2
try
    godatadir(expdate1, session1, filenum1)
    S1=load(stimfile1);
catch
    godatadirbak(expdate1, session1, filenum1)
    S1=load(stimfile1);
end

try godatadir(expdate2, session2, filenum2)
    S2=load(stimfile2);
catch
    godatadirbak(expdate2, session2, filenum2)
    S2=load(stimfile2);
end


stim=[S1.stim; S2.stim];
nativeScalingStim=S1.nativeScalingStim;
nativeOffsetStim=S1.nativeOffsetStim;
merge=sprintf('this file was created by merging %s and %s', stimfile1, stimfile2);
save(newstimfile, 'stim', 'nativeScalingStim', 'nativeOffsetStim', 'merge');


if numchannels~=1 % Make Axopatch2
    if numchannels~=2
        warning('There are more than two channels, only making two axopatch channels!!!')
    end
    
    [datafile1, eventsfile1, stimfile1]=getfilenames(expdate1, session1, filenum1, [], '2');
    [datafile2, eventsfile2, stimfile2]=getfilenames(expdate2, session2, filenum2, [], '2');
    [newdatafile, neweventsfile, ~]=getfilenames(newexpdate, newsession, newfilenum, [], '2');
    
    try godatadir(newexpdate, newsession, newfilenum)
    catch
        godatadirbak(newexpdate, newsession, newfilenum)
    end
    if exist(newdatafile)==2
        error(sprintf('%s already exists', newdatafile))
    end
    if exist(neweventsfile)==2
        error(sprintf('%s already exists', neweventsfile))
    end
%     if exist(newstimfile)==2
%         error(sprintf('%s already exists', newstimfile))
%     end
    
    try godatadir(expdate1, session1, filenum1)
    catch
        godatadirbak(expdate1, session1, filenum1)
    end
    D1=load(datafile1);
    E1=load(eventsfile1);
    
    try godatadir(expdate2, session2, filenum2)
    catch
        godatadirbak(expdate2, session2, filenum2)
    end
    D2=load(datafile2);
    E2=load(eventsfile2);
    
    if D1.nativeScaling~=D2.nativeScaling | D1.nativeOffset~=D2.nativeOffset
        error('nativeScaling/nativeOffset do not match')
    end
    
    try godatadir(newexpdate, newsession, newfilenum)
    catch
        godatadirbak(newexpdate, newsession, newfilenum)
    end
    
    nativeScaling=D1.nativeScaling;
    nativeOffset=D1.nativeOffset;
    trace=[D1.trace; D2.trace];
    
    merge=sprintf('this file was created by merging %s and %s', datafile1, datafile2);
    save(newdatafile, 'trace', 'nativeScaling', 'nativeOffset', 'merge');
    
    event1=E1.event;
    event2=E2.event;
    for i=1:length(event2)
        event2(i).Position=event2(i).Position+length(D1.trace);
        event2(i).Position_rising=event2(i).Position_rising+length(D1.trace);
        if isfield(event2(i), 'soundcardtriggerPos')
            event2(i).soundcardtriggerPos=event2(i).soundcardtriggerPos+length(D1.trace);
        end
    end
    event(1:length(event1))=event1;
    event(length(event1)+1:length(event1)+length(event2))=event2;
    merge=sprintf('this file was created by merging %s and %s', eventsfile1, eventsfile2);
    save(neweventsfile, 'event', 'merge');
    
    clear E1 E2 D1 D2
    try godatadir(expdate1, session1, filenum1)
    catch
        godatadirbak(expdate1, session1, filenum1)
    end
    S1=load(stimfile1);
    try godatadir(expdate2, session2, filenum2)
    catch
        godatadirbak(expdate2, session2, filenum2)
    end
    S2=load(stimfile2);
    
    stim=[S1.stim; S2.stim];
    nativeScalingStim=S1.nativeScalingStim;
    nativeOffsetStim=S1.nativeOffsetStim;
    merge=sprintf('this file was created by merging %s and %s', stimfile1, stimfile2);
    save(newstimfile, 'stim', 'nativeScalingStim', 'nativeOffsetStim', 'merge');
    
%     expLogDataSingle=E2ProcessDAQFile(daqfilename, expType, saveit, outputdir, spikeMethod); % and process a single file
    
end