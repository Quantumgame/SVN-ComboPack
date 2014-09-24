function godatadirbak(expdate, session, filenum)
%cd to the processed-data directory on the lab backup server (blister)
%usage: godatadirbak(expdate, session, filenum)
%       user and rig are taken from prefs, you can set these using su
%       to specify user and sr to specify rig

global pref
if isempty(pref) Prefs; end
if ~isfield(pref, 'processed_data_dir') Prefs; end
username=pref.username;

rig=pref.rig;

if nargin ~=3
    error('godatadir: wrong number of arguments');
end


if ismac
    
    try
        cd('/Volumes/backup') %mw 11-19-2012 (this is confusing to have to keep switching back and forth - might be a new OSX thing?
    catch
        try
            cd('/Volumes/blister') %mw 01-25-2012
            if isempty(ls) error('backup server mount point /Volumes/blister exists but is empty...');end
        catch
            cd('/Volumes')
            mkdir('blister')
            fprintf('\nattempting to mount backup file server...\n')
            
%             note: this doesn't work for me, take a look at http://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-samba-connect-share.html
            
            [status, result]=system('mount -t smbfs //lab@blister/Backup  /Volumes/blister');
            if ~status error(status);
            else
            fprintf('\nsuccessfully mounted backup server')
            end
            cd('/Volumes/blister')
        end
    end
    
elseif ispc
    cd('\\blister\backup')
else error('cannot tell what kind of computer this is')
end


    cd(rig)
    cd(sprintf('Data-%s-processed', username))
    cd(sprintf('%s-%s',expdate, username))
    cd(sprintf('%s-%s-%s',expdate, username, session))
    


















