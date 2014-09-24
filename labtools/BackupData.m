function BackupData(expdate, session, filenum)
%copies raw data in Data directory to Backup directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
if isempty(pref); Prefs;end
username=whoami;
raw_data_dir=fullfile(pref.home, sprintf('Data-%s\\%s-%s', username, expdate, username));
session_dir=sprintf('%s-%s-%s', expdate, username, session);

backup_data_dir=fullfile(pref.home, sprintf('Data-%s-backup\\%s-%s', username, expdate, username));
daqfilename=sprintf('%s-%s-%s-%s.daq', expdate,username, session, filenum);
experfilename=sprintf('%s-%s-%s-%s.mat', expdate,username, session, filenum);
stimbakfilename=sprintf('%s-%s-%s-%s-stimuli.bak', expdate,username, session, filenum);

if ~exist(backup_data_dir, 'dir')
    mkdir(backup_data_dir)
end
cd(backup_data_dir)
if ~exist(session_dir, 'dir')
    mkdir(session_dir)
end
cd(raw_data_dir)
cd(session_dir)
cmdstring=sprintf('copy %s %s', daqfilename, fullfile(backup_data_dir,session_dir,daqfilename ));
system(cmdstring);
cmdstring=sprintf('copy %s %s', experfilename, fullfile(backup_data_dir,session_dir,experfilename ));
system(cmdstring);
cmdstring=sprintf('copy %s %s', stimbakfilename, fullfile(backup_data_dir,session_dir,stimbakfilename ));
system(cmdstring);
