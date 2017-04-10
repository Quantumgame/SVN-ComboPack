function out=AOSound(varargin)

% exper2 module that initializes, loads, and plays sounds using the
% daqtoolbox winsound device
%mw 12.15.2010


global exper pref aotimer

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end
% Message(me, action)
switch action
    case 'init'
        % ModuleNeeds(me,{'rp2control'}); % needs RP2Control to find out how to talk to RP2
        SetParam(me,'priority',GetParam('stimulusprotocol','priority')+1);
        InitializeGUI;                  % show the gui = message box:-)
        InitAOSound;                        % Initialize sound object
        
    case 'reset'
        % Stop playback:
        AOhandle=GetParam(me,'AOhandle');
        delete(AOhandle)
        numChan=getparam(me, 'numChan'); %number of output channels we initialized the soundcard with
        if numChan>2
            AOhandle2=GetParam(me,'AOhandle2');
            delete(AOhandle2)
        end
        %clear(AOhandle)
        InitAOSound;
        
        %     case 'getready'
        %         start(aotimer)
        
    case 'esealteston'
        %PPASound('reset');
        
    case 'estimulusprotocolchanged'
        %PPASound('reset');
        
    case 'load'
        if nargin<3
            return;
        end
        try
            if nargin==4
                LoadAOSound(varargin{2},varargin{3},varargin{4});
            else
                param.channel=1;
                LoadAOSound(varargin{2},varargin{3},param); % first channel is the default channel
            end
        catch
            Message(me,'Cannot load sound');
        end
        
    case 'samplerate'
        out=GetParam(me,'SoundFs');
        
    case 'AOhandle'
        out=GetParam(me,'AOhandle');
        
    case 'playsound'
        PlaySound;
        
    case 'stop'
        % Stop playback:
        AOhandle=GetParam(me,'AOhandle');
        stop(AOhandle)
        set(AOhandle, 'RepeatOutput', 0)
        numChan=getparam(me, 'numChan'); %number of output channels we initialized the soundcard with
        if numChan>2
            AOhandle2=GetParam(me,'AOhandle2');
            stop(AOhandle2)
            set(AOhandle2, 'RepeatOutput', 0)
        end
    case 'showmymessage'
        ShowMyMessage;
    case 'trialend'
        stop(aotimer)
    case 'close'
        try
            % Stop playback:
            AOhandle=GetParam(me,'AOhandle');
            stop(AOhandle)
            delete(AOhandle)
            clear(AOhandle)
            numChan=getparam(me, 'numChan'); %number of output channels we initialized the soundcard with
            
            if numChan>2
                AOhandle2=GetParam(me,'AOhandle2');
                stop(AOhandle2)
                set(AOhandle2, 'RepeatOutput', 0)
                delete(AOhandle2)
                clear(AOhandle2)
            end
            
        catch
            Message(me, 'failed to close device')
            pause(.2)
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitAOSound
global exper pref aotimer
if ExistParam(me,'PPAhandle') % take the existing object
    AOhandle=GetParam(me,'AOhandle');
    try
        delete(AOhandle);
    catch
        Message(me, 'InitAOSound: failed to close device')
        pause(.2)
    end
end

deviceid =pref.soundcarddeviceID;
%I'm guessing deviceID will be machine dependent, so we set it in Prefs.m
%I know it should be 1 for Rig1
%to see which deviceID corresponds to your soundcard, try this:
%devices=daqhwinfo('winsound')
%devices.BoardNames

%create soundcard analog output object and add channels
AOhandle = analogoutput('winsound', deviceid);
numChan = pref.num_soundcard_outputchannels; %set in Prefs.m
%adding winsound support for >2 channels requires multiple stereo devices
%mw 02092011
%except that the multiple objects are not synchronized, and not supported
%by matlab. Thank you, Mathworks.
numChan=2; %overwriting prefs, since it never worked anyway
if numChan<=2
    addchannel(AOhandle, [1:numChan]);
else
    addchannel(AOhandle, [1:2]);
    deviceid2 =pref.soundcarddeviceID2;
    AOhandle2 = analogoutput('winsound', deviceid2); %
    addchannel(AOhandle2, [1:numChan-2]);
end
SoundFs = pref.SoundFs;
set(AOhandle, 'StandardSampleRates','Off')
set(AOhandle, 'SampleRate', SoundFs);
set(AOhandle, 'BitsPerSample', 16)

if numChan>2
    set(AOhandle2, 'StandardSampleRates','Off')
    set(AOhandle2, 'SampleRate', SoundFs);
    set(AOhandle2, 'BitsPerSample', 16)
    InitParam(me,'AOhandle2','value',AOhandle2); %param to hold the analogout winsound object
end

if isempty(AOhandle)
    Message(me,'Can''t create winsound object...');
    return;
end
InitParam(me,'AOhandle','value',AOhandle); %param to hold the analogout winsound object
InitParam(me,'numChan','value',numChan); %param to hold number of output channels with which we initialized card (num rows of samples must match this)
InitParam(me,'SoundFs','value',SoundFs); %param to hold the sampling rate
InitParam(me,'Samples','value',[]); %param to hold the samples, used only for looping
InitParam(me,'loop_flg','value',0); %param to store loop flag
InitParam(me,'seamless','value',0); %param to store whether transition should be seamless or not
InitParam(me,'buffers','value',[]); %param to store pointers to buffers for later deletion
Message(me, sprintf('Initialized winsound with device %d Fs %d', deviceid, SoundFs));

aotimer=timer('TimerFcn',[me '(''ShowMyMessage'');'],'Period',1,'ExecutionMode','FixedRate');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadAOSound(type,where,param)
global aotimer
% prepare sound data and load to soundcard object. type can be either 'file' or 'var'
switch type
    case 'file'
        try
            load(where,'samples');
            str=[where ' loaded'];  % string to be displayed in the message box
        catch
            Message(sprintf('Cannot load %s', where));
            return;
        end
    case 'var'
        samples=where;
        str='vector loaded'; % string to be displayed in the message box
    otherwise
        return;
end



if isfield(param, 'loop_flg')
    loop_flg=param.loop_flg;
else
    loop_flg=0;
end

if isfield(param, 'seamless')
    if param.seamless==1
        seamless=param.seamless;
    else
        seamless=0;
    end
    if strcmp(get(aotimer, 'running'), 'off')
        start(aotimer)
    end
else
    seamless=0;
end

AOhandle=GetParam(me,'AOhandle'); %grab AOhandle object from param
SoundFs=GetParam(me,'SoundFs'); %sampling rate
numChan=getparam(me, 'numChan'); %number of output channels we initialized the soundcard with
nstimchans=min(size(samples)); %number of channels of requested stimulus (i.e. mono or stereo)
samples=reshape(samples, nstimchans, length(samples)); %ensure samples are a row vector
if seamless
    padlength=0;
else
     padlength=.1*SoundFs; %add 100 ms of silence as a pad at end to avoid truncation
      %padlength=.01*SoundFs; %add 10 ms of silence as a pad at end to avoid truncation
end
silence=zeros(numChan, length(samples)+padlength);
silence(1:nstimchans,1:length(samples))=samples;
samples=silence;

%last channel serves as trigger
trigsamples=zeros(1, length(samples));
triglength=round(SoundFs/1000); %1 ms trigger

%uncomment this line to make the soundcard trigger last as long as the sound
%for example, if you're using the soundcard trigger to drive an LED pulse
%triglength=length(samples);


trigsamples(1:triglength)=.8*ones(size(1:triglength));
%trigsamples(end-triglength+1:end)=-.5*ones(size(1:triglength));
if loop_flg
    trigsamples=0*trigsamples;
    SetParam(me,'samples', samples); %store samples for re-buffering if we're looping (used only for looping)
end
samples(numChan,:)=trigsamples;

if seamless  %note: I haven't upgraded seamless playback to allow >2 channels, i.e. no seamless binaural yet
    if strcmp(get(AOhandle, 'Running'), 'Off') %device not running, need to start it
        str=sprintf('%s\nhad to start it', str);
        putdata(AOhandle, samples');
        start(AOhandle)
    else
        str=sprintf('%s\nalready started', str);
        Message(me, str);
        putdata(AOhandle, samples');
    end
else %this stimulus is not seamless
    if numChan<=2
        putdata(AOhandle, samples');
    else
        AOhandle2=GetParam(me,'AOhandle2'); %grab AOhandle object from param
        putdata(AOhandle, samples(1:2,:)');
        putdata(AOhandle2, samples(3:end,:)');
    end
    nreps=0; %0=repeat
    seamless=0;
end
SetParam(me,'loop_flg', loop_flg); %store loop flag
SetParam(me,'seamless', seamless); %store whether transition should be seamless or not
Message(me, str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlaySound
AOhandle=GetParam(me,'AOhandle'); %grab AOhandle object from param
samples=GetParam(me,'samples'); %get samples (simulus vector)
seamless=GetParam(me,'seamless', 'value'); %whether transition should be seamless or not
loop_flg=GetParam(me,'loop_flg', 'value'); %get loop flag
numChan=getparam(me, 'numChan'); %number of output channels we initialized the soundcard with

if seamless
    %    do nothing, since sound was added to schedule in LoadPPA
else %not seamless
    %start device here, it was filled in Load
    if loop_flg
        if numChan<=2
            set(AOhandle, 'RepeatOutput', Inf)
            start(AOhandle)
        else
            AOhandle2=GetParam(me,'AOhandle2'); %grab AOhandle object from param
            set(AOhandle, 'RepeatOutput', Inf)
            set(AOhandle2, 'RepeatOutput', Inf)
            start([AOhandle AOhandle2])
        end
    else
        if numChan<=2
            start(AOhandle)
        else
            AOhandle2=GetParam(me,'AOhandle2'); %grab AOhandle object from param
            set(AOhandle, 'TriggerType', 'Manual')
set(AOhandle2, 'TriggerType', 'Manual')
            start([AOhandle AOhandle2])
trigger([ AOhandle2; AOhandle])

        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function ShowMyMessage;
global aotimer
AOhandle=GetParam(me,'AOhandle'); %grab AOhandle object from param
samplescued=get(AOhandle, 'SamplesAvailable');
Message(me,sprintf('samples cued: %d',samplescued ), 'append');
if samplescued==0
    stop(aotimer)
    Message(me, 'done', 'append');
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
fig = ModuleFigure(me);
set(fig,'doublebuffer','on','visible','off');

hs = 120;
h = 5;
vs = 50;
n = 1;
% message box
uicontrol('parent',fig,'tag','message','style','text',...
    'enable','inact','horiz','left','pos',[h h hs 2*vs]); n=n+1;
screensize=get(0,'screensize');

uicontrol('parent',fig,'string','Reset','tag','reset','units','normal',...
    'position',[0.02 0.02 0.40 0.20],'enable','on','foregroundcolor',[0.9 0 0],...
    'fontweight','bold',...
    'style','pushbutton','callback',[me ';']);

set(fig,'pos', [screensize(3)-128 screensize(4)-n*vs-100 158 150] ,'visible','on');

Message(me, 'Initialized GUI');
pause(.2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
