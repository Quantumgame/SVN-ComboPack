function SplitData(user, expdate, session, filenum)
% usage: SplitData(user, expdate, session, filenum)
%utility to split raw data into two halves for cross-validation
% the two halves have the same filenum with an appended 'a' or 'b'
% the approach is to leave the axopatch data and stim intact, but delete either the
% first or second half of the events

godatadir(user, expdate, session, filenum)

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum, user);
[datafilea, eventsfilea, stimfilea]=getfilenames(expdate, session, [filenum, 'a'], user);
[datafileb, eventsfileb, stimfileb]=getfilenames(expdate, session, [filenum, 'b'], user);

load(datafile);
save(datafilea, 'nativeOffset','nativeScaling','trace')
save(datafileb, 'nativeOffset','nativeScaling','trace')

load(stimfile);
save(stimfilea, 'nativeOffsetStim','nativeScalingStim','stim')
save(stimfileb, 'nativeOffsetStim','nativeScalingStim','stim')

load(eventsfile);
halfevents=round(length(event)/2);
eventa=event;
eventb=event;

eventa((halfevents+1):end)=[];
event=eventa;
save(eventsfilea, 'event')

eventb(1:halfevents)=[];
event=eventb;
save(eventsfileb, 'event')










