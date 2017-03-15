function Plotrecordedsound(expdate, session, filenum, varargin)
% Plots sounds recorded with B&K, raw data and spectrogram
% usage:
% Plotrecordeddata(expdate, session, filenum, [xlimits])
% created by ira 04.21.15

global pref
if nargin<3 | nargin>4
    error('wrong number of arguments');
end
if nargin==4
    xlimits=varargin{1};
else
   xlimits=[];
end
username=pref.username;
rig=pref.rig;

%looking for data folder
daqfilename=sprintf('%s-%s-%s-%s',expdate,username, session, filenum);
    cd(pref.data)
    daqdir=sprintf('%s-%s\\%s-%s-%s',expdate,username,expdate,username, session);
    cd(daqdir)
    if isempty(xlimits)
        triggers=daqread(daqfilename);
    else
        triggers=daqread(daqfilename, 'samples', xlimits);
    end
    cd(pref.data)
    cd(sprintf('%s-%s',expdate, username));
    cd(sprintf('%s-%s-%s',expdate, username, session));


end

