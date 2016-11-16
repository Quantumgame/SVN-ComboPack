function varargout = dio(varargin)
% dio
% A module for digital input and output
% 
% DIO('trigger')
% DIO('line',line,value)
% DIO('line',line,port,value)
% 	value is 0 or 1
%		
%
% ZF Mainen, CSHL, 10/00
% SL Macknik, CSHL, 9/00

global exper pref

out = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action

case 'init'
	fig = ModuleFigure(me,'visible','off');
	%set initial parameters 
	SetParam(me,'priority',1);
	ModuleNeeds(me,{'ai'});
	
	hs=60;
	h=5;
	vs=20;
	n=1;
	
	if ~ExistParam(me,'board')
		% if we haven't been initialized
		[boards boardinits] = find_boards;
		InitParam(me,'Board','ui','menu','list',boards,'value',1);
		InitParam(me,'Boardinit','list',boardinits);
	else
		InitParam(me,'Board','ui','menu');
	end
	SetParamUI(me,'Board','label','Board');
% 	InitParam(me,'Trigchan','value','0','ui','edit','pos',[h 0 hs vs]);
% 	InitParam(me,'HwTrigger','value',1,'ui','checkbox','pos',[h n*vs+1 hs vs]); n=n+1;
	InitParam(me,'HwTrigger','ui','togglebutton','value',1,'String','HWTrig','pref',0,'units','normal','pos',[0.5 0.26 0.48 0.24],...
        'backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold'); n=n+1;
	InitParam(me,'Trigchan','value','0','ui','edit','units','normal','pos',[0.02 0.02 0.45 0.24]);
	
    % create those small buttons, one for each line and the lines to the
    % DIO object
    [lines ports] = init_dio(fig);
    dio=exper.dio.dio;
    p=1+ports;
	count=0;
	portnames={'','a','b','c'};
	for l=1:ports % one row of line buttons for each port
		for m=1:(lines/ports) % # of lines per port
            port=portnames{l};
			name=sprintf('%s%d',port,m-1);
            boardn=daqhwinfo('nidaq', 'BoardNames');
            switch boardn{1} %mw 04.18.06
                case 'PCI-6052E'
                    line=addline(dio,count,0,'Out',name)
                case 'PCI-6289'
                    if count<32 %mw 07.02.07
                        line=addline(dio,count,0,'Out',name)
                    end
                    %line=addline(dio,m-1,l-1,'Out',name); %mw 12.16.05
            end

            % status panel
% 			h=uicontrol(fig,'string',name,'style','toggle','units','normal','pos',[0.02+(0.96/(lines/ports))*(m-1) 0.50 0.96/(lines/ports) 0.24], ...
% 				'value', 0, 'tag', 'line', 'user', line, 'callback', callback, ...
% 				'BackgroundColor', get(gcf,'color'));
			h=uicontrol(fig,'string',name,'style','toggle','units','normal','pos',[0.02+(0.96/(lines/ports))*(m-1) 0.50+(0.96/ports)*(l-1) 0.96/(lines/ports) 0.24/ports], ...
				'value', 0, 'tag', 'line', 'user', line, 'callback', callback, ...
				'BackgroundColor', get(gcf,'color'));
			% save a set of handles to the toggles, which in turn
			% reference the lines
			exper.dio.lineh(l,m)=h;
			count=count+1;
		end
		p=p-1;
	end
    
	% set up the trigger
	set_trigchan;   % trigchan is a local function
	
	n = n+ports;
    h=5;
	% message box
	uicontrol('parent',fig,'tag','message','style','edit','units','normal',...
		'enable','inact','horiz','left','pos',[0.02 0.74 0.96 0.24]); n=n+1;
	Message(me,sprintf('%s DIO initialized',GetParam(me,'board')));
	set(fig,'pos',[5 188-n*vs 128 n*vs],'visible','on');
	
case 'close'
	if ~isfield(exper.dio,'dio') % if there is nothing to close, return
        return; %nm 8/28/08 added semi-colon to end of line to try to fix exit error
    end
    stop(exper.dio.dio);                % otherwise stop DIO,
	while(length(exper.dio.dio.Line))   % delete all the lines,
		delete(exper.dio.dio.Line(1)); 
	end
	delete(exper.dio.dio);              % and delete the object
    clear exper.dio.dio;
	
% handle UI callbacks

case 'line'
% line is both a callback and an external function	
% handle callback from the status panel or
% called with syntax:
%
% dio('line',line,value)
% dio('line',line,port,value)
% 	value is 0 or 1
	if nargin <2 
		% called from the object = someone (something:-) pushed the button
		val = get(gcbo,'Value');
		h = gcbo;
	else
		% called from a function
		line = varargin{2};
		if nargin < 4
			port = 1;
			val = varargin{3};
		else
			port = varargin{3};
			val = varargin{4};
		end
		% we have stored an array of handles to the button objects
		% which in turn contain a reference to the dio line in their
		% user field
		h = exper.dio.lineh(port,line+1);
	end
	
	%change the color of the button 
	if val
		set(h,'BackgroundColor',[0 1 0],'value',1);
	else
		set(h,'BackgroundColor',get(gcf,'color'),'value',0);
	end
	% set the line
	lineobj = get(h,'user');
	if length(lineobj)>1
		for n=1:length(lineobj)
			putvalue(lineobj{n}, val);
		end
	else
		putvalue(lineobj, val);
	end
	
case 'hwtrigger'
    if GetParam(me,'HWTrigger')
        SetParamUI(me,'HWTrigger','backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1]);
    else
        SetParamUI(me,'HWTrigger','backgroundcolor',[0 0 1],'foregroundcolor',[1 1 1]);
    end
    
% handle external function calls

case 'reset'
	Message(me,'');
	    
case 'trigger'
% sends out a hardware trigger
	if ~ExistParam(me,'hwtrigger') 
        return; 
    end
    
    if GetParam(me,'hwtrigger') & GetParam(me,'open')
        lineh=getparam(me,'hwtrigger','lineh'); % get the line handle
        line=get(lineh,'user');                 % and the line itself
        set(lineh,'background',[0 1 0]);
        putvalue(line,1);                       % send it out
        pause(.0001);
        putvalue(line,0);
        set(lineh,'background',get(gcf,'color'));
    end

otherwise	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 								begin local functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = me
out = lower(mfilename); 
%function out=me
%%%%%

%%%%%
function out = callback
out = [lower(mfilename) ';'];
% function out=callback
%%%%%

%%%%%
function varargout = find_boards
% returns board names and initialization 'calls' for those available DAQ
% boards with DIO capabilities
a=daqhwinfo;
adaptors = a.InstalledAdaptors;
boards = {''};
boardinits = {''};
q = 1;
for n=1:length(adaptors)
    try %parallel adaptor causes error on 64-bit windows, this way we skip it. mw 08.25.09
        b = daqhwinfo(adaptors{n});
        names = b.BoardNames;
        ids = b.InstalledBoardIds;
        
        for p=1:length(names)
            if strcmp(b.AdaptorName,'nidaq')
                boards{q} = names{p};
                v=ver('daq'); %daq toolbox version number
                %mw 08.28.08  new version of matlab refers to devices differently
                if str2num(v.Version) >= 2.12
                    boardinits{q} = sprintf('digitalio(''%s'',''%s'')',adaptors{n},ids{p}); %mw 12.16.05
                    q = q+1;
                else %assume old version of matlab
                    switch names{1} %mw 04.18.06
                        case 'PCI-6052E'
                            %                    boardinits{q} =	sprintf('digitalio(''%s'',%d)',adaptors{n},ids{p});
                            boardinits{q} =	sprintf('digitalio(''%s'',%d)',adaptors{n},str2num(ids{end})); %hack! mw 04.18.06 ?multiple instantiations of pci 6052E???
                        case 'PCI-6289'
                            boardinits{q} = sprintf('digitalio(''%s'',''%s'')',adaptors{n},ids{p}); %mw 12.16.05
                    end
                    q = q+1;
                end
            end
        end
    end
end
varargout{1} = boards;
varargout{2} = boardinits;
% function varargout = find_boards
%%%%% 

%%%%%
function [lines, ports]=init_dio(fig)
global exper pref
	board=GetParam(me,'board','value');
	SetParam(me,'boardinit',board);
	bo=GetParam(me,'boardinit');
	if isempty(bo)
        ports=0;
        lines=0;
        return
    end
    dio=eval(bo); %this initializes DIO by evaluating the string "dio = digitalio('nidaq', ...
	exper.dio.dio=dio;
	nidioinfo=daqhwinfo(dio);
	ports=length(nidioinfo.Port);
	lines=nidioinfo.TotalLines;
% function [lines, ports] = init_dio(fig)
%%%%%

%%%%%
function set_trigchan
    % sets up the trigger channel
	lineh=findobj('parent',findobj('type','figure','tag',me),'tag','line',...
		'string',GetParam(me,'trigchan','value'));
	if ~isempty(lineh)
		SetParam(me,'hwtrigger','lineh',lineh)
		SetParamUI(me,'hwtrigger','enable','on');
		Message(me,'Trigger chan changed');
	else
		SetParamUI(me,'hwtrigger','enable','off');
		Message(me,'Invalid Trigger chan');
	end
% function trigchan
%%%%%