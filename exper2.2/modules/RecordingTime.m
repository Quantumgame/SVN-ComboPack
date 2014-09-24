function out = RecordingTime(varargin)
%RecordingTime
%exper module which displays total and remaining recording time
%based on number of channels, samplerate, and memory allocated for daq
%mw 5-09

global exper pref rectimer

out = lower(mfilename);
if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action

    case 'init'
        fig = ModuleFigure(me,'visible','off');
        %     SetParam(me,'priority',7);
        hs = 100;
        h = 5;
        vs = 20;
        n = 0;
        % message box
        uicontrol('parent',fig,'tag','message','style','text',...
            'enable','inact','horiz','left','pos',[h h+n*vs hs*3 3*vs]);
        n=n+3;
        n=n+.25;
        set(fig,'pos', [1368  750  hs*2 n*vs] ,'visible','on');

        rectimer=timer('TimerFcn',[me '(''ShowMyMessage'');'],'Period',60,'ExecutionMode','FixedRate');

        ShowMyMessage;

    case 'epathchange'
%        ShowMyMessage;
    case 'getready'
        start(rectimer)
        ShowMyMessage;
    case 'trialend'
        stop(rectimer)
%         ShowMyMessage;
Message(me, 'Stopped')
    case 'showmymessage'
        ShowMyMessage;
    case 'reset'
        ShowMyMessage;
    otherwise
end

% begin local functions

function out = me
out = lower(mfilename);

function ShowMyMessage;
global exper pref
samprate=GetParam('ai', 'samplerate');
nchan=length(GetParam('ai', 'aichannels'));
bytespersec=samprate*nchan*8;
out=daqmem(exper.ai.daq);
secposs=out.MaxBytes/bytespersec;
minpossible=secposs/60;
exptime=getparam('Control', 'exptime');
secremain=secposs-exptime;
minremain=secremain/60;
Message(me,sprintf('max recording time available: %.0f minutes\nminutes remaining: %.0f ',minpossible,minremain ));

if minremain<2
Message(me,sprintf('max recording time available: %.0f minutes\nminutes remaining: %.1f\nseconds remaining: %.0f ',minpossible,minremain, secremain ));
h = findobj(findobj('tag',me),'tag','message');
set(h, 'backgroundcolor', [1 0 0])
end