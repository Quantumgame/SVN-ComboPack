function gorawdatadirbak(expdate, session, filenum)
%usage gorawdatadirbak(expdate, session, filenum)
%just cd to the right directory on blister
global pref
if isempty(pref) Prefs; end
username=pref.username;
rig=pref.rig;
cd(pref.data);
[ret, hostname]=system('hostname');
raw_data_dir=fullfile(sprintf('%s-%s', expdate, username), sprintf('%s-%s-%s', expdate, username, session));
godatadirbak(expdate, session, filenum)
cd ../../..
cd(sprintf('Data-%s', username))
cd(raw_data_dir)
