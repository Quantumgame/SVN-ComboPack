function WaterDelivery(varargin)

% delivers drop of water using a 'subcircuit' in the timestamp circuit

global exper pref

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
case 'init'
    ModuleNeeds(me,{'timestamp','stimulusczar'}); % we use the timestamp circuit for water delivery
    InitializeGUI;
    InitRP2
   
case 'send'
    stimulus=PrepareStimulus;
    StimulusCzar('send',stimulus);
  
case 'load'
    stimulus=PrepareStimulus;
    StimulusCzar('send',stimulus,'notrigger');
      
case 'sethwtrigger'
    RP2=GetParam(me,'RP2');
    status=invoke(RP2,'GetStatus'); % are we connected and loaded?
    if status==3    % but not running
        invoke(RP2,'Run');  
    end    
  try
    invoke(RP2,'SoftTrg',3);
  catch
    Message(me,'HW trigger not set!!!');
  end
  
case 'rp2object'
    out=GetParam(me,'RP2');
  
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitRP2

global exper pref
    if existparam(me, 'RP2')
        RP2=GetParam(me, 'RP2');
    else
        RP2=GetParam('timestamp','RP2');
        RP2h=GetParam('timestamp','RP2h');
        %store these in params
        InitParam(me,'RP2','value',RP2); %param to hold the RP2 activex object
        InitParam(me,'RP2h','value',RP2h); %hidden figure for the RP2 activex object
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
    fig = ModuleFigure(me,'visible','off');	
    
    % GUI positioning factors
    hs = 60;
    h = 5;
    vs = 20;
    n = 0;
    
    uicontrol(fig,'tag','message','style','edit','units','normal',...
        'enable','inact','horiz','left','pos',[0.02 0.02 0.96 0.1]); n = n+1;
%         'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*1]); n = n+1;
    pulse_start=100; % in ms
    InitParam(me,'pulse_start',...
        'value',pulse_start,'units','normal',...
        'ui','edit','pos',[0.02 0.12 0.45 0.1]); n=n+1;
%         'ui','edit','pos',[h n*vs hs vs]); n=n+1;
    pulse_isi=0;
    InitParam(me,'pulse_isi',...
        'value',pulse_isi,'units','normal',...
        'ui','edit','pos',[0.02 0.22 0.45 0.1]); n=n+1;
%         'ui','edit','pos',[h n*vs hs vs]); n=n+1;
    npulses=1;
    InitParam(me,'npulses',...
        'value',npulses,'units','normal',...
        'ui','edit','pos',[0.02 0.32 0.45 0.1]); n=n+1;
%         'ui','edit','pos',[h n*vs hs vs]); n=n+1;
    pulse_width=200;  % in ms
    InitParam(me,'pulse_width',...
        'value',pulse_width,'units','normal',...
        'ui','edit','pos',[0.02 0.42 0.45 0.1]); n=n+2;
%         'ui','edit','pos',[h n*vs hs vs]); n=n+2;
    
    uicontrol('parent',fig,'string','Load','tag','load',...
		'position',[0.02 0.62 0.96 0.18],'fontweight','bold','enable','on','units','normal',...
		'style','pushbutton','callback',[me ';']); n=n+2;
% 		'position',[h n*vs hs*2 vs],'enable','on',...
    
    uicontrol('parent',fig,'string','Send','tag','send','units','normal',...
		'position',[0.02 0.80 0.96 0.18],'fontweight','bold','enable','on','backgroundcolor',[0.9 0.9 0],...
		'style','pushbutton','callback',[me ';']); n=n+2;
% 		'position',[h n*vs hs*2 vs],'enable','on','backgroundcolor',[0.9 0.9 0],...

    screensize=get(0,'screensize');
    set(fig,'pos', [screensize(3)-140 screensize(4)-n*vs-160 140 n*vs] ,'visible','on'); 
    
    % Make figure visible again.
    set(fig,'visible','on');
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimulus=PrepareStimulus;
    stimulus.type='waterdelivery';
    stimulus.param.pulse_width=GetParam(me,'pulse_width');
    stimulus.param.npulses=GetParam(me,'npulses');
    stimulus.param.pulse_isi=GetParam(me,'pulse_isi');
    %stimulus.param.pulse_start=GetParam(me,'pulse_start');
    RP2=GetParam(me,'RP2');
     invoke(RP2,'SetTagVal','WaterDuration',stimulus.param.pulse_width);
     invoke(RP2,'SetTagVal','WaterISI',stimulus.param.pulse_isi);
     invoke(RP2,'SetTagVal','WaterPulses',stimulus.param.npulses);
    