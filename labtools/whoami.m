function varargout=whoami

global pref
if isempty(pref)
    username='not logged in';
else
    username=pref.username;
end

if nargout==0
    fprintf('%s\n', username);
elseif nargout==1
    varargout{1}=username;
end
