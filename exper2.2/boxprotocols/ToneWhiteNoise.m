function varargout=ToneWhiteNoise(varargin)

% Behavior protocol for BoxMaster module
% Classical conditioning with some 'negative' reinforcement
% Water delivered after tone. Incorrect licks are 'punished' by a
% white-noise bursts.

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
    LoadBurst;  % loading stuff up takes some time so we do it separately
    BoxMaster('SendStateMatrix',StateMatrix);
    
% case 'getready'
    
% case 'trialend'

% case 'close'
    
case 'reset'
    SetParam(me,'Rewards',0);
    SetParam(me,'Performance',0);
    SetParam(me,'TotalLicks',0);
    SetParam(me,'PreviousTrials',[]);
    % clear plot
    myaxes=GetParam(me,'MyAxes');
    axes(myaxes);
    cla;
    
    LoadTone;
    LoadBurst;
    BoxMaster('SendStateMatrix',StateMatrix);
    
case 'eboxmastertrialend'
    lastTrial=str2num(varargin{2});     % BoxMaster sends out the trial that just ended    
    trial=BoxMaster('gettrial',lastTrial);
    trial=trial{:};

%     LoadBurst;
    SoundLoad('resetbuffers');
    SoundLoad('sethwtrigger',1);
    LoadTone;
    BoxMaster('SendStateMatrix',StateMatrix);    
    
    if length(trial)>1
        trial=trial(2:end);         % the first element is just info about the trial
        states=[trial.state];
        events=[trial.event];
        times=[trial.clock];
        toneStartIdx=find(states==1);
        if ~isempty(toneStartIdx)
            toneStart=times(toneStartIdx(1));
            rewardOffset=GetParam(me,'RewardOffset')/1000;
            timesIdx=find(times<=toneStart+rewardOffset);
            if ~isempty(timesIdx)
                toneEndIdx=timesIdx(end);
                totalTrialLicks=length(find(events==1));
                correctTrialLicks=length(find(events(toneStartIdx:toneEndIdx)==1));
        
                rewards=GetParam(me,'Rewards');
                if correctTrialLicks>0
                    SetParam(me,'Rewards',rewards+1);
                end
                if totalTrialLicks>0
                    isi=GetParam(me,'CurrentISI');
                    rewardPeriod=GetParam(me,'rewardPeriod')/1000;
                    corrLicks=correctTrialLicks;
                    errLicks=(totalTrialLicks-correctTrialLicks);
%                     errLicks=(totalTrialLicks-correctTrialLicks)*rewardPeriod/isi;
                    performance=corrLicks/(corrLicks+errLicks);
                    SetParam(me,'Performance',performance);
                    % update the plot
                    if totalTrialLicks>1   % with only one lick it doesn't really make sense either
                        previous=GetParam(me,'PreviousTrials');
                        if length(previous)==10
                            previous=[previous(2:10) performance];
                            average=mean(previous);
                            myaxes=GetParam(me,'MyAxes');
%                             current=gca;
                            axes(myaxes);
                            xlim=get(myaxes,'XLim');
                            if lastTrial>xlim(2)
                                set(myaxes,'XLim',[xlim(1) xlim(2)+50]);
                            end
                            plot(lastTrial,average,'o','Color',[0 1 1],'MarkerSize',2,'MarkerFaceColor',[0 1 1]);
%                             axes(current);
                        else
                            previous=[previous performance];
                        end
                        SetParam(me,'PreviousTrials',previous);
                    end
                else
                    SetParam(me,'Performance',0);
                end
                SetParam(me,'TotalLicks',totalTrialLicks);
            end
        end
    end    
  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
	
        height=0.96/15;  % height of ui control in normalized units (we have 9 rows now, buttons count twice)
        h=0.02;
        width=0.2;
        
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[h 14*height+h 0.48 height]);

        rewards=0;
        InitParam(me,'Rewards','ui','disp','value',rewards,'pref',0,'units','normal','pos',[h 13*height+h width height]);
        SetParamUI(me,'Rewards','label','Rewards');

        correct=0;
        InitParam(me,'Performance','ui','disp','value',correct,'pref',0,'units','normal','pos',[h 12*height+h width height]);
        SetParamUI(me,'Performance','label','Performance');
        total=0;
        InitParam(me,'TotalLicks','ui','disp','value',total,'pref',0,'units','normal','pos',[h 11*height+h width height]);
        SetParamUI(me,'TotalLicks','label','Total Licks');

        frequency=20000;
        InitParam(me,'ToneFrequency','ui','edit','value',frequency,'pref',0,'units','normal','pos',[h 9.5*height+h width height]);
        SetParamUI(me,'ToneFrequency','label','Tone Frequency');
        intensity=70;
        InitParam(me,'ToneIntensity','ui','edit','value',intensity,'pref',0,'units','normal','pos',[h 8.5*height+h width height]);
        SetParamUI(me,'ToneIntensity','label','Tone Intensity');
        duration=500;
        InitParam(me,'ToneDuration','ui','edit','value',duration,'pref',0,'units','normal','pos',[h 7.5*height+h width height]);
        SetParamUI(me,'ToneDuration','label','Tone Duration');
        ramp=5;
        InitParam(me,'ToneRamp','ui','edit','value',ramp,'pref',0,'units','normal','pos',[h 6.5*height+h width height]);
        SetParamUI(me,'ToneRamp','label','Tone Ramp');
        channel=1;
        InitParam(me,'Channel','ui','edit','value',channel,'pref',0,'units','normal','pos',[h 5.5*height+h width height]);
        SetParamUI(me,'Channel','label','Tone Channel');
        burstDuration=1000;
        InitParam(me,'BurstDuration','ui','edit','value',burstDuration,'pref',0,'units','normal','pos',[h 4.5*height+h width height]);
        SetParamUI(me,'BurstDuration','label','Burst Duration');
        burstIntensity=75;
        InitParam(me,'BurstIntensity','ui','edit','value',burstIntensity,'pref',0,'units','normal','pos',[h 3.5*height+h width height]);
        SetParamUI(me,'BurstIntensity','label','Burst Intensity');

        rewardOffset=3000;
        InitParam(me,'RewardOffset','ui','edit','value',rewardOffset,'pref',0,'units','normal','pos',[h 2*height+h width height]);
        SetParamUI(me,'RewardOffset','label','Reward Offset');
        
        InitParam(me,'RewardPeriod','value',0); % actual length of reward period - tone dur + valve dur + reward offset (randomized)
        
        isi=1000;
        InitParam(me,'ISI','ui','edit','value',isi,'pref',0,'units','normal','pos',[h height+h width height]);
        SetParamUI(me,'ISI','label','ISI');

        valveDuration=10;
        InitParam(me,'ValveDuration','ui','edit','value',valveDuration,'pref',0,'units','normal','pos',[h h width height]);
        SetParamUI(me,'ValveDuration','label','Valve Duration');
	
        InitParam(me,'CurrentISI','value',0);
        
        myaxes=axes('Parent',fig,'Position',[0.5 0.1 0.48 0.79],'Color','none','YLim',[0 1],'XLim',[0 100],'NextPlot','add');
        InitParam(me,'MyAxes','value',myaxes);  % axes for plotting running average of performance
        previousTrials=[];
        InitParam(me,'PreviousTrials','value',previousTrials);  % performance from 10 previous trials for computing the running average
        
        
	set(fig,'pos',[400 400 500 280],'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function stateMatrix=StateMatrix
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from State 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)
valvedur=GetParam(me,'ValveDuration')/1000;  % water duration in sec
tonedur=GetParam(me,'ToneDuration')/1000;
burstdur=GetParam(me,'BurstDuration')/1000;

channel1=64;    % DOUT 6 = 7th output pin   - tone stimulus
channel2=128;   % DOUT 7 = 8th output pin   - white noise burst

wait=0.01;               % starts playing sound after 'wait' seconds
trig=0.01;              % duration of sound trigger - RP2 is triggered by falling edge of a pulse
reward=GetParam(me,'RewardOffset')/1000;
isi=GetParam(me,'ISI')/1000;
randisi=isi+random('exp',3*isi);         % 'isi' interval (seconds)
% randisi=isi+random('unif',0,isi);         % 'isi' interval (seconds)
SetParam(me,'CurrentISI',randisi);
message(me,num2str(randisi));
rewardPeriod=(reward+tonedur+valvedur)*1000;    % reward period
SetParam(me,'RewardPeriod',rewardPeriod);
myStateMatrix=[ ...                                  
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer     DIO       AO  
   0    0    0    0    0    0    1      wait      0         0;    % start state - starts playing sound after wait seconds
   1    1    1    1    1    1    2      trig      channel1  0;    % tone trigger
   2    2    2    2    2    2    3      tonedur   0         0;
   3    3    3    3    3    3    4      valvedur  0         1;    % reward itself - valve stays open for dur seconds
   4    4    4    4    4    4    5      reward    0         0;
   6    5    5    5    5    5    35     randisi   0         0;
   6    6    6    6    6    6    7      trig      channel2  0;
   7    7    7    7    7    7    5      burstdur  0         0];   % inter-stimulus interval

stateMatrix=myStateMatrix;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadTone
% loads the requested tone using MakeTone and SoundLoad
    param.frequency=GetParam(me,'ToneFrequency');
    param.amplitude=GetParam(me,'ToneIntensity');
    param.duration= GetParam(me,'ToneDuration');
    param.ramp=     GetParam(me,'ToneRamp');
    param.channel=   GetParam(me,'Channel');
    samplerate=GetParam(me,'SampleRate');
    tone=MakeTone(param,samplerate);
    SoundLoad('load','var',tone,param);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadBurst
% loads the requested tone using MakeTone and SoundLoad
    samplerate=GetParam(me,'SampleRate');
    burstparam.amplitude=GetParam(me,'BurstIntensity');
    burstparam.duration=GetParam(me,'BurstDuration');
    burstparam.ramp=GetParam(me,'ToneRamp');
    burstparam.channel=2;                       % white noise is loaded to channel 2
    burst=MakeWhiteNoise(burstparam,samplerate);
    SoundLoad('load','var',burst,burstparam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%