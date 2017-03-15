function stimtypes=stimtype(expdate, session, filename)
% usage: stimtypes=stimtype(expdate, session, filename)
%returns stimulus types that were presented for that file, in a cell array
%
%e.g. tone, whitenoise, clicktrain, holdcmd
% updated by mak 21feb2011 to also look for processed data on the backup server
global pref
if isempty(pref); Prefs; end
username=pref.username;

stimtypes=[];
try godatadir(expdate, session, filename)
catch
    godatadirbak(expdate, session, filename)
end
eventsfile=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate, username, session, filename);
if exist(eventsfile,'file')~=2
    godatadirbak(expdate, session, filename)
    if exist(eventsfile,'file')~=2
        fprintf('no events file found')
        return
    end
end
load(eventsfile)
allevents=[];
for i=1:length(event)
    allevents{i}=event(i).Type;
end
stimtypes=unique(allevents);

% fprintf('\nstimtypes for %s:', eventsfile)
% for i=1:length(stimtypes)
%     fprintf('\n%s', stimtypes{i})
% end
%     fprintf('\n\n')