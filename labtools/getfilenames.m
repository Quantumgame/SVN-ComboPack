function [datafile, eventsfile, stimfile]=getfilenames(varargin)
%usage: [datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [user], [chan]);
%just builds the filenames for AxopatchData1-trace.mat,
%AxopatchData1-events.mat, and stim.mat
%user defaults to pref.user
%use optional chan string argument to specify data channel (e.g. for AxopatchData2-trace.mat, default is 1)
%mw 052209


global pref
if isempty(pref) Prefs; end
username=pref.username;

if nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    global pref
    if isempty(pref) Prefs; end
    username=pref.username;
    chan='1';
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    username=varargin{4};
    if isempty(username)
        global pref
        if isempty(pref) Prefs; end
        username=pref.username;
    end
    chan='1';
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    username=varargin{4};
    if isempty(username)
        global pref
        if isempty(pref) Prefs; end
        username=pref.username;
    end
    chan=varargin{5};
    if isempty(chan)
        chan='1';
    end
end

datafile=sprintf('%s-%s-%s-%s-AxopatchData%s-trace.mat',expdate,username, session, filenum, chan);
eventsfile=sprintf('%s-%s-%s-%s-AxopatchData%s-events.mat',expdate, username, session, filenum, chan);
stimfile=sprintf('%s-%s-%s-%s-stim.mat', expdate, username, session, filenum);
