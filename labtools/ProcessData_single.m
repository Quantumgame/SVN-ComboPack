function ProcessData_single(expdate, session, filenum)
% E2 process data script
% converts raw data (.daq) to processed data (axopatch-trace.mat)
% Moving rawdata into backup is now automated using 
% BackupData(expdate, session, filenum), mk & mw 3may2011
% processes only the filenum specified (not the entire directory)
% ProcessData_single(expdate, session, filenum)
% 
% eg. ProcessData_single('032607','001','001')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
if isempty(pref); Prefs;end
username=whoami;

processed_data_session_dir=sprintf('%s-%s-%s',expdate, username, session);
if ispc
    raw_data_dir=sprintf('%s\\Data-%s\\%s-%s', pref.home, username, expdate, username);
    backup_raw_data_dir=sprintf('%s\\Data-%s-backup\\%s-%s', pref.home, username, expdate, username);
    processed_data_dir=sprintf('%s\\Data-%s-processed\\%s-%s', pref.home, username, expdate, username);
    outputdir=sprintf('%s\\%s', processed_data_dir, processed_data_session_dir);
elseif ismac
    raw_data_dir=sprintf('%s/Data-%s/%s-%s', pref.home, username, expdate, username);
    backup_raw_data_dir=sprintf('%s/Data-%s-backup/%s-%s', pref.home, username, expdate, username);
    processed_data_dir=sprintf('%s/Data-%s-processed/%s-%s', pref.home, username, expdate, username);
    outputdir=sprintf('%s/%s', processed_data_dir, processed_data_session_dir);
end

expType='unknown';
saveit=1;
spikeMethod='skip'; %don't detect spikes
raw_data_session_dir=sprintf('%s-%s-%s', expdate, username, session);
daqfilename=sprintf('%s-%s-%s-%s.daq', expdate,username, session, filenum);

try cd(raw_data_dir) %is the raw data on this computer, i.e. did you just take the data?
    try cd(backup_raw_data_dir) % if there is no rawdatabackup folder, BackupData
        cd(raw_data_session_dir) % if there is no rawdatabackup_session folder, BackupData
        if exist(daqfilename,'file')~=2 % if the file hasn't been copied, BackupData
            fprintf('\nRaw data will now be copied into the backup folder\n');
            BackupData(expdate, session, filenum);
        end
    catch
        BackupData(expdate, session, filenum);
    end
catch % if not, find raw data on server
    if ismac
        try cd('/Volumes/blister')
        catch
            cd('/Volumes')
            mkdir('blister')
            !mount -t smbfs //lab@blister/Backup  /Volumes/blister
            cd('/Volumes/blister')
        end
    elseif ispc
        cd('\\blister\backup')
    else error('cannot tell what kind of computer this is')
    end
    cd(pref.rig)
    raw_data_dir_bak=sprintf('%s\\Data-%s\\%s-%s', pwd, username, expdate, username);
    cd(raw_data_dir_bak)
     
    
    cd(raw_data_session_dir)
end
expLogDataSingle=E2ProcessDAQFile(daqfilename, expType, saveit, outputdir, spikeMethod); % and process a single file
godatadir(expdate, session, filenum)
fprintf('done.\n');

