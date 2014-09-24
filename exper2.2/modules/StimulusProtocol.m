function varargout=StimulusProtocol(varargin)

% Plays a bunch of different stimuli stored in a .mat file ('protocol')
%now has the capability to load files programatically
%call StimulusProtocol('load', fullfilename)
%where fullfilename includes the absolute path (e.g. 'D:\lab\exper2.2\protocols\Tuning Curve protocols\tuning-curve-tones-20f_1000-20000Hz-1a_80-80dB-1d_400ms-isi500ms.mat'
%mw 09.24.13

%ISI works by setting the stimulusProtocolTimerDelay to
%stimulus.param.duration/1000 + stimulus.param.next/1000


global exper pref shared stimulusProtocolTimer stimulusProtocolTimerDelay

varargout{1} = lower(mfilename);

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end


switch action
    case 'init'
        %required modules
        ModuleNeeds(me,{'ao','ai','patchpreprocess','stimulusczar','dataguru'});
        %    SetParam(me,'priority',GetParam('rp2load','priority')+1);
        InitializeGUI;
        % set the timer
        stimulusProtocolTimer=timer('TimerFcn',[me '(''next_stimulus'');'],'StopFcn',[me '(''restart_timer'');'],'ExecutionMode','singleShot');

    case 'close'
        delete(stimulusProtocolTimer);
        clear stimulusProtocolTimer

    case 'run'
        if GetParam(me,'run')
            SetParamUI(me,'Run','backgroundcolor',[0.9 0 0],'String','Playing...');
            start(stimulusProtocolTimer);
        else
            %we want to stop
            SetParamUI(me,'Run','backgroundcolor',[0 0.9 0],'String','Play');
            stimulusProtocolTimerDelay=-1;
            stop(stimulusProtocolTimer);
            
            %reset soundmachine to stop looping sounds %mw 071607
%note that this also aborts sounds in progress
% if ExistParam('soundloadsm', 'sm')
%                 soundloadsm('reset');
%             end
        end

    case 'reset'
        Message(me,'');
        prot=GetParam(me,'Protocol');
        if prot>0
            cstim=GetParam(me,'CurrentStimulus');
            cstim(prot)=0;
            SetParam(me,'CurrentStimulus',cstim);
            SetParam(me,'NRepeats',0);
        end

    case 'resetall'
        Message(me,'');
        cstim=GetParam(me,'CurrentStimulus');
        cstim(:)=0;
        SetParam(me,'CurrentStimulus',cstim);
        SetParam(me,'NRepeats',0);
        
    case 'repeat'
        if GetParam(me,'repeat')
            SetParamUI(me,'Repeat','backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1]);
            SetParamUI(me,'Repeat','string','Repeat On');
        else
            SetParamUI(me,'Repeat','foregroundcolor',[1 1 1],'backgroundcolor',[0.1 0 0.9]);
            SetParamUI(me,'Repeat','string','Repeat Off');
        end

    case 'next_stimulus'
        NextStimulus;

    case 'restart_timer'
        if stimulusProtocolTimerDelay>-1
            stimulusProtocolTimerDelay= round(1000*stimulusProtocolTimerDelay)/1000; 
            %hack to stop that annoying Warning: StartDelay property is
            %limited to 1 millisecond precision.  Sub-millisecond precision
            %will be ignored. mw053007
            set(stimulusProtocolTimer,'StartDelay',stimulusProtocolTimerDelay);
            start(stimulusProtocolTimer);
        else
            stop(stimulusProtocolTimer);
            set(stimulusProtocolTimer,'StartDelay',0);    % next time we push the Play button, it will start immediately
        end

    case 'load'

        %adding capability to push files programatically
        %call StimulusProtocol('load', 'fullfilename')
        %where fullfilename includes the absolute path (e.g. 'D:\lab\exper2.2\protocols\Tuning Curve protocols\tuning-curve-tones-20f_1000-20000Hz-1a_80-80dB-1d_400ms-isi500ms.mat'  

        if nargin==2
            if varargin{2}
                try
                    [pathname, filename,ext] = fileparts(varargin{2});
                end
            end
        else
            
            currentdir=pwd;
            cd(pref.stimuli);
            %         if strcmp(pref.username,'mak')
            %             cd('Michael')
            %         else
            if strcmp(pref.username,'ira')
                cd('Iryna')
            elseif strcmp(pref.username,'teg')
                cd('Taryn')
            end
            [filename, pathname] = uigetfile('*.mat', 'Pick a protocol file');
            cd(currentdir);
        end %if nargin==2
        if isequal(filename,0) || isequal(pathname,0)
            return;
        else
            try
                stimuli=load([pathname '\' filename]);
                f=fieldnames(stimuli);
                stimuli=eval(['stimuli.' f{1}]);        % we take the first field in the loaded structure
                if strcmpi(stimuli(1).type,'exper2 stimulus protocol')
                    AllProtocols=GetParam(me,'AllProtocols');
                    if isempty(find(strcmpi(AllProtocols,stimuli(1).param.name)))
                        desc=stimuli(1).param.description;
                        description=GetParam(me,'Description');
                        description={description{:} desc};
                        SetParam(me,'Description',description);
                        nam=stimuli(1).param.name;
                        name=GetParam(me,'Name');
                        name={name{:} nam};
                        SetParam(me,'Name',name);

                        stimuli(1)=[];
                        %                     stim=GetParam(me,'Stimuli');
                        stim=GetSharedParam('StimulusProtocols');
                        stim={stim{:} stimuli};
                        %                     SetParam(me,'Stimuli',stim);
                        SetSharedParam('StimulusProtocols',stim);

                        cstim=GetParam(me,'CurrentStimulus');
                        cstim=[cstim 0];
                        SetParam(me,'CurrentStimulus',cstim);

                        nstim=GetParam(me,'NStimuli');
                        nstim=[nstim length(stimuli)];
                        SetParam(me,'NStimuli',nstim);

                        nprot=GetParam(me,'NProtocols');
                        nprot=nprot+1;
                        SetParam(me,'NProtocols',nprot);

                        allprot=GetParam(me,'AllProtocols');
                        if isequal(allprot,{''})    % this is the first protocol added
                            allprot={nam};
                            SetParamUI(me,'Run','enable','on');
                            obj=findobj('tag','protocol_description');
                            outstring=textwrap(obj(1),{desc});
                            set(obj,'String',outstring);
                            obj=findobj('tag','protocol_name');
                            outstring=textwrap(obj(1),{nam});
                            set(obj,'String',outstring);
                            SendEvent('EStimulusProtocolChanged',[],me,'all');
                        else
                            allprot={allprot{:} nam};
                        end
                        SetParam(me,'AllProtocols',allprot);
                        SetParamUI(me,'Protocol','String',allprot);
                        if numel(allprot)==1    % if this is the first protocol, make it active
                            SetParam(me,'Protocol','value',1);
                        end

                        SetParam(me,'Stimulus',[]);
                        Message(me,'Stimuli loaded');
                        SetParam(me,'NRepeats',0);

                    else
                        Message(me,'Protocol already loaded');
                    end
                else
                    Message(me,'Not a valid protocol file');
                end
            catch
                Message(me,'Can''t load the protocol file');
            end
        end

    case 'protocol'
        protocol=GetParam(me,'Protocol');
        current=GetParam(me,'CurrentStimulus');
        nstimuli=GetParam(me,'NStimuli');
        Message(me,[num2str(current(protocol)) '/' num2str(nstimuli(protocol))]);
        desc=GetParam(me,'Description');
        obj=findobj('tag','protocol_description');
        outstring=textwrap(obj(1),{desc{protocol}});
        set(obj,'String',outstring);
        nam=GetParam(me,'Name');
        obj=findobj('tag','protocol_name');
        outstring=textwrap(obj(1),{nam{protocol}});
        set(obj,'String',outstring);
        SendEvent('EStimulusProtocolChanged',[],me,'all');
        SetParam(me,'NRepeats',0);

    case 'getcurrentprotocol'
        varargout={GetParam(me,'Protocol')};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SendStimulus(stimulus)
%global exper pref
StimulusCzar('send',stimulus);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NextStimulus
global stimulusProtocolTimer stimulusProtocolTimerDelay
protocol=GetParam(me,'Protocol');
current=GetParam(me,'CurrentStimulus');
nstimuli=GetParam(me,'NStimuli');
if current(protocol)==nstimuli(protocol) % we played everything
    current(protocol)=0;                % so let's start from the beginning;
    SetParam(me,'NRepeats', GetParam(me, 'NRepeats')+1);
    if ~GetParam(me,'Repeat')           % if we don't want to repeat,
        stimulusProtocolTimerDelay=-1;          % this will cause the timer to stop
        SetParam(me,'Run',0);
        SetParamUI(me,'Run','backgroundcolor',[0 0.9 0],'String','Play');
        SetParam(me,'CurrentStimulus',current);
        return;
    end
end
current(protocol)=current(protocol)+1;
SetParam(me,'CurrentStimulus',current);
%         stimuli=GetParam(me,'Stimuli');
stimuli=GetSharedParam('StimulusProtocols');
stimuli=stimuli{protocol};
stimulus=stimuli(current(protocol));
multipleStimuli=iscell(stimulus.param);
switch multipleStimuli
    case 0
        if isfield(stimulus.param,'next')
            iti=stimulus.param.next/1000;
        else
            iti=0.5;    % set fixed iti for now to 500ms;
        end
    case 1   % just look at the first one of the multiple stimuli for now
        if isfield(stimulus.param{1},'next')
            iti=stimulus.param{1}.next/1000;
        else
            iti=0.5;    % set fixed iti for now to 500ms;
        end
end

delay=0;  % 0.25s is the min. delay imposed by SoundLoad
delay=max(delay,0);
if ~isfield(stimulus.param, 'duration')
    error('Improperly designed stimulus: no duration field. ')
end
if multipleStimuli
    durs=[stimulus.param{:}];
    duration=max([durs.duration]);
    stimulusProtocolTimerDelay=duration/1000+iti-delay; % next time I should also check whether iti-delay>0
else
    stimulusProtocolTimerDelay=stimulus.param.duration/1000+iti-delay; % next time I should also check whether iti-delay>0
end
%fprintf('\nstimulusProtocolTimerDelay %.1f', stimulusProtocolTimerDelay)
SendStimulus(stimulus);
% Message(me,[num2str(current(protocol)) '/' num2str(nstimuli(protocol))]);
Message(me,[num2str(current(protocol)) '/' num2str(nstimuli(protocol)) ', ' num2str(GetParam(me, 'NRepeats')) ' repeats' ]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);
% me
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisableParamChange
fig=findobj('type','figure','tag',me);
h=findobj(fig,'type','uicontrol','style','edit');
for cnt=1:length(h)
    set(h(cnt),'enable','off')
end
% DisableParamChange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EnableParamChange
fig=findobj('type','figure','tag',me);
h=findobj(fig,'type','uicontrol','style','edit');
for cnt=1:length(h)
    set(h(cnt),'enable','on')
end
%EnableParamChange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function InitializeGUI
fig = ModuleFigure(me,'visible','off');
set(fig,'pos',[200 300 200 300],'visible','on');

%     figure(fig);
% GUI positioning factors

% message box
uicontrol('parent',fig,'string','Reset','tag','reset','units','normal',...
    'position',[0.02 0.02 0.48 0.12],'enable','on','foregroundcolor',[0.9 0 0],...
    'fontweight','bold',...
    'style','pushbutton','callback',[me ';']);

uicontrol('parent',fig,'string','Reset All','tag','resetall','units','normal',...
    'position',[0.5 0.02 0.48 0.12],'enable','on','foregroundcolor',[0.9 0 0],...
    'fontweight','bold',...
    'style','pushbutton','callback',[me ';']);

uicontrol(fig,'tag','protocol_description','style','text','units','normal',...
    'enable','inact','horiz','left','pos',[0.02 0.14 0.96 0.20]);

uicontrol(fig,'tag','protocol_name','style','text','units','normal','fontweight','bold',...
    'enable','inact','horiz','left','pos',[0.02 0.34 0.96 0.10]);

AllProtocols={''};
InitParam(me,'AllProtocols','value',AllProtocols);
InitParam(me,'Protocol',...
    'pref',0,'units','normal',...
    'ui','popupmenu','pos',[0.02 0.44 0.68 0.1]);
SetParamUI(me,'Protocol','String',AllProtocols,'value',1);

uicontrol('parent',fig,'string','Load from...','tag','load','units','normal',...
    'position',[0.02 0.54 0.48 0.12],'enable','on',...
    'style','pushbutton','callback',[me ';']);
InitParam(me,'Repeat','string','Repeat','value',1,'ui','togglebutton','pref',0,'units','normal',...
    'backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold','pos',[0.5 0.54 0.48 0.12]);

uicontrol(fig,'tag','message','style','edit','fontweight','bold','units','normal',...
    'enable','inact','horiz','left','pos',[0.02 0.66 0.96 0.1]);

InitParam(me,'Run','value',0,'ui','togglebutton','pref',0,'units','normal','pos',[0.02 0.76 0.96 0.22]);
SetParamUI(me,'Run','string','Play','fontweight','bold','fontsize',12,'fontname','Arial','backgroundcolor',[0 0.9 0],'label','','enable','off');

set(fig,'pos',[150 115 300 300],'visible','on');

SetSharedParam('StimulusProtocols',{});
InitParam(me,'CurrentStimulus','value',[]);
InitParam(me,'NStimuli','value',[]);
InitParam(me,'Name','value',{});
InitParam(me,'Description','value',{});
InitParam(me,'NProtocols','value',0);
InitParam(me,'NRepeats','value',0); %accumulates number of repeats played %mw101806
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
