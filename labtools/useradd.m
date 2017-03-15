function useradd(username)
%creates data directories for a new exper username
%usage: useradd('username')
%
%creates the following directories in pref.home:
%Data-username
%Data-username-backup
%Data-username-processed
%
%note: if a window pops up asking for a username don't worry about it,
% just click OK
if nargin~=1; error('wrong number of arguments. Usage: useradd(''username'')'); end
if ~isstr(username); error('username must be a string'); end

Prefs
global pref
cd(pref.home)

mkdir(fullfile(pref.home, sprintf('Data-%s', username)));
mkdir(fullfile(pref.home, sprintf('Data-%s-backup', username)));
mkdir(fullfile(pref.home, sprintf('Data-%s-processed', username)));

fprintf('\nNOTE: DeltaCopy must be updated to backup the new user''s data!!!');
fprintf('\nIn the Start menu open DeltaCopy Client');
fprintf('\nIn "Existing Profiles" click on "blister backup"');
fprintf('\nIn the "File List" tab click on "Add Folder"');
fprintf('\nAdd two folders: Data-NewUser and Data-NewUser-processed\n');


