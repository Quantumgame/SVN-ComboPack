function out=SoundLoad(varargin)

% simple module that loads data to SoundMachine (realtime linux box), either from a file or from a
% variable
%
% SoundLoadSM('load','file',some_COMPLETE_file_name) : Just try to pass the
% COMPLETE (ie with the full path) file name. Partial file name is usually
% sufficient, but you just cannot assume it would ALWAYS work
%
% SoundLoadSM('load','var',variable) : The variable is a vector at some
% sampling rate.
%
% fs=SoundLoadSM('samplerate'); : Returns samplerate. ALL MODULES
% using SoundLoadSM should check this and use it!
%??? rp2=SoundLoadSM('rp2object'); : Returns an RP2 object used by SoundLoad.
%
%??? SoundLoadSM('sethwtrigger'): enables hardware trigger
%

global exper pref

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
    case 'init'
        %     ModuleNeeds(me,{'rp2control'}); % needs RP2Control to find out how to talk to RP2
        SetParam(me,'priority',GetParam('stimulusprotocol','priority')+1);
        InitializeGUI;                  % show the gui = message box:-)
        InitSM;                        % Initialize soundmachine

    case 'reset'
        InitSM;

    case 'esealteston'
        InitSM; %clear any previously loaded sound from buffer so sealtest doesn't trigger it %mw 111406

    case 'estimulusprotocolchanged'
        InitSM; %clear any previously loaded sound from buffer so non-sound stimuli don't trigger it %mw 111706

        
    case 'load'
        if nargin<3
            return;
        end
        try
            if nargin==4
                LoadSM(varargin{2},varargin{3},varargin{4});
            else
                param.channel=1;
                LoadSM(varargin{2},varargin{3},param); % first channel is the default channel
            end
        catch
            Message(me,'Cannot load sound');
        end

    case 'samplerate'
        out=GetParam(me,'SoundFs');

    case 'smobject'
        out=GetParam(me,'SM');

    case 'sethwtrigger'
        %     sm=GetParam(me,'SM');
        %     if nargin>1
        %         channel=varargin{2};   % channel should be the second argument
        %     end
        %     if isempty(channel)             % if no channel is specified, set up all
        %         invoke(rp2,'SoftTrg',1);    % channel 1
        %         invoke(rp2,'SoftTrg',2);    % channel 2
        %     else
        %         invoke(rp2,'SoftTrg',channel);  % start specific channel
        %     end

    case 'setchannel'
        %     sm=GetParam(me,'SM');
        %     channel=[];
        %     if nargin>1
        %         channel=str2num(varargin{2});   % channel should be the second argument
        %     end
        %     if isempty(channel)
        %         channel=1;                      % if there are no arguments, or the second argument is not a number, let's make it 1
        %     end
        %     invoke(rp2,'SetTagVal','channel',channel); % set the output channel
        %     Message(me,['Channel set: ' num2str(channel)]);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitSM
global exper pref
if ExistParam(me,'SM') % take the existing ActiveX control
    sm=GetParam(me,'SM');
else
    hostname='192.168.0.2';
%    hostname='128.223.140.212'; %cornkix 060107
%    hostname='128.223.140.135'; %deepsix
    port=3334;
    sm = RTLSoundMachine(hostname, port);
    if isempty(sm)
        Message(me,'Can''t create sm object...');
        return;
    end
    InitParam(me,'SM','value',sm); %param to hold the RP2 activex object
end

Initialize(sm);

Message(me, 'Initialized SM');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadSM(type,where,param)
% loads data to soundmachine. type can be either 'file' or 'var'
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

if isfield(param,'channel')
    channel=param.channel(1);
else
    channel=1;  % default channel
end

%grab soundmachine object from param
sm=GetParam(me,'SM');
%SoundFs=GetParam(me,'SoundFs'); %sampling rate not used mw 051607

% load sound to soundmachine.
if isfield(param, 'triggernum')
    triggernum=param.triggernum;
else
    triggernum=1;
end

%loop_flg: if true, the sound should loop indefinitely whenever it is triggered, otherwise it will play only once for each triggering.
if isfield(param, 'loop_flg')
    loop_flg=param.loop_flg;
else
    loop_flg=0;
end

side='both';
stop_ramp_tau_ms=20;
predelay_s=0; % time in seconds to pre-delay the playing of the sound when triggering
samples=reshape(samples, 1, length(samples)); %ensure samples are a row vector
%sm=SetSampleRate(sm, 96000);
%sm=SetSampleRate(sm, 200000); %mw 060606 Warning: For now, RTLSoundMachine is limited to a sample rate of 200kHz only!  Please fix your code!
%sampling rate not used mw 051607
sm=LoadSound(sm, triggernum, samples, side, stop_ramp_tau_ms, predelay_s, loop_flg);

Message(me, str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
fig = ModuleFigure(me);
set(fig,'doublebuffer','on','visible','off');

hs = 120;
h = 5;
vs = 20;
n = 0;
% message box
uicontrol('parent',fig,'tag','message','style','text',...
    'enable','inact','horiz','left','pos',[h n*vs hs vs]); n=n+1;
screensize=get(0,'screensize');
set(fig,'pos', [screensize(3)-128 screensize(4)-n*vs-120 128 n*vs] ,'visible','on');
%InitParam(me,'SoundFs','value',96000);        % stores sound sample rate we use
InitParam(me,'SoundFs','value',200000); %mw 060606       % stores sound sample rate we useInitParam(me,'SoundFs','value',96000);        % stores sound sample rate we use
Message(me, 'ready');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
