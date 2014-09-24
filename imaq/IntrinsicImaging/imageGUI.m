function varargout = imageGUI(varargin)
% IMAGEGUI MATLAB code for imageGUI.fig
%      IMAGEGUI, by itself, creates a new IMAGEGUI or raises the existing
%      singleton*.
%
%      H = IMAGEGUI returns the handle to a new IMAGEGUI or the handle to
%      the existing singleton*.
%
%      IMAGEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEGUI.M with the given input arguments.
%
%      IMAGEGUI('Property','Value',...) creates a new IMAGEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageGUI

% Last Modified by GUIDE v2.5 10-Aug-2012 15:58:22

% Begin initialization code - DO NOT EDIT
global user
if ~nargin
    [ok, user]=Login;
    if ~ok
        return
    end
end

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imageGUI_OpeningFcn, ...
    'gui_OutputFcn',  @imageGUI_OutputFcn, ...
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

if iscell(user) user=user{:};end
    h=findobj('Tag', 'User');
    set(h, 'string', user);


% --- Executes just before imageGUI is made visible.
function imageGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)
% varargin   command line arguments to imageGUI (see VARARGIN)

% Choose default command line output for imageGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imageGUI wait for User response (see UIRESUME)
% uiwait(handles.figure1);

WriteMessage('Did you open Sapera CamExpert and, in the Camera Link Serial Command window, enter "sbm 2 2", and "ssf 8", and "set 125000"? Note you only need to do this once when first powering on the camera.')
InitCamera(hObject, handles)
CreateDataDir
InitStimInputTable
StimInputTable_CellEditCallback(findobj('Tag', 'StimInputTable'))
 set(0,'DefaultFigureWindowStyle','normal') 

% --- Outputs from this function are returned to the command line.
function varargout = imageGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in TakeSurfaceImage.
function TakeSurfaceImage_Callback(hObject, eventdata, handles)
% hObject    handle to TakeSurfaceImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)
close(findobj('Type', 'figure', 'Tag', 'Surface Image'));
vid=handles.vid;
if isempty(vid) fprintf('\nsimulation mode');return; end
vid.FramesPerTrigger=10;
vid.TriggerRepeat = 0;
triggerconfig(vid, 'immediate');
start(vid)
g = getdata(vid, 10);
stop(vid)
g=squeeze(g);
g=mean(g,3);
fig=figure;
imagesc(g)
colormap(gray)
title('Surface Image')
set(gcf, 'Tag', 'Surface Image');
set(gcf, 'pos', [44   571   560   420])
save g g


% --- Executes on button press in LoadSurfaceImage.
function LoadSurfaceImage_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSurfaceImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)
[filename, pathname] = uigetfile('g.mat', 'Pick a surface image file (g.mat)');
if isequal(filename,0) || isequal(pathname,0)
    %'user pressed cancel'
else
    try
        cd(pathname)
        load(filename)
        close(findobj('Type', 'figure', 'Tag', 'Surface Image'));
        figure
        imagesc(g)
        colormap(gray)
        set(gcf, 'pos', [44   571   560   420])
        title('Surface Image')
        set(gcf, 'Tag', 'Surface Image');
        %save to local file
        h=findobj('Tag', 'DataPath');
        datapath=get(h, 'string');
        cd(datapath)
        save g g
        
    end
end

% --- Executes on button press in CheckLightLevels.
function CheckLightLevels_Callback(hObject, eventdata, handles)
% hObject    handle to CheckLightLevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)
close(findobj('Type', 'figure', 'Tag', 'Light Level Histogram'));
close(findobj('Type', 'figure', 'Tag', 'Image'));
vid=handles.vid;
if isempty(vid) fprintf('\nsimulation mode');return; end
vid.FramesPerTrigger=10;
triggerconfig(vid, 'immediate');
start(vid)
m = getdata(vid, 10);
stop(vid)
m=squeeze(m);
m=mean(m,3);

figure;
set(gcf, 'pos', [44   571   560   420])
imagesc(m)
colormap(gray)
title('Image')
set(gcf, 'Tag', 'Image');

fig=figure;
set(gcf, 'pos', [144   571   560   420])
hist(reshape(m, 1, prod(size(m))), 1000);
title('Light Level Histogram')
set(gcf, 'Tag', 'Light Level Histogram');


% --- Executes on button press in Go.
function Go_Callback(hObject, eventdata, handles)
% hObject    handle to Go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)

%make sure current stimparams are written
StimInputTable_CellEditCallback(findobj('tag', 'StimInputTable'), '', '')

vid=handles.vid;
if isempty(vid) fprintf('\nsimulation mode');return; end
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;
triggerconfig(vid, 'hardware', 'risingEdge-ttl', 'trigger1');

filenum=0;
data=get(findobj('tag', 'StimOutputTable'), 'Data');
nframes=data(4);
totaldurationsecs=data(5);
vid.timeout=totaldurationsecs+10;
fprintf('\ncollecting %d frames (%.1f s)', nframes, totaldurationsecs)

start(vid);
fprintf('\nimaq started, waiting for triggers...')
fprintf('\nlaunching stimulus thread...')

%launch matlab-32 R2010b for PPA sound delivery
imstimstr=sprintf('imstimTonesPPA_GUI(''%s''); exit', pwd);
cmdstr=sprintf('"C:\\Program Files (x86)\\MATLAB\\R2010b\\bin\\matlab.exe" -automation -nodesktop -nosplash -nojvm -r "%s"', imstimstr);
system(cmdstr);



if 1 %nframes<100
   try
       M = getdata(vid, nframes);
 %   filenum=filenum+1;
    %save(fn, 'M');
    %fprintf('\nsaved all %d frames to file 1', nframes)
   catch
       M = getdata(vid, get(vid, 'FramesAvailable'));
   end
    fn=sprintf('M-%d.mat', filenum);
   end
% for i=1:floor(nframes/100)
%     try
%         m = getdata(vid, 100);
%         
%         filenum=filenum+1;
%         fn=sprintf('M-%d.mat', filenum);
%         save(fn, 'm');
%         fprintf('\nsaved file %d', i)
%         
%     catch
%         fprintf('\n\ntime out error. \nall data saved.')
%         return
%     end
% end
        fprintf('\ndone')
WriteMessage('done')
stop(vid)

%check the AnalyzeWhenDone checkbox
% Hint: get(hObject,'Value') returns toggle state of AnalyzeWhenDone
hAnalyzeWhenDone=findobj('Tag', 'AnalyzeWhenDone');
if get(hAnalyzeWhenDone,'Value')
    %     imanal2(pwd)
    fprintf('\nAnalyzing...')
    fft_mem(pwd, M);
end
%write video data to file for possible later analysis
fprintf('\nsaving raw video data...')
save(fn, 'M');
fprintf('done\n')


function User_Callback(hObject, eventdata, handles)
% hObject    handle to User (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of User as text
%        str2double(get(hObject,'String')) returns contents of User as a double


% --- Executes during object creation, after setting all properties.
function User_CreateFcn(hObject, eventdata, handles)
% hObject    handle to User (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes when entered data in editable cell(s) in StimInputTable.
function StimInputTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to StimInputTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the User
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and User data (see GUIDATA)
fprintf('\n%s', get(hObject, 'tag'))
data=get(hObject, 'Data');
stimparams.freqsperoctave=data(1);
stimparams.minfreq=data(2);
stimparams.maxfreq=data(3);
stimparams.duration=data(4);
stimparams.amplitude=data(5);
stimparams.ramp=data(6);
stimparams.nreps=data(7);
stimparams.iti=data(8);
stimparams.delay=data(9);
% error checking
if stimparams.duration  <0
    error('duration out of bounds')
end
if stimparams.nreps  <1
    error('nreps out of bounds')
end
GenerateToneSeries(stimparams)

function InitStimInputTable
%here is where we set the default stimulus parameters
freqsperoctave=4;
minfreq=1189;
maxfreq=80000;
duration=50;
amplitude=75;
ramp=5;
nreps=25;
iti=500;
delay=20;

data(1)=freqsperoctave;
data(2)=minfreq;
data(3)=maxfreq;
data(4)=duration;
data(5)=amplitude;
data(6)=ramp;
data(7)=nreps;
data(8)=iti;
data(9)=delay;
hObject=findobj('Tag', 'StimInputTable');
set(hObject, 'Data', data')

% --- Executes when selected cell(s) is changed in StimInputTable.
function StimInputTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to StimInputTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and User data (see GUIDATA)

function GenerateToneSeries(stimparams)
freqsperoctave=stimparams.freqsperoctave;
minfreq=stimparams.minfreq;
maxfreq=stimparams.maxfreq;
duration=stimparams.duration;
amplitude=stimparams.amplitude;
ramp=stimparams.ramp;
nreps=stimparams.nreps;
iti=stimparams.iti;
delay=stimparams.delay;
Fs=192000;
numoctaves=log2(maxfreq/minfreq);
logspacedfreqs=minfreq*2.^([0:(1/freqsperoctave):numoctaves]);
newmaxfreq=logspacedfreqs(end);
numfreqs=length(logspacedfreqs);
ascending= get(findobj('tag', 'Ascending'), 'value');
if ascending<=0
    logspacedfreqs=fliplr(logspacedfreqs);
end

if maxfreq~=newmaxfreq
    str=sprintf('note: could not divide %d-%d Hz evenly into exactly %d frequencies per octave', minfreq, maxfreq, freqsperoctave);
    WriteMessage(str)
    str=sprintf('using new maxfreq of %d to achieve exactly %d frequencies per octave', round(newmaxfreq), freqsperoctave);
    WriteMessage(str)
    maxfreq=newmaxfreq;
end


t=0:1/Fs:.001*duration;
toneseries=[];
for i=1:numfreqs
    frequency = logspacedfreqs(i);
    tone=sin(frequency*2*pi*t);
    tone=tone./(max(abs(tone))); % normalize
    calibrated_amplitude=calibrate(frequency, amplitude, logspacedfreqs);
    tone=calibrated_amplitude*tone;
    
    if ramp>0
        [edge,ledge]=MakeEdge(ramp,Fs);     % prepare the edges
        tone(1:ledge)=tone(1:ledge).*fliplr(edge);
        tone((end-ledge+1):end)=tone((end-ledge+1):end).*edge;
    end
    silence=zeros(1, round(Fs*.001*(iti-duration)));
    toneseries=[toneseries tone silence];
end
serieslength=length(toneseries);



total_duration=nreps*length(toneseries)/Fs;
series_periodicity = Fs/serieslength;

% %this code puts  synch clock (1-ms TTL pulses) on channel 2 (to trig each frame grab)
triglength=round(Fs/1000); %1 ms trigger
ttl_interval=134; %in ms %ttl_interval=1000/FPS; %in ms %125ms=8Hz
FPS=1000/ttl_interval; %FPS=10; %frames per second
ttl_int_samp=round(ttl_interval*Fs/1000); %ttl_interval in samples
series_period_frames=serieslength/ttl_int_samp;
newserieslength=ttl_int_samp*round(series_period_frames);
str=sprintf('readjusting toneseries by %d samples (%.2f ms)', newserieslength-serieslength, 1000*(newserieslength-serieslength)/Fs);
WriteMessage(str)
if newserieslength<serieslength
    toneseries=toneseries(1:newserieslength);
elseif serieslength<newserieslength
    spoo=zeros(1,newserieslength);
    spoo(1:serieslength)=toneseries;
    toneseries=spoo;
end
ttl_pulses=zeros(size(toneseries));
serieslength=length(toneseries);

str=sprintf('video frame interval: %d samples = %.4f ms = %.4f fps', ttl_int_samp, 1000*ttl_int_samp/Fs,Fs/ttl_int_samp);
WriteMessage(str)
%fprintf('\nseries period %.4f frames', serieslength/ttl_int_samp)
series_period_sec=serieslength/Fs;
%write stimulus params to file
timestamp=datestr(now);

ttl_idx=1:ttl_int_samp:(length(toneseries)-triglength);
total_duration_frames=nreps*length(ttl_idx);
for i=ttl_idx
    ttl_pulses(i:i+triglength-1)=.8*ones(size(1:triglength));
end
tone2=zeros(length(toneseries),2); %iti is implemented as silence after tone
tone2(:,1)=toneseries;
tone2(:,2)=ttl_pulses;

save toneseries tone2

%update StimOutputTable
data=[series_period_sec; series_periodicity; length(logspacedfreqs); total_duration_frames; total_duration;total_duration/60 ];
set(findobj('tag', 'StimOutputTable'), 'Data', data)
stimparams.series_period_sec=series_period_sec;
stimparams.series_period_frames=series_period_frames;
stimparams.series_periodicity=series_periodicity;
stimparams.FPS=FPS;
save stimparams stimparams
%end function GenerateToneSeries

function  lineamp=calibrate(frequency, amplitude, logspacedfreqs)
%look-up table to correct for speaker frequency response
%the speaker frequency response has to be collected by hand with
%B&K and oscilloscope
%frequencies (Hz):
f=sort(logspacedfreqs); %sort so descending tones are ascending, since the cal values below are for ascending freq

% I recorded these freqs using the B&K from rig2 and placing the microphone
% ~11 cm from the speaker. Using the oscilloscope on Cyc RMS and averaging
% 64 traces I obtained the following values (mV).
% 85 dB command amplitude did pretty well
% mk 22may2012

%amp_in_mV=[1.490 1.100 .968 1.270 .984 .685 .904 .485 .301 .233 .373 .528 .573 .140 .125 .530 .533];
%above is for old speaker setup
amp_in_mV=[1.75 .90 1.22 1.92 1.84 2.37 3.14 6.8 9.7 11.2 6.7 5.1 10.8 6.70 5.16 4.50 11.3 12.4 2.69 2.12 1.41 .920 .880 .758 .350];
%amp_in_mV=[1.75 .90 1.22 1.92 1.84 2.37 3.14 6.8 9.7 11.2 6.7 5.1 10.8 6.70 5.16 4.50] %1.189-16Khz
%   recorded at 85dB command, with maxSPL=100 cto 06aug2012 - new
%   ultrasonic speaker
%amp_in_mV=[];
% converts amp_in_mV to dB
a=zeros(1,length(amp_in_mV));
for i=1:length(amp_in_mV)
    a(i)=dBSPL(amp_in_mV(i),1);
end
da=a-min(min(a));
% da=zeros(1,length(f)); %comment in and comment out the line above to calibrate,
% place recorded values (mV) into amp_in_mV above and note the command dB

maxSPL=100; % set by mk 23may2012. See lab notebook on page 7 for details.
% This works in conjuction with amp_in_mV
% In short, maxSPL=110, with command amp of 85 produced ~65 dB
%           maxSPL=100, with command amp of 85 produced 76 dB
%           maxSPL= 91, with command amp of 85 produced 85 +/- 0.5 dB
%           maxSPL= 91, with command amp of 75 produced 74 +/- 1 dB
%           maxSPL= 91, with command amp of 65 produced 62 +/- 2 dB
% I used maxSPL=100 to obtain amp_in_mV above da set to zero. If I were to
% re-record these values by simply setting maxSPL to 91, the amp_in_mV
% values will change. Thus, maxSPL needs to be adjusted by 9 in the linamps
% calculation.
maxSPL_adjusted=maxSPL-9;
%changed from -9 (old setup)
amps=amplitude-da; %adjusted dB for each freq

%  lineamps = 1*(10.^((amps-maxSPL)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
%   Use this one for recording the raw sounds with da set to zero
lineamps = 1*(10.^((amps-maxSPL_adjusted)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
%   Use this one to ensure the command amplitude matches the actual speaker
%   output. You may need to adjust maxSPL_adjusted a little, currently -9
%   works pretty well

findex=find(f<=frequency, 1, 'last');

try
    lineamp=lineamps(findex);
catch
    warning('calibration error: tones not calibrated')
    lineamp=lineamps(end);
end

%end function calibrate

function WriteMessage(text)
h=findobj('Tag', 'MessageBox');
% oldstr=get(h, 'String');
% newstr={oldstr, str};
% set(h, 'String', newstr)

prev_text=get(h, 'string');

if size(prev_text,1)>=6
    new_text=sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s',prev_text(end-5,:),prev_text(end-4,:),prev_text(end-3,:),prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
elseif size(prev_text,1)==5
    new_text=sprintf('%s\n%s\n%s\n%s\n%s\n%s',prev_text(end-4,:),prev_text(end-3,:),prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
elseif size(prev_text,1)==4
    new_text=sprintf('%s\n%s\n%s\n%s\n%s',prev_text(end-3,:),prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
elseif size(prev_text,1)==3
    new_text=sprintf('%s\n%s\n%s\n%s',prev_text(end-2,:),prev_text(end-1,:),prev_text(end,:), text);
elseif size(prev_text,1)==2
    new_text=sprintf('%s\n%s\n%s',prev_text(end-1,:),prev_text(end,:), text);
elseif size(prev_text,1)==1
    new_text=sprintf('%s\n%s',prev_text, text);
elseif isempty(prev_text)
    new_text= text;
else
    error('?')
end
set(h,'string',new_text)

function InitCamera(hObject, handles)
try
    vid = videoinput('dalsa', 1, 'C:\DALSA\Sapera\CamFiles\User\my_ccf_sbm.ccf');
    src = getselectedsource(vid);
    imaqmem(1e12);
    vid.timeout=60;
    vid.LoggingMode = 'memory';
catch
    questdlg('Failed to initialize camera! Running in simulation mode.',     'Camera Init Failure!', 'OK', 'Cancel', 'OK');
    vid=[];
end
handles.vid=vid;
guidata(hObject, handles)

function [ok, user]=Login
prompt={'Please enter your username'};
name='Login';
numlines=1;
defaultanswer={'lab'};
user=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(user) %user pressed cancel
    fprintf('\nUser pressed cancel, goodbye.')
    ok=0;
else
    ok=1;
end

function CreateDataDir
warning off MATLAB:MKDIR:DirectoryExists
dataroot='c:\lab\imaq';
cd(dataroot)
h=findobj('Tag', 'User');

user=get(h, 'string');
mkdir(user)
cd(user)

expdate=datestr(now, 'mmddyy');
if ~exist(expdate, 'dir')
    mkdir(expdate)
end
cd(expdate)


sess_idx=1;
session=sprintf('%03d',sess_idx);
while exist(session, 'dir')
    sess_idx=sess_idx+1;
    session=sprintf('%03d',sess_idx);
end
mkdir(session)
cd(session)
h=findobj('Tag', 'DataPath');
set(h, 'string', pwd)

function uipanel2_SelectionChangeFcn(hObject,eventdata, handles)
StimInputTable_CellEditCallback(findobj('Tag', 'StimInputTable'))


% --- Executes on button press in SetRoot.
function SetRoot_Callback(hObject, eventdata, handles)
% hObject    handle to SetRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and User data (see GUIDATA)


% --- Executes on button press in NewDir.
function NewDir_Callback(hObject, eventdata, handles)
% hObject    handle to NewDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CreateDataDir


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vid=handles.vid;
delete(vid)
clear vid
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in AnalyzeWhenDone.
function AnalyzeWhenDone_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeWhenDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AnalyzeWhenDone


% --- Executes on button press in AnalyzeCurrentDir.
function AnalyzeCurrentDir_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeCurrentDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%imanal2(pwd)
fft_mem(pwd);


% --- Executes on button press in ViewCurrentDir.
function ViewCurrentDir_Callback(hObject, eventdata, handles)
% hObject    handle to ViewCurrentDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imview(pwd)

% --- Executes on button press in ChangeDir.
function ChangeDir_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newpath = uigetdir('..', 'Choose new directory in which to save data')
cd(newpath)
h=findobj('Tag', 'DataPath');
set(h, 'string', pwd)

