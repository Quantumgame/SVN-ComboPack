function varargout=SingleStimulus(varargin) 

% Simple module playing a single pure tone stimulus with defined parameters
% (frequency, amplitude, duration) via RP2. Uses RP2Load

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
    ModuleNeeds(me,{'ao','ai','patchpreprocess','stimulusczar'});
%    SetParam(me,'priority',GetParam('rp2load','priority')+1);
    fig = ModuleFigure(me,'visible','off');	
    
    figure(fig);
    handle=axes('Units','Pixels','Position',[40 40 160 160]);
    InitParam(me,'PhotoHandle','value',handle);    
    
    xaxis=logspace(3,4.61,1000);
    InitParam(me,'XAxis','value',xaxis);
    
    [x,y]=meshgrid(xaxis,80000:-1000:0);
    z=x+y;
    imagesc(z);
    hold on;
    colormap(bone);
    set(handle,'ButtonDownFcn',[me '(''mark'');']);
    set(gca,'XTick',linspace(1,1000,6),'XTickLabel',[1 2 4.4 10 20 40]);
    set(gca,'YTick',[1 20 40 60 80],'YTickLabel',[0 20 40 60 80]);
    xlabel('kHz');
    
    % GUI positioning factors
    hs = 60;
%    h = 5;
    h=260;
    vs = 20;
    n = 1;
    
    % message box
    uicontrol(fig,'tag','message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*1]); n = n+2;
    
    Duration=500;             % duration of the stimulus in ms
    InitParam(me,'Duration',...
        'value',Duration,...
        'ui','edit','pos',[h n*vs hs vs]); n=n+1;
    Attenuation=10;           % Attenuation of the stimulus
    InitParam(me,'Attenuation',...
        'value',Attenuation,...
        'ui','edit','pos',[h n*vs hs vs]); n=n+1;
    Frequency=5000;         % frequency of the stimulus
    InitParam(me,'Frequency',...
        'value',Frequency,...
        'ui','edit','pos',[h n*vs hs vs]); n=n+2;

% 	InitParam(me,'Load','value',0,'ui','togglebutton','pref',0,'pos',[h n*vs hs vs]);
% 	SetParamUI(me,'Load','string','Load','label',''); n=n+2;

%     InitParam(me,'Run','value',0,'ui','togglebutton','pref',0,'pos',[h n*vs hs vs]);
% 	SetParamUI(me,'Run','string','Run','label','','backgroundcolor',[0.9 0.9 0]); n=n+1;
    
    uicontrol('parent',fig,'string','Load','tag','load',...
		'position',[h n*vs hs vs],'enable','on',...
		'style','pushbutton','callback',[me ';']); n=n+2;
    
    uicontrol('parent',fig,'string','Send','tag','send',...
		'position',[h n*vs hs vs],'enable','on','backgroundcolor',[0.9 0.9 0],...
		'style','pushbutton','callback',[me ';']); n=n+1;
    
    
    set(fig,'pos',[200 200 400 220]);
    % Make figure visible again.
    set(fig,'visible','on');
    
    rate=round(GetParam('ai','samplerate')); 

    InitParam(me,'Stimulus','value',[]);
    
case 'send'
%     if GetParam(me,'run')
%         SetParam(me,'run',0);
%         SetParamUI(me,'run','backgroundcolor',[0.9 0.9 0]);
        stimulus=PrepareStimulus;
        SetParam(me,'Stimulus',stimulus);
 
        StimulusCzar('send',stimulus);
%     end

case 'load'
%     if GetParam(me,'Load')
%         SetParam(me,'Load',0);
        stimulus=PrepareStimulus;
        SetParam(me,'Stimulus',stimulus); 
        StimulusCzar('send',stimulus,'notrigger');
%     end
    
case 'reset'
    Message(me,'');
    
case 'mark'
    [x,y]=ginput(1);
    plot(x,y,'+y');
    xaxis=GetParam(me,'XAxis');
    Message(me,sprintf('%d:%d',round(xaxis(round(x))),round(y)));
    SetParam(me,'Frequency',round(xaxis(round(x))));
    SetParam(me,'Attenuation',round(y/10)*10);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);
% me
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisableParamChange
fig=findobj('type','figure','tag',me);
h=findobj(fig,'type','uicontrol','style','edit');
for cnt=1:length(h)
	set(h(cnt),'enable','off')
end
% DisableParamChange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EnableParamChange
fig=findobj('type','figure','tag',me);
h=findobj(fig,'type','uicontrol','style','edit');
for cnt=1:length(h)
	set(h(cnt),'enable','on')
end
%EnableParamChange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stimulus=PrepareStimulus
        stimulus.type='tone';
        stimulus.param.frequency=GetParam(me,'Frequency');
        stimulus.param.attenuation=GetParam(me,'Attenuation');
        stimulus.param.duration=GetParam(me,'Duration');
        stimulus.param.ramp=3;  % 3ms ramp
