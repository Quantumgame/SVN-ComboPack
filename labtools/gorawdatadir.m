function gorawdatadir(expdate, session, filenum)
%usage gorawdatadir(expdate, session, filenum)
%just cd to the right directory
global pref
if isempty(pref) Prefs; end
username=pref.username;
rig=pref.rig;
cd(pref.data);
[ret, hostname]=system('hostname');
        
        raw_data_dir=fullfile(sprintf('%s-%s', expdate, username), sprintf('%s-%s-%s', expdate, username, session));
        
        if ismac
            godatadirbak(expdate, session, filenum)
            wd=pwd;
            raw_data_dir=strrep(wd, '-processed', '')  ;
        
        end
 if isempty(raw_data_dir)
                 error('Cannot determine which computer I am using!')
 end

 
cd(raw_data_dir)
