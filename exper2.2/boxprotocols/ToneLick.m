function varargout=ToneLick(varargin)

% Behavior protocol for BoxMaster module
% Reward during a tone

global exper pref

varargout{1} = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	ModuleNeeds(me,{'boxmaster','soundload'});
    samplerate=SoundLoad('samplerate');
    InitParam(me,'SampleRate','value',samplerate);
	CreateGUI; %local function that creates ui controls and initializes ui variables    
    LoadTone;
    BoxMaster('SendStateMatrix',StateMatrix);
    
% case 'getready'
    
% case 'trialend'

% case 'close'
    
case 'reset'
    SetParam(me,'Rewards',0);
    SetParam(me,'CorrectLicks',0);
    SetParam(me,'ErrorLicks',0);
    LoadTone;
    BoxMaster('SendStateMatrix',StateMatrix);
    
case 'eboxmastertrialend'
    lastTrial=str2num(varargin{2});     % BoxMaster sends out the trial that just ended    
    trial=BoxMaster('gettrial',lastTrial);
    trial=trial{:};
   
    if length(trial)>1
        trial=trial(2:end);         % the first element is just info about the trial
        states=[trial.state];
        events=[trial.event];
        times=[trial.clock];
        toneStartIdx=find(states==1);
        if ~isempty(toneStartIdx)
            toneStart=times(toneStartIdx(1));
            rewardPeriod=(GetParam(me,'ToneDuration')+GetParam(me,'RewardOffset'))/1000;  % period for correct licks
            timesIdx=find(times<=toneStart+rewardPeriod);
            if ~isempty(timesIdx)
                toneEndIdx=timesIdx(end);
                totalTrialLicks=length(find(events==1));
                correctTrialLicks=length(find(events(toneStartIdx:toneEndIdx)==1));
                errorTrialLicks=totalTrialLicks-correctTrialLicks;
        
                rewards=GetParam(me,'Rewards');
                if correctTrialLicks>0
                    SetParam(me,'Rewards',rewards+1);
                end

                correctTotal=GetParam(me,'CorrectLicks');
                SetParam(me,'CorrectLicks',correctTotal+correctTrialLicks);
                errorTotal=GetParam(me,'ErrorLicks');
                SetParam(me,'ErrorLicks',errorTotal+errorTrialLicks);
            end
        end
    end    
   
    LoadTone;
    BoxMaster('SendStateMatrix',StateMatrix);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
	
        height=0.96/12;  % height of ui control in normalized units (we have 9 rows now, buttons count twice)
        h=0.02;
        
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[h 11*height+h 0.96 height]);

        rewards=0;
        InitParam(me,'Rewards','ui','disp','value',rewards,'pref',0,'units','normal','pos',[h 10*height+h 0.4 height]);
        SetParamUI(me,'Rewards','label','Rewards');

        correct=0;
        InitParam(me,'CorrectLicks','ui','edit','value',correct,'pref',0,'units','normal','pos',[h 9*height+h 0.4 height]);
        SetParamUI(me,'CorrectLicks','label','Correct Licks');
        error=0;
        InitParam(me,'ErrorLicks','ui','edit','value',error,'pref',0,'units','normal','pos',[h 8*height+h 0.4 height]);
        SetParamUI(me,'ErrorLicks','label','ErrorLicks');

        frequency=20000;
        InitParam(me,'ToneFrequency','ui','edit','value',frequency,'pref',0,'units','normal','pos',[h 6.5*height+h 0.4 height]);
        SetParamUI(me,'ToneFrequency','label','Tone Frequency');
        intensity=65;
        InitParam(me,'ToneIntensity','ui','edit','value',intensity,'pref',0,'units','normal','pos',[h 5.5*height+h 0.4 height]);
        SetParamUI(me,'ToneIntensity','label','Tone Intensity');
        duration=200;
        InitParam(me,'ToneDuration','ui','edit','value',duration,'pref',0,'units','normal','pos',[h 4.5*height+h 0.4 height]);
        SetParamUI(me,'ToneDuration','label','Tone Duration');
        ramp=5;
        InitParam(me,'ToneRamp','ui','edit','value',ramp,'pref',0,'units','normal','pos',[h 3.5*height+h 0.4 height]);
        SetParamUI(me,'ToneRamp','label','Tone Ramp');
        channel=1;
        InitParam(me,'Channel','ui','edit','value',channel,'pref',0,'units','normal','pos',[h 2.5*height+h 0.4 height]);
        SetParamUI(me,'Channel','label','Channel');

        rewardOffset=100;
        InitParam(me,'RewardOffset','ui','edit','value',rewardOffset,'pref',0,'units','normal','pos',[h height+h 0.4 height]);
        SetParamUI(me,'RewardOffset','label','Reward Offset');
        
        valveDuration=10;
        InitParam(me,'ValveDuration','ui','edit','value',valveDuration,'pref',0,'units','normal','pos',[h h 0.4 height]);
        SetParamUI(me,'ValveDuration','label','Valve Duration');
	
	set(fig,'pos',[400 400 200 240],'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function stateMatrix=StateMatrix
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from State 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)
dur=GetParam(me,'ValveDuration')/1000;  % water duration in sec
reward=(GetParam(me,'ToneDuration')+GetParam(me,'RewardOffset'))/1000;  % reward period
aChannel=GetParam(me,'Channel');
switch aChannel
    case 1
        channel=64;    % DOUT 6 = 7th output pin
    case 2
        channel=128    % DOUT 7 = 8th output pin
    otherwise
        channel=64;    % channel 1 = DOUT 6 is the default channel
end

% channel=2;

wait=0.1;               % starts playing sound after 'wait' seconds
trig=0.01;              % duration of sound trigger - RP2 is triggered by falling edge of a pulse
isi=reward+random('unif',25,30);         % 'isi' interval (seconds)
message(me,num2str(isi));
myStateMatrix=[ ...                                  % one lick for water
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer   DIO      AO  
   0    0    0    0    0    0    1      wait    0        0;    % start state - starts playing sound after wait seconds
   1    1    1    1    1    1    2      trig    channel  0;    % tone trigger
   3    2    2    2    2    2    4      reward  0        0;    % reward period - wait for lick (Cin)  
   3    3    3    3    3    3    4      dur     0        1;    % reward itself - valve stays open for dur seconds
   4    4    4    4    4    4    35     isi     0        0];   % inter-stimulus interval

stateMatrix=myStateMatrix;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadTone
% loads the requested tone using MakeTone and SoundLoad
    param.frequency=GetParam(me,'ToneFrequency');
    param.amplitude=GetParam(me,'ToneIntensity');
    param.duration= GetParam(me,'ToneDuration');
    param.ramp=     GetParam(me,'ToneRamp');
    param.chanel=   GetParam(me,'Channel');
    samplerate=GetParam(me,'SampleRate');
    tone=MakeTone(param,samplerate);
    SoundLoad('load','var',tone,param);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%