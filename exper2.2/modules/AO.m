function varargout = AO(varargin)
% AO
% A module for analog output
%
% The hwtrigger input pin for AO on a National Instruments board is PFI6
%
%
% SL Macknik, 9/00
% ZF Mainen 10/00
%

global exper pref

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action

    case 'init'
        % ao is called right before ai
        SetParam(me,'priority',2);
        ModuleNeeds(me,{'ai'});

        fig=ModuleFigure(me,'visible','off');
        hs=60;
        h=5;
        vs=20;
        n=0;

        % find available DAQ boards with AO capabilities and create the
        % corresponding menus
        find_boards;

        % Duration is new. AO now uses different 'trial duration' than AI (AI
        % goes on forever...)
        % 	InitParam(me,'Duration','ui','edit','value',1,'pos',[h n*vs hs vs]); n=n+1;
        % 	InitParam(me,'SampleRate','ui','edit','value',10000,'pos',[h n*vs hs vs]); n=n+1;
        % 	InitParam(me,'HwTrigger','ui','checkbox','value',1,'pos',[h n*vs hs vs]); n = n+1;
        %
        % 	InitParam(me,'Send','ui','togglebutton','value',1,'pos',[h n*vs hs vs]);
        % 	SetParamUI(me,'Send','string','Send','background',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold','label','','pref',0);
        % 	% reset
        % 	uicontrol('parent',fig,'string','Reset','tag','reset','style','pushbutton',...
        % 		'callback',[me ';'],'foregroundcolor',[.9 0 0],'pos',[h+hs n*vs hs vs]); n=n+1;
        % 	% message box
        % 	uicontrol('parent',fig,'tag','message','style','edit',...
        % 		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;

        % foma - 2004/07/29 - I changed the duration from edit ui control to a normal parameter
        % 	InitParam(me,'Duration','ui','edit','value',1,'units','normal','pos',[0.02 0.02 0.55 0.19]);
        InitParam(me,'Duration','value',1);
        InitParam(me,'SampleRate','ui','edit','value',10000,'units','normal','pos',[0.02 0.02 0.45 0.24]);
        % reset
        uicontrol('parent',fig,'string','Reset','tag','reset','style','pushbutton',...
            'callback',[me ';'],'foregroundcolor',[.9 0 0],'fontweight','bold','units','normal','pos',[0.02 0.26 0.48 0.24]);
        InitParam(me,'Send','ui','togglebutton','value',1,'units','normal','pos',[0.02 0.50 0.48 0.24]);
        SetParamUI(me,'Send','string','Send','background',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold','label','','pref',0);
        InitParam(me,'HwTrigger','ui','togglebutton','String','HWTrig','pref',0,'value',1,'units','normal','pos',[0.50 0.50 0.48 0.24],...
            'backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold');
        % message box
        uicontrol('parent',fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[0.02 0.74 0.96 0.24]);

        n=n+4;
        set(fig,'pos',[5 234 128 n*vs],'visible','on');

        % and now we open AO board
        boardn=daqhwinfo('nidaq', 'BoardNames');
        v=ver('daq'); %daq toolbox version number
        %mw 08.28.08  new version of matlab refers to devices differently
        if str2num(v.Version) >= 2.12
            board_open('nidaq','Dev1');
        else %assume old version of matlab
            switch boardn{1} %mw 04.18.06
                case 'PCI-6052E'
                    board_open('nidaq',1);
                case 'PCI-6289'
                    board_open('nidaq','Dev1'); %mw 12.16.05
            end
        end
        reset_ao_data;

        AOHwChannels=exper.ao.daq.Channel.HwChannel;
        if iscell(AOHwChannels)             % we have multiple channels
            AOHwChannels=[AOHwChannels{:}];
        else
            AOHwChannels=[AOHwChannels];
        end
        AOChannelIdx=exper.ao.daq.Channel.Index;
        if iscell(AOChannelIdx)
            AOChannelIdx=[AOChannelIdx{:}];
        else
            AOChannelIdx=[AOChannelIdx];
        end
        InitParam(me,'AOChannels','value',[AOHwChannels; AOChannelIdx]);


    case 'getready'
        if GetParam(me,'Send')
            % get rid of extra cued AO samples!
            if get(exper.ao.daq(1),'samplesavailable')>0
              %  start(exper.ao.daq); %mw 06-10-10
              %  stop(exper.ao.daq); %mw 06-10-10
            end
            %  		for n=1:length(exper.ao.daq)
            %             if ~isempty(exper.ao.data{n});
            %  			    putdata(exper.ao.daq(n),exper.ao.data{n});
            %             end
            %         end
        end

    case 'close'
        if ~isfield(exper.ao,'daq')
            return
        end
        for n=1:length(exper.ao.daq)
            %this hack prevents ao('close') from crashing if daqfind returns multiple ao objects
            %(which will happen if sealtest is running, since it has its own ao object!) mw 101801
            temp=daqfind('name',exper.ao.daq(n).name);
            if length(temp)==1
                dev(n)=daqfind('name',exper.ao.daq(n).name);
            elseif length(temp)==2 %if sealtest's ao object exists too
                dev{n}=temp{1};
            else error('hack didn''t work. mw 101801')
            end
        end
        for n=1:length(dev)                         % first, stop if AO is running
            if strcmp(get(dev{n},'Running'),'On')
                stop(dev{n});
            end
            delete(dev{n});                         % then delete it
        end
        exper.ao=rmfield(exper.ao,'daq');           % and remove the reference from the exper structure

        % deal with UI callbacks

    case 'ao_board_menu'
        % Board menu calback. Opens or closes AO depending on what you choose:-)
        name = get(gcbo,'user');
        if strcmp(name(1:5),'nidaq')        % we have nidaq
            adaptor = name(1:5);
            id = str2num(name(6));
        else                                % or winsound
            adaptor = name(1:8);
            id = str2num(name(9));
        end
        if strcmp(get(gcbo,'checked'),'on')
            close_ao(adaptor,id);
        else
            open_ao(adaptor,id);
        end

    case 'reset'
        % a simple start/stop clears the cue
        if ~isvalid(exper.ao.daq)
            return
        end
        if strcmp(exper.ao.daq(1).running,'On')
            stop(exper.ao.daq);
        end
        reset_ao_data;
        
    case 'really_reset'
        % trying a more hard-core reset that really clears ao data
        if ~isvalid(exper.ao.daq)
            return
        end
        if strcmp(exper.ao.daq(1).running,'On')
            stop(exper.ao.daq);
        end
        really_reset_ao_data;

    case 'hwtrigger'
        if GetParam(me,'HWTrigger')
            SetParamUI(me,'HWTrigger','backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1]);
        else
            SetParamUI(me,'HWTrigger','backgroundcolor',[0 0 1],'foregroundcolor',[1 1 1]);
        end

        ao_pause;       %stops AO
        for n=1:length(exper.ao.daq)
            set_hwtrigger(exper.ao.daq(n)); % local function: sets the trigger to hardware, if possible
        end

    case 'samplerate'
        if nargin>=2
            SetParam(me,'SampleRate',varargin{2});
        end
        ao_pause;   %stops AO
        set(exper.ao.daq,'SampleRate',GetParam(me,'SampleRate')); % sets the sampling rate
        SetParam(me,'SampleRate',exper.ao.daq(1).SampleRate);     % and reads the real sampling rate
        reset_ao_data;  % resets AO (flushes and zeroes the data)

    case 'duration'
        if nargin>=2
            SetParam(me,'Duration',varargin{2});
        end
        ao_pause;   %stops AO
        reset_ao_data;  % resets AO (flushes and zeroes the data)



    case 'send'
        if nargin>1
            SetParam(me,'send',varargin{2});
        end
        if GetParam(me,'send')
            SetParamUI(me,'send','background',[0 1 1],'foregroundcolor',[0 0 1]);
        else
            SetParamUI(me,'send','background',[0.1 0 0.9],'foregroundcolor',[1 1 1]);
        end

        % implement external functions

    case 'start'
        ao_start;

    case 'board_open'
        % ao('board_open',adaptor,id)
        % adaptor is 'nidaq' or 'winsound'
        adaptor=varargin{2};
        id=varargin{3};
        [board,nchan]=board_open(adaptor,id);
        varargout{1} = board;
        varargout{2} = nchan;

    case 'board_close'
        % ao('board_close',adaptor,id)
        % adaptor is 'nidaq' or 'winsound'
        close_ao(varargin{2},varargin{3})

    case 'putsample'
        % ao('putsample',data)
        % ao('putsample',board,data)
        % Immediately set AO channels to a specific voltage.
        % If more than one board is in use, the board number should be
        % specified. Data must be a vector with same length as the
        % number of channels on the board
        if strcmp(exper.ao.daq(1).sending,'On')
            Message(me,'Can''t putsample while sending','error');
        else
            if nargin>2
                % either the board is specified
                board=varargin{2};
                data=varargin{3};
            else
                % or it isn't and we assume it's board no. 1
                if length(exper.ao.daq)==1
                    data=varargin{2};
                    board=1;
                else
                    Message(me,'Must specify board number');
                    return
                end
            end
            nchan=length(exper.ao.daq(board).Channel);
            if length(data)==nchan
                putsample(exper.ao.daq(board),data)
            else
                if nchan~=0
                    Message(me,sprintf('Need %d channels!',nchan));
                else
                    Message(me,sprintf('Board %d not initialized',board));
                end
            end
        end

    case 'setdata'
        % sets the data in AO (for output). The data must be of proper size, as
        % specified by the number of channels for the board (columns) and sampling
        % rate & trial duration for AO (rows)
        % ao('setdata', board, data)
        if nargin > 2
            board=varargin{2};
            data=varargin{3};
        else
            if length(exper.ao.daq)==1
                data=varargin{2};
                board=1;
            else
                Message(me,'Must specify board number');
                return
            end
        end
        aosize=GetParam(me,'SampleRate')*GetParam(me,'Duration');

        if size(data,2)~=length(exper.ao.daq(board).channel) | ...
                size(data,1)~=aosize
            Message(me,sprintf('Data size must be %d x %d',aosize,length(exper.ao.daq(board).channel)));
        else
            exper.ao.data{board} = data;
        end

    case {'setchandata','addchandata'}
        % sets AO data for a specified channel
        % these fcns clear the current ao data
        %   ao('setchandata', channel, data)
        %   ao('setchandata', board, channel, data)
        % while these sum the new data and the existing data
        %   ao('addchandata', channel, data)
        %   ao('addchandata', board, channel, data)
        if nargin>=4
            % User specified board.
            board=varargin{2};
            chan=varargin{3};
            data=varargin{4};
        elseif nargin>=3
            % No board specified. Assume board 1.
            board=1;
            chan=varargin{2};
            data=varargin{3};
        else
            Message(me,'Incorrect use of setchandata.');
            return;
        end

        aosize = round(GetParam(me,'SampleRate')*GetParam(me,'Duration'));
        if size(data,1) > aosize
            Message(me,sprintf('Data size must be <%d',aosize));
        else
            switch varargin{1}
                case 'setchandata'
                    exper.ao.data{board}(1:length(data),chan)=data;
                case 'addchandata'
                    exper.ao.data{board}(1:length(data),chan)=data+...
                        exper.ao.data{board}(1:length(data),chan);
                otherwise
            end
            Message(me,sprintf('Loaded channel %d',chan));
        end

    case 'putdata'
        % puts the data in exper.ao.daq{board} (set by setchandata, for
        % example) into ao

    case 'pause'
        ao_pause;

    case 'gethwchannel'
        if nargin<2
            return;
        end
        inchannel=varargin{2};
        aochannels=GetParam(me,'AOChannels');
        nchannels=length(inchannel);
        outchannel=zeros(1,nchannels);
        for k=1:nchannels
            idx=find(aochannels(2,:)==inchannel(k));
            if isempty(idx)
                varargout(1)={-1};
                return;
            end
            outchannel(k)=aochannels(1,idx);
        end
        varargout(1)={outchannel};

    case 'getchannelidx'
        if nargin<2
            return;
        end
        inchannel=varargin{2};
        aochannels=GetParam(me,'AOChannels');
        nchannels=length(inchannel);
        outchannel=zeros(1,nchannels);
        for k=1:nchannels
            idx=find(aochannels(1,:)==inchannel(k));
            if isempty(idx)
                varargout(1)={-1};
                return;
            end
            outchannel(k)=aochannels(2,idx);
        end
        varargout(1)={outchannel};

    case 'getsamplerate'
        varargout{1}=GetParam(me,'SampleRate');

    otherwise
end

% begin local functions

%%%%%
function out = callback
out = [lower(mfilename) ';'];
%%%%%

%%%%%
function out = me
out = lower(mfilename);
%%%%%

%%%%%
function find_boards
% finds available boards with AO capabilities and creates the corresponding
% menu items in AO
fig=findobj('type','figure','tag',me);
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
            % this condition makes sure there is an analogoutput for this board
            if ~isempty(b.ObjectConstructorName{p,2})
                namestr=sprintf('%s%s-AO',adaptors{n},ids{p});
                label=sprintf('    %s (%s)',namestr,names{p});
                uimenu(hf,'tag','ao_board_menu','label',label,'user',namestr,'callback',callback);
            end
        end
    end
end
% function find_boards
%%%%%

%%%%%
function [board,nchan]=board_open(adaptor,id)
global exper pref
% open the AO data acquisition object
board=open_ao(adaptor,id);
if board>0
    nchan=length(exper.ao.daq(board).Channel);
else
    nchan=0;
end
%%%%%

%%%%%
function ao_start
% starts the AO object
global exper pref
if ~GetParam(me,'send')
    return
end
if strcmp(exper.ao.daq(1).running,'On')
    % if AO is still running, stop it
    stop(exper.ao.daq);
    Message(me,'Was still running!','error');
end
% if we have enough samples available to send out...
if exper.ao.daq(1).SamplesAvailable>=GetParam(me,'SampleRate')*GetParam(me,'Duration')
    % we start the AO object
    start(exper.ao.daq);
    % if we don't use the hardware trigger, we use the manual one
    if ~GetParam(me,'hwtrigger')
        if strcmp(exper.ao.daq(1).running,'On')
            trigger(exper.ao.daq);
            Message(me,'Manually triggered');
        end
    end
    Message(me,'');
else
    Message(me,sprintf('Too few (%d) samples cued',exper.ao.daq(1).SamplesAvailable));
end
% ai handles sending dio trigger    ?????
% note trigger for AO on NI boards is PFI-6
% function ao_start
%%%%%

%%%%%
function ao_pause
% stops the AO object.
% Weird name!!! I might rename it to ao_stop
global exper pref
if isfield(exper.ao,'daq')
    if strcmp(exper.ao.daq(1).running,'On')
        stop(exper.ao.daq);
    end
end
% function ao_pause
%%%%%

%%%%%
function close_ao(adaptor,id)
% stops and removes the given AO object (adaptor and id)
global exper pref
boardname=sprintf('%s%d-AO',adaptor,id);
ao=daqfind('name',boardname);
if isempty(ao)
    Message(me,'Board not open')
end
for n=1:length(ao)
    if strcmp(get(ao{n},'running'),'On')
        stop(ao{n});
    end
    k=length(exper.ao.daq);
    while k>=1
        if strcmp(exper.ao.daq(k).name,boardname)
            if length(exper.ao.daq)>1
                exper.ao.daq(k)=[];
            else
                exper.ao=rmfield(exper.ao,'daq');
            end
        end
        k=k-1;
    end
    delete(ao{n});
    %foma - 2005/02/16
    clear ao{n};
    Message(me,sprintf('%s closed',boardname));
end
board_menu_labels;
% function ao_close
%%%%%

%%%%%
function board=open_ao(adaptor,id)
% opens AO (given by adaptor and id), sets its parameters
global exper pref
board=0;
boardname=sprintf('%s%d-AO',adaptor,id);
% first, we have to check if it isn't already initialized
if isfield(exper.ao,'daq')
    for n=1:length(exper.ao.daq)
        if strcmp(exper.ao.daq(n).Name,boardname)
            Message(me,'Already initialized');
            board = n;
            return
        end
    end
end

% second, we like to see only nidaq or winsound. Sorry:-)
if ~strcmp(adaptor,'nidaq') & ~strcmp(adaptor,'winsound')
    Message(me,'nidaq and winsound are valid');
    return
end
boardn=daqhwinfo('nidaq', 'BoardNames');

v=ver('daq'); %daq toolbox version number
%mw 08.28.08  new version of matlab refers to devices differently
if str2num(v.Version) >= 2.12
    boardinit=sprintf('analogoutput(''%s'',''%s'')',adaptor,id);
else %assume old version of matlab
    switch boardn{1} %mw 04.18.06
        case 'PCI-6052E'
            boardinit=sprintf('analogoutput(''%s'',%d)',adaptor,id);
        case 'PCI-6289'
            boardinit=sprintf('analogoutput(''%s'',''%s'')',adaptor,id); %mw 12.16.05
    end
end


ao=eval(boardinit);
ao.SampleRate=GetParam(me,'SampleRate');
ao.TriggerFcn={'ao_trig_handler'};
switch adaptor
    case 'nidaq'
        h=daqhwinfo(ao);
        device=h.DeviceName;
        switch device
            case 'PCI-6025E'
                switch version %mw 08.28.08
                    case '7.6.0.324 (R2008a)' %new version of matlab refers to devices differentl
                        chan = 0:7;
                    otherwise %assume old version of matlab
                        ao.TransferMode = 'Interrupts';
                        chan = 0:1;
                end
            case 'PCI-6713'
                chan = 0:7;
            otherwise
                chan = 0:1;
        end
        % 		for n=1:length(chan)            % this would crash, if there's only
        % 		one output channel specified, for example
        for n=1:length(pref.ao_channels)
            %addchannel(ao,n,sprintf('Chan %d',n)); % this was with for n=chan
%            addchannel(ao,pref.ao_channels(n).number,pref.ao_channels(n).name); %bak mw092209
            chan=addchannel(ao,pref.ao_channels(n).number,pref.ao_channels(n).name);%mw092209
                        set(chan,'UnitsRange',[-10 10]);
                        set(chan,'OutputRange',[-10 10]);
                        
        end
        Message(me,'nidaq');
        ok = 1;
    case 'winsound'
        for n=1:2
            addchannel(ao,n,sprintf('Chan %d',n));
        end
        Message(me,'winsound');
    otherwise
        Message(me,'no board!');
        return
end

if isfield(exper.ao,'daq')
    exper.ao.daq(end+1) = ao;
else
    exper.ao.daq = ao;
end

set_hwtrigger(ao);
Message(me,sprintf('%s%d initialized',ao.name));
board_menu_labels;  % set up the menu

% erase data
for n=1:length(exper.ao.daq)
    exper.ao.data{n} = [];
end
board = length(exper.ao.daq);
% function=open_ao
%%%%%

%%%%%
function board_menu_labels
% sets the items for the Board menu of the AO module
global exper pref
menuitems = findobj('tag','ao_board_menu');
for n=1:length(menuitems)
    label = get(menuitems(n),'label');
    label(1:2) = '  ';
    set(menuitems(n),'checked','off','label',label);
end
if isfield(exper.ao,'daq')
    for n=1:length(exper.ao.daq)
        menuitem = findobj('tag','ao_board_menu','user',exper.ao.daq(n).name);
        label = get(menuitem,'label');
        label(1:2) = sprintf('%d:',n);
        set(menuitem,'checked','on','label',label);
    end
end
%%%%%

%%%%%
function set_hwtrigger(board)
% sets the trigger for 'board' to hardware, if possible
global exper pref
%if its possible to set the Trigger to HwDigital, then do it
inputs = propinfo(board, 'TriggerType');
if isempty(find(strcmp(inputs.ConstraintValue, 'HwDigital')))
    SetParamUI(me,'hwtrigger','enable','off');
    SetParam(me,'hwtrigger','value',0,'range',[0 0]);
    board.TriggerType = 'Manual'; %added
else
    SetParamUI(me,'hwtrigger','enable','on');
    SetParam(me,'hwtrigger','range',[0 1]);
    board.TriggerType = 'HwDigital';    % added
end
Message(me,sprintf('%s trigger',board.triggertype));
% function set_hwtrigger(board)
%%%%%%

%%%%%
function reset_ao_data
% resets AO, i.e. flushes any remaining samples and zeros all AO data
global exper pref
% get rid of extra cued AO samples!
if exper.ao.daq(1).samplesavailable > 0
   start(exper.ao.daq); 
   stop(exper.ao.daq);
end
for n=1:length(exper.ao.daq)
    nchan=length(exper.ao.daq(n).Channel);
    aosamp=ceil(GetParam(me,'SampleRate')*GetParam(me,'Duration'));
    %         aosamp=10; %mw 01.11.06
    if isempty(exper.ao.data{n}) | size(exper.ao.data{n},1)~=aosamp
        exper.ao.data{n}=zeros(aosamp,nchan);
    end
    if GetParam(me,'Send')
        putdata(exper.ao.daq(n),exper.ao.data{n});
    end
end
%%putting zeroed data causes a big delay when start/stopping ao object
%%during getready. mw 01.11.06

Message(me,'');
%fprintf('\nAO: reset');
% function reset_ao_data
%%%%%

function really_reset_ao_data
%trying a more hard-core version that really does what it says mw 052610
% resets AO, i.e. flushes any remaining samples and zeros all AO data
global exper pref
% get rid of extra cued AO samples!
if exper.ao.daq(1).samplesavailable > 0
   start(exper.ao.daq); 
   stop(exper.ao.daq);
end
for n=1:length(exper.ao.daq)
    nchan=length(exper.ao.daq(n).Channel);
    aosamp=ceil(GetParam(me,'SampleRate')*GetParam(me,'Duration'));
    %         aosamp=10; %mw 01.11.06
    if isempty(exper.ao.data{n}) | size(exper.ao.data{n},1)~=aosamp
        exper.ao.data{n}=zeros(aosamp,nchan);
    end
    if GetParam(me,'Send')
        putdata(exper.ao.daq(n),exper.ao.data{n});
    end
end
%here is the hard-core line:
exper.ao.data{n}=zeros(aosamp,nchan);
Message(me,'');
%fprintf('\nAO: really reset');