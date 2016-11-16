function HoldCmd( varargin )

%exper module for programmatic control of Axopatch 200B external holding commands
%mw 10-01

global exper

% error('turn holdcmd ramp back on at bottom of rp2daddy.m')

if nargin > 0
    if isobject( varargin{1} )
    else
        action = lower(varargin{1});
    end
else
    action = lower(get(gcbo,'tag'));
end

Message(me,action);
switch action
    
case 'init'
    
    ModuleNeeds(me,{'ao','patchpreprocess'});
    
    SetParam(me,'priority','value', GetParam('sealtest2','priority')+1);
    fig = ModuleFigure(me);
    set(fig,'DoubleBuffer','on');
    set(fig,'menubar','figure');
%    set(fig, 'pos', [162   429   278   185]);
    set(fig, 'pos', [162   429   278   245]);
    
    % Parameters for gui spacing
    hs = 60;
    h = 5;
    vs = 20;
    n = 0;
    m = 0;
    
    v_height=-10;
    InitParam(me,'v_height',...
        'value',v_height,...
        'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    v_width=50;
    InitParam(me,'v_width',...
        'value',v_width,'range',[26 Inf],...
        'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs],'save',1); 
    
    n=n+1;
    v_onset=500;
    InitParam(me,'v_onset',...
        'value',v_onset,'range',[26 Inf],...
        'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs],'save',1); 
    
    n=n+1;
    i_height=-100;
    InitParam(me,'i_height',...
        'value',i_height,...
        'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    i_width=100;
    InitParam(me,'i_width',...
        'value',i_width,'range',[26 Inf],...
        'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs],'save',1); 
    n=n+1;
    
    TrialNum = GetParam('control','trial');
    Mode = GetParam('patchpreprocess','mode');
    Mode = Mode{TrialNum};
    
    switch Mode
    case { 'Track','V-Clamp' }
        npulses=10;
        potentials={'-80', '-60', '-20', '0', '+20'};
        manual_cmd=-70;
    case { 'I=0','I-Clamp Normal','I-Clamp Fast' }    
        potentials={'-500', '-250', '0', '+250', '+500'};
        npulses=5;
        manual_cmd=-70;
    end
    InitParam(me,'mode',...
        'value',Mode,'save', 1, ...
        'ui','disp','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    InitParam(me, 'npulses', 'value', npulses, 'save', 1)   
    
    
    InitParam(me,'manual_cmd',...
        'value',manual_cmd,'ui','edit', 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0); 
    n=n+1;
    InitParam(me,'set_manual',...
        'value',0,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0); 
    SetParamUI(me,'set_manual','background',[.8 .8 .8],'label',''); 
    n=n+1;
    
    InitParam(me,'set_0',...
        'value',0,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0); 
    SetParamUI(me,'set_0','background',[.8 .8 .8],'label',''); 
n=n+1;
    
    InitParam(me,'set_70',...
        'value',0,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0); 
    SetParamUI(me,'set_70','background',[.8 .8 .8],'label',''); 

    n=n+1;
    InitParam(me,'onoff',...
        'value',1,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',1); 
    SetParamUI(me,'onoff','string','On','label',''); n=n+1;
    n=n+1;
   
    
    n=0;
    m=1;
    
    rampdur=1;
    InitParam(me,'rampdur',...
        'value',rampdur,...
        'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    
%    nrp2trials=length(exper.rp2daddy.param.tones.value);
     nrp2trials=length(exper.rp2repeater2.param.tones.value);
    InitParam(me,'nrp2trials',...
        'value',nrp2trials,...
        'ui','disp','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    
    %default nrepeats
    nrepeats=10;
    InitParam(me,'nrepeats',...
        'value',nrepeats,...
        'ui','edit','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;   
    
    
    %default potentials
     InitParam(me,'potentials', 'value', 1, 'String', potentials,...
         'list',potentials,'ui','popupmenu','pos',[h+m*2*(hs+h) n*vs hs vs]);
    SetParam('holdcmd', 'potentials', 'list', potentials);
    n=n+1;
    
    
    InitParam(me,'ntrials',...
        'value',0,...
        'ui','disp','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    
    InitParam(me,'lastpotential',...
        'value',0,'save', 1, ...
        'ui','disp','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    InitParam(me,'thispotential',...
        'value',0,'save', 1, 'fontsize', '12',...
        'ui','disp','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    InitParam(me,'nextpotential',...
        'value',0,'save', 1, ...
        'ui','disp','pos',[h+m*2*(hs+h) n*vs hs vs]); 
    n=n+1;
    

    InitParam(me, 'settings','String', ' ', 'value', 1,...
        'ui','popupmenu','pos',[h+m*2*(hs+h) n*vs 2*hs vs]);
    n=n+1;
    
%     InitParam(me, 'potentialsequence','String', '', 'value', 1,...
%         'ui','popupmenu','pos',[h+m*2*(hs+h) n*vs hs vs]);
%     n=n+1;
    InitParam(me, 'potentialsequence','String', '', 'value', 1       );
    %n=n+1;
    
    % message box
    uicontrol(fig,'tag','message','style','edit',...
        'enable','inact','horiz','left','pos',[h+m*2*(hs+h) n*vs 2*hs vs]);
    n=n+1;
    
    InitParam(me,'Resequence',...
        'value',0,'ui','togglebutton','pref',0, 'label', '','pos',[h+m*2*(hs+h) n*vs hs vs],'save',0); 
    n=n+1;
    InitParam(me,'Reset',...
        'value',0,'ui','togglebutton','pref',0, 'pos',[h+m*2*(hs+h) n*vs hs vs],'save',0); 
    SetParamUI(me,'reset','background',[.8 .8 .8],'label','','foregroundcolor',[.9 0 0]); 
    
    n=n+1;
    
    
    settings;
    resequence
    AO('reset');    
    callmodule(me,'reset');
    n=n+1;
    
    
case 'slice'
    
case { 'trialready' , 'reset' }
    
    if getparam(me, 'reset') 
        setparam(me, 'reset', 0);
    end
    
    if getparam(me, 'onoff')    
        TrialNum = GetParam('control','trial');
        Message(me, ['trial ',int2str(TrialNum)]);
        Mode = GetParam('patchpreprocess','mode');
        Mode = Mode{TrialNum};
        setparam(me, 'mode', Mode);
        
        switch Mode
        case { 'Track','V-Clamp' }
            % Because 20 mV/V, divide by 20.
            SetParam(me, 'npulses', 10) %because they're short, we can do 10
            ph = GetParam(me,'v_height');
            pw=GetParam(me,'v_width');
            phScaled=ph / 20;
            potentialsequence=getparam(me, 'potentialsequence','list');
            if TrialNum<=length(potentialsequence)
                potential=potentialsequence{TrialNum};
                setparam(me, 'thispotential', 'value', potential);
                if TrialNum>1
                    lastpotential=potentialsequence{TrialNum-1};                    
                    if TrialNum<=length(potentialsequence)-1
                        nextpotential=potentialsequence{TrialNum+1};
                    else
                        nextpotential=-70;
                    end
                    setparam(me, 'lastpotential', 'value', lastpotential);
                    setparam(me, 'nextpotential', 'value', nextpotential);
                else
                    nextpotential=potentialsequence{TrialNum+1};
                    lastpotential=-70;
                    setparam(me, 'lastpotential', 'value', lastpotential);
                    setparam(me, 'nextpotential', 'value', nextpotential);
                end
                potentialscaled=potential/20;
                lastpotentialscaled=lastpotential/20;
                nextpotentialscaled=nextpotential/20;
            else
                setparam(me, 'thispotential', 'value', -70);
                potentialscaled=-70/20;
                nextpotentialscaled=-70/20;
                Message(me, 'sequence finished!');
            end
        case { 'I=0','I-Clamp Normal','I-Clamp Fast' }
            % Because 2/beta nA/V = 2000/beta pA/V, scale.
            % Assumes beta = 1. Figure out what I should do.
            SetParam(me, 'npulses', 3) %because they're longer, we can only do 5            
            ph = GetParam(me, 'i_height');
            pw=GetParam(me,'i_width');
            phScaled=ph/(2e3);
            
            potentialsequence=getparam(me, 'potentialsequence','list');           
            if TrialNum<=length(potentialsequence)
                potential=potentialsequence{TrialNum};
                setparam(me, 'thispotential', 'value', potential);
                potentialscaled=potential/2e3;
            else
                setparam(me, 'thispotential', 'value', 0);
                potentialscaled=0;
                nextpotentialscaled=0;
                Message(me, 'sequence finished!');
            end   
            %nextpotentialscaled should be set in the above if-block, this is a hack 
            nextpotentialscaled=0;
            
        end
        
        % Create and send step waveform.
        CommandCh = GetParam('patchpreprocess','commandchannel');
        CommandCh = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
        CommandCh = CommandCh{1}.Index;
        samples=potentialscaled*ones( size( exper.ao.data{1}(:,CommandCh) ) );
        v_onset=getparam(me, 'v_onset'); %onset timing of voltage pulse
        
%         %add ramp at beginning from previous potential to this potential 
%         rampdur=getparam(me, 'rampdur');
%         rampinds=1:rampdur*GetParam('ao','SampleRate');
%         samples(rampinds)=linspace(lastpotentialscaled,potentialscaled, length(rampinds));
        
        %add ramp at end from this potential to next potential 
        rampdur=getparam(me, 'rampdur');
        rampinds=(length(samples)-rampdur*GetParam('ao','SampleRate'))+1:length(samples);
        samples(rampinds)=linspace(potentialscaled,nextpotentialscaled, length(rampinds));
        
        %add n sealtest-like pulses to ao samples, since we just overwrote sealtest's pulse  
        for i=1:GetParam(me,'npulses')
            pulseinds=(1e-3)*GetParam('ao','SampleRate')*(2*pw*(i-1)+v_onset): ceil((1e-3)*GetParam('ao','SampleRate')*((2*i-1)*pw +v_onset));
            samples( pulseinds ) = samples( pulseinds ) + phScaled*ones( size( pulseinds ) )';
        end
        
        %  send samples to AO.
        AO('setchandata',CommandCh,samples);
        AO('trialready');
        %h=findobj('tag', 'holdcmd', 'type', 'figure');
        %figure(h);
        %plot(samples);
        %axis([0 1000 -1 .1])
    end
case 'trialend'
    SaveParamsTrial(me);
    
    
case 'close'
    %    stop( ao );
    %    stop( ai );
    %    delete( ao );
    %    delete( ai );
    %    delete( dio );
    %    clear ai ao dio DataCh GainCh ModeCh samples ph pw fig curaxes curline RunningH RsH RtH
    
    % Now for its own modes.
case 'resequence'
    resequence
    setparam(me, 'resequence', 0)

case {'nrepeats', 'potentials', 'resequence'}    
    resequence
    setparamui(me, 'potentials', 'value', 1)
    
case 'onoff'
    h=findobj('tag', 'onoff');
    if getparam(me, 'onoff')
        SetParamUI(me,'onoff','string','On','label','');         
    else
        SetParamUI(me,'onoff','string','Off','label','');         
    end
    
case 'settings'
    settings
    
case 'potentialsequence'
    setparamui(me, 'potentialsequence', 'value', 1)
    
case 'set_manual'
    %set ao data to manual_cmd, in order to clear a holding potential still left
    %from a previous trial, sealtest, or whatever
    CommandCh = GetParam('patchpreprocess','commandchannel');
    CommandChobj = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
    CommandChline = CommandChobj{1}.Index;
    cmd=getparam(me, 'manual_cmd');
    cmdvec=zeros(size(exper.ao.daq));
    VClamp_extcmd_factor=20; %20 mV/V factor for V-Clamp ext cmd on the axopatch 200b
    cmdvec(CommandChline)=cmd/VClamp_extcmd_factor;
    ao('putsample', cmdvec);
    setparam(me, 'set_manual', 0)
    
case 'set_0'
    %set ao data to manual_cmd, in order to clear a holding potential still left
    %from a previous trial, sealtest, or whatever
    CommandCh = GetParam('patchpreprocess','commandchannel');
    CommandCh = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
    CommandCh = CommandCh{1}.Index;
    cmd=0;
    ao('putsample', [cmd 0]/20);
    setparam(me, 'set_0', 0)
    
case 'set_70'
    %set ao data to manual_cmd, in order to clear a holding potential still left
    %from a previous trial, sealtest, or whatever
    CommandCh = GetParam('patchpreprocess','commandchannel');
    CommandCh = daqfind( exper.ao.daq, 'hwchannel', CommandCh );
    CommandCh = CommandCh{1}.Index;
    cmd=-70;
    ao('putsample', [cmd 0]/20);
    setparam(me, 'set_70', 0)
    
end %switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newao=InitDAQAO

global exper

stopandstartao = isfield(exper,'ao') & isfield(exper.ao,'daq') & isobject(exper.ao.daq) & ...
    strcmp( get(exper.ao.daq,'Running'),'On');
if stopandstartao
    stop( exper.ao.daq );
end

CommandCh = GetParam('patchpreprocess','commandchannel');
% Create ao.
newao=analogoutput('nidaq',1);
addchannel(newao,CommandCh);
newao.Channel(:).OutputRange=[-10 10];
newao.Channel(:).UnitsRange=[-10 10];
% Set trigger.
newao.TriggerType = 'HwDigital';
% Set sample rate.
newao.SampleRate = GetParam('ao','samplerate');

if stopandstartao
    AO('putdata');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newai=InitDAQAI

global exper

stopandstartai=strcmp(get(exper.ai.daq,'Running'),'On');
if stopandstartai
    stop( exper.ai.daq );
end

RawCh = GetParam('patchpreprocess','datachannel');
GainCh = GetParam('patchpreprocess','gainchannel');
ModeCh = GetParam('patchpreprocess','modechannel');
% Create ai.
newai=analoginput('nidaq',1);
addchannel(newai,[RawCh GainCh ModeCh]);
newai.Channel(:).InputRange=[-10 10];
newai.Channel(:).SensorRange=[-10 10];
newai.Channel(:).UnitsRange=[-10 10];
% Set trigger.
newai.TriggerType = 'HwDigital';
% Copy the sample rate from the other module.
newai.SampleRate = GetParam('ai','samplerate');
% Set length to be twice the pulse length.
newai.SamplesPerTrigger = ceil(newai.SampleRate);
% Call this file at the end.
%ai.StopAction = [ me ];

if stopandstartai
    start( exper.ai.daq );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newdio=InitDAQDIO
newdio=digitalio('nidaq',1);
trigchan=GetParam('dio','trigchan');
if ischar(trigchan)
    trigchan=str2double(trigchan);
end
addline(newdio, trigchan, 'out');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mode = AxonMode( Readings )
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
[dum,inds]=min( abs(Readings - PossibleReadings), [], 2);

% If all modes/indices were the same, return a single string.
if ( prod(size(unique(inds))) == 1 )
    Mode=PossibleModes( inds(1) );
else
    % Otherwise, reshape to match the input matrix shape.
    Mode=PossibleModes(inds);
    Mode=reshape(Mode,sizeout);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Gain=AxonGain( Readings )

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
[dum,inds]=min( abs(Readings - PossibleReadings), [], 2);
Gain=PossibleGains(inds);

% Reshape to match the input matrix shape.
Gain=reshape(Gain,sizeout);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recompute pseudoramdom sequence of holding potentials
function resequence

cpotentials=getparam(me, 'potentials', 'list');
npotentials=getparam(me, 'potentials', 'range');
npotentials=npotentials(2);  
nrepeats=getparam(me, 'nrepeats', 'value');
ntrials=nrepeats*npotentials;
setparam(me, 'ntrials', ntrials);

for i=1:length(cpotentials)
    potentials(i)=str2num(cpotentials{i})
end
sequence=zeros(1, ntrials);
for i=1:nrepeats
    shuffled=potentials(randperm(npotentials));
    sequence((npotentials*(i-1)+1):i*npotentials)=shuffled;
end

% %%%%%%%%%%%%%%%%%%   hard-coding potential sequence to non-pseudorandom order !!!!!!!!!!
% disp('hard-coding potential sequence to non-pseudorandom order');
% m=1;
% for n=1:npotentials
%     for i=1:nrepeats
%         sequence(m)=potentials(n);
%         m=m+1;
%     end
% end
% %%%%%%%%%%%%%%%%%%%

SetParam(me, 'potentialsequence', 'list', num2cell(sequence), 'value', 1);
setparam(me, 'thispotential', 'value', sequence(1));
setparam(me, 'nextpotential', 'value', sequence(2));

if ntrials < getparam(me, 'nrp2trials')
    Message(me, 'too many tones');
elseif ntrials > getparam(me, 'nrp2trials')
    Message(me, 'not enough tones');
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load settings of favorite potentials
function settings
%enter your favorite settings: names here and values in switch below
settings={'-70',...                     %default,   %case 1
        '-500 -250 0 250 500', ...              %case 2
        '-120 -90 -60 60 100', ...               %case 3
        '0', ...                                %case 4
        '-140 -120 -100 -80 -60', ...             %case 5
        '100 120 140 160 180', ...               %case 6
        '-100 -80 -60 60', ...               %case 7
        '-100 -90 -80 -70 -60', ...               %case 8
        '-100 -80 -60', ...               %case 9
        '-120 -85 -50', ...               %case 10
        '-70 -100 60', ...               %case 11
        '-70 -120 100', ...               %case 12
    '-120 -85 -50', ...    %case 13    
    '-120 -90 -60', ...%case 14    
    '-140 -100 -60', ...%case 15
    '-180 -120 -60', ...%case 16
    '-80 -50 -20', ...%case 17
    '-70 -30 +10', ...%case 18
    '-100 -30 60', ...%case 19
    '-40', ...%case 20    
    '-50', ...%case 21    
    '+300', ...%case 22    
};

%initialize ui
setparam(me, 'settings', 'list', settings);
%load the selected settings
setindex=getparam(me, 'settings', 'value');
switch setindex
case 1
    set={'-70'}; % default
case 2
    set={'-500','-250','0','250','500'};
case 3
    set={'-120', '-90','-60','60', '100'};
case 4
    set={'0'};
case 5
    set={'-140','-120','-100','-80','-60'};
case 6
    set={'100','120','140','160','180'};
case 7
    set={'-100','-80','-60','60'};
case 8
    set={'-100','-90','-80','-70', '-60'};
case 9
    set={'-100','-80', '-60'};
case 10
    set={'-120','-85', '-50'};
case 11
    set={'-70','-100', '60', '-70','-100', '60'};
case 12
    set={'-70','-120', '100', '-70','-120', '100'};
case 13
    set={'-120','-85', '-50'};
case 14
    set={'-120','-90', '-60'};
case 15
    set={'-140','-100', '-60'};
case 16
    set={'-180','-120', '-60'};
case 17
    set={'-80','-50', '-20'};
case 18
    set={'-70','-30', '10'};
case 19
    set={'-100','-30', '60'};
case 20
    set={'-40'};
case 21
    set={'-50'};
case 22
    set={'+300'};
otherwise
    set={'-70'};
end
setparam(me, 'potentials', 'list', set)
resequence

%update mode and default manual cmd
patchpreprocess('reset');
TrialNum = GetParam('control','trial');
Message(me, ['trial ',int2str(TrialNum)]);
Mode = GetParam('patchpreprocess','mode');
Mode = Mode{TrialNum};
setparam(me, 'mode', Mode);

%            ModeCh = GetParam('patchpreprocess','modechannel');
%            ModeCh = daqfind('HwChannel',ModeCh);
%            ModeCh = ModeCh{1}.Index;
%            Samp=getsample( ai );
%            Mode=AxonMode( Samp(ModeCh) );

switch Mode
case { 'Track','V-Clamp' }
    manual_cmd=-70;
case { 'I=0','I-Clamp Normal','I-Clamp Fast' }    
    manual_cmd=0;
end
setparam(me, 'manual_cmd', manual_cmd);
callmodule(me,'reset');
