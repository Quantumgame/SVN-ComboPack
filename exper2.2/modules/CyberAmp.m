function varargout = CyberAmp( varargin )

% Simple module for CyberAmp 380 control
% v0.1 foma 02/2003


global exper pref

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
	
    InitializeCyberAmp;
    
case 'getready'
    %  here we just disable all the controls
    
case 'trialend'
    % here we just enable all the controls	

case 'close'
    %just delete the serial port object if it's still there
    CyberAmp=GetParam(me,'CyberAmp');
    fclose(CyberAmp);
    
case 'reset'
    %delete everything and reinitialize
    
case 'channel'
	% nothing so far. we'll stick to channel no. 1
    
case 'positiveinput'
    InputCommands=GetParam(me,'InputCommands');
    posinput=GetParam(me,'PositiveInput');
    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    command=['AT' num2str(Device) 'C' num2str(Channel) '+' InputCommands{posinput}];
    CyberAmp=GetParam(me,'CyberAmp');
    set(CyberAmp,'Terminator','CR');    
    fprintf(CyberAmp,command);
    
    CheckOverload;
    
case 'negativeinput'
    InputCommands=GetParam(me,'InputCommands');
    posinput=GetParam(me,'NegativeInput');
    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    command=['AT' num2str(Device) 'C' num2str(Channel) '-' InputCommands{posinput}];
    CyberAmp=GetParam(me,'CyberAmp');
    set(CyberAmp,'Terminator','CR');    
    fprintf(CyberAmp,command);
    CheckOverload;
    
case 'initialgain'
    InitialGains=GetParam(me,'InitialGains');
    gain=GetParam(me,'InitialGain');
    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    command=['AT' num2str(Device) 'G' num2str(Channel) 'P' InitialGains{gain}];
    CyberAmp=GetParam(me,'CyberAmp');
    set(CyberAmp,'Terminator','CR');    
    fprintf(CyberAmp,command);
    CheckOverload;
    
    totalgains=GetParam(me,'TotalGains');
    newgains=cellstr(num2str(str2num(char(totalgains))*str2num(InitialGains{gain})))';
    SetParamUI(me,'TotalGain','String',newgains);
    
    CallModule(me,'dcoffset');
    
case 'dcoffset'
    dcoffset=GetParam(me,'DCOffset');
    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    
    InitialGains=GetParam(me,'InitialGains');
    gain=GetParam(me,'InitialGain');
    initialgain=str2num(InitialGains{gain});
    
    maxvalue=3000/initialgain;
    if dcoffset>(maxvalue)
        dcoffset=maxvalue;
    end;
    if dcoffset<(-maxvalue)
        dcoffset=-maxvalue;
    end;
    
    SetParam(me,'DCOffset',dcoffset);
    
    command=['AT' num2str(Device) 'D' num2str(Channel) num2str(dcoffset*1000)];
    CyberAmp=GetParam(me,'CyberAmp');
    set(CyberAmp,'Terminator','CR');    
    fprintf(CyberAmp,command);
    
    CheckOverload;
    
case 'lowpassfilter'
    LowpassFilters=GetParam(me,'LowpassFilters');
    filter=GetParam(me,'LowpassFilter');
    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    command=['AT' num2str(Device) 'F' num2str(Channel) LowpassFilters{filter}];
    CyberAmp=GetParam(me,'CyberAmp');
    set(CyberAmp,'Terminator','CR');    
    fprintf(CyberAmp,command);
    CheckOverload;
    
case 'notchfilter'
    NotchFilterCommands=GetParam(me,'NotchFilterCommands');
    filter=GetParam(me,'NotchFilter');
    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    command=['AT' num2str(Device) 'N' num2str(Channel) NotchFilterCommands{filter}];
    CyberAmp=GetParam(me,'CyberAmp');
    set(CyberAmp,'Terminator','CR');    
    fprintf(CyberAmp,command);
    CheckOverload;
    
case 'totalgain'
    TotalGains=GetParam(me,'TotalGains');
    gain=GetParam(me,'TotalGain');
    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    command=['AT' num2str(Device) 'G' num2str(Channel) 'O' TotalGains{gain}];
    CyberAmp=GetParam(me,'CyberAmp');
    set(CyberAmp,'Terminator','CR');    
    fprintf(CyberAmp,command);
    CheckOverload;
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
	
	% GUI positioning factors
	hs = 80;
	h = 5;
	vs = 20;
	n = 0;
    
  %NOTE: in v0.1 we are using only device no. 1!!! and Channel #1!!!
    % Channel is the active channel of the device #1
    Device=1;
    InitParam(me,'Device','value',Device);
    
    %TotalGain is the total gain:-) (Again, if you read the manual, don't get confused: Total Gain is
    %what they use in CyberAmp Control software; in reality it corresponds to Pre-filter gain (=initial
    %gain) * Output gain.
    TotalGains={'1','2','5','10','20','50','100','200'};
    InitParam(me,'TotalGains','value',TotalGains);
	InitParam(me,'TotalGain',...
		'value',1,'String',TotalGains,...
		'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;

    % NotchFilter is the Notch filter value (boolean)
    NotchFilters={'Off','On'};
    NotchFilterCommands={'0','1'};
    
    InitParam(me,'NotchFilters','value',NotchFilters);
    InitParam(me,'NotchFilterCommands','value',NotchFilterCommands);
	InitParam(me,'NotchFilter',...
		'value',1,'String',NotchFilters,...
		'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;


    %LowpassFilter is the lowpass filter value (in Hz)
    LowpassFilters={'2','4','6','8','10','12','14','16','18','20','22','24','26','28','30','40','60','80','100',...
            '120','140','160','180','200','220','240','260','280','300','400','600','800','1000','1200','1400',...
            '1600','1800','2000','2200','2400','2600','2800','3000','4000','6000','8000','10000','12000','14000',...
            '16000','18000','20000','22000','24000','26000','28000','30000','-'};
    InitParam(me,'LowpassFilters','value',LowpassFilters);
	InitParam(me,'LowpassFilter',...
		'value',1,'String',LowpassFilters,...
		'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;
  
    % DCOffset is the DC offset value (Warning: it's in mV but CyberAmp wants it in uV!!!!!)
    DCOffset=1;
    InitParam(me,'DCOffset',...
        'value',DCOffset,...
        'ui','edit','pos',[h n*vs hs vs]); n=n+1;
    
    %InitialGain is the initial gain value (it's equal to the pre-filter gain mentioned in the manual,
    % and for some obscure reason it's called initial gain in the CyberAmp Control software:)
    InitialGains={'1','10','100'};
    InitParam(me,'InitialGains','value',InitialGains);
	InitParam(me,'InitialGain',...
		'value',1,'String',InitialGains,...
		'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;


    %NegativeInput is the negative input value
    Inputs={'DC','GND','AC@0.1Hz','AC@1Hz','AC@10Hz','AC@30Hz','AC@100Hz','AC@300Hz'};
    InputCommands={'DC','GND','0.1','1','10','30','100','300'};
    
    InitParam(me,'Inputs','value',Inputs);
    InitParam(me,'InputCommands','value',InputCommands);
	InitParam(me,'NegativeInput',...
		'value',1,'String',Inputs,...
		'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;
    
    %PositiveInput is the positive input value
	InitParam(me,'PositiveInput',...
		'value',1,'String',Inputs,...
		'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;

    % Probe is the probe id string obtained from CyberAmp
    Probe='?';
	InitParam(me,'Probe',...
		'value',Probe,...
		'ui','edit','pos',[h n*vs hs vs]); n=n+1;	

    Channel=1;
	InitParam(me,'Channel',...
		'value',Channel,...
		'ui','edit','pos',[h n*vs hs vs]); n=n+1;

    % message box
	uicontrol(fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*1]); n = n+1;
	
	
	set(fig,'pos',[163 646 168 n*vs]);
	% Make figure visible again.
	set(fig,'visible','on');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=InitializeCyberAmp;
% this just creates a new serial port object and initializes CyberAmp using the variables defined before
% returns the created serial port object
    CyberAmp=serial('COM1','Terminator','CR'); %CyberAmp needs carriage return as a terminator instead of the default line feed
    InitParam(me,'CyberAmp','value',CyberAmp);
    fopen(CyberAmp);    

    Device=GetParam(me,'Device');
    Channel=GetParam(me,'Channel');
    fprintf(CyberAmp,['AT' num2str(Device) 'S' num2str(Channel)]);

    set(CyberAmp,'Terminator','>');
    % CyberAmp uses different terminators for input and output. So if you
    % keep CR as terminator for output you will have one character left in
    % the buffer after the first reading (with fscanf, for example). I'm
    % sure there are better ways how to deal with this, but for now...:-)

    value=fscanf(CyberAmp);
    
    Probe=value(5:12);
    SetParam(me,'Probe',Probe);
    
    InputCommands=GetParam(me,'InputCommands');
    
    PositiveInput=str2num(value(16:18));
    if isempty(PositiveInput)
        PositiveInput=value(16:18);
        valuepos=find(strcmp(InputCommands,cellstr(PositiveInput)));
    else
        valuepos=find(strcmp(InputCommands,num2str(PositiveInput)));
    end
    SetParam(me,'PositiveInput',valuepos);
    
    NegativeInput=str2num(value(22:24));
    if isempty(NegativeInput)
        NegativeInput=value(22:24);
        valuepos=find(strcmp(InputCommands,cellstr(NegativeInput)));
    else
        valuepos=find(strcmp(InputCommands,num2str(NegativeInput)));
    end
    SetParam(me,'NegativeInput',valuepos);

    InitialGains=GetParam(me,'InitialGains');
    
    InitialGain=str2num(value(28:30));
    valuepos=find(strcmp(InitialGains,num2str(InitialGain)));
    SetParam(me,'InitialGain',valuepos);
    
    DCOffset=str2num(value(44:51))/1000;     % the value is in microvolts, but we want it in milivolts
    SetParam(me,'DCOffset',DCOffset);
    
    LowpassFilters=GetParam(me,'LowpassFilters');
    
    LowpassFilter=str2num(value(55:end-1));
    if isempty(LowpassFilter)
        LowpassFilter=value(55:end-1);
        valuepos=find(strcmp(LowpassFilters,cellstr(LowpassFilter)));
    else
        valuepos=find(strcmp(LowpassFilters,num2str(LowpassFilter)));
    end
    SetParam(me,'LowpassFilter',valuepos);
    
    NotchFilters=GetParam(me,'NotchFilters');
    
    NotchFilter=value(40);
    valuepos=find(strcmp(GetParam(me,'NotchFilterCommands'),cellstr(NotchFilter)));
    SetParam(me,'NotchFilter',valuepos);
    
    TotalGains=GetParam(me,'TotalGains');
    
    %TotalGain=str2num(value(34:36))*InitialGain;
    TotalGain=str2num(value(34:36));
    valuepos=find(strcmp(TotalGains,num2str(TotalGain)));
    SetParam(me,'TotalGain',valuepos);

    CheckOverload;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=CyberAmpCommand(com);
% this just sends command com to serial (CyberAmp) object
% returns 1 if successful and 0 if not


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckOverload;
    CyberAmp=GetParam(me,'CyberAmp');
    Channel=GetParam(me,'Channel');
    Device=GetParam(me,'Device');

    set(CyberAmp,'Terminator','>');
    fscanf(CyberAmp);

    pause(.1);
    
    set(CyberAmp,'Terminator','CR');
    fprintf(CyberAmp,['AT' num2str(Device) 'O']);

    set(CyberAmp,'Terminator','>');
    value=fscanf(CyberAmp)
    
    set(CyberAmp,'Terminator','CR');
    fprintf(CyberAmp,['AT' num2str(Device) 'O']);

    set(CyberAmp,'Terminator','>');
    value=fscanf(CyberAmp)
    
    overload=findstr(num2str(Channel),value);
    
    if ~isempty(overload)
        Message(me,'!!!OVERLOAD!!!');
    else
        Message(me,'');
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);