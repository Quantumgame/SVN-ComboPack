function out=VisLoad(varargin)

% simple module that initializes, loads, and plays visual stimuli
% using PsychoPhysicsToolbox (PTB) routines
%mw072108

global exper pref

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
    case 'init'
        %     ModuleNeeds(me,{'rp2control'}); % needs RP2Control to find out how to talk to RP2
        SetParam(me,'priority',GetParam('stimulusprotocol','priority')+1);
        InitializeGUI;                  % show the gui = message box:-)
        InitScreen;                        % Initialize PTB Screen

    case 'reset'
       % InitScreen;

    case 'esealteston'
        %InitSM; %clear any previously loaded sound from buffer so sealtest doesn't trigger it %mw 111406

    case 'estimulusprotocolchanged'
        %InitSM; %clear any previously loaded sound from buffer so non-sound stimuli don't trigger it %mw 111706


    case 'load'
        if nargin<3
            return;
        end
        try
            if nargin==4
                LoadSM(varargin{2},varargin{3},varargin{4});
            else
                param.channel=1;
                LoadSM(varargin{2},varargin{3},param); % first channel is the default channel
            end
        catch
            Message(me,'Cannot load visual stimulus');
        end

        %     case 'samplerate'
        %         out=GetParam(me,'SoundFs');
        %
        %     case 'smobject'
        %         out=GetParam(me,'SM');
    case 'play'
        PlayStim

    case 'sethwtrigger'
        %     sm=GetParam(me,'SM');
        %     if nargin>1
        %         channel=varargin{2};   % channel should be the second argument
        %     end
        %     if isempty(channel)             % if no channel is specified, set up all
        %         invoke(rp2,'SoftTrg',1);    % channel 1
        %         invoke(rp2,'SoftTrg',2);    % channel 2
        %     else
        %         invoke(rp2,'SoftTrg',channel);  % start specific channel
        %     end

    case 'setchannel'
        %     sm=GetParam(me,'SM');
        %     channel=[];
        %     if nargin>1
        %         channel=str2num(varargin{2});   % channel should be the second argument
        %     end
        %     if isempty(channel)
        %         channel=1;                      % if there are no arguments, or the second argument is not a number, let's make it 1
        %     end
        %     invoke(rp2,'SetTagVal','channel',channel); % set the output channel
        %     Message(me,['Channel set: ' num2str(channel)]);
    case 'close'
        Priority(0);
        %The same commands wich close onscreen and offscreen windows also close
        %textures.
        Screen('CloseAll');
        Message(me, 'closing...')


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitScreen
global exper pref
% if ExistParam(me,'SM') % take the existing ActiveX control
%     sm=GetParam(me,'SM');
% else
    try
        echo off
        oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
        oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
        Screen('Preference', 'SkipSyncTests', 1);
        AssertOpenGL;
        screens=Screen('Screens');
        screenNumber=2 ;
        white=WhiteIndex(screenNumber);
        black=BlackIndex(screenNumber);
        gray=(white+black)/2;
        if round(gray)==white
            gray=black;
        end
        inc=white-gray;
        [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('FillRect',w, gray);
        Screen('Flip', w);
        sm=w;
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
    catch
        %this "catch" section executes in case of an error in the "try" section
        %above.  Importantly, it closes the onscreen window if its open.
        Screen('CloseAll');
        Priority(0);
        Message(me,'Can''t create sm object...');
    end %try..catch..

    if isempty(sm)
        Message(me,'Can''t create sm object...');
        return;
    end
    InitParam(me,'SM','value',sm); %param to hold the screen pointer
    InitParam(me,'screenRect','value',screenRect); %param to hold the screenRect
    InitParam(me,'stimparam','value',[]); %param to hold the calculated stimulus params
    
%end



Message(me, 'Initialized Screen');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadSM(type,where,param)
% loads data to soundmachine. type can be either 'file' or 'var'
switch type
    case 'file'
        try
            load(where,'samples');
            str=[where ' loaded'];  % string to be displayed in the message box
        catch
            Message(sprintf('Cannot load %s', where));
            return;
        end
    case 'var'
        samples=where;
        str='vector loaded'; % string to be displayed in the message box
    otherwise
        return;
end
dstRect=GetParam(me,'dstRect');
visiblesize=dstRect(3);

movieDurationSecs=param.duration/1000;   % Abort demo after 20 seconds.
% texsize=600;            % Half-Size of the grating image.%
texsize= (visiblesize-1)/2;            % Half-Size of the grating image.
screenNumber=1 ;
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=(white+black)/2;
if round(gray)==white
    gray=black;
end
inc=white-gray;

%grab screen and screenrect object
w=GetParam(me,'SM');
screenRect=GetParam(me,'screenRect');

%extract grating params from param structure
f=param.spatialfrequency;
cyclespersecond=param.cyclespersecond;
angle=param.angle;

% Calculate parameters of the grating:
p=ceil(1/f);  % pixels/cycle
fr=f*2*pi;
%visiblesize=2*texsize+1;

% Create one single static grating image:
[x,y]=meshgrid(-texsize:texsize + p, -texsize:texsize);
grating=gray + inc*cos(fr*x);

%try out photodiode square here?

% Store grating in texture:
gratingtex=Screen('MakeTexture', w, grating);

% location and size of the drawn rectangle on the screen:
% use this code for fixed size, centered on screen
%dstRect=[0 0 visiblesize visiblesize];
%dstRect=CenterRect(dstRect, screenRect);

% Query duration of monitor refresh interval:
ifi=Screen('GetFlipInterval', w);

waitframes = 1;
waitduration = waitframes * ifi;

% Translate requested speed of the grating (in cycles per second)
% into a shift value in "pixels per frame", assuming given
% waitduration: This is the amount of pixels to shift our "aperture" at
% each redraw:
shiftperframe= cyclespersecond * p * waitduration;

stimparam.movieDurationSecs=movieDurationSecs;
stimparam.shiftperframe=shiftperframe;
stimparam.p=p;
stimparam.visiblesize=visiblesize;
stimparam.w=w;
stimparam.gratingtex=gratingtex;
stimparam.dstRect=dstRect;
stimparam.angle=angle;
stimparam.waitframes=waitframes;
stimparam.ifi=ifi;
stimparam.gray=gray;

SetParam(me,'stimparam', 'value', stimparam);

Message(me, str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlayStim

stimparam=GetParam(me,'stimparam');
w=GetParam(me,'SM');
screenRect=GetParam(me,'screenRect');

shiftperframe=stimparam.shiftperframe;
p=stimparam.p;
visiblesize=stimparam.visiblesize;
w=stimparam.w;
gratingtex=stimparam.gratingtex;
dstRect=stimparam.dstRect;
angle=stimparam.angle;
waitframes=stimparam.waitframes;
ifi=stimparam.ifi;
movieDurationSecs=stimparam.movieDurationSecs;
gray=stimparam.gray;
i=0;


%try out photodiode square
screenNumber=2 ;
white=WhiteIndex(screenNumber);
diodesquare=white.*ones(100, 100);
diodesquaretex=Screen('MakeTexture', w, diodesquare);

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
vbl=Screen('Flip', w);
% We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
vblendtime = vbl + movieDurationSecs;

% Animationloop:
while(vbl < vblendtime)

    % Shift the grating by "shiftperframe" pixels per frame:
    xoffset = mod(i*shiftperframe,p);
    i=i+1;

    % Define shifted srcRect that cuts out the properly shifted rectangular
    % area from the texture:
    srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

    % Draw grating texture, rotated by "angle":
    %note: I specify dstRect here in [x, y, width, height], where x,y=center
    %in Screen('DrawTexture') dstRect is specified as x1, y1, x2, y2 (corners)
    %Here is where I convert to Screen specs
    halfwidth=dstRect(3)/2;
    Screen_dstRect=[dstRect(1)-halfwidth dstRect(2)-halfwidth dstRect(1)+halfwidth dstRect(2)+halfwidth];
    Screen('DrawTexture', w, gratingtex, srcRect, Screen_dstRect, angle);

    % Draw photodiode texture:
    diodedstRect=[0 0 100 100];
    Screen('DrawTexture', w, diodesquaretex, [], diodedstRect, []);

    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

    % Abort demo if any key is pressed:
    %    if KbCheck
    %         break;
    %     end;
end;

Screen('FillRect',w, gray);
Screen('Flip', w);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
fig = ModuleFigure(me);
set(fig,'doublebuffer','on','visible','off');

hs = 100;
h = 5;
vs = 20;
n = 0;
% message box
uicontrol('parent',fig,'tag','message','style','text',...
    'enable','inact','horiz','left','pos',[h n*vs hs vs]); n=n+1;
dstRect=[700 525 1200 1200]; %default full-field destination rect for grating
%note: I specify dstRect here in x, y, width, height
%in Screen('DrawTexture') dstRect is specified as x1, y1, x2, y2
InitParam(me,'dstRect',... %param to hold the destination rect on the screen
       'value',dstRect,...
    'ui','edit','pos',[h n*vs hs vs]); n=n+1;
screensize=get(0,'screensize');
set(fig,'pos', [screensize(3)-168 screensize(4)-n*vs-120 158 n*vs] ,'visible','on');
%InitParam(me,'SoundFs','value',96000);        % stores sound sample rate we use
% InitParam(me,'SoundFs','value',200000); %mw 060606       % stores sound sample rate we useInitParam(me,'SoundFs','value',96000);        % stores sound sample rate we use
Message(me, 'ready');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
