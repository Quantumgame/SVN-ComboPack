function varargout = lfModelDesignerX(varargin)
% LFMODELDESIGNERX MATLAB code for lfModelDesignerX.fig
%      LFMODELDESIGNERX, by itself, creates a new LFMODELDESIGNERX or raises the existing
%      singleton*.
%
%      H = LFMODELDESIGNERX returns the handle to a new LFMODELDESIGNERX or the handle to
%      the existing singleton*.
%
%      LFMODELDESIGNERX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LFMODELDESIGNERX.M with the given input arguments.
%
%      LFMODELDESIGNERX('Property','Value',...) creates a new LFMODELDESIGNERX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lfModelDesignerX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lfModelDesignerX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lfModelDesignerX
%   Originally designed and coded by Hideki Kawahara
%   10/July/2015 first version
%   29/July/2015 integrated with VT shape to sound tool
%   01/Aug./2015 bug fixed version

% Last Modified by GUIDE v2.5 30-Jul-2015 18:54:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @lfModelDesignerX_OpeningFcn, ...
    'gui_OutputFcn',  @lfModelDesignerX_OutputFcn, ...
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


% --- Executes just before lfModelDesignerX is made visible.
function lfModelDesignerX_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lfModelDesignerX (see VARARGIN)

% Choose default command line output for lfModelDesignerX
handles.output = hObject;
%disp(['vargin counts of lfModelDesignerX:' num2str(nargin)]);
%celldisp(varargin);
if nargin == 4 && ishandle(varargin{1}) && isvalid(varargin{1})
    parentUserData = guidata(varargin{1});
    if isfield(parentUserData,'vtTester')
        handles.parentUserData = parentUserData;
        disp('called from the vt tool.');
    end;
end;
%hObject
%handles
handles = initializeGraphics(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lfModelDesignerX wait for user response (see UIRESUME)
% uiwait(handles.LFModelDesignerFigure);


% --- Outputs from this function are returned to the command line.
function varargout = lfModelDesignerX_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%--- private ---
function updatedHandles = initializeGraphics(handles)
updatedHandles = handles;
%--- L-F parameter initial value
LFparameters = struct;
%LFparameters.voiceQuality = 'breathy';
voiceQuality = 'modal';
fsPlot = 1000;
LFparameters.timeForDisplay = -0.2:1/fsPlot:1.2;
switch voiceQuality
    case 'modal'
        LFparameters.tp = 0.4134;
        LFparameters.te = 0.5530;
        LFparameters.ta = 0.0041;
        LFparameters.tc = 0.5817;
    case 'fry'
        LFparameters.tp = 0.4808;
        LFparameters.te = 0.5955;
        LFparameters.ta = 0.0269;
        LFparameters.tc = 0.7200;
    case 'breathy'
        LFparameters.tp = 0.4621;
        LFparameters.te = 0.6604;
        LFparameters.ta = 0.0270;
        LFparameters.tc = 0.7712;
end;
lfpModal = [0.4134 0.5530 0.0041 0.5817];
lfpBreathy = [0.4621 0.6604 0.0270 0.7712];
lfpFry = [0.4808 0.5955 0.0269 0.7200];
lfpDisplay = 0.4*lfpModal+0.3*lfpBreathy+0.3*lfpFry;
LFparameters.tp = lfpDisplay(1);
LFparameters.te = lfpDisplay(2);
LFparameters.ta = lfpDisplay(3);
LFparameters.tc = lfpDisplay(4);
set(updatedHandles.tpText,'string',['tp:' num2str(LFparameters.tp*100,'%7.3f')]);
set(updatedHandles.teText,'string',['te:' num2str(LFparameters.te*100,'%7.3f')]);
set(updatedHandles.taText,'string',['ta:' num2str(LFparameters.ta*100,'%7.3f')]);
set(updatedHandles.tcText,'string',['tc:' num2str(LFparameters.tc*100,'%7.3f')]);
modelOut = sourceByLFmodelAAF(LFparameters.timeForDisplay,LFparameters.tp, ...
    LFparameters.te,LFparameters.ta,LFparameters.tc,0.01);
axes(handles.sourceAxis);
plot(LFparameters.timeForDisplay([1 end]),[0 0]);
hold on;
updatedHandles.sourceHandle = plot(LFparameters.timeForDisplay,modelOut.source,'k','linewidth',2);
set(gca,'xlim',[0 1],'ylim',[min(modelOut.source) max(modelOut.source)]);
ylimSource = get(handles.sourceAxis,'ylim');
updatedHandles.tpHandle = plot(LFparameters.tp*[1 1],[0 ylimSource(2)],'b');
updatedHandles.teHandle = plot(LFparameters.te*[1 1],[ylimSource(1) 0],'b');
taXline = LFparameters.ta/abs(ylimSource(1))*diff(ylimSource);
updatedHandles.taHandle = plot(LFparameters.te+[0 taXline],ylimSource,'r');
updatedHandles.taTopHandle = plot(LFparameters.te+taXline,ylimSource(2),'r.','markersize',40);
updatedHandles.tcHandle = plot(LFparameters.tc*[1 1],ylimSource,'b');
axis off;
axes(handles.vvAxis);
plot(LFparameters.timeForDisplay([1 end]),[0 0]);
hold on;
updatedHandles.vvHandle = plot(LFparameters.timeForDisplay,modelOut.volumeVerocity,'k','linewidth',2);
set(gca,'xlim',[0 1],'ylim',[0 max(modelOut.volumeVerocity)]);
fftl = 8192*2;
fx = (0:fftl-1)'/fftl*fsPlot;
axis off
axes(handles.spectrumAxis);
sourceSpectrum = 20*log10(abs(fft(modelOut.source,fftl)));
frequencyWeight = 20*log10(fx);
levelAtF0 = interp1(fx,sourceSpectrum+frequencyWeight,1);
updatedHandles.spectrumHandle = semilogx(fx,sourceSpectrum+frequencyWeight-levelAtF0,'linewidth',2);
set(gca,'xlim',[1 40],'ylim',[-20 20],'fontsize',14);
hold on;
modal = sourceByLFmodelAAF(LFparameters.timeForDisplay,lfpModal(1), ...
    lfpModal(2),lfpModal(3),lfpModal(4),0.01);
sourceSpectrumModal = 20*log10(abs(fft(modal.source,fftl)));
levelAtF0 = interp1(fx,sourceSpectrumModal+frequencyWeight,1);
semilogx(fx,sourceSpectrumModal+frequencyWeight-levelAtF0);
breathy = sourceByLFmodelAAF(LFparameters.timeForDisplay,lfpBreathy(1), ...
    lfpBreathy(2),lfpBreathy(3),lfpBreathy(4),0.01);
sourceSpectrumBreathy = 20*log10(abs(fft(breathy.source,fftl)));
levelAtF0 = interp1(fx,sourceSpectrumBreathy+frequencyWeight,1);
semilogx(fx,sourceSpectrumBreathy+frequencyWeight-levelAtF0);
fry = sourceByLFmodelAAF(LFparameters.timeForDisplay,lfpFry(1), ...
    lfpFry(2),lfpFry(3),lfpFry(4),0.01);
sourceSpectrumFry = 20*log10(abs(fft(fry.source,fftl)));
levelAtF0 = interp1(fx,sourceSpectrumFry+frequencyWeight,1);
semilogx(fx,sourceSpectrumFry+frequencyWeight-levelAtF0);
legend('test','modal','breathy','vocal fry','location','southwest');
xlabel('frequency (re. 1/T0)');
ylabel('level (dB re. at F0)');
title('source spectrum with +6dB/oct emphasis');
grid on;
%--- equalizer design
cosineCoefficient = [0.355768 0.487396 0.144232 0.012604]; % Nuttall win12
upperLimit = 50;
halfSample = 50;
updatedHandles.equalizerStr = equalizerDesignAAFX(cosineCoefficient,upperLimit,halfSample);
%--- set other voicing parameters
updatedHandles.LFparameters = LFparameters;
updatedHandles.duration = 0.5; % in second
updatedHandles.samplingFrequency = 44100;
updatedHandles.F0 = 110;
updatedHandles.vibratoRate = 5.5; % in Hz
updatedHandles.vibratoDepth = 100; % in cent
updatedHandles.sampleTime = (0:1/updatedHandles.samplingFrequency:updatedHandles.duration)';
%--- handler assignment
set(handles.LFModelDesignerFigure,'WindowButtonMotionFcn',@moveWhileMouseUp);
set(handles.LFModelDesignerFigure,'windowbuttonDownFcn',@MousebuttonDown);
set(handles.saveButton,'enable','off');

%--- handler for mouse movemnet
function moveWhileMouseUp(src,evnt)
handles = guidata(src);
sourceStructure = guidata(handles.LFModelDesignerFigure);
if isInsideAxis(handles.sourceAxis)
    switch whichLFParameter(sourceStructure)
        case 'tp'
            set(src,'Pointer','hand');
            set(sourceStructure.tpHandle,'linewidth',2);
        case 'te'
            set(src,'Pointer','hand');
            set(sourceStructure.teHandle,'linewidth',2);
        case 'ta'
            set(src,'Pointer','hand');
            set(sourceStructure.taHandle,'linewidth',2);
        case 'tc'
            set(src,'Pointer','hand');
            set(sourceStructure.tcHandle,'linewidth',2);
        otherwise
            set(src,'Pointer','cross');
            set(sourceStructure.tpHandle,'linewidth',1);
            set(sourceStructure.teHandle,'linewidth',1);
            set(sourceStructure.tcHandle,'linewidth',1);
            set(sourceStructure.taHandle,'linewidth',1);
    end;
else
    set(src,'Pointer','arrow');
    set(sourceStructure.tpHandle,'linewidth',1);
    set(sourceStructure.teHandle,'linewidth',1);
    set(sourceStructure.tcHandle,'linewidth',1);
    set(sourceStructure.taHandle,'linewidth',1);
end;
guidata(handles.LFModelDesignerFigure,sourceStructure);

function MousebuttonDown(src,evnt)
handles = guidata(src);
sourceStructure = guidata(handles.LFModelDesignerFigure);
set(handles.saveButton,'enable','off');
switch get(src,'Pointer')
    case 'hand'
        sourceStructure.currentLFParameter = whichLFParameter(sourceStructure);
        switch sourceStructure.currentLFParameter
            case 'tp'
                set(sourceStructure.tpHandle,'linewidth',5);
                xdata = get(sourceStructure.tpHandle,'xdata');
                sourceStructure.lastPosition = xdata(1);
            case 'te'
                set(sourceStructure.teHandle,'linewidth',5);
                xdata = get(sourceStructure.teHandle,'xdata');
                sourceStructure.lastPosition = xdata(1);
            case 'ta'
                set(sourceStructure.taHandle,'linewidth',5);
                xdata = get(sourceStructure.taTopHandle,'xdata');
                sourceStructure.lastPosition = xdata(1);
            case 'tc'
                set(sourceStructure.tcHandle,'linewidth',5);
                xdata = get(sourceStructure.tcHandle,'xdata');
                sourceStructure.lastPosition = xdata(1);
        end;
        set(handles.LFModelDesignerFigure,'WindowButtonMotionFcn',@moveVTLWhileMouseDown);
        set(handles.LFModelDesignerFigure,'windowbuttonUpFcn',@penUpFunction);
end;
guidata(handles.LFModelDesignerFigure,sourceStructure);

function moveVTLWhileMouseDown(src,evnt)
handles = guidata(src);
sourceStructure = guidata(handles.LFModelDesignerFigure);
currentPoint = get(handles.sourceAxis,'currentPoint');
fsDisplay = 1000;
normalizedTime = (-0.2:1/fsDisplay:1.2);
tp = sourceStructure.LFparameters.tp;
te = sourceStructure.LFparameters.te;
ta = sourceStructure.LFparameters.ta;
tc = sourceStructure.LFparameters.tc;
nyqFreq = fsDisplay/2;
Tw = 2/nyqFreq;
modelOut = sourceByLFmodelAAF(normalizedTime,tp,te,ta,tc,Tw);
switch sourceStructure.currentLFParameter
    case 'tp'
        sourceStructure.LFparameters.tp = min(sourceStructure.LFparameters.te-0.02,...
            max(sourceStructure.LFparameters.te/2+0.02,currentPoint(1,1)));
        set(sourceStructure.tpHandle,'xdata',sourceStructure.LFparameters.tp*[1 1]);
    case 'te'
        teToTc = sourceStructure.LFparameters.tc-sourceStructure.LFparameters.te;
        sourceStructure.LFparameters.te = max(sourceStructure.LFparameters.tp+0.02,...
            min(sourceStructure.LFparameters.tp*2-0.02,currentPoint(1,1)));
        sourceStructure.LFparameters.tc = min(1,teToTc+sourceStructure.LFparameters.te);
        sourceStructure.LFparameters.te = ...
            min(sourceStructure.LFparameters.tc-ta-0.02,sourceStructure.LFparameters.te);
        set(sourceStructure.teHandle,'xdata',sourceStructure.LFparameters.te*[1 1]);
        set(sourceStructure.tcHandle,'xdata',sourceStructure.LFparameters.tc*[1 1]);
        taTopValue = getTaTopValue(handles);
        set(sourceStructure.taTopHandle,'xdata',sourceStructure.LFparameters.te+taTopValue);
        set(sourceStructure.taHandle,'xdata',sourceStructure.LFparameters.te+[0 taTopValue]);
    case 'ta'
        ylimit = get(handles.sourceAxis,'ylim');
if sum(isnan(modelOut.source)) == 0
    taYinitial = interp1(normalizedTime,modelOut.source,te,'linear','extrap');
    topMarginCoeffient = (ylimit(2)-taYinitial)/abs(taYinitial);
else
    topMarginCoeffient = diff(ylimit)/abs(ylimit(1));
end;
        topMargin = topMarginCoeffient* ...
            (sourceStructure.LFparameters.tc-sourceStructure.LFparameters.te)+sourceStructure.LFparameters.te;
        taTopX = min(topMargin-0.02*topMarginCoeffient,max(sourceStructure.LFparameters.te+0.0035,currentPoint(1,1)));
        set(sourceStructure.taTopHandle,'xdata',taTopX);
        tmpXdata = get(sourceStructure.taHandle,'xdata');
        set(sourceStructure.taHandle,'xdata',[tmpXdata(1) taTopX]);
        taValue = taTopToTaValue(handles);
        sourceStructure.LFparameters.ta = taValue;
    case 'tc'
        sourceStructure.LFparameters.tc = max(sourceStructure.LFparameters.te+ ...
            sourceStructure.LFparameters.ta+0.02,min(1,currentPoint(1,1)));
        set(sourceStructure.tcHandle,'xdata',sourceStructure.LFparameters.tc*[1 1]);
    otherwise
        set(src,'Pointer','cross');
end;
sourceStructure = updateDisplay(sourceStructure);
guidata(handles.LFModelDesignerFigure,sourceStructure);

function sourceStructure = updateDisplay(sourceStructure)
fsDisplay = 1000;
normalizedTime = (-0.2:1/fsDisplay:1.2);
tp = sourceStructure.LFparameters.tp;
te = sourceStructure.LFparameters.te;
ta = sourceStructure.LFparameters.ta;
tc = sourceStructure.LFparameters.tc;
nyqFreq = fsDisplay/2;
Tw = 2/nyqFreq;
modelOut = sourceByLFmodelAAF(normalizedTime,tp,te,ta,tc,Tw);
if sum(isnan(modelOut.source)) == 0
    set(sourceStructure.sourceHandle,'xdata',normalizedTime,'ydata',modelOut.source);
    set(sourceStructure.sourceAxis,'ylim',[min(modelOut.source) max(modelOut.source)]);
    ylimit = get(sourceStructure.sourceAxis,'ylim');
    set(sourceStructure.tpHandle,'ydata',[0 max(modelOut.source)],'xdata',tp*[1 1]);
    set(sourceStructure.teHandle,'ydata',[min(modelOut.source) 0],'xdata',te*[1 1]);
    %taXtop = te+diff(ylimit)/abs(ylimit(1))*ta;
    taYinitial = interp1(normalizedTime,modelOut.source,te,'linear','extrap');
    taXtop = te+(ylimit(2)-taYinitial)/abs(taYinitial)*ta;
    set(sourceStructure.taHandle,'ydata',[taYinitial max(modelOut.source)], ...
        'xdata',[te taXtop]);
    set(sourceStructure.taTopHandle,'ydata',max(modelOut.source),'xdata',taXtop);
    set(sourceStructure.tcHandle,'ydata',[min(modelOut.source) max(modelOut.source)], ...
        'xdata',tc*[1 1]);
    set(sourceStructure.vvHandle,'xdata',normalizedTime,'ydata',modelOut.volumeVerocity);
    set(sourceStructure.vvAxis,'ylim',[0 max(modelOut.volumeVerocity)]);
    fftl = 8192*2;
    fx = (0:fftl-1)'/fftl*fsDisplay;
    sourceSpectrum = 20*log10(abs(fft(modelOut.source,fftl)));
    frequencyWeight = 20*log10(fx);
    levelAtF0 = interp1(fx,sourceSpectrum+frequencyWeight,1);
    ydata = sourceSpectrum+frequencyWeight-levelAtF0;
    set(sourceStructure.spectrumHandle,'ydata',ydata);
    if max(ydata(fx<50))>20
        set(sourceStructure.spectrumAxis,'ylim',[-20 max(ydata(fx<50))]);
    else
        set(sourceStructure.spectrumAxis,'ylim',[-20 20]);
    end;
set(sourceStructure.tpText,'string',['tp:' num2str(tp*100,'%7.3f')]);
set(sourceStructure.teText,'string',['te:' num2str(te*100,'%7.3f')]);
set(sourceStructure.taText,'string',['ta:' num2str(ta*100,'%7.3f')]);
set(sourceStructure.tcText,'string',['tc:' num2str(tc*100,'%7.3f')]);
%if isfield(sourceStructure,'parentUserData') && sourceStructure.parentUserData.releaseToPlay
%    vtShapeToSoundTestV20('SoundItButton_Callback',sourceStructure.parentUserData.SoundItButton,[], ... 
%        sourceStructure.parentUserData);
%end;
end;

function taTopValue = getTaTopValue(handles)
%ylimit = get(handles.sourceAxis,'ylim');
%taTopValue = diff(ylimit)/abs(ylimit(1))*handles.LFparameters.ta;
sourceStructure = guidata(handles.LFModelDesignerFigure);
fsDisplay = 1000;
normalizedTime = (-0.2:1/fsDisplay:1.2);
tp = sourceStructure.LFparameters.tp;
te = sourceStructure.LFparameters.te;
ta = sourceStructure.LFparameters.ta;
tc = sourceStructure.LFparameters.tc;
nyqFreq = fsDisplay/2;
Tw = 2/nyqFreq;
modelOut = sourceByLFmodelAAF(normalizedTime,tp,te,ta,tc,Tw);
if sum(isnan(modelOut.source)) == 0
    ylimit = get(sourceStructure.sourceAxis,'ylim');
    taYinitial = interp1(normalizedTime,modelOut.source,te,'linear','extrap');
    taTopValue = (ylimit(2)-taYinitial)/abs(taYinitial)*ta;
end;

function taValue = taTopToTaValue(handles)
taTop = get(handles.taTopHandle,'xdata');
taBottom = get(handles.taHandle,'xdata');
taBottom = taBottom(1);
taHandleYdata = get(handles.taHandle,'ydata');
taBottomY = taHandleYdata(1);
%ylimit = get(handles.sourceAxis,'ylim');
%taValue = abs(ylimit(1))/diff(ylimit)*(taTop-taBottom);
taValue = abs(taBottomY)/diff(taHandleYdata)*(taTop-taBottom);

function penUpFunction(src,evnt)
handles = guidata(src);
sourceStructure = guidata(handles.LFModelDesignerFigure);
switch sourceStructure.currentLFParameter
    case 'tp'
        xdata = get(sourceStructure.tpHandle,'xdata');
        sourceStructure.LFparameters.tp = xdata(1);
    case 'te'
        xdata = get(sourceStructure.teHandle,'xdata');
        sourceStructure.LFparameters.te = xdata(1);
    case 'ta'
        taValue = taTopToTaValue(handles);
        sourceStructure.LFparameters.ta = taValue;
    case 'tc'
        xdata = get(sourceStructure.tcHandle,'xdata');
        sourceStructure.LFparameters.tc = xdata(1);
end;
set(sourceStructure.tpHandle,'linewidth',1);
set(sourceStructure.teHandle,'linewidth',1);
set(sourceStructure.tcHandle,'linewidth',1);
set(sourceStructure.taHandle,'linewidth',1);
set(handles.LFModelDesignerFigure,'WindowButtonMotionFcn',@moveWhileMouseUp);
set(handles.LFModelDesignerFigure,'windowbuttonUpFcn','');
sourceStructure.currentLFParameter = 'NA';
guidata(handles.LFModelDesignerFigure,sourceStructure);
if isfield(handles,'parentUserData') 
    handles.parentUserData = guidata(handles.parentUserData.vtTester);
    if handles.parentUserData.releaseToPlay
    vtShapeToSoundTestV24('SoundItButton_Callback',handles.parentUserData.SoundItButton,[], ... 
        handles.parentUserData);
    end;
end;


function currentLFParameter = whichLFParameter(sourceStructure)
currentLFParameter = 'NA';
tp = sourceStructure.LFparameters.tp;
te = sourceStructure.LFparameters.te;
tc = sourceStructure.LFparameters.tc;
taTopX = get(sourceStructure.taTopHandle,'xdata');
taTopY = get(sourceStructure.taTopHandle,'ydata');
currentPoint = get(sourceStructure.sourceAxis,'currentPoint');
if abs(currentPoint(1,1)-tp)<0.01 && currentPoint(1,2)>0
    currentLFParameter = 'tp';
end
if abs(currentPoint(1,1)-te)<0.01 && currentPoint(1,2)<0
    currentLFParameter = 'te';
end
if abs(currentPoint(1,1)-tc)<0.01
    currentLFParameter = 'tc';
end
if abs(currentPoint(1,1)-taTopX)<0.02 && abs(currentPoint(1,2)-taTopY)<0.02
    currentLFParameter = 'ta';
end

function insideInd = isInsideAxis(axisHandle)
insideInd = false;
currentPoint = get(axisHandle,'currentPoint');
%currentPoint
xLimit = get(axisHandle,'xlim');
yLimit = get(axisHandle,'ylim');
if ((currentPoint(1,1)-xLimit(1))*(currentPoint(1,1)-xLimit(2)) < 0)  && ...
        ((currentPoint(1,2)-yLimit(1))*(currentPoint(1,2)-yLimit(2)) < 0)
    insideInd = true;
end;

function f0BaseStr = generateF0baseStructure(handles)
f0BaseStr = struct;
f0Base = handles.F0;
fs = handles.samplingFrequency;
tt = handles.sampleTime;
fVibrato = handles.vibratoRate;
depth = handles.vibratoDepth;
f0 = 2.0.^(log2(f0Base)+depth/1200*sin(2*pi*fVibrato*tt));
f0BaseStr.f0Trajectory = f0;
f0BaseStr.samplingFrequency = fs;
f0BaseStr.temporalPositions = tt;

% --- Executes on button press in quitButton.
function quitButton_Callback(hObject, eventdata, handles)
% hObject    handle to quitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.LFModelDesignerFigure);

% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sourceStructure = guidata(handles.LFModelDesignerFigure);
fs = sourceStructure.samplingFrequency;
LFparameters = sourceStructure.LFparameters;
f0BaseStr = generateF0baseStructure(sourceStructure);
outStr = AAFLFmodelFromF0Trajectory(f0BaseStr.f0Trajectory,f0BaseStr.temporalPositions,fs, ...
    LFparameters.tp,LFparameters.te,LFparameters.ta,LFparameters.tc);
x = outStr.antiAliasedSignal;
sourceStructure.synthStructure.LFparameters = LFparameters;
sourceStructure.synthStructure.samplingFrequency = fs;
sourceStructure.synthStructure.f0BaseStr = f0BaseStr;
sourceStructure.synthStructure.synthesisOut = outStr;
if sum(isnan(x)) == 0;
set(handles.saveButton,'enable','on');
end;
equalizerStr = sourceStructure.equalizerStr;
%xFIR = fftfilt(equalizerStr.response,x);
xMin = fftfilt(equalizerStr.minimumPhaseResponseW,x);
%xAnt = fftfilt(equalizerStr.antiCausalResp,x);
sourceStructure.player = audioplayer(xMin,fs);
play(sourceStructure.player);
guidata(handles.LFModelDesignerFigure,sourceStructure);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sourceStructure = guidata(handles.LFModelDesignerFigure);
outFileNameRoot = ['LFmodel' datestr(now,30)];
outStructure = struct;
outStructure.synthStructure = sourceStructure.synthStructure;
outStructure.originalTimeStump = datestr(now);
outStructure.creator = 'lfModelDesigner';
[file,path] = uiputfile('*','Save synth. parameters (.mat) and sound at once.',outFileNameRoot);
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Save is cancelled!');
        return;
    end;
end;
save([path [file '.mat']],'outStructure');
x = sourceStructure.synthStructure.synthesisOut.antiAliasedSignal;
fs = sourceStructure.synthStructure.samplingFrequency;
audiowrite([path [file '.wav']],x/max(abs(x))*0.9,fs);


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sourceStructure = guidata(handles.LFModelDesignerFigure);
[file,path] = uigetfile({'*.mat';'*.txt'},'Select saved .mat file or compliant .txt file');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
switch file(end-2:end)
    case 'mat'
        sourceStructure = loadSavedMatFile(sourceStructure,path,file);
    case 'txt'
        sourceStructure = loadCompliantTextFile(sourceStructure,path,file);
end;
set(sourceStructure.saveButton,'enable','off');
sourceStructure = updateDisplay(sourceStructure);
guidata(handles.LFModelDesignerFigure,sourceStructure);

function sourceStructure = loadCompliantTextFile(sourceStructure,path,file)
fid = fopen([path file]);
tline = fgetl(fid);
fieldChecker = zeros(4,1);
tmpLFparameter = struct;
while ischar(tline)
    %disp(tline);
    readItem = textscan(tline,'%s %f');
    switch char(readItem{1})
        case 'tp'
            if ~isempty(readItem{2})
                fieldChecker(1) = 1;
                tmpLFparameter.tp = readItem{2}/100;
            end;
        case 'te'
            if ~isempty(readItem{2})
                fieldChecker(2) = 1;
                tmpLFparameter.te = readItem{2}/100;
            end;
        case 'ta'
            if ~isempty(readItem{2})
                fieldChecker(3) = 1;
                tmpLFparameter.ta = readItem{2}/100;
            end;
        case 'tc'
            if ~isempty(readItem{2})
                fieldChecker(4) = 1;
                tmpLFparameter.tc = readItem{2}/100;
            end;
    end;
    tline = fgetl(fid);
end;
fclose(fid);
if prod(fieldChecker) == 0
    disp('Some parameter(s) is(are) missing!');
    return;
end;
fsDisplay = 1000;
normalizedTime = (-0.2:1/fsDisplay:1.2);
nyqFreq = fsDisplay/2;
Tw = 2/nyqFreq;
modelOut = sourceByLFmodelAAF(normalizedTime,tmpLFparameter.tp,tmpLFparameter.te,...
    tmpLFparameter.ta,tmpLFparameter.tc,Tw);
if sum(isnan(modelOut.source)) == 0
    sourceStructure.LFparameters = tmpLFparameter;
end;

function sourceStructure = loadSavedMatFile(sourceStructure,path,file)
tmp = load([path file]);
if ~isfield(tmp,'outStructure')
    disp('field: outStructure is missing!');
    return;
end;
if ~isfield(tmp.outStructure,'synthStructure');
    disp('field: outStructure.synthStructure is missing');
    return;
end;
if ~isfield(tmp.outStructure.synthStructure,'LFparameters');
    disp('field: outStructure.synthStructure.LFparameters is missing');
    return;
end;
sourceStructure.LFparameters = tmp.outStructure.synthStructure.LFparameters;


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sourceStructure = guidata(handles.LFModelDesignerFigure);
lfpModal = [0.4134 0.5530 0.0041 0.5817];
lfpBreathy = [0.4621 0.6604 0.0270 0.7712];
lfpFry = [0.4808 0.5955 0.0269 0.7200];
lfpDisplay = 0.4*lfpModal+0.3*lfpBreathy+0.3*lfpFry;
sourceStructure.LFparameters.tp = lfpDisplay(1);
sourceStructure.LFparameters.te = lfpDisplay(2);
sourceStructure.LFparameters.ta = lfpDisplay(3);
sourceStructure.LFparameters.tc = lfpDisplay(4);
set(sourceStructure.saveButton,'enable','off');
sourceStructure.currentLFParameter = 'NA';
sourceStructure = updateDisplay(sourceStructure);
guidata(handles.LFModelDesignerFigure,sourceStructure);
