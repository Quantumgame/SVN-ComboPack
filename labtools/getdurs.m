function durs=getdurs(expdate, session, filename)
% usage: durs=getdurs(expdate, session, filename)
%returns stimulus durations of all stimuli that were presented for that
%file
global pref
if isempty(pref) Prefs; end
durs=[];
% try
    if pref.usebak
        godatadirbak(expdate, session, filename)
    else
        godatadir(expdate, session, filename)
    end
% catch
%     ProcessData_single(expdate, session, filename)
%     godatadir(expdate, session, filename)
% end
eventsfile=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate,pref.username, session, filename);
if exist(eventsfile)~=2
    fprintf('no events file found')
        ProcessData_single(expdate, session, filename)
end
if exist(eventsfile)~=2
    fprintf('still no events file found')
    return
end

load(eventsfile)


allevents=[];
alldurs=[];
for i=1:length(event)
    if isfield(event(i).Param, 'duration')
        alldurs(i)=event(i).Param.duration;
    end
end

durs=unique(alldurs);
