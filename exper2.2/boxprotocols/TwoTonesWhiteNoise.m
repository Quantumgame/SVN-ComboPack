function varargout=TwoTonesWhiteNoise(varargin)

% Behavior protocol for BoxMaster module
% Classical conditioning with some 'negative' reinforcement
% Water delivered after target tone, but not after the other tone:-). Incorrect licks are 'punished' by a
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
%     LoadTone; % tones are now loaded in StateMatrix;
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
    
%     LoadTone;
    LoadBurst;
    BoxMaster('SendStateMatrix',StateMatrix);
    
case 'eboxmastertrialend'
    lastTrial=str2num(varargin{2});     % BoxMaster sends out the trial that just ended    
    trial=BoxMaster('gettrial',lastTrial);
    trial=trial{:};
    whichTone=GetParam(me,'CurrentTone');

%     LoadBurst;
    SoundLoad('resetbuffers');
    SoundLoad('sethwtrigger',1);
%     LoadTone;
    BoxMaster('SendStateMatrix',StateMatrix);    
    
    if length(trial)>1
        trial=trial(2:end);         % the first element is just info about the trial
        states=[trial.state];
        events=[trial.event];
        times=[trial.clock];
        toneStartIdx=find(states==1);
        if ~isempty(toneStartIdx)
            toneStart=times(toneStartIdx(1));
            rewardPeriod=GetParam(me,'RewardPeriod')/1000;
            toneDuration=GetParam(me,'ToneDuration')/1000;
            timesIdx=find(times<=toneStart+rewardPeriod);
            if ~isempty(timesIdx)   % there are some licks
                toneEndIdx=find(times<=toneStart+toneDuration);
%                 totalTrialLicks=length(find(events==1));
                if isempty(toneEndIdx)
                    licksTone=0;
                else
                    toneEndIdx=toneEndIdx(end);
                    licksTone=length(find(events(toneStartIdx:toneEndIdx)==1)); % licks during the tone
                end
                licksReward=length(find(events(toneStartIdx:timesIdx(end))==1))-licksTone; % licks during the reward period after tone
                
                rewards=GetParam(me,'Rewards');
                if licksReward>0
                    SetParam(me,'Rewards',rewards+1);
                end
%                 if totalTrialLicks>0
%                     isi=GetParam(me,'CurrentISI');
%                     rewardPeriod=GetParam(me,'rewardPeriod')/1000;
%                     corrLicks=correctTrialLicks;
%                     errLicks=(totalTrialLicks-correctTrialLicks);
%                     errLicks=(totalTrialLicks-correctTrialLicks)*rewardPeriod/isi;
                    SetParam(me,'Performance',licksReward);
                    % update the plot
%                     if (totalTrialLicks>1) & (whichTone==1)  % with only one lick it doesn't really make sense either
%                         previous=GetParam(me,'PreviousTrials');

                    if whichTone==1
                        previousTone=GetParam(me,'LicksTarget');
                        previousReward=GetParam(me,'LicksTargetReward');
                        colorTone=[0 0.5 0];
                        colorReward=[0 1 0];
                    else
                        previousTone=GetParam(me,'LicksOther');
                        previousReward=GetParam(me,'LicksOtherReward');
                        colorTone=[0.5 0 0];
                        colorReward=[1 0 0];
                    end
                    previousTone=[previousTone licksTone];
                    if length(previousTone)>10
                        previousTone=previousTone(2:end);
                    end
                    previousReward=[previousReward licksReward];
                    if length(previousReward)>10
                        previousReward=previousReward(2:end);
                    end
                    averageTone=mean(previousTone);
                    averageReward=mean(previousReward);
                    myaxes=GetParam(me,'MyAxes');
                    axes(myaxes);
                    xlim=get(myaxes,'XLim');
                    if lastTrial>xlim(2)
                       set(myaxes,'XLim',[xlim(1) xlim(2)+50]);
                    end
                    plot(lastTrial,averageTone,'o','Color',colorTone,'MarkerSize',2,'MarkerFaceColor',colorTone);
                    plot(lastTrial,averageReward,'o','Color',colorReward,'MarkerSize',2,'MarkerFaceColor',colorReward);
                    if whichTone==1
                        SetParam(me,'LicksTarget',previousTone);
                        SetParam(me,'LicksTargetReward',previousReward);
                    else
                        SetParam(me,'LicksOther',previousTone);
                        SetParam(me,'LicksOtherReward',previousReward);
                    end
%                     end
%                 else
%                     SetParam(me,'Performance',0);
%                 end
                SetParam(me,'TotalLicks',licksTone+licksReward);
            end
        end
    end    
  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
	
        height=0.96/16;  % height of ui control in normalized units (we have 9 rows now, buttons count twice)
        h=0.02;
        width=0.2;
        
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[h 15*height+h 0.48 height]);

        rewards=0;
        InitParam(me,'Rewards','ui','disp','value',rewards,'pref',0,'units','normal','pos',[h 14*height+h width height]);
        SetParamUI(me,'Rewards','label','Rewards');

        correct=0;
        InitParam(me,'Performance','ui','disp','value',correct,'pref',0,'units','normal','pos',[h 13*height+h width height]);
        SetParamUI(me,'Performance','label','Performance');
        total=0;
        InitParam(me,'TotalLicks','ui','disp','value',total,'pref',0,'units','normal','pos',[h 12*height+h width height]);
        SetParamUI(me,'TotalLicks','label','Total Licks');

        frequency=20000;
        InitParam(me,'TargetFrequency','ui','edit','value',frequency,'pref',0,'units','normal','pos',[h 10.5*height+h width height]);
        SetParamUI(me,'TargetFrequency','label','Target Frequency');
        otherFrequency=2000;
        InitParam(me,'OtherFrequency','ui','edit','value',otherFrequency,'pref',0,'units','normal','pos',[h 9.5*height+h width height]);
        SetParamUI(me,'OtherFrequency','label','Other Frequency');
        targetProbability=0.8;
        InitParam(me,'TargetProbability','ui','edit','value',targetProbability,'pref',0,'units','normal','pos',[h 8.5*height+h width height]);
        SetParamUI(me,'TargetProbability','label','Target Probability');
        intensity=65;
        InitParam(me,'ToneIntensity','ui','edit','value',intensity,'pref',0,'units','normal','pos',[h 7.5*height+h width height]);
        SetParamUI(me,'ToneIntensity','label','Tone Intensity');
        duration=500;
        InitParam(me,'ToneDuration','ui','edit','value',duration,'pref',0,'units','normal','pos',[h 6.5*height+h width height]);
        SetParamUI(me,'ToneDuration','label','Tone Duration');
        ramp=5;
        InitParam(me,'ToneRamp','ui','edit','value',ramp,'pref',0,'units','normal','pos',[h 5.5*height+h width height]);
        SetParamUI(me,'ToneRamp','label','Tone Ramp');
%         channel=1;
%         InitParam(me,'Channel','ui','edit','value',channel,'pref',0,'units','normal','pos',[h 5.5*height+h width height]);
%         SetParamUI(me,'Channel','label','Tone Channel');
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
        
        myaxes=axes('Parent',fig,'Position',[0.5 0.1 0.48 0.79],'Color','none','XLim',[0 100],'NextPlot','add');
        InitParam(me,'MyAxes','value',myaxes);  % axes for plotting running average of performance
        previousTrials=[];
        InitParam(me,'PreviousTrials','value',previousTrials);  % performance from 10 previous trials for computing the running average
        
        InitParam(me,'LicksTarget','value',[]);
        InitParam(me,'LicksOther','value',[]);
        InitParam(me,'LicksTargetReward','value',[]);
        InitParam(me,'LicksOtherReward','value',[]);
        
        InitParam(me,'CurrentTone','value',0);
        
	set(fig,'pos',[400 400 500 300],'visible','on');

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

% wait=0.01;               % starts playing sound after 'wait' seconds
trig=0.01;              % duration of sound trigger - RP2 is triggered by falling edge of a pulse
reward=GetParam(me,'RewardOffset')/1000;
isi=GetParam(me,'ISI')/1000;
randisi=isi+random('exp',2*isi);         % 'isi' interval (seconds)
% randisi=isi+random('unif',0,isi);         % 'isi' interval (seconds)
SetParam(me,'CurrentISI',randisi);
message(me,num2str(randisi));
rewardPeriod=(reward+tonedur+valvedur)*1000;    % reward period
SetParam(me,'RewardPeriod',rewardPeriod);
myStateMatrix{1}=[ ...                                  
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer     DIO       AO  
   0    0    0    0    0    0    1      trig      channel1  0;    % tone trigger
   1    1    1    1    1    1    2      tonedur   0         0;
   2    2    2    2    2    2    3      valvedur  0         1;    % reward itself - valve stays open for dur seconds
   3    3    3    3    3    3    4      reward    0         0;
   5    4    4    4    4    4    35     randisi       0         0;
   5    5    5    5    5    5    6      trig      channel2  0;
   6    6    6    6    6    6    4      burstdur  0         0];   % inter-stimulus interval

myStateMatrix{2}=[ ...                                  
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer     DIO       AO  
   0    0    0    0    0    0    1      trig      channel1  0;    % tone trigger
   1    1    1    1    1    1    2      tonedur   0         0;
   2    2    2    2    2    2    3      valvedur  0         0;    % reward itself - valve stays open for dur seconds
   3    3    3    3    3    3    4      reward    0         0;
   5    4    4    4    4    4    35     randisi       0         0;
   5    5    5    5    5    5    6      trig      channel2  0;
   6    6    6    6    6    6    4      burstdur  0         0];   % inter-stimulus interval

targetProbability=GetParam(me,'TargetProbability');
whichTone=(rand>targetProbability)+1;   % 1==target, 2==other 
LoadTone(whichTone);
SetParam(me,'CurrentTone',whichTone);
stateMatrix=myStateMatrix{whichTone};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadTone(which)
% loads the requested tone using MakeTone and SoundLoad
% which==1 - target
% which==2 - nn-target (other)
    if which==1
        param.frequency=GetParam(me,'TargetFrequency');
    else
        param.frequency=GetParam(me,'OtherFrequency');
    end
    param.amplitude=GetParam(me,'ToneIntensity');
    param.duration= GetParam(me,'ToneDuration');
    param.ramp=     GetParam(me,'ToneRamp');
    param.channel=  1;
%     param.channel=   GetParam(me,'Channel');
    samplerate=GetParam(me,'SampleRate');
    tone=MakeTone(param,samplerate);
    SoundLoad('load','var',tone,param);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadBurst
% loads the requested tone using MakeTone and SoundLoad
    samplerate=          GetParam(me,'SampleRate');
    burstparam.amplitude=GetParam(me,'BurstIntensity');
    burstparam.duration= GetParam(me,'BurstDuration');
    burstparam.ramp=     GetParam(me,'ToneRamp');
    burstparam.channel=  2;                       % white noise is loaded to channel 2
    burst=MakeWhiteNoise(burstparam,samplerate);
    SoundLoad('load','var',burst,burstparam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%