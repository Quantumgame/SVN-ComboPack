function varargout = AI(varargin)
% AI
% A module for analog input
% The hwtrigger input pin for AI on a National Instruments board is PFI0/TRIG1
%
% AI('start')
% AI('pause')
%
% ZFM, CSHL 10/00
%
global exper pref

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action

    case 'init'
        % AI goes last so that other modules can access it's data before
        % it is cleared for the next trial
        SetParam(me,'priority',3);
        fig = ModuleFigure(me,'visible','off');

        hs = 60;
        h = 5;
        vs = 20;
        n = 0;

        find_boards; %finds DAQ boards with AI and sets up the Board menu

        hf = uimenu(fig,'label','Chan','tag','channel');
        hf = uimenu(fig,'label','Scope','tag','scope');

        % 	InitParam(me,'SampleRate','ui','edit','value',10000,'pos',[h n*vs hs vs]); n=n+1;
        % 	InitParam(me,'HWTrigger','ui','checkbox','value',0,'pos',[h n*vs hs vs]); n = n+1;
        %   	InitParam(me,'Save','ui','togglebutton','value',1,'pos',[h n*vs hs vs]); n=n+1;
        % 	SetParamUI(me,'Save','string','Save','background',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold','label','','pref',0);
        %
        % 	% message box
        % 	uicontrol(fig,'tag','message','style','edit',...
        % 		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n = n+1;
        InitParam(me,'SampleRate','ui','edit','value',10000,'units','normal','pos',[0.02 0.02 0.45 0.32]);
        InitParam(me,'Save','ui','togglebutton','value',1,'units','normal','pos',[0.02 0.34 0.48 0.32]);
        SetParamUI(me,'Save','string','Save','background',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold','label','','pref',0);
        InitParam(me,'HWTrigger','ui','togglebutton','String','HWTrig','value',0,'units','normal','pos',[0.5 0.34 0.48 0.32],...
            'backgroundcolor',[0 0 1],'foregroundcolor',[1 1 1],'fontweight','bold');

        % message box
        uicontrol(fig,'tag','message','style','edit','units','normal',...
            'enable','inact','horiz','left','pos',[0.02 0.66 0.96 0.32]);

        n=n+3;
        set(fig,'pos',[5 461-n*vs 128 n*vs],'visible','on');

        % now initialize the data acquisition board (nidaq in our case)
        boardn=daqhwinfo('nidaq', 'BoardNames');
        v=ver('daq'); %daq toolbox version number
        if str2num(v.Version) >= 2.12
            %mw 08.28.08
            %new version of matlab uses nidaqmx rather than nidaq_trad driver
            switch boardn{1} %mw 04.18.06
                case 'PCI-6052E'
                    board_open('nidaq','Dev1');
                case 'PCI-6289'
                    board_open('nidaq','Dev1'); %mw 12.16.05
            end
        else %assume old version of matlab
            switch boardn{1} %mw 04.18.06
                case 'PCI-6052E'
                    board_open('nidaq',1);
                case 'PCI-6289'
                    board_open('nidaq','Dev1'); %mw 12.16.05
            end
        end

        % add some channels to the AI object
        for n=1:length(pref.ai_channels);
            if strcmpi(pref.ai_channels(n).status,'permanent')  % add only permanent channels
                add_chan(pref.ai_channels(n).number,pref.ai_channels(n).name); %add_chan is a local function
            end
        end

        AIHwChannels=exper.ai.daq.Channel.HwChannel;
        if iscell(AIHwChannels)
            AIHwChannels=[AIHwChannels{:}];
        else
            AIHwChannels=[AIHwChannels];
        end
        AIChannelIdx=exper.ai.daq.Channel.Index;
        if iscell(AIChannelIdx)
            AIChannelIdx=[AIChannelIdx{:}];
        else
            AIChannelIdx=[AIChannelIdx];
        end
        InitParam(me,'AIChannels','value',[AIHwChannels; AIChannelIdx]);

        % and finally set the range for the channels
        % note: the range for the Axopatch Data channel is later scaled by
        % PatchPreProcess
        daqrange=[-10 10];
        exper.ai.daq.Channel.InputRange=daqrange;
        exper.ai.daq.Channel.UnitsRange=daqrange;
        exper.ai.daq.Channel.SensorRange=daqrange;

    case 'getready'
        ai_trial_ready;

    case 'trialend'
        % 	if getparam('control','SliceRate') == 0
        % 		get_ai_trial_data;
        % 	end
        % 	%update_trial_plots;

    case 'close'
        close_all_ai;

        % handle UI parameter callbacks

    case 'reset'
        ai_pause;
        stop(exper.ai.daq);
        flushdata(exper.ai.daq);
        Message(me,'');

    case 'save'
        if nargin > 1
            SetParam(me,'save',varargin{2});
        end
        ai_pause;
        if GetParam(me,'save')
            set(exper.ai.daq,'loggingmode','disk&memory');
            set(exper.ai.daq,'logtodiskmode','overwrite');
            SetParamUI(me,'save','background',[0 1 1],'foregroundcolor',[0 0 1]);
        else
            set(exper.ai.daq,'loggingmode','memory');
            SetParamUI(me,'save','background',[0.1 0 0.9],'foregroundcolor',[1 1 1]);
        end

    case 'hwtrigger'
        if GetParam(me,'HWTrigger')
            SetParamUI(me,'HWTrigger','backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1]);
        else
            SetParamUI(me,'HWTrigger','backgroundcolor',[0 0 1],'foregroundcolor',[1 1 1]);
        end
        ai_pause;                   % stops AI
        set_hwtrigger(exper.ai.daq);% sets hardware trigger
        ai_trial_ready;             % starts AI again

    case 'samplerate'
        if nargin >= 2
            SetParam(me, 'SampleRate', varargin{2});
        end
        ai_pause;

        % the following could be(?) used to monitor the data acquisition = call
        % something after a specified number of samples?
        % 	exper.ai.daq.SamplesAcquiredFcnCount = GetParam(me,'SamplesPerTrial');
        exper.ai.daq.SampleRate = GetParam(me,'SampleRate');
        SetParam(me,'SampleRate',exper.ai.daq.SampleRate);
        %	exper.ai.daq.SamplesPerTrigger = GetParam(me,'SamplesPerTrial');
        exper.ai.daq.SamplesPerTrigger=inf;
        ai_trial_ready;

    case 'end'
        SetParam(me,'EndExp',1);

    case 'ai_board_menu'
        % opens or closes DAQ board, based on what the user decided to do:-)
        name = get(gcbo,'user');
        if strcmp(name(1:5),'nidaq')
            adaptor = name(1:5);
            id = str2num(name(6));
        else
            adaptor = name(1:8);
            id = str2num(name(9));
        end
        if strcmp(get(gcbo,'checked'),'on')
            close_ai(adaptor,id);
        else
            open_ai(adaptor,id);
        end

    case 'chan_menu'
        if strcmp(get(gcbo,'checked'),'on')
            del_chan(get(gcbo,'user'));
            set(gcbo,'checked','off');
        else
            chan = get(gcbo,'user');
            ok = add_chan(get(gcbo,'user'));
            if ok
                set(gcbo,'checked','on');
            end
        end

        % implement external functions

    case 'board_open'
        % ai('board_open',adaptor,id)
        % adaptor is 'nidaq' or 'winsound'
        adaptor=varargin{2};
        id=varargin{3};
        [board, nchan]=board_open(adaptor,id);
        varargout{1}=board;
        varargout{2}=nchan;

    case 'board_close'
        % ao('board_close',adaptor,id)
        % adaptor is 'nidaq' or 'winsound'
        close_ai(varargin{2},varargin{3})

    case 'pause'
        ai_pause;

    case 'start'
        ai_start;

    case 'add_chan'
        % ADDCHAN(HWCHAN, NAME)
        % Initialize an analog input channel.
        hwchan=varargin{2};
        name=varargin{3};
        add_chan(hwchan,name);

    case 'del_chan'
        % AI('del_chan', HWCHAN)
        % Delete a channel.
        hwchan=varargin{2};
        del_chan(hwchan);

    case 'epathchange'
        if nargin<2
            return;
        end
        if strcmpi(varargin{2},'datapath')     % datapath has changed, we have to change the data filename
            ai_trial_ready;
        end

    case 'getsamplerate'
        varargout(1)={GetParam(me,'SampleRate')};

    case 'gethwchannel'
        if nargin<2
            return;
        end
        inchannel=varargin{2};
        aichannels=GetParam(me,'AIChannels');
        nchannels=length(inchannel);
        outchannel=zeros(1,nchannels);
        for k=1:nchannels
            idx=find(aichannels(2,:)==inchannel(k));
            if isempty(idx)
                varargout(1)={-1};
                return;
            end
            outchannel(k)=aichannels(1,idx);
        end
        varargout(1)={outchannel};

    case 'getchannelidx'
        if nargin<2
            return;
        end
        inchannel=varargin{2};
        aichannels=GetParam(me,'AIChannels');
        nchannels=length(inchannel);
        outchannel=zeros(1,nchannels);
        for k=1:nchannels
            idx=find(aichannels(1,:)==inchannel(k));
            if isempty(idx)
                varargout(1)={-1};
                return;
            end
            outchannel(k)=aichannels(2,idx);
        end
        varargout(1)={outchannel};


    otherwise
end

% begin local functions

%%%%%
function out = me
out = lower(mfilename);
%%%%%

%%%%%
function out = callback
out = [lower(mfilename) ';'];
%%%%%

%%%%%
function find_boards
% looks for available DAQ boards with AI capabilities and creates the
% corresponding menu in AI
fig=findobj('type','figure','tag','ai');
hf=uimenu(fig,'label','Board','tag','board');
delete(findobj('parent',hf));	% kill existing labels

a=daqhwinfo;
adaptors = a.InstalledAdaptors;

for n=1:length(adaptors)
    try %parallel adaptor causes error on 64-bit windows, this way we skip it. mw 08.25.09
        b=daqhwinfo(adaptors{n});
        names=b.BoardNames;
        ids=b.InstalledBoardIds;
        for p=1:length(names)
            % this condition makes sure there is an analoginput for this board
            if ~isempty(b.ObjectConstructorName{p,1})
                namestr=sprintf('%s%s-AI',adaptors{n},ids{p});
                label=sprintf('    %s (%s)',namestr,names{p});
                uimenu(hf,'tag','ai_board_menu','label',label,'user',namestr,'callback',callback);
            end
        end
    end
end
%%%%%

%%%%%
function [board, nchan]=board_open(adaptor,id)
global exper pref
board=open_ai(adaptor,id);
if board>0
    nchan=length(exper.ai.daq(board).Channel);
else
    nchan=0;
end
%%%%%

%%%%%
function close_all_ai
% user wants to close all (AI) boards
global exper pref
if ~isfield(exper.ai,'daq')
    return
end
daq=exper.ai.daq;
for n=1:length(daq)
    if length(daq)>1
        d=daqhwinfo(daq(n));
    else
        d=daqhwinfo(daq);
    end
    if strcmp(d.SubsystemType,'AnalogInput')
        adaptor=d.AdaptorName;
        id=str2num(d.ID);
        close_ai(adaptor,id);
    end
end
%%%%%

%%%%%
function close_ai(adaptor,id)
% closes (AI) board with a given adaptor and id
global exper pref
boardname=sprintf('%s%d-AI',adaptor,id);
ai=daqfind('name',boardname);
if isempty(ai)
    Message(me,'Board not open')
end
for n=1:length(ai)
    if strcmp(get(ai{n},'running'),'On')
        stop(ai{n});
    end
    k=length(exper.ai.daq);
    while k>=1
        if strcmp(exper.ai.daq(k).name,boardname)
            if length(exper.ai.daq)>1
                exper.ai.daq(k)=[];
            else
                exper.ai=rmfield(exper.ai,'daq');
            end
        end
        k=k-1;
    end
    delete(ai{n});
    % foma 2005/02/16
    clear ai{n};
    Message(me,sprintf('%s closed',boardname));
end
board_menu_labels;
% get rid of those pesky lines!
delete(findobj('type','line','tag',me));
%%%%%

%%%%%
function board=open_ai(adaptor,id)
global exper pref
% for now, just allow a single ai
if isfield(exper.ai,'daq')
    close_all_ai;
end
board=0;


%             boardname=sprintf('%s',adaptor,id,'mx-AI');
boardname=sprintf('%s%d-AI',adaptor,id);
if isfield(exper.ai,'daq')
    for n=1:length(exper.ai.daq)
        if strcmp(exper.ai.daq(n).Name,boardname)
            Message(me,'Already initialized');
            board=n;
            board_menu_labels;
            return
        end
    end
end


if ~strcmp(adaptor,'nidaq') & ~strcmp(adaptor,'winsound')
    Message(me,'nidaq and winsound are valid');
    return
end

boardn=daqhwinfo('nidaq', 'BoardNames');
v=ver('daq'); %daq toolbox version number
if str2num(v.Version) >= 2.12
    %mw 08.28.08
    %new version of matlab refers to devices differently
%     switch boardn{1} %mw 04.18.06
%         case 'PCI-6052E'
            %                     boardinit=sprintf('analoginput(''%s'',%d)',adaptor,id);
            boardinit=sprintf('analoginput(''%s'',''%s'')',adaptor,id);
%         case 'PCI-6289'
%             boardinit=sprintf('analoginput(''%s'',''%s'')',adaptor,id); %mw 12.16.05
%     end
else %assume old version of matlab
    switch boardn{1} %mw 04.18.06
        case 'PCI-6052E'
            boardinit=sprintf('analoginput(''%s'',%d)',adaptor,id);
        case 'PCI-6289'
            boardinit=sprintf('analoginput(''%s'',''%s'')',adaptor,id); %mw 12.16.05
    end
end


ai=eval(boardinit);

ai.SampleRate=GetParam(me,'SampleRate');
% REPLACE THIS WITH WHAT????
%ai.SamplesAcquiredFcnCount = GetParam(me,'SamplesPerTrial');
% 	ai.SamplesAcquiredFcn='ai_handler';
ai.TriggerFcn={'ai_trig_handler'};
%ai.SamplesPerTrigger=GetParam(me,'SampleRate')/10; % 100ms per trigger
ai.SamplesPerTrigger=inf;   % continuous acquisition
%ai.TriggerRepeat=0;
ai.TriggerRepeat=inf;         % MANY triggers

if GetParam(me,'save')
    set(ai,'loggingmode','disk&memory');
    set(ai,'logtodiskmode','overwrite');
else
    set(ai,'loggingmode','memory');
end

%get the type of input types the board likes
inputs=propinfo(ai, 'InputType');
%if its possible to set the InputType to SingleEnded, then do it
% 2004/11/10 - foma - I talked to Mike Wehr, and decided to switch to
% differential
% We're going to use differential inputs
% see also open_ai above
% 	if ~isempty(find(strcmpi(inputs.ConstraintValue, 'SingleEnded')))
% 		ai.InputType='SingleEnded';
% 	end

h=daqhwinfo(ai);
SetParam(me,'samplerate','range',[h.MinSampleRate h.MaxSampleRate]);
exper.ai.daq=ai;
set_hwtrigger(ai);
chan_menu(ai);
Message(me,sprintf('%s initialized',ai.name));
board_menu_labels;
ai_trial_ready;
%%%%%

%%%%%
function board_menu_labels
% creates AI Board submenu
global exper pref
menuitems=findobj('tag','ai_board_menu');
for n=1:length(menuitems)
    label=get(menuitems(n),'label');
    label(1:2)='  ';
    set(menuitems(n),'checked','off','label',label);
end

if isfield(exper.ai,'daq')
    for n=1:length(exper.ai.daq)
        menuitem=findobj('tag','ai_board_menu','user',exper.ai.daq(n).name);
        label=get(menuitem,'label');
        label(1:2)=sprintf('%d:',n);
        set(menuitem,'checked','on','label',label);
    end
end
% function board_menu_labels
%%%%%

%%%%%
function chan_menu(ai)
% creates the Chan and Scope submenus in AI
global exper pref
hf=findobj('type','uimenu','tag','channel');
hf2=findobj('type','uimenu','tag','scope');
delete(findobj('parent',hf2));
delete(findobj('parent',hf));
a=daqhwinfo(ai);
chan=a.SingleEndedIDs;
for n=1:length(chan)
    hw=chan(n);
    ch=daqfind(ai,'HwChannel',hw);
    mh=uimenu(hf,'tag','chan_menu','user',hw,'callback',callback);  % callback is a local function
    if ~isempty(ch)
        name=get(ch{1},'ChannelName');
        str=sprintf('Ch %d: %s',hw,name);
        set(mh,'checked','on','label',str);
        uimenu(hf2,'tag','scope_menu','label',str,'user',hw,'callback',callback);  % callback is a local function
    else
        str=sprintf('Ch %d',hw);
        set(mh,'checked','off','label',str);
    end
end
%%%%%

%%%%%
function out=add_chan(HWChan, name)
% adds channel 'HWChan' with 'name'
global exper pref
if GetParam('control','Run')
    ai_pause;
end
cancelled=0;
hw=daqfind(exper.ai.daq,'HWchan',HWChan);
if isempty(hw)
    if nargin<2
        board=exper.ai.daq.name;
        prompt='Enter channel name:';
        dtitle=sprintf('Add AI channel %d to %s',HWChan,board);
        default=sprintf('Chan %d',HWChan);
        lineno=[1 25];
        n=inputdlg(prompt,dtitle,lineno,{default});
        if ~isempty(n)
            name=n{1};
        else
            cancelled=1;
        end
    end
    if cancelled
        out=0;
        return;
    else
        channel=addchannel(exper.ai.daq,HWChan,name);
        out=1;
        Message(me,sprintf('Chan %d added',HWChan));
    end
else
    Message(me,sprintf('Chan %d already added',HWChan),'error');
    out=0;
    return;
end
chan_menu(exper.ai.daq);
% n = length(exper.ai.daq.channel);
% exper.ai.data = zeros(GetParam(me,'SamplesPerTrial'),n);
%%%%%

%%%%%
function del_chan(HWChan)
% deletes channel HWChan
global exper pref
ai_pause;
ch = daqfind('HWchan',HWChan);
if isempty(ch)
    Message(me,sprintf('Ch %d: no such channel to delete',HWChan));
    return;
end
delete(ch{1});
Message(me,sprintf('Chan %d deleted',HWChan));
chan_menu(exper.ai.daq);
n = length(exper.ai.daq.channel);
%exper.ai.data = zeros(GetParam(me,'SamplesPerTrial'),n);
%%%%%

%%%%%
function ai_trial_ready
% prepares new trial and starts AI if it's already running
% also sets the logfilename (saved data) according to the control module
% parameters
global exper pref
fname=Control('GetDataFileName');
if strcmp(exper.ai.daq.running,'On')
    stop(exper.ai.daq);
    set(exper.ai.daq,'logfilename',fname);
    start(exper.ai.daq);
else
    set(exper.ai.daq,'logfilename',fname);
end
%function ai_trial_ready
%%%%%

%%%%%
function ai_pause
% stops AI. If the data is still being acquired (logging on) this
% subroutine just displays a Message in control because it knows it will be
% called again when the trial is over.
% In continuous acquisition it should stop logging and stop AI
% It should also avoid setting parameters of a different module, especially
% control!!!
global exper pref
if ~isfield(exper.ai,'daq') return; end

if strcmp(exper.ai.daq.running,'On')
    stop(exper.ai.daq);
    % 	else
    % 		SetParamUI('control','run','Background',get(gcf,'color'));
end
% function ai_pause
%%%%%

%%%%%
function ai_start
% starts AI (if i's initialized). If AI doesn't want a hardware trigger, it's triggered from here, otherwise it waits
global exper pref
if isempty(exper.ai.daq.channel)
    Message(me,'Can''t start acquisition until channels are added!','error');
    SetParam('control','run',0);
else
    if ~strcmp(exper.ai.daq.running,'On')
        start(exper.ai.daq);
        if ~GetParam(me,'hwtrigger')
            trigger(exper.ai.daq);
            while ~get(exper.ai.daq, 'TriggersExecuted') %trying to solve ai-not-triggering bug. mw 071106
                trigger(exper.ai.daq);
            end
        else
            Message(me,'Waiting for hw trigger...');
        end
        %    		SetParam('control','run',1);
        %    		SetParamUI('control','run','background',[0 0 0]);
    end
end
%function ai_start
%%%%%

%%%%%
function set_hwtrigger(board)
global exper pref
%if its possible to set the Trigger to HwDigital, then do it
inputs=propinfo(board, 'TriggerType');

if GetParam(me,'hwtrigger')
    board.TriggerType='HwDigital';
else
    board.TriggerType='Manual';
end


% 	if isempty(find(strcmp(inputs.ConstraintValue, 'HwDigital')))
% 		SetParamUI(me,'hwtrigger','enable','off');
% 		SetParam(me,'hwtrigger','value',0,'range',[0 0]);
%         board.TriggerType='Manual';
% 	else
% 		SetParamUI(me,'hwtrigger','enable','on');
% 		SetParam(me,'hwtrigger','range',[0 1]);
%         board.TriggerType='HwDigital';
% 	end
% 	Message(me,sprintf('%s trigger',exper.ai.daq.triggertype));
%function set_hwtrigger(board)
%%%%%

function board=open_trigerai(adaptor,id)
global exper pref
% for now, just allow a single ai
% 	if isfield(exper.ai,'triggerdaq')
%         close_all_trigger_ai;
%     end
board=0;
boardname=sprintf('%s%d-AI',adaptor,id);
if isfield(exper.ai,'triggerdaq')
    for n=1:length(exper.ai.triggerdaq)
        if strcmp(exper.ai.triggerdaq(n).Name,boardname)
            Message(me,'Already initialized');
            board=n;
            return
        end
    end
end
if ~strcmp(adaptor,'nidaq') & ~strcmp(adaptor,'winsound')
    Message(me,'nidaq and winsound are valid');
    return
end
boardinit=sprintf('analoginput(''%s'',%d)',adaptor,id);
ai=eval(boardinit);
ai.SampleRate=GetParam(me,'SampleRate');
% REPLACE THIS WITH WHAT????
%ai.SamplesAcquiredFcnCount = GetParam(me,'SamplesPerTrial');
%	ai.SamplesAcquiredFcn='ai_handler';
%	ai.TriggerFcn={'ai_trig_handler'};
%	ai.SamplesPerTrigger=GetParam(me,'SampleRate')/100; % 10ms per trigger
ai.SamplesPerTrigger=inf;
ai.TriggerRepeat=inf;         % MANY triggers
if GetParam(me,'save')
    set(ai,'loggingmode','disk&memory');
    set(ai,'logtodiskmode','overwrite');
else
    set(ai,'loggingmode','memory');
end
%get the type of input types the boards likes
inputs=propinfo(ai, 'InputType');
%if its possible to set the InputType to SingleEnded, then do it
% 2004/11/10 - foma - I talked to Mike Wehr, and decided to switch to
% differential
% We're going to use differential inputs
% see also open_ai above
% 	if ~isempty(find(strcmpi(inputs.ConstraintValue, 'SingleEnded')))
% 		ai.InputType='SingleEnded';
% 	end


h=daqhwinfo(ai);
SetParam(me,'samplerate','range',[h.MinSampleRate h.MaxSampleRate]);
ai.TriggerType='HwDigital';
exper.ai.triggerdaq=ai;
Message(me,sprintf('%s initialized',ai.name));
ai_trial_ready;
%%%%%
