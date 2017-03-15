function ProcessData(expdate, session, filenum)
% E2 process data script
%converts raw data (.daq) to processed data (axopatch-trace.mat)
%Copying raw data into backup is now automated using BackupData
%automatically backs up and processes the entire data directory for expdate
%(actually only works for one directory at a time, need to improve this)
%use ProcessData_single if you want to process a single file not all data
%from that day
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
Prefs
username=pref.username;
eventsfile=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate, username, session, filenum);

%back up data
try cd(backup_raw_data_dir) % if there is no rawdatabackup folder, BackupData
    cd(raw_data_session_dir) % if there is no rawdatabackup_session folder, BackupData
    if exist(daqfilename,'file')~=2 % if the file hasn't been copied, BackupData
        fprintf('\nRaw data will now be copied into the backup folder\n');
        BackupData(expdate, session, filenum);
    end
catch
    BackupData(expdate, session, filenum);
end

raw_data_dir=sprintf('%s\\Data-%s-backup\\%s-%s', pref.home, username, expdate, username);
processed_data_dir=sprintf('%s\\Data-%s-processed\\%s-%s', pref.home, username, expdate, username);
fprintf('\ntrying to process raw data in %s...', raw_data_dir)
E2ProcessSession(raw_data_dir, 1, processed_data_dir) %1 means save it
godatadir(expdate,  session, filenum)

fprintf('done.');
