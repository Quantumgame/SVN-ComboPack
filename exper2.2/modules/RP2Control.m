function varargout=RP2Control(varargin) 

% Simple module to control various parameters of RP2
%
% foma 03/2003
%
% RP2Control('GetRP2',desc) returns ActiveX object with description
% matching desc
% RP2Control('GetRP2Circuit',desc) returns circuit with description
% matching desc. This is just pref.rp2(x).circuit.
% Descriptions, circuits, connection types, and device types MUST be
% defined in Prefs.m and as such are stored in pref.rp2
%


global exper pref

% varargout{1} = lower(mfilename); 

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
case 'init'
    InitializeGUI;    
    InitRP2;
    
case 'reset'
    ClearRP2;
    
case 'close'
    ClearRP2;    
        
case 'getrp2'    
    varargout{1}={};
    if nargin<2 
        return;
    end
    RP2=GetParam(me,'RP2');
    rp2description=GetParam(me,'RP2Description');
    nrp2s=GetParam(me,'NRP2s');
    desc=varargin{2};
    for n=1:nrp2s
        if findstr(desc,rp2description{n}) % search for circuit matching the description
            varargout(1)={RP2{n}};
            break;
        end
    end
    
case 'getrp2circuit'    
    varargout{1}={};
    if nargin<2 
        return;
    end
    rp2description=GetParam(me,'RP2Description');
    nrp2s=GetParam(me,'NRP2s');
    desc=varargin{2};
    for n=1:nrp2s
        if findstr(desc,rp2description{n}) % search for circuit matching the description
            varargout(1)={pref.rp2(n).circuit};
            break;
        end
    end
    
case 'reconnect'
    ReInitRP2;
    SendEvent('erp2reconnect',[],me); % tell the dependents that RP2 was reconnected
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
global exper pref
    fig = ModuleFigure(me,'visible','off');	
    InitParam(me,'Fig','value',fig);
    hs = 120;
    h = 5;
    vs = 20;
    n = 0;
    % message box
    nrp2s=length(pref.rp2); % how many rp2 we have specified in preferences...    
    InitParam(me,'NRP2s','value',nrp2s);        % how many rp2s we have

    height=0.96/(nrp2s+3);
    uicontrol('parent',fig,'tag','message','style','text','enable','inact',...
        'horiz','left','units','normal','pos',[0.02 0.02 0.96 height]); n=n+1;
%     nrp2s=length(pref.rp2); % how many rp2 we have specified in preferences...    
    for k=nrp2s:-1:1
        uicontrol('parent',fig,'tag',['rp2_' num2str(k)],'style','text','enable','inact',...
            'horiz','left','units','normal','pos',[0.02 0.02+height*k 0.96 height]); n=n+1;
    end
    
    uicontrol('parent',fig,'string','RP Reconnect','tag','reconnect','units','normal',...
    		'position',[0.02 0.02+height*(nrp2s+1) 0.96 height*2],'fontweight','bold','enable','on',...
    		'style','pushbutton','callback',[me ';']); n=n+2;
    
    screensize=get(0,'screensize');
    set(fig,'pos', [screensize(3)-128 screensize(4)-n*vs-20 128 n*vs] ,'visible','on'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitRP2
global exper pref

    fig=GetParam(me,'Fig');
    nrp2s=GetParam(me,'NRP2s');
    rp2h=figure('visible','off');   % figure for ActiveX control
    rp2={};
    rp2description={};
    for n=1:nrp2s
        h=findobj(fig,'tag',['rp2_' num2str(n)]);
        try
            axctl=actxcontrol('RPco.x',[20 20 60 60],rp2h);
            rp2{n}=axctl;
            rp2description{n}=pref.rp2(n).description;
        catch
            set(h,'String','ActiveX failure');
            Message(me, 'Failed to create ActiveX control','error');
            break;
        end
        try
            invoke(axctl,'Halt');
            invoke(axctl,'ClearCOF');
            connect=['Connect' pref.rp2(n).type];            
            if ~invoke(axctl,connect,pref.rp2(n).interface,n);
                set(h,'String', [pref.rp2(n).type ' ' num2str(n) ' FAILURE']);
            end
        catch
            set(h,'String',['Failed to clear/connect ' pref.rp2(n).type]);
            Message(me,['Failed to clear/connect ' pref.rp2(n).type],'error');
            break;
        end
        
        set(h,'String',[pref.rp2(n).type ' ' num2str(n) ' initialized']);
    end
    
    InitParam(me,'RP2h','value',rp2h);
    InitParam(me,'RP2','value',rp2);            % corresponding ActiveX objects
    InitParam(me,'RP2Description','value',rp2description); % user defined descriptions of indiv. circuits

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ReInitRP2
global exper pref

    fig=GetParam(me,'Fig');
    nrp2s=GetParam(me,'NRP2s');
    rp2=GetParam(me,'RP2');
    for n=1:nrp2s
        h=findobj(fig,'tag',['rp2_' num2str(n)]);
        try
            invoke(rp2{n},'Halt');
            invoke(rp2{n},'ClearCOF');
            connect=['Connect' pref.rp2(n).type];            
            if ~invoke(rp2{n},connect,pref.rp2(n).interface,n);
                set(h,'String', [pref.rp2(n).type ' ' num2str(n) ' FAILURE']);
            end
        catch
            set(h,'String',['Failed to clear/connect ' pref.rp2(n).type]);
            Message(me,['Failed to clear/connect ' pref.rp2(n).type],'error');
            break;
        end
        
        set(h,'String',[pref.rp2(n).type ' ' num2str(n) ' initialized']);
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ClearRP2
% just clears RP2
    RP2=GetParam(me,'RP2');
    rp2description=GetParam(me,'RP2Description');
    nrp2s=GetParam(me,'NRP2s');
    for n=1:nrp2s
        % Clear RP2
        if ~findstr('timestamp',rp2description{n}) % don't stop the circuit running timestamp!
           invoke(RP2{n},'Halt');
           invoke(RP2{n},'ClearCOF');
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);
% me
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
