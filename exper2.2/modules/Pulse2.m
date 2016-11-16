function varargout = Pulse( varargin ) 

% creates a pulse(s) for AO module. Pulse is loaded and waits for the
% hwtrigger

global exper pref

varargout{1} = lower(mfilename); if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
case 'init'
    %required modules
    ModuleNeeds(me,{'stimulusczar'});
%    SetParam(me,'priority','value',GetParam('PatchPreProcess','priority')+1);
    fig = ModuleFigure(me);	
    
    % GUI positioning factors
    hs = 60;
    h = 5;
    vs = 20;
    n = 0;
    
    % message box
    uicontrol(fig,'tag','message','style','edit','units','normal',...
        'enable','inact','horiz','left','pos',[0.02 0.02 0.96 0.1]); n = n+1;
    start=100; % in ms
    InitParam(me,'start',...
        'value',start,'units','normal',...
        'ui','edit','pos',[0.02 0.12 0.2 0.1]); n=n+1;
    npulses=1;
    InitParam(me,'npulses',...
        'value',npulses,'units','normal',...
        'ui','edit','pos',[0.02 0.22 0.2 0.1]); n=n+1;
    pulse_isi=200;
    InitParam(me,'pulse_isi',...
        'value',pulse_isi,'units','normal',...
        'ui','edit','pos',[0.02 0.32 0.2 0.1]); n=n+1;
    pulse_height=500; % in pA
    InitParam(me,'pulse_height',...
        'value',pulse_height,'units','normal',...
        'ui','edit','pos',[0.02 0.42 0.2 0.1]); n=n+1;
    pulse_width=200;  % in ms
    InitParam(me,'pulse_width',...
        'value',pulse_width,'units','normal',...
        'ui','edit','pos',[0.02 0.52 0.2 0.1]); n=n+2;
    
    % message box: second electrode
    start2=100; % in ms
    InitParam(me,'start2',...
        'value',start2,'units','normal',...
        'ui','edit','pos',[0.5 0.12 0.2 0.1]); n=n+1;
    npulses2=1;
    InitParam(me,'npulses2',...
        'value',npulses2,'units','normal',...
        'ui','edit','pos',[0.5 0.22 0.2 0.1]); n=n+1;
    pulse_isi2=200;
    InitParam(me,'pulse_isi2',...
        'value',pulse_isi2,'units','normal',...
        'ui','edit','pos',[0.5 0.32 0.2 0.1]); n=n+1;
    pulse_height2=500; % in pA
    InitParam(me,'pulse_height2',...
        'value',pulse_height2,'units','normal',...
        'ui','edit','pos',[0.5 0.42 0.2 0.1]); n=n+1;
    pulse_width2=200;  % in ms
    InitParam(me,'pulse_width2',...
        'value',pulse_width2,'units','normal',...
        'ui','edit','pos',[0.5 0.52 0.2 0.1]); n=n+2;
    
    commandChannels=GetChannel('ao','commandchannel');
    nChannels=length(commandChannels);
    InitParam(me,'nChannels','value',nChannels);
    if nChannels>1
        uicontrol('parent',fig,'string','Load AO','tag','loadao','units','normal',...
    		'position',[0.02 0.71 0.96 0.09],'fontweight','bold','enable','on',...
    		'style','pushbutton','callback',[me ';']); n=n+2;
        channelButtons=zeros(1,nChannels);
        commandChannelColors={commandChannels.color};
        bSize=0.96/nChannels;
        for channel=1:nChannels
            bPos=0.02+(channel-1)*bSize;
            channelButtons(channel)=uicontrol('Style','togglebutton','units','normal','tag','channelbutton',...
                'value',0,'backgroundcolor',commandChannelColors{channel},'pos',[bPos 0.62 bSize 0.09],...
                'ForegroundColor',[1 1 1],'CallBack',[me ';'],'FontWeight','bold');    
        end
        InitParam(me,'ChannelButtons','value',channelButtons);
%         commandChannelNames={commandChannels.name};
%         InitParam(me,'CommandChannelNames','value',commandChannelNames);
    else
        uicontrol('parent',fig,'string','Load AO','tag','loadao','units','normal',...
    		'position',[0.02 0.62 0.96 0.18],'fontweight','bold','enable','on',...
    		'style','pushbutton','callback',[me ';']); n=n+2;
    end
    commandChannelNames={commandChannels.name};
    InitParam(me,'CommandChannelNames','value',commandChannelNames);
    
    uicontrol('parent',fig,'string','Send','tag','send','units','normal',...
		'position',[0.02 0.80 0.96 0.18],'fontweight','bold','enable','on','backgroundcolor',[0.9 0.7 0],...
		'style','pushbutton','callback',[me ';']); n=n+2;

    set(fig,'pos',[163 646 340 n*vs]);
    
    % Make figure visible again.
%     set(fig,'visible','on');
      
% case 'reset'
%     
% case 'trialready'
%         
% case 'close'

case 'loadao'
    stimulus=PrepareStimulus;
    StimulusCzar('send',stimulus,'notrigger');

case 'send'
    stimulus=PrepareStimulus;
    StimulusCzar('send',stimulus);
    
case 'channelbutton'
    button=gco;
    if get(button,'Value')
       set(button,'String','On');
   else
       set(button,'String','');
   end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stimulus=PrepareStimulus
    commandChannelNames=GetParam(me,'CommandChannelNames');

    stim(1).type='pulse';    
    stim(1).param.width=    GetParam(me,'pulse_width');
    stim(1).param.npulses=  GetParam(me,'npulses');
    stim(1).param.isi=      GetParam(me,'pulse_isi');
    stim(1).param.start=    GetParam(me,'start');
    stim(1).param.height=   GetParam(me,'pulse_height');
    stim(1).param.channel=  commandChannelNames{1};
    
    stim(2).type='pulse';    
    stim(2).param.width=    GetParam(me,'pulse_width2');
    stim(2).param.npulses=  GetParam(me,'npulses2');
    stim(2).param.isi=      GetParam(me,'pulse_isi2');
    stim(2).param.start=    GetParam(me,'start2');
    stim(2).param.height=   GetParam(me,'pulse_height2');

    nchannels=GetParam(me,'nChannels');
    if nchannels>1
        stim(2).param.channel=  commandChannelNames{2};
        values=get(GetParam(me,'ChannelButtons'),'Value');
        idx=find([values{:}]);
        pressed=length(idx);
        switch pressed
            case 1
                stimulus=stim(idx(1));
            case 0
                stimulus.type={stim(1).type stim(2).type};
                stimulus.param={stim(1).param stim(2).param};
            case 2
                stimulus.type={stim(1).type stim(2).type};
                stimulus.param={stim(1).param stim(2).param};
        end
    else
        stimulus=stim(1);
    end
        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    