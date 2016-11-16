function usebak(varargin)
%sets prefs to use the backup server when looking for data files
%usage:
%     usebak or usebak(1): sets prefs to use the backup server
%     usebak(0): sets prefs to not use the backup server
global pref
if nargin==0
    pref.usebak=1;
elseif nargin==1
    if varargin{1}
        pref.usebak=1;
    else
        pref.usebak=0;
    end
else
    error('usebak: wrong number of arguments')
end