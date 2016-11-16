function varargout = RecordSound(varargin)
% RECORDSOUND M-file for RecordSound.fig
%
%standalone function to record sounds through a B&K
%mike 08.13.13
%
%      RECORDSOUND, by itself, creates a new RECORDSOUND or raises the existing
%      singleton*.
%
%      H = RECORDSOUND returns the handle to a new RECORDSOUND or the handle to
%      the existing singleton*.
%
%      RECORDSOUND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORDSOUND.M with the given input arguments.
%
%      RECORDSOUND('Property','Value',...) creates a new RECORDSOUND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RecordSound_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RecordSound_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RecordSound

% Last Modified by GUIDE v2.5 13-Aug-2013 18:13:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RecordSound_OpeningFcn, ...
                   'gui_OutputFcn',  @RecordSound_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RecordSound is made visible.
function RecordSound_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RecordSound (see VARARGIN)

% Choose default command line output for RecordSound
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RecordSound wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%initialize
mic_sensitivity=1;
aisamprate=176000;
dataChannel=3;
ai=analoginput('nidaq','Dev1'); %mw 12.16.05
addchannel(ai,dataChannel);
ai.Channel(:).InputRange=[-10 10];
ai.Channel(:).SensorRange=[-10 10];
ai.Channel(:).UnitsRange=[-1 1]; %changed to -1 to 1 for wav file format
% Set trigger.
ai.TriggerType='Immediate'; %goes as soon as you start ai
set(ai, 'samplerate', aisamprate);
ai.SamplesPerTrigger=inf;
ai.LoggingMode='Disk'; %default "Memory" runs out of memory after about 2 minutes

%store ai in guidata
mydata = guidata(hObject);
mydata.ai=ai;
guidata(hObject, mydata);
fprintf('\ninitialized')


% --- Outputs from this function are returned to the command line.
function varargout = RecordSound_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
ai=mydata.ai;
start(ai);
fprintf('\nstarted')


% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
ai=mydata.ai;
stop(ai);
fprintf('\nstopped')
SamplesAcquired=get(ai, 'SamplesAcquired');

%get data 
mydata = guidata(hObject);
ai=mydata.ai;
Fs=get(ai, 'samplerate');
%SamplesAvailable=get(ai, 'SamplesAvailable');
%data=getdata(ai, SamplesAvailable); %(this was for log to memory)
SamplesAcquired=get(ai, 'SamplesAcquired');
data=daqread('logfile.daq'); 
mydata.data=data;
mydata.SamplesAcquired=SamplesAcquired;
guidata(hObject, mydata);
fprintf('\nread data')

fprintf('\nplotting...')
%plot data
% try
%     h=findobj('type', 'axes', 'tag', 'PlotWindow');
%     % plot(data);
%     win=1024; noverlap=0; nfft=512;
%     nfft=4096
%     figure; hold on; %plots data on a separate figure, ira 08.17.15
%     spectrogram(data, win, noverlap, nfft, Fs, 'yaxis');
% catch
%     fprintf('\ncould not plot. error message:')
%     lasterr
%     %if you get out of memory errors, try increasing win size to 2^12 or
%     %higher, and lowering nfft to 256 vs. win=1024 and nfft =512.
% end



% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
data=mydata.data;
ai=mydata.ai;
Fs=get(ai, 'samplerate');
wd=pwd;
try
    cd D:\lab\
end
[filename, pathname] = uiputfile('*.wav', 'Save wav file as...');
cd(pathname)
wavwrite(data, Fs, 16, filename);
cd(wd)
delete('logfile.daq')
cd(pathname)
fprintf('\nsaved wav file and deleted daqfile.')
