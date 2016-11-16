function out=BoxMaster(varargin)
global exper pref boxMasterTimer boxMasterTimerDelay

% Master module for controlling the behavior circuit and all the behavior
% protocols

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end


switch action
    case 'init'
        ModuleNeeds(me,{'rp2control'});
%         SetParam(me,'priority','value',GetParam('ai','priority')+1);

        InitializeGUI;
        LoadProtocolsMenu; % setup menu for protocols
        InitRP;            % initialize RP2 and load the circuit if necessary
                
        InitParam(me,'LastEventCounter','value',0);     % keeps track of position in Event and EventTime buffers
        InitParam(me,'LastTriggerCounter','value',0);   % keeps track of position in HWTriggerBuffer     
        InitParam(me,'BoxTrials','value',{});           % saves trials' parameters
        InitParam(me,'StateMatrix','value',[]);         % state matrix currently uploaded in RP2
        InitParam(me,'TrialTimestamp','value',0);       % timestamp value when starting the circuit (=experiment)
        boxMasterTimer=timer('TimerFcn','BoxMaster(''update'');','StopFcn','BoxMaster(''update'');','ExecutionMode','fixedDelay','TasksToExecute',Inf);    
%         boxMasterTimer=timer('TimerFcn',[me '(''update'');'],'StopFcn',[me '(''update'');'],'ExecutionMode','fixedRate','TasksToExecute',Inf);    
        
    case 'getready'
        StopBoxCircuit;
        ResetBoxCircuit;
        ResetBoxVariables;
        StartBoxCircuit;
        SetParam(me,'TrialTimestamp',TimeStamp('CurrentValue'));
        SetParam(me,'Trial',1); % start with the first trial:-)
        update=GetParam(me,'UpdatePeriod')/1000; % update period in sec
        set(boxMasterTimer,'Period',update,'StartDelay',update);    % set the requested update period
        start(boxMasterTimer);
        
    case 'trialend'
        StopBoxCircuit;
        stop(boxMasterTimer);   %this also calles 'update' one last time (StopFcn)
        
    case 'run'
        if GetParam(me,'Run')
            SetParamUI(me,'Run','backgroundcolor',[0.9 0 0],'string','Running...');
            update=GetParam(me,'UpdatePeriod')/1000; % update period in sec
            set(boxMasterTimer,'Period',update,'StartDelay',update);    % set the requested update period
            StartBoxCircuit;
            start(boxMasterTimer);
        else
            stop(boxMasterTimer);
            StopBoxCircuit;
            SetParamUI(me,'Run','backgroundcolor',[0 0.9 0],'string','Run');
        end
        
    case 'update'
        RP=GetParam(me,'RP');
        State=invoke(RP,'GetTagVal','State'); % get the current state
        LastEventCounter=GetParam(me,'LastEventCounter');
        LastTriggerCounter=GetParam(me,'LastTriggerCounter');
        EventCounter=invoke(RP,'GetTagVal','EventCounter');     % get the total number of events
        TriggerCounter=invoke(RP,'GetTagVal','TriggerCounter'); % get the total number of hw triggers
        Clock=invoke(RP,'GetTagVal','Clock');
        
        SetParam(me,'Clock',Clock);
        SetParam(me,'EventCounter',EventCounter);
        SetParam(me,'State',State);
        
        nEvents=EventCounter-LastEventCounter;          % number of new events since the last time
        nTriggers=TriggerCounter-LastTriggerCounter;    % number of hardware triggers since the last time 
        
        Events      =invoke(RP,'ReadTagVex','Event',LastEventCounter,nEvents,'F32','F64',1);
        eventTimes  =invoke(RP,'ReadTagVex','EventTime',LastEventCounter,nEvents,'F32','F64',1);
        triggerTimes=invoke(RP,'ReadTagVex','HWTriggerTime',LastTriggerCounter,nTriggers,'F32','F64',1);

        newStates=num2cell(floor(Events./(2^7)));       % states
%         newStates=num2cell(Events);       % states
        newEvents=num2cell(rem(Events,2^7));            % events
        eventTimes=num2cell(eventTimes);                % event times
        triggerTimes=num2cell(triggerTimes);            % trigger times
        
        BoxTrials=GetParam(me,'BoxTrials');
        trial=GetParam(me,'Trial');
        currentTrial=[];
        if nEvents>0
            [currentTrial(1:nEvents).event]=deal(newEvents{:});
            [currentTrial(1:nEvents).state]=deal(newStates{:});
            [currentTrial(1:nEvents).clock]=deal(eventTimes{:});
        end
        if nTriggers>0
            [currentTrial((nEvents+1):(nEvents+nTriggers)).event]=deal(127);        % special event for hw trigger (all bits are set)
            [currentTrial((nEvents+1):(nEvents+nTriggers)).state]=deal(999);        % special state for hw triggers
            [currentTrial((nEvents+1):(nEvents+nTriggers)).clock]=deal(triggerTimes{:});
        end
        if trial>length(BoxTrials)                      % new trial
            first.event=-1;
            first.state=GetParam(me,'StateMatrix');
            first.clock=GetParam(me,'TrialTimestamp');
            BoxTrials{trial}=[first currentTrial];
        else                                            % continuing trial
            trialSoFar=BoxTrials{trial};
            BoxTrials{trial}=[trialSoFar currentTrial];
        end
        SetParam(me,'BoxTrials',BoxTrials);
        
        if isequal(State,35)                            % end of trial
            SetParam(me,'Trial',trial+1);
            SendEvent('eboxmastertrialend',num2str(trial),me);   % tell the dependent modules which trial has just ended
            BoxCircuitNextState;                        % go back to state 0
            SetParam(me,'TrialTimestamp',TimeStamp('CurrentValue')); % get timestamp for the new trial
        end

        SetParam(me,'LastEventCounter',EventCounter);
        SetParam(me,'LastTriggerCounter',TriggerCounter);
        
        
    case 'close'
        stop(boxMasterTimer);
        delete(boxMasterTimer);
        clear boxMasterTimer
        RP=GetParam(me,'RP');
        if ~isempty(RP)
            StopBoxCircuit;     % stop the circuit
            ResetBoxCircuit;    % reset the circuit
        end
        
    case 'reset'
        stop(boxMasterTimer);
        StopBoxCircuit;
        ResetBoxCircuit;
        ResetBoxVariables;
        
    case 'start'
        StartBoxCircuit;
        
    case 'stop'
        StopBoxCircuit;
        
    case 'nextstate'
        BoxCircuitNextState;
        
    case 'water'
        if ExistParam(me,'RP');
            RP=GetParam(me,'RP');
            dur=GetParam(me,'ValveDuration');
            invoke(RP,'SetTagVal','WaterValveDur',dur);
            invoke(RP,'SoftTrg',4);
        end
        
    case 'sendstatematrix'
        if nargin>1
            stateMatrix=varargin{2};
            SetParam(me,'StateMatrix',stateMatrix);
            SendStateMatrix(stateMatrix);
        end    
            
    case 'protocols'
        pNew =GetParam(me,'Protocols','value'); % current position in the list of all protocols
        pList=GetParam(me,'Protocols','list');  % list of all protocols
        pOld =GetParam(me,'Protocols','user');
        newProtocol=lower(pList{pNew});
        oldProtocol=lower(pList{pOld});
        if ~strcmpi(oldProtocol,'')    % there was a protocol open
            ModuleClose(oldProtocol);
            SetParam(me,'dependents','list',{});    % this gets rid of the old module as a dependent. If the module remains as a dependent, it interferes with event sending
                                                    % I know this is ugly,
                                                    % but it will remain
                                                    % here until I come up
                                                    % with some general
                                                    % mechanism to do it...
        end
        if ~strcmpi(newProtocol,'')
            ModuleInit(newProtocol);
        end
        SetParam(me,'Protocols','user',pNew); % remember the new protocol
        StopBoxCircuit;
        ResetBoxCircuit
        ResetBoxVariables;
        
    case 'gettrial'
        out=[];
        if nargin<2
            return;
        else
            ntrial=varargin{2};
        end
        boxtrials=GetParam(me,'BoxTrials');
        if ntrial>length(boxtrials)
            return;
        else
            out=boxtrials(ntrial);
        end
        
end

% Local functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
        % Initialize GUI
        fig = ModuleFigure(me,'visible','off');	
        
        height=0.96/13;  % height of ui control in normalized units (we have 9 rows now, buttons count twice)
        h=0.02;
        
        InitParam(me,'Run','value',0,'ui','togglebutton','pref',0,'units','normal','pos',[h 10*height+h 0.96 3*height]);
    	SetParamUI(me,'Run','string','Run','backgroundcolor',[0 .9 0],'fontweight','bold','fontsize',14,'fontname','Arial','label','');
        
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[h 9*height+h 0.96 height]);
        
        InitParam(me,'Protocols','ui','popupmenu','list',{' '},'value',1,'user',1,...
            'pref',0,'units','normal','pos',[h 8*height+h 0.65 height]);
        SetParamUI(me,'Protocols','label','Protocol');    

        InitParam(me,'Trial','ui','disp','value',1,'pref',0,'units','normal','pos',[h 7*height+h 0.48 height]);
        SetParamUI(me,'Trial','label','Trial');    
        InitParam(me,'EventCounter','ui','disp','value',0,'pref',0,'units','normal','pos',[h 6*height+h 0.48 height]);
        SetParamUI(me,'EventCounter','label','Events');
        InitParam(me,'State','ui','disp','value',0,'pref',0,'units','normal','pos',[h 5*height+h 0.48 height]);
        SetParamUI(me,'State','label','State');
        InitParam(me,'Clock','ui','disp','value',0,'pref',0,'units','normal','pos',[h 4*height+h 0.48 height]);
        SetParamUI(me,'Clock','label','Clock');    

        uicontrol(fig,'string','Next State','style','pushbutton','units','normal','pos',[h 2*height+h 0.48 2*height], ...
            'value', 0, 'tag', 'nextstate', 'callback', [me ';']);
        uicontrol(fig,'string','Water','style','pushbutton','units','normal','pos',[h+0.48 2*height+h 0.48 2*height], ...
            'value', 0, 'tag', 'water', 'callback', [me ';']);

        InitParam(me,'ValveDuration','ui','edit','value',10,'pref',0,'units','normal','pos',[h 1*height+h 0.48 height]);
        SetParamUI(me,'ValveDuration','label','Valve Duration');
        InitParam(me,'UpdatePeriod','ui','edit','value',250,'pref',0,'units','normal','pos',[h h 0.48 height]);
        SetParamUI(me,'UpdatePeriod','label','Update');    
        set(fig,'pos',[200 200 200 300],'visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function InitRP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%	Initialize RP and load the finite state machine
global exper pref
        if ExistParam(me,'RP')
            RP2=GetParam(me,'RP');
        else
            RP2=RP2Control('GetRP2','behavior');
            if isempty(RP2)
                Message(me,'Not enough RP2s...');
                return;
            else    
                InitParam(me,'RP','value',RP2); %param to hold the RP2 activex object
            end
        end

        status=invoke(RP2,'GetStatus');
        loadCircuit=1;  % do we have to load a circuit?
        if status>2 % we're at least connected and some circuit is loaded
            % check if it's the proper circuit. We're looking for a
            % component named StateBuf (should correspond to the
            % buffer which stores the state machine)
            nComponents=invoke(RP2,'GetNumOf','Component');
            for n=1:nComponents
                nameComp=invoke(RP2,'GetNameOf','Component',n);
                if findstr(lower(nameComp),'statebuf')
                    loadCircuit=0; % the loaded circuit appears to be the right one
                    break;
                end
            end
        end
        
        if loadCircuit
            circuit=RP2Control('GetRP2Circuit','behavior');
            if ~invoke(RP2,'LoadCOF',[pref.tdt circuit]);
                Message(me, 'Loading circuit failed');
            else
                Message(me,'Behavior circuit loaded');
            end
        end
        
        status=invoke(RP2,'GetStatus');
        if ~isequal(status,7);
            invoke(RP2,'Run');  % run the circuit if it's not running already
                                % NOTE: don't confuse running the circuit
                                % in RP2 (ActiveX Run; starts the
                                % processing chain) and running the
                                % behavior circuit (SoftTrg 1 in this case;
                                % makes the circuit listen to inputs). The
                                % latter requires the earlier.
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SendStateMatrix(stateMatrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stateMatrix is the state matrix including timer, dio and ao values
% each row has:
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
% there can be 1 to 35 rows, the 36th row is end of trial, added here
if size(stateMatrix,1) > 35
    Message(me,'Matrix > 35 states!','error');
end

% fill out the full state matrix into 36 rows
fullMatrix=zeros(36,10); % 36 states and 7 input,1 timer, 2 output
[rows columns]=size(stateMatrix);
fullMatrix(1:rows,1:columns)=stateMatrix;
fullMatrix(36,:)=[ ...
%  Cin Cout Lin Lout Rin Rout TimeUp Timer DIO AO  
   35  35   35  35   35  35   0      999   0   0]; % State 35 "End Of Trial"

stateMatrix=fullMatrix(:,1:end-3);
rp2Buffer=Matrix2Buffer(stateMatrix); % convert to address table used by RP
timedur=fullMatrix(:,end-2)';   % time duration for states
dio_out=fullMatrix(:,end-1)';   % water valves
ao_out=fullMatrix(:,end)';

RP=GetParam(me,'RP');
invoke(RP,'WriteTagV','StateMatrix',0,rp2Buffer);
invoke(RP,'WriteTagV','TimDurMatrix',0,timedur);
invoke(RP,'WriteTagVEX','DIO_Out',0,'I32',dio_out); % 'I32' uses Word(32bit) format for DIO-Out to Word-Out
invoke(RP,'WriteTagVEX','AO_Out',0,'I32',ao_out); % 'I32' uses Word(32bit) format for AO-Out to Word-Out


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function rp2Buffer=Matrix2Buffer(stateMatrix)    % originally by Gonzalo
% takes the normal (humna readable) state matrix and converts it to vector
% uploadable to RP2/RM1 buffer (StateBuf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%create matrix of indexes
[rows,columns]=size(stateMatrix);  % rows - number of states
                                   % columns - 'atomic' events (always 7)

% we now define the ram matrix
rp2Buffer=zeros(1,rows*128);

% The matrix should be "stable", if no input , it should stay in the same state
rp2Buffer(1:128:(rows*128))=(0:rows-1);

%              Cin  Cout Lin  Lout Rin  Rout TimeUp
channel_value=[1    2    4    8    16   32   64];

for i=1:rows
    for j=1:columns
        if j==7
            addr_index=[1 2 4 8 16 32 0]+channel_value(j)+(i-1)*128; 
        else
            addr_index=(i-1)*128+channel_value(j); 
        end
        rp2Buffer(addr_index+1)=stateMatrix(i,j);        
    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function LoadProtocolsMenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
global exper pref
protocolModules=what(pref.boxprotocols);
protocolList{1}='';  % first protocol is an empty one, so the user has to choose something
if ~isempty(protocolModules)
    protocolModules=protocolModules.m;   % *.m files (protocols) in the directory
        for n=1:length(protocolModules)
            protocolList{n+1} = protocolModules{n}(1:end-2);
        end
end
SetParam(me,'Protocols','value',1,'list',protocolList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResetBoxVariables
global exper pref
SetParam(me,'Trial',1);
SetParam(me,'LastEventCounter',0);
SetParam(me,'LastTriggerCounter',0);
SetParam(me,'BoxTrials','value',{});
SetParam(me,'TrialTimestamp','value',0);
SetParam(me,'EventCounter',0);
SetParam(me,'State',0);
SetParam(me,'Clock',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StartBoxCircuit
global exper pref
    if ExistParam(me,'RP')
            RP=GetParam(me,'RP');
%             StopBoxCircuit;         % stop the circuit in case it's running
%             ResetBoxCircuit;        % reset the circuit
            invoke(RP,'SoftTrg',1); % and run
    end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StopBoxCircuit        
global exper pref
    if ExistParam(me,'RP')
          RP=GetParam(me,'RP');
          invoke(RP,'SoftTrg',2); % stop the circuit
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResetBoxCircuit
global exper pref
    if ExistParam(me,'RP')
          RP=GetParam(me,'RP');
          % be careful with the following lines. They don't work with every
          % circuit!!!
%           % first set current state to state 0
%           state=invoke(RP,'GetTagVal','State'); % get the current state
%           while state>0
%               BoxCircuitNextState;
%               state=invoke(RP,'GetTagVal','State'); % get the current state
%           end
          invoke(RP,'SoftTrg',10); % reset the circuit
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BoxCircuitNextState
global exper pref
    if ExistParam(me,'RP')
          RP=GetParam(me,'RP');
          invoke(RP,'SoftTrg',3); % force Next State in the behavior circuit. In case of state 35 this will shift the circuit to state 0
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
