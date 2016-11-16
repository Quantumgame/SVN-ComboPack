function su(username)
%change exper username
%usage: su('username') or su username
global pref
pref.username=username;
%fprintf('you are now logged in as %s', username);