function varargout=ToneWarbleWhiteNoise(varargin)

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
    expectedISI=GetParam(me,'CurrentISI');

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
        toneStartIdx=find(states==0);
        if isempty(toneStartIdx)
            return;                     % no stimulus in trial = abort
        else
            toneStartIdx=toneStartIdx(end);
        end
        toneEndIdx=find(states==1);
        if isempty(toneEndIdx)
            return;                     % no stimulus in trial = abort
        else
            toneEndIdx=toneEndIdx(end);
            rewardStartIdx=toneEndIdx;
        end
        rewardEndIdx=find(states==3);
        if isempty(rewardEndIdx)
            return;                     % no reward period in trial = abort
        else
            rewardEndIdx=rewardEndIdx(end);
            negStartIdx=rewardEndIdx;
        end
        negEndIdx=find(states==4);
        if isempty(negEndIdx)
            negEndIdx=negStartIdx;      % no negative reinforcement period
        else
            negEndIdx=negEndIdx(end);
        end
        
        rewardPeriod=GetParam(me,'RewardPeriod')/1000;
         licksTone=length(find(events(toneStartIdx:toneEndIdx)==1));
         licksReward=length(find(events(rewardStartIdx:rewardEndIdx)==1));
         actualISI=times(negEndIdx)-times(negStartIdx);
         % now let's compute how many 0.5 sec intervals contain licks
         burstsNeg=length(find(states==5));
         halfNeg=2*burstsNeg;   % each burst is 1 s long, and we consider that 2 0.5 sec intervals, because it's REALLY BAD, BAD to lick during that period
          licksPosIdx=find(events(toneStartIdx:rewardEndIdx)==1);    % all good licks
          licksPosTimes=times(licksPosIdx)-times(toneStartIdx);      % and their relative position
         halfPos=length(unique(floor(2*licksPosTimes)));
         
         if (halfPos+halfNeg)==0
             performance=0;
         else
            performance=halfPos/(halfPos+halfNeg);
         end
        
         rewards=GetParam(me,'Rewards');
         if licksReward>0
            SetParam(me,'Rewards',rewards+1);
         end
         SetParam(me,'Performance',performance);

         if whichTone==1
            previousTone=       [GetParam(me,'LicksTargetTone') licksTone];
            previousReward=     [GetParam(me,'LicksTargetReward') licksReward];
            previousPerformance=[GetParam(me,'TargetPerformance') performance];
            previousExpected=   [GetParam(me,'TargetExpectedDuration') expectedISI];
            previousActual=     [GetParam(me,'TargetActualDuration') actualISI];
            SetParam(me,'LicksTargetTone',previousTone);
            SetParam(me,'LicksTargetReward',previousReward);
            SetParam(me,'TargetPerformance',previousPerformance);
            SetParam(me,'TargetExpectedDuration',previousExpected);
            SetParam(me,'TargetActualDuration',previousActual);
            colorTone=[0 0.5 0];
            colorReward=[0 1 0];
         else
            previousTone=       [GetParam(me,'LicksNonTargetTone') licksTone];
            previousReward=     [GetParam(me,'LicksNonTargetReward') licksReward];
            previousPerformance=[GetParam(me,'NonTargetPerformance') 1-performance];
            previousExpected=   [GetParam(me,'NonTargetExpectedDuration') expectedISI];
            previousActual=     [GetParam(me,'NonTargetActualDuration') actualISI];
            SetParam(me,'LicksNonTargetTone',previousTone);
            SetParam(me,'LicksNonTargetReward',previousReward);
            SetParam(me,'NonTargetPerformance',previousPerformance);
            SetParam(me,'NonTargetExpectedDuration',previousExpected);
            SetParam(me,'NonTargetActualDuration',previousActual);
            colorTone=[0.5 0 0];
            colorReward=[1 0 0];
         end
 
         nAverage=GetParam(me,'NAverage');
         
         plotPerf=mean(previousPerformance(max(end-nAverage+1,1):end));
         plotTone=mean(previousTone(max(end-nAverage+1,1):end));
         plotReward=mean(previousReward(max(end-nAverage+1,1):end));
         plotFraction=rewardPeriod/actualISI;
         plotExtension=mean(previousActual(max(end-nAverage+1,1):end)./previousExpected(max(end-nAverage+1,1):end));

         myaxes=GetParam(me,'Axes1');
         axes(myaxes);
         xlim=get(myaxes,'XLim');
         if lastTrial>xlim(2)
            set(myaxes,'XLim',[xlim(1) xlim(2)+50]);
         end
         plot(lastTrial,plotPerf,'o','Color',colorReward,'MarkerSize',3,'MarkerFaceColor',colorReward);

         myaxes=GetParam(me,'Axes2');
         axes(myaxes);
         xlim=get(myaxes,'XLim');
         if lastTrial>xlim(2)
            set(myaxes,'XLim',[xlim(1) xlim(2)+50]);
         end
         plot(lastTrial,plotTone,'o','Color',colorTone,'MarkerSize',3,'MarkerFaceColor',colorTone);
         plot(lastTrial,plotReward,'o','Color',colorReward,'MarkerSize',3,'MarkerFaceColor',colorReward);
          
         myaxes=GetParam(me,'Axes4');
         axes(myaxes);
         xlim=get(myaxes,'XLim');
         if lastTrial>xlim(2)
            set(myaxes,'XLim',[xlim(1) xlim(2)+50]);
         end
         plot(lastTrial,plotExtension,'o','Color',colorReward,'MarkerSize',3,'MarkerFaceColor',colorReward);
          
         myaxes=GetParam(me,'Axes5');
         axes(myaxes);
         xlim=get(myaxes,'XLim');
         if lastTrial>xlim(2)
            set(myaxes,'XLim',[xlim(1) xlim(2)+50]);
         end
         plot(lastTrial,plotFraction,'o','Color',colorReward,'MarkerSize',3,'MarkerFaceColor',colorReward);
         
         myaxes=GetParam(me,'Axes6');
         axes(myaxes);
         xlim=get(myaxes,'XLim');
         if lastTrial>xlim(2)
            set(myaxes,'XLim',[xlim(1) xlim(2)+50]);
         end
         plot(expectedISI,actualISI,'o','Color',colorReward,'MarkerSize',3,'MarkerFaceColor',colorReward);
         
          SetParam(me,'TotalLicks',licksTone+licksReward);
    end    
  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
	
        height=0.96/16;  % height of ui control in normalized units (we have 9 rows now, buttons count twice)
        h=0.02;
        width=0.12;
        
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[h 15*height+h 0.28 height]);

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
        intensity=70;
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
        
        % Axes 1
        myaxes=axes('Parent',fig,'Position',[0.35 0.6 0.16 0.38],'Color','none','XLim',[0 100],'NextPlot','add');
        hxlabel=get(myaxes,'XLabel');
        hylabel=get(myaxes,'YLabel');
        set(hxlabel,'String','Trial');
        set(hylabel,'String','Performance');
        InitParam(me,'Axes1','value',myaxes);
        % Axes 2
        myaxes=axes('Parent',fig,'Position',[0.58 0.6 0.16 0.38],'Color','none','XLim',[0 100],'NextPlot','add');
        hxlabel=get(myaxes,'XLabel');
        hylabel=get(myaxes,'YLabel');
        set(hxlabel,'String','Trial');
        set(hylabel,'String','Licks');
        InitParam(me,'Axes2','value',myaxes);
        % Axes 3
%         myaxes=axes('Parent',fig,'Position',[0.81 0.6 0.16 0.38],'Color','none','XLim',[0 100],'NextPlot','add');
%         hxlabel=get(myaxes,'XLabel');
%         hylabel=get(myaxes,'YLabel');
%         set(hxlabel,'String','');
%         set(hylabel,'String','');
%         InitParam(me,'Axes3','value',myaxes);
        % Axes 4
        myaxes=axes('Parent',fig,'Position',[0.35 0.1 0.16 0.38],'Color','none','XLim',[0 100],'NextPlot','add');
        hxlabel=get(myaxes,'XLabel');
        hylabel=get(myaxes,'YLabel');
        set(hxlabel,'String','Trial');
        set(hylabel,'String','Extension');
        InitParam(me,'Axes4','value',myaxes);
        % Axes 5
        myaxes=axes('Parent',fig,'Position',[0.58 0.1 0.16 0.38],'Color','none','NextPlot','add');
        hxlabel=get(myaxes,'XLabel');
        hylabel=get(myaxes,'YLabel');
        set(hxlabel,'String','Trial');
        set(hylabel,'String','Duration fraction');
        InitParam(me,'Axes5','value',myaxes);
        % Axes 6
        myaxes=axes('Parent',fig,'Position',[0.81 0.1 0.16 0.38],'Color','none','NextPlot','add','XLim',[0.5 100],'YLim',[0.5 100],'XScale','log','YScale','log');
        hxlabel=get(myaxes,'XLabel');
        hylabel=get(myaxes,'YLabel');
        set(hxlabel,'String','Expected duration');
        set(hylabel,'String','Actual duration');
        InitParam(me,'Axes6','value',myaxes);

        InitParam(me,'CurrentPosition','value',1);
        
%         previous=zeros(1,100);
%         previous(1)=2;  % pointer to the last empty position
        previous=[];
        InitParam(me,'TargetPerformance','value',previous);
        InitParam(me,'NonTargetPerformance','value',previous);
%         previous=zeros(2,100);
%         previous(:,1)=2;  % pointer to the last empty position
        InitParam(me,'TargetExpectedDuration','value',previous);
        InitParam(me,'TargetActualDuration','value',previous);
        InitParam(me,'NonTargetExpectedDuration','value',previous);
        InitParam(me,'NonTargetActualDuration','value',previous);
        InitParam(me,'LicksTargetTone','value',previous);
        InitParam(me,'LicksTargetReward','value',previous);
        InitParam(me,'LicksNonTargetTone','value',previous);
        InitParam(me,'LicksNonTargetReward','value',previous);
        
        InitParam(me,'NAverage','value',10);        % plot running average of last NAverage values
        InitParam(me,'CurrentTone','value',0);
        
	set(fig,'pos',[400 400 700 400],'visible','on');

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
   5    4    4    4    4    4    35     randisi   0         0;
   5    5    5    5    5    5    6      trig      channel2  0;
   6    6    6    6    6    6    4      burstdur  0         0];   % inter-stimulus interval

myStateMatrix{2}=[ ...                                  
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer     DIO       AO  
   0    0    0    0    0    0    1      trig      channel1  0;    % tone trigger
   1    1    1    1    1    1    2      tonedur   0         0;
   2    2    2    2    2    2    3      valvedur  0         0;    % reward itself - valve stays open for dur seconds
   3    3    3    3    3    3    4      reward    0         0;
   5    4    4    4    4    4    35     randisi   0         0;
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
    param.amplitude=GetParam(me,'ToneIntensity');
    param.duration= GetParam(me,'ToneDuration');
    param.ramp=     GetParam(me,'ToneRamp');
    param.channel=  1;
%     param.channel=   GetParam(me,'Channel');
    samplerate=GetParam(me,'SampleRate');
    if which==1
        param.frequency=GetParam(me,'TargetFrequency');
        sound=MakeTone(param,samplerate);
    else
        param.carrier_frequency=2000;
        param.carrier_phase=0;
        param.modulation_frequency=10;
        param.modulation_phase=0;
        param.modulation_index=100;
        sound=MakeFMTone(param,samplerate);
    end
    SoundLoad('load','var',sound,param);
   
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