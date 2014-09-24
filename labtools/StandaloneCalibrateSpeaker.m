function varargout = StandaloneCalibrateSpeaker(varargin)
% STANDALONECALIBRATESPEAKER MATLAB code for StandaloneCalibrateSpeaker.fig
%      STANDALONECALIBRATESPEAKER, by itself, creates a new STANDALONECALIBRATESPEAKER or raises the existing
%      singleton*.
%
%      H = STANDALONECALIBRATESPEAKER returns the handle to a new STANDALONECALIBRATESPEAKER or the handle to
%      the existing singleton*.
%
%      STANDALONECALIBRATESPEAKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STANDALONECALIBRATESPEAKER.M with the given input arguments.
%
%      STANDALONECALIBRATESPEAKER('Property','Value',...) creates a new STANDALONECALIBRATESPEAKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StandaloneCalibrateSpeaker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StandaloneCalibrateSpeaker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StandaloneCalibrateSpeaker

% Last Modified by GUIDE v2.5 29-Aug-2013 16:53:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @StandaloneCalibrateSpeaker_OpeningFcn, ...
    'gui_OutputFcn',  @StandaloneCalibrateSpeaker_OutputFcn, ...
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

% --- Executes just before StandaloneCalibrateSpeaker is made visible.
function StandaloneCalibrateSpeaker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StandaloneCalibrateSpeaker (see VARARGIN)

% Choose default command line output for StandaloneCalibrateSpeaker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using StandaloneCalibrateSpeaker.
if strcmp(get(hObject,'Visible'),'off')
    t=1:1000;t=t/1000;
    plot(t,sin(2*pi*10*t));
end

%Initialize default parameters, daq, etc.
InitializePsychSound
InitParams(handles)
InitSoundIn(handles)
InitSoundOut(handles)

InputDeviceID = 1+get(handles.InputDeviceID, 'Value');
userdata=get(handles.figure1, 'userdata');
userdata.InputDeviceID=InputDeviceID;
set(handles.figure1, 'userdata', userdata);
InitializeInputCh(handles)
InitSoundIn(handles)

OutputDeviceID = get(handles.OutputDeviceID, 'Value')-1;
userdata=get(handles.figure1, 'userdata');
userdata.OutputDeviceID=OutputDeviceID;
set(handles.figure1, 'userdata', userdata);
InitializeOutputCh(handles)
InitSoundOut(handles)

% UIWAIT makes StandaloneCalibrateSpeaker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StandaloneCalibrateSpeaker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Prefs;
global pref
axes(handles.axes1);
cla;
axes(handles.axes2);
cla;
userdata=get(handles.figure1, 'userdata');
samplingrate=userdata.samplingrate;
atten=userdata.atten;
logspacedfreqs=userdata.logspacedfreqs;
numfreqs=length(logspacedfreqs);
logspacedfreqs=[-1 logspacedfreqs]; %add white noise at end
maxfreq=max(logspacedfreqs);
target_amp=str2num(get(handles.target_amp, 'string'));
convergence=str2num(get(handles.convergence, 'string'));
override_atten=str2num(get(handles.override_atten, 'string'));
reset_atten=str2num(get(handles.reset_atten, 'string'));
save1=get(handles.save,'value');


Message('Running...', handles)
set(hObject, 'background', 'r', 'String', 'Running...', 'enable', 'on')

wb=waitbar(0, 'calibrating...');
set(wb, 'pos', [870 700 270  50])
num_loops=str2num(get(handles.numLoops, 'string'));

for lp = 1:num_loops
    sampleLength=500;   % sample length in ms
    tonedur=sampleLength+300;
    %                 numfreqs=userdata;
    %                 maxfreq=GetParam(me, 'maxfreq');
    %                 minfreq=GetParam(me, 'minfreq');
    %                 if minfreq==-1; error('minfreq not supposed to be -1'); end
    %                 logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );
    if isempty (atten)
        atten=zeros(size(logspacedfreqs));
    elseif length(atten)~=length(logspacedfreqs)
        atten=zeros(size(logspacedfreqs));
    end
    
    for i=1:length(logspacedfreqs) %play tones
        running=get(hObject, 'value');
        if ~running %user pressed run again
            break
        end
        
        Message(sprintf('playing tone %d/%d (%.1f Hz)',i, numfreqs+1, logspacedfreqs(i)), handles)
        tonefreq=logspacedfreqs(i);
        %start playing tone
        PlayCalibrationTone(tonefreq, tonedur, handles);
        WaitSecs(.2); %output latency is ~120 ms
        audiodata=RecordTone(sampleLength, handles);
        BKsensitivity=str2num(get(handles.BKsensitivity, 'string'));
        %scale audiodata by V/Pa?
        ScaledData=detrend(audiodata, 'constant'); %in volts
        %high pass filter a little bit to remove rumble
        %for display purposes only
        [b,a]=butter(1,100/(samplingrate*1000), 'high');
        % Display trace.
        ax1=handles.axes1;
        ax2=handles.axes2;
        t=1:length(ScaledData);
        t=1000*t/samplingrate;
        plot(ax1,t,filtfilt(b,a,ScaledData));
        xlabel(ax1, 'time (ms)');
        ylabel(ax1, 'Microphone Voltage (V)');
        
        %estimate frequency
        hold(ax2, 'on')
        xlim(ax2, [0 1.25*maxfreq])
        [Pxx,f] = pwelch(ScaledData,[],[],[],samplingrate);
        fmaxindex=(find(Pxx==max(Pxx(100:end)))); %skip freqs<250hz
        fmaxindex=fmaxindex(1);
        fmax=round(f(fmaxindex));
        Message(sprintf('est. freq: %d', fmax), handles);
        
        c=repmat('rgbkm', 1, ceil(numfreqs/5)+1);
        semilogy(ax2, f(100:end), Pxx(100:end), c(i))
        semilogy(ax2, f(fmaxindex), Pxx(fmaxindex), ['o',c(i)])
        xlabel(ax2, 'Frequency, Hz');
        ylabel(ax2, 'PSD');
        if tonefreq==-1
            %estimate amplitude -- RMS method
            % high-pass filtering at 500 hz (mw 01-30-09)
            %ai2SampleRate
            [b,a]=butter(5, 500/(samplingrate/2), 'high');
            Vrms=sqrt(mean(filtfilt(b,a,ScaledData).^2));
            db=dBSPL(Vrms, BKsensitivity);
            Message( sprintf('estimated noise amp: %.2f dB', db), handles);
        else
            %estimate amplitude -- Pxx method
            %                 fidx=closest(f, tonefreq);
            db=dBPSD(Pxx(fmaxindex), BKsensitivity);%should return 94 for B&K calibrator
            %db=dBPSD(Pxx(fidx), GetParam(me, 'mic_sensitivity'));
            Message( sprintf('estimated tone amp: %.2f dB', db), handles);
            %                             pause(.35)
        end
        FMAX(i)=fmax;
        DB(i)=db;
        waitbar(((lp-1)*numfreqs+i)/(num_loops*numfreqs), wb)
    end %play tones
    if ~running %user pressed run again
        break
    end

    Message('measured freqs: ', handles)
    Message(sprintf('%d ',FMAX), handles)
    Message('measured dB: ', handles)
    Message(sprintf('%.1f ',DB), handles)
    
    
    semilogx(ax1, logspacedfreqs, DB, '-o')
    xlabel(ax1, 'Frequency, Hz');
    ylabel(ax1, 'dB SPL');
    xlim(ax1, [-2 1.25*maxfreq])
    grid(ax1, 'on')
    
    %  create inverse filter
    %atten=DB-min(DB); %this is the inverse filter
    atten=convergence*(DB-target_amp); %this is the inverse filter
    atten(atten<0)=0;
    
    %apply over ride value if any
    atten=atten-override_atten;
    
    % iteratively store calibration data
    if save1 
        stored_atten=userdata.atten;
        if length(atten)==length(stored_atten)
            atten=atten+stored_atten; %iteratively add to stored calibration
        end
        reset_amount=reset_atten;
        atten=atten-reset_amount*min(atten); %reset min atten towards 0 to avoid saturating
        atten(atten<0)=0;
        cd(pref.experhome)
        cd calibration
        try
            cal=load('calibration.mat');
        catch %#ok
            cal=[];
        end
        timestampstr=['last saved ', datestr(now)];
        save calibration logspacedfreqs timestampstr DB  atten
        userdata.atten=atten;
        userdata.DB=DB;
        set(handles.figure1, 'userdata', userdata);
        Message('saved calibration data to file', handles)
        
    end
        Message([sprintf('\nmin dB %.2f', min(DB)), sprintf('\nmax dB %.2f', max(DB)), ...
        sprintf('\nmean dB %.2f', mean(DB)), sprintf('\nstd dB %.2f', std(DB)), ...
        sprintf('\nmin atten %.2f', min(atten)),  ...
        sprintf('\nmax atten %.2f', max(atten)), ...
        sprintf('\npref.maxSPL is %d',pref.maxSPL )], handles)
    StdDB(lp)=std(DB);
end %loop_num
  
    %stop and turn off Run button
    set(hObject, 'background', [0 1 0], 'String', 'Run','enable', 'on', 'value', 0)

close(wb)
% if ~isempty(handles.axes2)
%     hold(handles.axes2, 'off')
%     %    plot(handles.axes2, StdDB, '-o')
%     ylabel(handles.axes2, 'std dB')
%     xlabel(handles.axes2, 'iterations')
% end

Message('Done', handles)




% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Reset(handles)

function Reset(handles)
userdata=get(handles.figure1, 'userdata');
userdata.atten=[];
userdata.DB=[];
set(handles.figure1, 'userdata', userdata);
InitParams(handles)
cla(handles.axes1)
cla(handles.axes2)

function minfreq_Callback(hObject, eventdata, handles)
% hObject    handle to minfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minfreq as text
%        str2double(get(hObject,'String')) returns contents of minfreq as a double
calculate_logspacedfreqs(handles);
Reset(handles)

% --- Executes during object creation, after setting all properties.
function minfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxfreq_Callback(hObject, eventdata, handles)
% hObject    handle to maxfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxfreq as text
%        str2double(get(hObject,'String')) returns contents of maxfreq as a double
calculate_logspacedfreqs(handles);
Reset(handles)

% --- Executes during object creation, after setting all properties.
function maxfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freqsperoctave_Callback(hObject, eventdata, handles)
% hObject    handle to freqsperoctave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqsperoctave as text
%        str2double(get(hObject,'String')) returns contents of freqsperoctave as a double
calculate_logspacedfreqs(handles);
Reset(handles)

% --- Executes during object creation, after setting all properties.
function freqsperoctave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqsperoctave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_amp_Callback(hObject, eventdata, handles)
% hObject    handle to target_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_amp as text
%        str2double(get(hObject,'String')) returns contents of target_amp as a double
Reset(handles)

% --- Executes during object creation, after setting all properties.
function target_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save



function convergence_Callback(hObject, eventdata, handles)
% hObject    handle to convergence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of convergence as text
%        str2double(get(hObject,'String')) returns contents of convergence as a double


% --- Executes during object creation, after setting all properties.
function convergence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to convergence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reset_atten_Callback(hObject, eventdata, handles)
% hObject    handle to reset_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reset_atten as text
%        str2double(get(hObject,'String')) returns contents of reset_atten as a double


% --- Executes during object creation, after setting all properties.
function reset_atten_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reset_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function override_atten_Callback(hObject, eventdata, handles)
% hObject    handle to override_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of override_atten as text
%        str2double(get(hObject,'String')) returns contents of override_atten as a double


% --- Executes during object creation, after setting all properties.
function override_atten_CreateFcn(hObject, eventdata, handles)
% hObject    handle to override_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Message(string, handles)
h=handles.Message;
old_string=get(h, 'string');
if iscell(old_string)
    %old_string=old_string{:};end
    n= length(old_string);
    old_string{n+1}=string;
    set(h, 'String', old_string);
else
    new_string={old_string, string};
    set(h, 'String', new_string);
end
try
    jhEdit = findjobj(h);
    jEdit = jhEdit.getComponent(0).getComponent(0);
    jEdit.setCaretPosition(jEdit.getDocument.getLength);
end

function InitSoundOut(handles)

InitializePsychSound(0);
userdata=get(handles.figure1, 'userdata');
SoundFs=userdata.samplingrate;
OutputDeviceID=userdata.OutputDeviceID;
outputCh=userdata.OutputCh;
reqlatencyclass =1;
numChan=2;
buffSize=512;

%stop and close
try
    PsychPortAudio('Stop', handles.paOuthandle);
    PsychPortAudio('Close', handles.paOuthandle);
end

try paOuthandle = PsychPortAudio('Open', OutputDeviceID, 1, reqlatencyclass, SoundFs, numChan, buffSize);
    runMode = 0; %default, turns off soundcard after playback
    %runMode = 1; %leaves soundcard on (hot), uses more resources but may solve dropouts? mw 08.25.09: so far so good.
    PsychPortAudio('RunMode', paOuthandle, runMode);
    
    userdata.paOuthandle=paOuthandle;
    set(handles.figure1, 'userdata', userdata);
    Message('Initialized Sound Output', handles)
    
catch
    Message(sprintf('Error: could not open Output Device'), handles);
end



function InitSoundIn(handles)

InitializePsychSound(0);
userdata=get(handles.figure1, 'userdata');
samplingrate=userdata.samplingrate;
InputDeviceID=userdata.InputDeviceID-1;
inputCh=userdata.InputCh;
outputCh=userdata.OutputCh;

%stop and close
try
    PsychPortAudio('Stop', handles.paInhandle);
    PsychPortAudio('Close', handles.paInhandle);
end

% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of 44100 Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
try
    paInhandle = PsychPortAudio('Open', InputDeviceID, 2, 0, samplingrate, 1);
    
    userdata.paInhandle=paInhandle;
    set(handles.figure1, 'userdata', userdata);
    
    % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
    PsychPortAudio('GetAudioData', paInhandle, 10);
    
    Message('Initialized Sound Input', handles)
    
catch
    Message(sprintf('Error: could not open Input Device'), handles);
end

%
%


function InitParams(handles)
minfreq=1000;
maxfreq=2e3;%80000;
freqsperoctave=4;
target_amp=70;
save=0;
convergence=1;
reset_atten=0;
override_atten=0;

try %try to load existing calibration
    Prefs;
    global pref
    cd(pref.experhome)
    cd calibration
    cal=load('calibration');
    atten=cal.atten;
    DB=cal.DB;
    logspacedfreqs=cal.logspacedfreqs;
    semilogx(handles.axes1, logspacedfreqs, DB, '-o')
    ylabel('stored dB')
    xlabel('frequency, Hz')
    grid on
    if cal.logspacedfreqs(1)==-1
        minfreq=cal.logspacedfreqs(2);
        numfreqs=length(cal.logspacedfreqs)-1;
    else
        minfreq=cal.logspacedfreqs(1);
        numfreqs=length(cal.logspacedfreqs);
    end
    maxfreq=cal.logspacedfreqs(end);
    Message('succesfully loaded previously saved calibration', handles);
catch
    Message('failed to load previously saved calibration', handles);
    atten=[];
end

numoctaves=log2(maxfreq/minfreq);
logspacedfreqs=minfreq*2.^([0:(1/freqsperoctave):numoctaves]);
newmaxfreq=logspacedfreqs(end);
numfreqs=length(logspacedfreqs);
if maxfreq~=newmaxfreq
    Message(sprintf('note: could not divide %d-%d Hz evenly into exactly %d frequencies per octave', minfreq, maxfreq, freqsperoctave), handles)
    Message(sprintf('using new maxfreq of %d to achieve exactly %d frequencies per octave', round(newmaxfreq), freqsperoctave), handles)
    maxfreq=newmaxfreq;
end

h=handles.minfreq;
set(h, 'string', minfreq)
h=handles.maxfreq;
set(h, 'string', maxfreq)
h=handles.freqsperoctave;
set(h, 'string', freqsperoctave)
h=handles.target_amp;
set(h, 'string', target_amp)
h=handles.save;
set(h, 'value', save)
h=handles.convergence;
set(h, 'string', convergence)
h=handles.reset_atten;
set(h, 'string', reset_atten)
h=handles.override_atten;
set(h, 'string', override_atten)


userdata=get(handles.figure1, 'userdata');
userdata.samplingrate=192e3;
InputDeviceID = get(handles.InputDeviceID, 'Value');
userdata.InputDeviceID=InputDeviceID;
OutputDeviceID = get(handles.OutputDeviceID, 'Value');
userdata.OutputDeviceID=OutputDeviceID;
InputCh = get(handles.InputCh, 'Value');
userdata.InputCh=InputCh;
OutputCh = get(handles.OutputCh, 'Value');
userdata.OutputCh=OutputCh;
%userdata.inputCh=1; %default
%userdata.outputCh=1; %default
userdata.atten=atten;
userdata.DB=[];
userdata.logspacedfreqs=logspacedfreqs;
set(handles.figure1, 'userdata', userdata);

InitializeInputCh(handles)
InitializeOutputCh(handles)

function InitializeInputCh(handles)
devs = PsychPortAudio('GetDevices');
InputDeviceID = get(handles.InputDeviceID, 'Value');
numchannels=devs(InputDeviceID).NrInputChannels;
for i = 1:numchannels
    ChString{i}=sprintf('%d', i);
end
if numchannels==0 ChString='No Input Ch!!';
    Message('Error! Bad Input Device ID', handles)
end
set(handles.InputCh, 'String', ChString);

function InitializeOutputCh(handles)
devs = PsychPortAudio('GetDevices');
OutputDeviceID = get(handles.OutputDeviceID, 'Value');
numchannels=devs(OutputDeviceID).NrOutputChannels;
for i = 1:numchannels
    ChString{i}=sprintf('%d', i);
end
if numchannels==0
    ChString='No Output Ch!!';
    Message('Error! Bad Output Device ID', handles)
end
set(handles.OutputCh, 'String', ChString);


% --- Executes on selection change in InputDeviceID.
function InputDeviceID_Callback(hObject, eventdata, handles)
% hObject    handle to InputDeviceID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InputDeviceID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InputDeviceID
InputDeviceID = 1+get(handles.InputDeviceID, 'Value');
userdata=get(handles.figure1, 'userdata');
userdata.InputDeviceID=InputDeviceID;
set(handles.figure1, 'userdata', userdata);
InitializeInputCh(handles)
InitSoundIn(handles)

% --- Executes during object creation, after setting all properties.
function InputDeviceID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputDeviceID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
devs = PsychPortAudio('GetDevices');
for i = 1:length(devs)
    deviceString{i}=sprintf('%d: %s: %s', devs(i).DeviceIndex, devs(i).HostAudioAPIName, devs(i).DeviceName);
end
set(hObject, 'String', deviceString);
set(hObject, 'Value', 16); %default Input Device ID


% --- Executes on selection change in InputCh.
function InputCh_Callback(hObject, eventdata, handles)
% hObject    handle to InputCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InputCh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InputCh
InputCh = get(handles.InputCh, 'Value');
userdata=get(handles.figure1, 'userdata');
userdata.InputCh=InputCh;
set(handles.figure1, 'userdata', userdata);
InitSoundIn(handles)

% --- Executes during object creation, after setting all properties.
function InputCh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OutputCh.
function OutputCh_Callback(hObject, eventdata, handles)
% hObject    handle to OutputCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OutputCh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OutputCh
OutputCh = get(handles.OutputCh, 'Value');
userdata=get(handles.figure1, 'userdata');
userdata.OutputCh=OutputCh;
set(handles.figure1, 'userdata', userdata);
InitSoundOut(handles)

% --- Executes during object creation, after setting all properties.
function OutputCh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OutputDeviceID.
function OutputDeviceID_Callback(hObject, eventdata, handles)
% hObject    handle to OutputDeviceID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OutputDeviceID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OutputDeviceID
OutputDeviceID = get(handles.OutputDeviceID, 'Value')-1;
userdata=get(handles.figure1, 'userdata');
userdata.OutputDeviceID=OutputDeviceID;
set(handles.figure1, 'userdata', userdata);
InitializeOutputCh(handles)
InitSoundOut(handles)


% --- Executes during object creation, after setting all properties.
function OutputDeviceID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputDeviceID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
devs = PsychPortAudio('GetDevices');
for i = 1:length(devs)
    deviceString{i}=sprintf('%d: %s: %s', devs(i).DeviceIndex, devs(i).HostAudioAPIName, devs(i).DeviceName);
end
set(hObject, 'String', deviceString);
set(hObject, 'Value',7); %default Output Device ID, note devs is 0-indexed



function Message_Callback(hObject, eventdata, handles)
% hObject    handle to Message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Message as text
%        str2double(get(hObject,'String')) returns contents of Message as a double


% --- Executes during object creation, after setting all properties.
function Message_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % % Stop capture:
    PsychPortAudio('Stop', handles.paInhandle);
    % % Close the audio device:
    PsychPortAudio('Close', handles.paInhandle);
    % % Stop playback:
end
try
    PsychPortAudio('Stop', handles.paOuthandle);
    % % Close the audio device:
    PsychPortAudio('Close', handles.paOuthandle);
end

function PlayCalibrationTone(tonefreq, tonedur, handles);
userdata=get(handles.figure1, 'userdata');
target_amp=str2num(get(handles.target_amp, 'string'));
param.frequency=tonefreq; %hz
param.amplitude=target_amp;
nstimchans=1;

logspacedfreqs=userdata.logspacedfreqs;
atten=userdata.atten;
if tonefreq==-1 findex=1;
else
findex=find(logspacedfreqs<=tonefreq, 1, 'last');
end
if isempty(atten)
    attenuation=0;
else
    attenuation=atten(findex);
end
param.amplitude=param.amplitude-attenuation;

param.duration=tonedur; %ms
param.ramp=10;
samplerate=userdata.samplingrate;
if tonefreq==-1
    samples=MakeWhiteNoise(param, samplerate);
else
    samples=MakeTone(param, samplerate);
end
samples=reshape(samples, nstimchans, length(samples)); %ensure samples are a row vector
samples(2,:)=0.*samples;

paOuthandle=userdata.paOuthandle;
PsychPortAudio('FillBuffer', paOuthandle, samples); % fill buffer now, start in PlaySound
nreps=1;
when=0; %use this to start immediately
waitForStart=0;
PsychPortAudio('Start', paOuthandle,nreps,when,waitForStart);
%PsychPortAudio('Stop', paOuthandle,1); %waits for playback to complete

function audiodata=RecordTone(dur, handles); %dur is in ms
userdata=get(handles.figure1, 'userdata');
paInhandle=userdata.paInhandle;
% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero,
% i.e. record until recording is manually stopped.
reps=1;
when=0; %now
waitforstart=1;
now=GetSecs;
stopTime=[];%now+dur;
PsychPortAudio('Start', paInhandle, reps, when, waitforstart,stopTime );
% Fetch current audiodata:
% [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', paInhandle);

% Stop capture:
Waitsecs(dur/1000);
PsychPortAudio('Stop', paInhandle);

% Retrieve pending audio data from the drivers internal ringbuffer:
audiodata = PsychPortAudio('GetAudioData', paInhandle);
nrsamples = size(audiodata, 2);


% Close the audio device:
%PsychPortAudio('Close', paInhandle);

function calculate_logspacedfreqs(handles)
h=handles.minfreq;
minfreq=str2num(get(h, 'string'));
h=handles.maxfreq;
maxfreq=str2num(get(h, 'string'));
h=handles.freqsperoctave;
freqsperoctave=str2num(get(h, 'string'));

numoctaves=log2(maxfreq/minfreq);
logspacedfreqs=minfreq*2.^([0:(1/freqsperoctave):numoctaves]);
newmaxfreq=logspacedfreqs(end);
numfreqs=length(logspacedfreqs);
if maxfreq~=newmaxfreq
    Message(sprintf('note: could not divide %d-%d Hz evenly into exactly %d frequencies per octave', minfreq, maxfreq, freqsperoctave), handles)
    Message(sprintf('using new maxfreq of %d to achieve exactly %d frequencies per octave', round(newmaxfreq), freqsperoctave), handles)
    maxfreq=newmaxfreq;
end
h=handles.maxfreq;
set(h, 'string', maxfreq);

userdata=get(handles.figure1, 'userdata');
userdata.logspacedfreqs=logspacedfreqs;
set(handles.figure1, 'userdata', userdata);



function BKsensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to BKsensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BKsensitivity as text
%        str2double(get(hObject,'String')) returns contents of BKsensitivity as a double


% --- Executes during object creation, after setting all properties.
function BKsensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BKsensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ClearMessages.
function ClearMessages_Callback(hObject, eventdata, handles)
% hObject    handle to ClearMessages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=handles.Message;
set(h, 'String', '');
