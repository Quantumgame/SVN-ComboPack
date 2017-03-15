function varargout = Pulse( varargin ) 

% creates a pulse(s) for AO module. Pulse is loaded and waits for the
% hwtrigger

global exper pref

varargout{1} = lower(mfilename); 
if nargin > 0
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
        'ui','edit','pos',[0.02 0.12 0.45 0.1]); n=n+1;
    npulses=1;
    InitParam(me,'npulses',...
        'value',npulses,'units','normal',...
        'ui','edit','pos',[0.02 0.22 0.45 0.1]); n=n+1;
    pulse_isi=200;
    InitParam(me,'pulse_isi',...
        'value',pulse_isi,'units','normal',...
        'ui','edit','pos',[0.02 0.32 0.45 0.1]); n=n+1;
    pulse_height=500; % in pA
    InitParam(me,'pulse_height',...
        'value',pulse_height,'units','normal',...
        'ui','edit','pos',[0.02 0.42 0.45 0.1]); n=n+1;
    pulse_width=200;  % in ms
    InitParam(me,'pulse_width',...
        'value',pulse_width,'units','normal',...
        'ui','edit','pos',[0.02 0.52 0.45 0.1]); n=n+2;
    
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
        commandChannelNames={commandChannels.name};
        InitParam(me,'CommandChannelNames','value',commandChannelNames);
    else
        uicontrol('parent',fig,'string','Load AO','tag','loadao','units','normal',...
    		'position',[0.02 0.62 0.96 0.18],'fontweight','bold','enable','on',...
    		'style','pushbutton','callback',[me ';']); n=n+2;
    end
    
    uicontrol('parent',fig,'string','Send','tag','send','units','normal',...
		'position',[0.02 0.80 0.96 0.18],'fontweight','bold','enable','on','backgroundcolor',[0.9 0.9 0],...
		'style','pushbutton','callback',[me ';']); n=n+2;

    set(fig,'pos',[163 646 140 n*vs]);
    
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
    stimulus.type='pulse';    
    stimulus.param.width=GetParam(me,'pulse_width');
    stimulus.param.npulses=GetParam(me,'npulses');
    stimulus.param.isi=GetParam(me,'pulse_isi');
    stimulus.param.start=GetParam(me,'start');
    stimulus.param.height=GetParam(me,'pulse_height');
    stimulus.param.duration=(2*stimulus.param.start+stimulus.param.npulses*stimulus.param.width+(stimulus.param.npulses-1)*stimulus.param.isi); % in ms
    
    nchannels=GetParam(me,'nChannels');
    if nchannels>1
        values=get(GetParam(me,'ChannelButtons'),'Value');
        commandChannelNames=GetParam(me,'CommandChannelNames');
        idx=find([values{:}]);
        if isempty(idx) | length(idx)==nchannels
            return;
        else
            stimulus.param.channel=commandChannelNames{idx(1)};
        end
    end
        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    