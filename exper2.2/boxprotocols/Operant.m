function varargout = Operant( varargin )

% Behavior protocol for BoxMaster module
% Operant conditioning

global exper pref

varargout{1} = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	ModuleNeeds(me,{'boxmaster'});
	CreateGUI; %local function that creates ui controls and initializes ui variables
    
    rewardRatios=[1 1 1 1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 5 5 ceil(rand(1,100)*6)];
    InitParam(me,'RewardRatios','value',rewardRatios);
    
    BoxMaster('SendStateMatrix',OperantStateMatrix(1));
    
% case 'getready'
    
% case 'trialend'

% case 'close'
    
case 'reset'
    SetParam(me,'Ratio',1);
    SetParam(me,'Rewards',0);
    BoxMaster('SendStateMatrix',OperantStateMatrix(1));
    
case 'eboxmastertrialend'
    trialInfo=varargin{2};
    newTrial=str2num(trialInfo)+1;     % BoxMaster sends out the trial that just ended
    ratios=GetParam(me,'RewardRatios');
    if newTrial>length(ratios)
        newTrial=max([1 mod(newTrial,length(ratios))]);   % start with the random ones again
    end
    SetParam(me,'Ratio',ratios(newTrial));    
    rewards=GetParam(me,'Rewards');
    SetParam(me,'Rewards',rewards+1);
    BoxMaster('SendStateMatrix',OperantStateMatrix(ratios(newTrial)));
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
	
        height=0.96/4;  % height of ui control in normalized units (we have 9 rows now, buttons count twice)
        h=0.02;
        
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[h 3*height+h 0.96 height]);

        ratio=1;
        InitParam(me,'Ratio','ui','disp','value',ratio,'pref',0,'units','normal','pos',[h 2*height+h 0.48 height]);
        SetParamUI(me,'Ratio','label','Ratio');    
        rewards=0;
        InitParam(me,'Rewards','ui','disp','value',rewards,'pref',0,'units','normal','pos',[h height+h 0.48 height]);
        SetParamUI(me,'Rewards','label','Rewards');

        valveDuration=10;
        InitParam(me,'ValveDuration','ui','edit','value',valveDuration,'pref',0,'units','normal','pos',[h h 0.48 height]);
        SetParamUI(me,'ValveDuration','label','Valve Duration');
	
	set(fig,'pos',[400 400 150 80],'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function stateMatrix=OperantStateMatrix(rewardRatio)
% the columns of the transition matrix represent inputs
% Cin,Cout,Lin,Lout,Rin, Rout, Times-up
% The rows are the states (from Staet 0 upto 32)
% The timer is in unit of seconds, # of columns >= # of states
% DIO output in "word" format, 1=DIO-0_ON, 8=DIO-3_ON (DIO-0~8) 
% AO output in "word" format, 1=AO-1_ON, 3=AO-1,2_ON,  (AO-1,2)
dur=GetParam(me,'ValveDuration')/1000;  % water duration in sec

operantMatrix{1}=[ ...                                  % one lick for water
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer DIO AO  
   1    0    0    0    0    0    0      120   0   0;  
   1    1    1    1    1    1    35     dur   1   1];  

operantMatrix{2}=[ ...                                  % two licks for water
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer DIO AO  
   1    0    0    0    0    0    0      120   0   0;  
   2    1    0    0    0    0    0      120   0   0;  
   2    2    2    2    2    2    35     dur   1   1];  

operantMatrix{3}=[ ...                                  % three licks for water
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer DIO AO  
   1    0    0    0    0    0    0      120   0   0;  
   2    1    0    0    0    0    0      120   0   0;  
   3    2    0    0    0    0    0      120   0   0;  
   3    3    3    3    3    3    35     dur   1   1];  

operantMatrix{4}=[ ...                                  % four licks for water
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer DIO AO  
   1    0    0    0    0    0    0      120   0   0;  
   2    1    0    0    0    0    0      120   0   0;  
   3    2    0    0    0    0    0      120   0   0;  
   4    3    0    0    0    0    0      120   0   0;  
   4    4    4    4    4    4    35     dur   1   1];  

operantMatrix{5}=[ ...                                  % five licks for water
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer DIO AO  
   1    0    0    0    0    0    0      120   0   0;  
   2    1    0    0    0    0    0      120   0   0;  
   3    2    0    0    0    0    0      120   0   0;  
   4    3    0    0    0    0    0      120   0   0;  
   5    4    0    0    0    0    0      120   0   0;  
   5    5    5    5    5    5    35     dur   1   1];  

operantMatrix{6}=[ ...                                  % six licks for water
%  Cin  Cout Lin  Lout Rin  Rout TimeUp Timer DIO AO  
   1    0    0    0    0    0    0      120   0   0;  
   2    1    0    0    0    0    0      120   0   0;  
   3    2    0    0    0    0    0      120   0   0;  
   4    3    0    0    0    0    0      120   0   0;  
   5    4    0    0    0    0    0      120   0   0;  
   6    5    0    0    0    0    0      120   0   0;  
   6    6    6    6    6    6    35     dur   1   1];  

stateMatrix=operantMatrix{rewardRatio};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%