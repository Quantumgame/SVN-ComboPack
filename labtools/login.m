global pref
options.WindowStyle='modal';
pref.username=inputdlg('Please enter your username','username',1,{'lab'}, options);
pref.username=pref.username{:};
Prefs