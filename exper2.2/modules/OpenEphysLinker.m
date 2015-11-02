function varargout = OpenEphysLinker( varargin )

%Exper module that finds and stores the filename of the most recently created Open Ephys data file
% and whether it is being recorded when run is clicked in exper. Clicking
% 'Manually link file' allows you to manually associate a file.

global exper pref

varargout{1} = lower(mfilename);
if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
    
    case 'init'
        %ModuleNeeds(me,{'ao','ai'});
        %SetParam(me,'priority','value',GetParam('ai','priority')+1);
        CreateGUI; %local function that creates ui controls and initializes ui variables
        
    case 'trialready'
    case 'getready'
        getOEpathname
    case 'trialend'
        
    case 'close'
        
    case 'reset'
    case 'manual'
        ManualLink
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getOEpathname;
% finds the OE file
% assumes OE filenames are exactly 19 characters long
global pref
try
    cd(pref.data)
    d=dir;
    thisyear=clock;
    thisyear=thisyear(1);
    for i=1:length(d)
        if d(i).isdir
            if length(d(i).name)==19
                if strcmp(d(i).name(1:4), int2str(thisyear))
                    dn(i)=d(i).datenum;
                end
            end
        end
    end
    fileidx= find(dn==(max(dn))); %most recent dir
    OEpathname=fullfile(pwd, d(fileidx).name);
    SetParam(me,'OEpathname',OEpathname);
    cd(OEpathname)
    isRecording=0;
    
    d=dir('*.continuous');
    if ~isempty(d)
        fsize1=d(1).bytes;
        pause(.1)
        d=dir('*.continuous');
        fsize2=d(1).bytes;
        if fsize2>fsize1
            isRecording=1;
        end
    else
        d=dir('*.spikes');
        if ~isempty(d)
            fsize1=d(1).bytes;
            pause(.1)
            d=dir('*.spikes');
            fsize2=d(1).bytes;
            if fsize2>fsize1
                isRecording=1;
            end
        end
    end
    SetParam(me,'isRecording',isRecording);
    if isRecording
        str=sprintf('OEpath: %s\nrecording is ON', OEpathname);
    else
        str=sprintf('OEpath: %s\nrecording is OFF', OEpathname);
    end
catch
    str=sprintf('Could not find any OE files!');
    SetParam(me,'isRecording',0);
    SetParam(me,'OEpathname','');
    
end
%check that laser and soundcardtrigger channels are being recorded
filename='100_ADC1.continuous';
d=dir(filename);
if isempty(d)
    str=sprintf('%s\nWarning! ADC 1 not being recorded', str);
end
filename='100_ADC2.continuous';
d=dir(filename);
if isempty(d)
    str=sprintf('%s\nWarning! ACD 2 not being recorded', str);
end
Message(me, str);

function ManualLink
global pref
cd(pref.home)
[filename, OEpathname] = uigetfile({'*.continuous;*.spikes'}, 'Pick Open Ephys data file');

if isequal(filename,0) || isequal(OEpathname,0)
else
    SetParam(me,'OEpathname',OEpathname);
    cd(OEpathname)
    isRecording=0
    
    d=dir(filename);
    if ~isempty(d)
        fsize1=d(1).bytes;
        pause(.1)
        d=dir(filename);
        fsize2=d(1).bytes;
        if fsize2>fsize1
            isRecording=1;
        end
    end
    SetParam(me,'isRecording',isRecording);
end
if isRecording
    str=sprintf('Manually set OEpath to %s\nrecording is ON', OEpathname);
else
    str=sprintf('Manually set OEpath to %s\nrecording is OFF', OEpathname);
end
Message(me, str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
fig = ModuleFigure(me,'visible','off');

% GUI positioning factors
hs = 60;
h = 5;
vs = 20;
n = 0;

% pushbuttons
uicontrol('parent',fig,'string','Manually link file','tag','manual',...
    'units','normal','position',[.01 .01 .5 .2],...
    'style','pushbutton','callback',[me ';']);
n=n+2;

OEpathname='';
InitParam(me,'OEpathname','save',1,...
    'value',OEpathname,...
    'ui','disp','pos',[h n*vs hs vs]); n=n+1;

IsRecording=0;
InitParam(me,'isRecording','save',1, ...
    'value',IsRecording,...
    'ui','disp','pos',[h n*vs hs vs]); n=n+1;

% message box
uicontrol(fig,'tag','message','style','text', ...
    'enable','inact','horiz','left','pos',[h n*vs hs*4 vs*3]); n = n+1;



set(fig,'pos',[163 646 260 160]);
% Make figure visible again.
set(fig,'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%