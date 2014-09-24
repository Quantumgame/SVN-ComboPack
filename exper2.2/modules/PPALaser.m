function varargout = PPALaser( varargin ) 

% creates a TTL-like pulse to drive laser on last channel of soundcard
% using PPA 
%
%To use this module, 
% 1. load an Interleaved Arch Protocol in StimulusProtocol
% 2. set start (in ms relative to sound onset) and width (in ms)
% 3. click 'on' togglebutton
% 4. run BNC from last soundcard channel to laser TTL input
% 5. run a T off this BNC into ACH3 to record a copy the pulse (you might
% need to disconnect the BNC from DAC1 if you were using the AOpulse for
% the laser)
%
%Notes:
%-the timing of the laser pulse is controlled by the values in
% this module, not the values in the Interleaved Arch Protocol.
%-for a binaural rig, set pref.num_soundcard_outputchannels to 4
%   Ch1: R sound
%   Ch2: L sound
%   Ch3: soundcard triggers 
%   Ch4: laser pulse
%-for a monaural rig, set pref.num_soundcard_outputchannels to 3
%   Ch1: sound 
%   Ch2: soundcard triggers 
%   Ch3: laser pulse
%-this only works with PPASound, not AOSound, configure Prefs accordingly
%
%New as of December 2012:
%PPALaser now has the ability to do multiple pulses. Just set numpulses and
%isi to whatever you want.
%Want to make a more complicated train of pulses? You can enter a list of
%values into isi and width. Just make sure that numpulses matches the
%length of the list of widths, and that the list of isis is shorter by one.
%Or you could enter a single width with multiple isis, or a single isi with
%multiple widths. If you are making a more complicated train be sure to
%watch PPASound for error messages and use the oscilliscope to verify that
%the pulsetrain is what you intend.
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
  %  ModuleNeeds(me,{'ppasound'});
    SetParam(me,'priority','value',GetParam('ppasound','priority')+1);
    fig = ModuleFigure(me);	
    
    % GUI positioning factors
    hs = 60;
    h = 5;
    vs = 20;
    n = 0;
    
    start=100; % in ms, + indicates laser follows tone, - indicates laser precedes tone
    width=200;  % in ms
    numpulses=1;
    isi=100;

   % message box
    uicontrol(fig,'tag','message','style','edit','units','normal',...
        'horiz','left','pos',[0.02 0.02 0.96 0.3]); n = n+1;
    start=0; % in ms, + indicates laser follows tone, - indicates laser precedes tone
   width=100;  % in ms
   numpulses=1;
   isi=100; %ms
   
   InitParam(me,'on',...
       'value',0,'units','normal',...
       'ui','togglebutton','pos',[0.02 0.72 0.45 0.1]); n=n+2;
   InitParam(me,'start',...
       'value',start,'units','normal',...
       'ui','edit','pos',[0.02 0.62 0.45 0.1]); n=n+1;
   InitParam(me,'width',...
       'value',width,'units','normal',...
       'ui','edit','pos',[0.02 0.52 0.45 0.1]); n=n+1;
   InitParam(me,'numpulses',...
       'value',numpulses,'units','normal',...
       'ui','edit','pos',[0.02 0.42 0.45 0.1]); n=n+1;
   InitParam(me,'isi',...
       'value',isi,'units','normal',...
       'ui','edit','pos',[0.02 0.32 0.45 0.1]); n=n+1;
   
   uicontrol('style','pushbutton','string','help',...
       'callback',[me ';'],'tag','help',...
       'units','normal','pos',[0.69 0.9 0.3 0.1]);

    set(fig,'pos',[106   100   150   199]);
    
    % Make figure visible again.
     set(fig,'visible','on');
      
% case 'reset'
%     
% case 'trialready'
%         
% case 'close'
    case 'on'
        on=GetParam(me, 'on');
        if on
            message(me, 'ppaLaser is ON.')
            set(gcbo, 'BackgroundColor', 'r', 'string', 'on')
        else
             message(me, 'I am turned off, change BNCs')
                         set(gcbo, 'string', 'off', 'BackgroundColor', [.8 .8 .8] )
        end
       case 'help'
        helpstr=help(me);
        m = figure;
        set(m, 'position', [360   100   600   600]);
        OKHandle=uicontrol(m                             , ...
            'Style'              ,'pushbutton'                      , ...
            'Units'              ,'normal'                          , ...
            'Position'           , [.44 .04 .08 .04]                            , ...
            'CallBack'           ,'delete(gcbf)'                    , ...
            'String'             ,'OK'                              , ...
            'HorizontalAlignment','center'                          , ...
            'Tag'                ,'OKButton'                          ...
            ); 
        uicontrol('Parent',m,...
            'Units','normalized',...
            'Position',[0.02,0.1,0.96,0.9],...
            'Style','edit',...
            'Max',100,...
            'Enable','inactive',...
            'HorizontalAlignment','left'                          , ...
            'String',helpstr) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    