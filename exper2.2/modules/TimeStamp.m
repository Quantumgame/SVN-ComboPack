function out=TimeStamp(varargin)

% sends out a time-stamp (manchester encoded 22-bit integer) using RP2
%
% TimeStamp('CurrentValue') returns the current value of timestamp

%disabling this module because it is meant to control an RP2 (which we
%don't have in the Wehr Lab) and mistakenly loading this module causes
%annoying ActiveX errors.
%mw 07.14.10
fprintf('\ntimestamp: this module is currently disabled. Did you mean to load TimeMark?')
return

global exper pref

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

out=[];

switch action
case 'init'
    ModuleNeeds(me,{'rp2control'});
    InitializeGUI;
    InitRP2
       
case 'timestamp'
    RP2=GetParam(me,'RP2');
    Message(me,'');
    status=invoke(RP2,'GetStatus'); % are we connected and loaded?
    if GetParam(me,'TimeStamp')     % we want to start the timestamp
        if status==3
            invoke(RP2,'Run');
            pause(0.05); %wait for 50 ms - the circuit sends out 0 and then it's ready. This takes about one frame (~33ms)
        end
        status=invoke(RP2,'GetStatus'); % are we running?
        if status==7
            invoke(RP2,'SoftTrg',9);
            SetParamUI(me,'TimeStamp','String','TimeStamp running...','backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1]);
        else
            Message(me,'Can''t start timestamp');
            SetParam(me,'TimeStamp',0);
        end
    else
        % for now, we don't want to stop the entire circuit, because that
        % would mean stopping behavior circuit as well (timestamp and
        % behavior circuits are combined into one to save RP2s
%         invoke(RP2,'Halt');
        SetParamUI(me,'TimeStamp','String','TimeStamp','backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1]);
    end
       
case 'currentvalue'
    if ExistParam(me,'RP2')
        RP2=GetParam(me,'RP2');
        value=invoke(RP2,'GetTagVal','CurrentValue');
        out=value;
    end
        
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitRP2
global exper pref
        if ExistParam(me, 'RP2')
            RP2=GetParam(me, 'RP2');
        else
            RP2=RP2Control('GetRP2','timestamp');
            if isempty(RP2)
                Message(me,'Not enough RP2s...');
                return;
            else    
                InitParam(me,'RP2','value',RP2); %param to hold the RP2 activex object
            end
        end

        status=invoke(RP2,'GetStatus');
        loadCircuit=1;  % do we have to load a circuit?
        if status>2 % we're at least connected and some circuit is loaded
            % check if it's the proper circuit. We're looking for a
            % component named TStmpRun (should correspond to the
            % software trigger which starts timestamp
            nComponents=invoke(RP2,'GetNumOf','Component');
            for n=1:nComponents
                nameComp=invoke(RP2,'GetNameOf','Component',n);
                if findstr(lower(nameComp),'tstmprun')
                    loadCircuit=0; % the loaded circuit appears to be the right one
                    break;
                end
            end
        end
        
        if loadCircuit
            circuit=RP2Control('GetRP2Circuit','timestamp');
            if ~invoke(RP2,'LoadCOF',[pref.tdt circuit]);
                Message(me, 'Loading circuit failed');
            else
                Message(me,'TimeStamp circuit loaded');
            end
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
%		Configure the GUI for playing the stimuli.
    fig = ModuleFigure(me);
    set(fig,'doublebuffer','on','visible','off');

    hs = 120;
    h = 5;
    vs = 20;
    n = 4;
    % message box
    uicontrol('parent',fig,'tag','message','style','text','units','normal',...
              'enable','inact','horiz','left','pos',[0.02 0.02 0.96 0.2]);
	InitParam(me,'TimeStamp','string','TimeStamp','value',0,'ui','togglebutton','pref',0,'units','normal',...
        'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold','pos',[0.02 0.22 0.96 0.76]);
          
          
    screensize=get(0,'screensize');
    set(fig,'pos', [screensize(3)-128 screensize(4)-n*vs-240 128 n*vs] ,'visible','on'); 
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

