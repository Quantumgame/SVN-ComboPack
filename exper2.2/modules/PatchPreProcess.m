function varargout = PatchPreProcess( varargin )

% Scale the incoming data from the AxoPatch 200B.

global exper pref

varargout{1} = lower(mfilename);
if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
    
    case 'init'
        ModuleNeeds(me,{'ao','ai'});
        SetParam(me,'priority','value',GetParam('ai','priority')+1);
        fig = ModuleFigure(me,'visible','off');
        % GUI positioning factors
        hs = 100;
        h = 5;
        vs = 20;
        n = .5;
        modechannel=GetChannel('ai','modechannel');
        InitParam(me,'modechannel','value',[modechannel.number]);
        gainchannel=GetChannel('ai','gainchannel');
        InitParam(me,'gainchannel','value',[gainchannel.number]);
        commandchannel=GetChannel('ao','commandchannel');
        InitParam(me,'commandchannel','value',[commandchannel.number]);
        datachannel=GetChannel('ai','datachannel-patch');
        InitParam(me,'datachannel','value',[datachannel.number]);
        datachannel2=GetChannel('ai','datachannel2-patch'); %adding second channel mw031510
        InitParam(me,'datachannel2','value',[datachannel2.number]);
        datachannel_tetrode=GetChannel('ai','datachannel-tetrode'); %adding tetrode channels mw042612
        InitParam(me,'datachannel_tetrode','value',[datachannel_tetrode.number]);
        
        %adding 2 params to choose whether to set mode and gain from the
        %axopatch (our typical usage) or whether to ignore the axopatch and
        %manually enter the gain, e.g. for a different amplifier.
        %mw 091208
        %default is set by pref.patchpreprocessamp in Prefs.m
        InitParam(me,'amp',...
            'value',1,...
            'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;
        SetParamUI(me,'amp','String','use axopatch|manual gain')
        SetParam(me, 'amp','value',pref.patchpreprocessamp);
        
        InitParam(me,'manualgain',...
            'value',1e4,'visible', 'off', ... %only appears when amp is set to manual
            'ui','edit','pos',[h n*vs 60 vs]);n = n+1;
        
        %refresh button
        uicontrol(fig,'tag','refresh','string','refresh', 'style','pushbutton',...
            'callback', [me ';'], 'pos',[h n*vs 60 vs]); n = n+1;
        
        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'max', 10, 'min', 0, ... %as long as max-min>1, allows multi-line text
            'enable','inact','horiz','left','pos',[h n*vs 160 2.5*vs]); n = n+1;
        
        
        % Data parameters
        [mode, gain]=GetModeAndGain;
        InitParam(me,'mode','value',mode);
        InitParam(me,'gain','value',gain);
        
        % Resize
        n = n+.5;
        set(fig,'pos',[163 646 180 115]);
        % Make figure visible again.
        set(fig,'visible','on');
        
        %refresh
        PatchPreProcess('amp');
        
    case {'getready','reset'}
        
        amp=GetParam(me, 'amp');
        fig=findobj('tag','patchpreprocess');
        h=findobj('tag','message', 'parent', fig);
        switch amp
            case 1 %use axopatch
                [Mode, Gain]=GetModeAndGain;
                string=textwrap(h, {'using axopatch', sprintf('mode: %s', Mode{1}), sprintf('gain: %.1f', Gain(1))});
                Message(me, string)
            case 2 %use manual gain
                %                 [Mode, Gain]=GetModeAndGain; %just to get size
                %                 for i=1:length(Mode)
                %                     Mode{i}='I=0';
                %                 end
                %                 Gain=GetParam(me, 'manualgain')*ones(size(Gain));
                %mw 042612 adapting to tetrode use
                Mode{1}='I=0';
                Gain=GetParam(me, 'manualgain');
                string=textwrap(h, {'manual override', sprintf('mode: %s', Mode{1}), sprintf('gain: %.1f', Gain(1))});
                Message(me, string)
        end
        SetParam(me,'gain','value',Gain);
        SetParam(me,'mode','value',Mode);
        
        % Get the channel to have its ranges modified.
        dataChannels=GetParam(me,'datachannel');
        % modify the range of channels
        for channel=1:length(Gain)  % mode and gain have the same length, and Mode can be just a string
            % get the channel
            if ~isempty(dataChannels)
                DataCh=daqfind(exper.ai.daq,'HwChannel',dataChannels(channel));
                DataCh=DataCh{1}.Index;
                % set scaling
                daqrange=[-10 10];
                exper.ai.daq.Channel(DataCh).InputRange=daqrange;
                exper.ai.daq.Channel(DataCh).UnitsRange=daqrange;
                exper.ai.daq.Channel(DataCh).SensorRange=daqrange*Gain(channel)/1000;
                
                % and set also the units
                switch Mode{channel}
                    case {'Track','V-Clamp'}
                        exper.ai.daq.Channel(DataCh).Units='pA';
                    case {'I=0','I-Clamp Normal','I-Clamp Fast'}
                        exper.ai.daq.Channel(DataCh).Units='mV';
                end
            end
            
            %adding second channel mw031510
            
            dataChannel2=GetParam(me,'datachannel2');
            if ~isempty(dataChannel2)
                DataCh2=daqfind(exper.ai.daq,'HwChannel',dataChannel2(channel));
                DataCh2=DataCh2{1}.Index;
                % set scaling
                daqrange=[-10 10];
                exper.ai.daq.Channel(DataCh2).InputRange=daqrange;
                exper.ai.daq.Channel(DataCh2).UnitsRange=daqrange;
                exper.ai.daq.Channel(DataCh2).SensorRange=daqrange*Gain(channel)/1000;
                % and set also the units
                switch Mode{channel}
                    case {'Track','V-Clamp'}
                        exper.ai.daq.Channel(DataCh2).Units='pA';
                    case {'I=0','I-Clamp Normal','I-Clamp Fast'}
                        exper.ai.daq.Channel(DataCh2).Units='mV';
                end
            end
            %adding tetrode channels mw042612
            datachannel_tetrode=GetParam(me,'datachannel_tetrode');
            if ~isempty(datachannel_tetrode)
                
                TetrodeCh=daqfind(exper.ai.daq,'HwChannel',datachannel_tetrode(channel));
                TetrodeCh=TetrodeCh{1}.Index;
                % set scaling
                daqrange=[-10 10];
                exper.ai.daq.Channel(TetrodeCh).InputRange=daqrange;
                exper.ai.daq.Channel(TetrodeCh).UnitsRange=daqrange;
                exper.ai.daq.Channel(TetrodeCh).SensorRange=daqrange;
                
                % and set also the units
                switch Mode{channel}
                    case {'Track','V-Clamp'}
                        exper.ai.daq.Channel(TetrodeCh).Units='pA';
                    case {'I=0','I-Clamp Normal','I-Clamp Fast'}
                        exper.ai.daq.Channel(TetrodeCh).Units='mV';
                end
                
            end
            
            
        end
        
    case 'refresh'
        PatchPreProcess('amp');
    case 'getmode'
        if ~getparam('control', 'run')
            PatchPreProcess('refresh'); %mw 03.22.14
        end
        varargout{1}=GetParam(me,'Mode');
        
    case 'getgain'
        if ~getparam('control', 'run')
            PatchPreProcess('refresh'); %mw 03.22.14
        end
        varargout{1}=GetParam(me,'Gain');
        
    case {'amp', 'manualgain'} %mw 091208
        amp=GetParam(me, 'amp');
        fig=findobj('tag','patchpreprocess');
        h=findobj('tag','message', 'parent', fig);
        switch amp
            case 1 %use axopatch
                if isfield(pref,'rigconfig') %added 6jun2012 by mk to avoid rig2 error due to no pref.rigconfig on this machine
                    if strcmp(pref.rigconfig, 'tetrode')
                        error('PatchPreProcess: cannot use axopatch when pref.rigconfig set to ''tetrode''');
                    end
                end
                [Mode, Gain]=GetModeAndGain;
                string=textwrap(h, {'using axopatch', sprintf('mode: %s', Mode{1}), sprintf('gain: %.1f', Gain(1))});
                Message(me, string)
                g=findobj('tag', 'manualgain');
                set(g, 'visible', 'off');
            case 2 %use manual gain
                %keyboard
                %[Mode, Gain]=GetModeAndGain; %just to get size
                %for i=1:length(Mode)
                %    Mode{i}='I=0';
                %end
                %Gain=GetParam(me, 'manualgain')*ones(size(Gain));
                Mode{1}='I=0';
                Gain=GetParam(me, 'manualgain'); %mw042612
                string=textwrap(h, {'manual override', sprintf('mode: %s', Mode{1}), sprintf('gain: %.1f', Gain(1))});
                Message(me, string)
                g=findobj('tag', 'manualgain');
                set(g, 'visible', 'on');
        end
        SetParam(me,'gain','value',Gain);
        SetParam(me,'mode','value',Mode);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mode=AxonMode( Readings )
% Discover the operating mode of the Axon 200B.
% Modes
% 1		Track
% 2		V-Clamp
% 3		I=0
% 4		I-Clamp Normal
% 6		I-Clamp Fast

% Preserve input matrix size for output later.
sizeout=size(Readings);
PossibleReadings=[1 2 3 4 6];
PossibleModes={'I-Clamp Fast','I-Clamp Normal','I=0','Track','V-Clamp'};
% To get look up indices, make ndgrid of readings and possible readings.
% The find minimum differences and use them to index the possible gains.
[Readings,PossibleReadings]=ndgrid(Readings,PossibleReadings);
[dum,inds]=min(abs(Readings-PossibleReadings),[],2);
% If all modes/indices were the same, return a single string.
if (prod(size(unique(inds)))==1)
    Mode=PossibleModes(inds(1));
    Mode=Mode{1};
else
    % Otherwise, reshape to match the input matrix shape.
    Mode=PossibleModes(inds);
    Mode=reshape(Mode,sizeout);
end
%function Mode = AxonMode( Readings )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Gain=AxonGain(Readings)
% Discover the gain setting of the Axon 200B.

%	Telegraph Reading (V):		0.5		1	1.5	2.0	2.5	3.0	3.5	4.0	4.5	5.0	5.5	6.0	6.5
%	Gain (mV/mV) or (mV/pA):	0.05	0.1	0.2	0.5	1	2	5	10	20	50	100	200	500

% Preserve input matrix size for output later.
sizeout=size(Readings);
% Make matrices of the possible telegraph readings and corresponding gains.
PossibleReadings=[0.5:0.5:6.5];
PossibleGains=[0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500];
% To get look up indices, make ndgrid of readings and possible readings.
% The find minimum differences and use them to index the possible gains.
[Readings,PossibleReadings]=ndgrid(Readings,PossibleReadings);
[dum,inds]=min(abs(Readings-PossibleReadings),[],2);
Gain=PossibleGains(inds);
% Reshape to match the input matrix shape.
Gain=reshape(Gain,sizeout);
%function Gain=AxonGain(Readings)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Mode, Gain]=GetModeAndGain
% Get the gain for scaling.
% to find out the gain we need to create an ai object and read a value
% from the gainchannel and mode channel
daqrange=[-10 10];

gainChannels=GetParam(me,'gainchannel');
modeChannels=GetParam(me,'modechannel');
nChannels=length(gainChannels);
Gain=zeros(1,nChannels);
Mode={};

for channel=1:nChannels
    boardn=daqhwinfo('nidaq', 'BoardNames');
    switch version %mw 08.28.08
        case '7.6.0.324 (R2008a)' %new version of matlab refers to devices differently
            switch boardn{1} %mw 04.18.06
                case 'PCI-6052E'
                    ai=analoginput('nidaq','Dev1');
                case 'PCI-6289'
                    ai=analoginput('nidaq','Dev1'); %mw 12.16.05
            end
        otherwise %assume old version of matlab
            switch boardn{1} %mw 04.18.06
                case 'PCI-6052E'
                    ai=analoginput('nidaq',1);
                case 'PCI-6289'
                    ai=analoginput('nidaq','Dev1'); %mw 12.16.05
            end
    end
    %
    % NOTE: originally patchpreprocess used differential inputs for nidaq, which,
    % in our case meant up to 8 channels. With single ended inputs, as in
    % case of AI, we can use 16 channels
    %get the type of input types the board likes
    %if its possible to set the InputType to SingleEnded, then do it
    % 2004/11/10 - foma - I talked to Mike Wehr, and decided to switch to
    % differential
    % We're going to use differential inputs
    % see also open_ai above
    %     	inputs=propinfo(ai,'InputType');
    %     	%if its possible to set the InputType to SingleEnded, then do it
    %     	if ~isempty(find(strcmpi(inputs.ConstraintValue, 'SingleEnded')))
    %     		ai.InputType='SingleEnded';
    %     	end
    
    addchannel(ai,[gainChannels(channel) modeChannels(channel)]);
    set(ai.Channel,'UnitsRange',daqrange)
    set(ai.Channel,'InputRange',daqrange);
    set(ai.Channel,'SensorRange',daqrange);
    status_sample=getsample(ai);
    delete(ai);
    clear('ai');
    % get the gain and mode
    CurrentGain=AxonGain(status_sample(1));
    CurrentMode=AxonMode(status_sample(2));
    
    Gain(channel)=CurrentGain;
    Mode={Mode{:} CurrentMode};
end
%function [Mode, Gain]=SetModeAndGain

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out=me
out=lower(mfilename);