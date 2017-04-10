function varargout = TonePlayer( varargin )

% plays a single tone

global exper pref tonetimer

% Note: which soundmethod to use (AOSound or PPAsound) set in CreatGUI

varargout{1} = lower(mfilename);
if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
    case 'init'
        %ModuleNeeds(me,{'ao','ai'});
        %SetParam(me,'priority','value',GetParam('ai','priority')+1);
        CreateGUI; %local function that creates ui controls and initializes ui variables
        switch GetParam(me, 'soundmethod')
            case 'PPAsound'
                PPAsound('init');
            case 'AOSound'
                AOSound('init');
        end
    case 'reset'
        Stop;
        switch GetParam(me, 'soundmethod')
            case 'PPAsound'
                PPAsound('init');
            case 'AOSound'
                AOSound('init');
        end
        
    case 'trialready'
        
    case 'trialend'
        
   % case 'close'
        
    case 'update_time'
        newtime=etime(clock,GetParam(me,'StartTime'));
        SetParam(me,'ElapsedTime',newtime);
        
    case 'load'
        Load;
        
    case 'play'
        Play;
    case 'playloop' %temp 060109
        PlayLoop;
        
    case 'stop'
        Stop;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load
%Message(me, 'loading...');
param.duration=getparam(me, 'Duration');
param.frequency=getparam(me, 'Frequency');
param.amplitude=getparam(me, 'Amplitude');
param.ramp=getparam(me, 'Ramp');
    switch GetParam(me, 'soundmethod')
        case 'PPAsound'
            samplerate=PPAsound('samplerate');
        case 'AOSound'
            samplerate=AOSound('samplerate');
    end
% triggernum=getparam(me, 'Triggernum');
% side='both';
% stop_ramp_tau_ms=getparam(me, 'StopRamp');
% predelay_s=0; % time in seconds to pre-delay the playing of the sound when triggering
param.loop_flg =getparam(me, 'Loop');

%calibrate tone amplitudes
param=CalibrateSound(param);

if param.frequency==-1
    samples=MakeWhiteNoise(param, samplerate);
else
    samples=MakeTone(param, samplerate);
end

% Soundmachine code (uncomment to use soundmachine):
% sm=GetParam('soundloadsm','SM');
% sm=SetSampleRate(sm, 200000); %mw 060606 Warning: For now, RTLSoundMachine is limited to a sample rate of 200kHz only!  Please fix your code!
% sm=LoadSound(sm, triggernum, samples, side, stop_ramp_tau_ms, predelay_s, loop_flg);

try
    switch GetParam(me, 'soundmethod')
        case 'PPAsound'
            PPAsound('load','var',samples,param);
        case 'AOSound'
            AOSound('load','var',samples,param);
    end
    Message(me, 'sound loaded.', 'append');
catch
    Message(me, 'sound failed to load.');
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%temp function for playing with buffer refill
function PlayLoop
global tonetimer
switch GetParam(me, 'soundmethod')
    case 'PPAsound'
        PPAhandle=GetParam('PPAsound','PPAhandle');
    case 'AOSound'
        AOhandle=GetParam('AOSound','AOhandle');
end
% Soundmachine code (uncomment to use soundmachine):
% sm=GetParam('soundloadsm','SM');
% triggernum=getparam(me, 'triggernum');
% sm=PlaySound(sm, triggernum);
% Stop;
Load;
pause(.05)
% loop_flg=GetParam(me, 'Loop');
% if loop_flg==0
Message(me, 'sound playing...');
switch GetParam(me, 'soundmethod')
    case 'PPAsound'
        PPAsound('playsoundloop');
    case 'AOSound'
        AOSound('playsoundloop');
end
SetParam(me,'StartTime',clock);
start(tonetimer);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Play
global tonetimer
% PPAhandle=GetParam('PPAsound','PPAhandle');
% loop_flg=GetParam(me, 'Loop');
% Soundmachine code (uncomment to use soundmachine):
% sm=GetParam('soundloadsm','SM');
% triggernum=getparam(me, 'triggernum');
% sm=PlaySound(sm, triggernum);
if strcmp(get(tonetimer, 'Running'),'on')
    error('TonePlayer: already running! Press stop first')
    return
end

Load;
% if loop_flg==0
%Message(me, 'sound playing...');

switch GetParam(me, 'soundmethod')
    case 'PPAsound'
        PPAsound('playsound');
    case 'AOSound'
        AOSound('playsound');
end
%Message(me, 'sound played.');

% else %loop_flg==1
%
%     PPAsound('playsound');
%
%     Message(me, 'sound playing...');
SetParam(me,'StartTime',clock);

if getparam(me, 'Loop')
    start(tonetimer);
end
%
%     % PPAsound('playsoundloop');
%     % while getparam(me, 'Loop')==1
%     % PPAsound('playsoundloop');
% %          loop_flg=getparam(me, 'Loop');
% %         if loop_flg==1;
% %             return;
% %          end
%   %   end
%    % stop(tonetimer);
% end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stop
global tonetimer

% Soundmachine code (uncomment to use soundmachine):
% sm=GetParam('soundloadsm','SM');
% sm=StopSound(sm); %for some reason this is not working anymore
% sm=Initialize(sm); %Initialize and re-load in lieu of stopping

% SetParam(me,'Loop', 0); %break loop when stop pressed
switch GetParam(me, 'soundmethod')
    case 'PPAsound'
        PPAsound('stop');
    case 'AOSound'
        AOSound('stop');
end
Message(me, 'sound stopped.');
%if getparam(me, 'loop')
stop(tonetimer);
%   Message(me, 'timer stopped.');
%end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI
global tonetimer pref
% this creates all the ui controls for this module
fig = ModuleFigure(me,'visible','off'); %PPAsound

InitParam(me, 'soundmethod', 'value', pref.soundmethod);
%whether to use AOSound or PPAsound is set in Prefs.m

% GUI positioning factors
hs = 60;
h = 5;
vs = 20;
n = 0;

%Defaults
Duration=1e3; %ms
Frequency=2e3; %Hz
Amplitude=70; %dBSPL
Ramp=10; %ms
StopRamp=Ramp;
Triggernum=1;
Loop=0; %to loop or not to loop

InitParam(me,'Duration',...
    'value',Duration,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;
InitParam(me,'Frequency',...
    'value',Frequency,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;

InitParam(me,'Amplitude',...
    'value',Amplitude,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;

InitParam(me,'Ramp',...
    'value',Ramp,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;

InitParam(me,'StopRamp',...
    'value',StopRamp,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;

InitParam(me,'Triggernum',...
    'value',Triggernum,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;

InitParam(me,'Loop',...
    'value',Loop,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;

InitParam(me,'StartTime',...
    'save',1,'value', 0);
InitParam(me,'ElapsedTime',...
    'ui','disp','format','clock','save',1,'value', 0,...
    'pos',[h n*vs hs vs]); n=n+1;

tonetimer=timer('TimerFcn',[me '(''update_time'');'],'Period',1,'ExecutionMode','FixedRate');

% pushbuttons are little different
uicontrol('parent',fig,'string','Play','tag','Play',...
    'position',[h n*vs hs vs],...
    'style','pushbutton','callback',[me ';']); n=n+1;

uicontrol('parent',fig,'string','Stop','tag','Stop',...
    'position',[h n*vs hs vs],...
    'style','pushbutton','callback',[me ';']); n=n+1;

% nm 09.04.08 Load button causing crashes
% uicontrol('parent',fig,'string','Load','tag','Load',...
%     'position',[h n*vs hs vs],...
%     'style','pushbutton','callback',[me ';']); n=n+1;

% nm 09.05.08 Reset not needed
% uicontrol('parent',fig,'string','Reset','tag','Reset',...
%     'position',[h n*vs hs vs],...
%     'style','pushbutton','callback',[me ';']); n=n+1;

% uicontrol('parent',fig,'string','Stop','tag','Stop',...
%     'units','normal','position',[0.45 0.075 0.1 0.05],...
%     'style','pushbutton','callback',[me ';']); n=n+1;


% message box
uicontrol(fig,'tag','message','style','text',...
    'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*3]); n = n+1;

%try to load calibration data
try
    cd(pref.experhome)
    cd calibration
    cal=load('calibration');
    InitParam(me,'Calibration','value',cal);
    Message(me, 'loaded calibration')
    pause(.5)
catch
    InitParam(me,'Calibration','value',[]);
    Message(me, 'failed to load calibration')
    pause(.5)
end


set(fig,'pos',[1528         447         143         220]);
% Make figure visible again.
set(fig,'visible','on');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimparams=CalibrateSound(stimparams);
cal=GetParam(me, 'Calibration');
if ~isempty(cal) %it will be empty if Init failed to load calibration
    findex=find(cal.logspacedfreqs<=stimparams.frequency, 1, 'last');
    atten=cal.atten(findex);
    stimparams.amplitude=stimparams.amplitude-atten;
    Message(me, sprintf('calibrated'), 'append')
    %pause(.5)
else
    Message(me, 'NOT calibrated', 'append')
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%