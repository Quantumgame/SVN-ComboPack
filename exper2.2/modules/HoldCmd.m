function varargout = HoldCmd( varargin )

%exper2 module for programmatic control of Axopatch 200B external holding commands
%mw 01-06

global exper pref

varargout{1} = lower(mfilename);
if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action

    case 'init'
        ModuleNeeds(me,{'ao','patchpreprocess'});
        SetParam(me,'priority','value',GetParam('ao','priority')+1);
        CreateGUI; %local function that creates ui controls and initializes ui variables

    case 'trialready'

    case 'trialend'

    case 'close'

    case 'reset'

%     case 'set_cmd'
%         % set ao data to a holding potential received from a stimulus
%         % protocol via stimulus czar. include ramp & series pulses.
%         CommandCh = GetParam('patchpreprocess','commandchannel');
%         CommandChobj = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
%         CommandChline = CommandChobj{1}.Index;
%         cmd=getparam(me, 'manual_cmd');
%         nchan=length(exper.ao.daq(1).Channel); %assume only one board
%         cmdvec=zeros(1, nchan);
% %         cmdvec=zeros(size(exper.ao.daq));
%         VClamp_extcmd_factor=20; %20 mV/V factor for V-Clamp ext cmd on the axopatch 200b
%         cmdvec(CommandChline)=cmd/VClamp_extcmd_factor;
%         ao('putsample', cmdvec);
%         Message(me, sprintf('set to %d', cmd))
        
        
    case 'set_manual'
        %manually set ao data to manual_cmd
        CommandCh = GetParam('patchpreprocess','commandchannel');
        CommandChobj = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
        CommandChline = CommandChobj{1}.Index;
        cmd=getparam(me, 'manual_cmd');
        nchan=length(exper.ao.daq(1).Channel); %assume only one board
        cmdvec=zeros(1, nchan);
%         cmdvec=zeros(size(exper.ao.daq));
        VClamp_extcmd_factor=20; %20 mV/V factor for V-Clamp ext cmd on the axopatch 200b
        cmdvec(CommandChline)=cmd/VClamp_extcmd_factor;
        ao('putsample', cmdvec);
        setparam(me, 'set_manual', 0)
        Message(me, sprintf('manually set to %d', cmd))
        
    case 'set_0'
        %manually set ao data to 0
        CommandCh = GetParam('patchpreprocess','commandchannel');
        CommandChobj = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
        CommandChline = CommandChobj{1}.Index;
        cmd=0;
        nchan=length(exper.ao.daq(1).Channel); %assume only one board
        cmdvec=zeros(1, nchan);
%         cmdvec=zeros(size(exper.ao.daq));
        VClamp_extcmd_factor=20; %20 mV/V factor for V-Clamp ext cmd on the axopatch 200b
        cmdvec(CommandChline)=cmd/VClamp_extcmd_factor;
        ao('putsample', cmdvec);
        setparam(me, 'set_0', 0)
        Message(me, 'manually set to 0')

    case 'set_70'
        %manually set ao data to -70
        CommandCh = GetParam('patchpreprocess','commandchannel');
        CommandChobj = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
        CommandChline = CommandChobj{1}.Index;
        cmd=-70;
        nchan=length(exper.ao.daq(1).Channel); %assume only one board
        cmdvec=zeros(1, nchan);
%         cmdvec=zeros(size(exper.ao.daq));
        VClamp_extcmd_factor=20; %20 mV/V factor for V-Clamp ext cmd on the axopatch 200b
        cmdvec(CommandChline)=cmd/VClamp_extcmd_factor;
        ao('putsample', cmdvec);
        setparam(me, 'set_70', 0)
        Message(me, 'manually set to -70')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
fig = ModuleFigure(me,'visible','off');

% GUI positioning factors
hs = 60;
h = 5;
vs = 20;
n = 1;
m = 0;

% message box
uicontrol(fig,'tag','message','style','edit',...
    'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*1]); n = n+1;

% % pushbuttons are little different
% uicontrol('parent',fig,'string','Pushbutton Name','tag','pushbutton_action',...
%     'units','normal','position',[0.45 0.075 0.1 0.05],...
%     'style','pushbutton','callback',[me ';']);




v_height=-10;
InitParam(me,'v_height',...
    'value',v_height,...
    'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs]);
n=n+1;
v_width=50;
InitParam(me,'v_width',...
    'value',v_width,'range',[26 Inf],...
    'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs],'save',1);

n=n+1;
v_onset=500;
InitParam(me,'v_onset',...
    'value',v_onset,'range',[26 Inf],...
    'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs],'save',1);

n=n+1;

Mode = GetParam('patchpreprocess','mode');
InitParam(me,'mode',...
    'value',Mode{:},'save', 1, ...
    'ui','disp','pos',[h+m*2*(hs+h) n*vs hs vs]);
n=n+1;

npulses=10;
InitParam(me, 'npulses', 'value', npulses, 'save', 1)

manual_cmd=-70;
InitParam(me,'manual_cmd',...
    'value',manual_cmd,'ui','edit', 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0);
n=n+1;

InitParam(me,'set_manual',...
    'value',0,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0);
SetParamUI(me,'set_manual','background',[.8 .8 .8],'label','');
n=n+1;

rampdur=1;
InitParam(me,'rampdur',...
    'value',rampdur,...
    'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs]);
n=n+1;

InitParam(me,'set_0',...
    'value',0,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0);
SetParamUI(me,'set_0','background',[.8 .8 .8],'label','');
n=n+1;

InitParam(me,'set_70',...
    'value',0,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0);
SetParamUI(me,'set_70','background',[.8 .8 .8],'label','');
n=n+1;

set(fig,'pos',[163 646 128 n*vs]);
% Make figure visible again.
set(fig,'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%