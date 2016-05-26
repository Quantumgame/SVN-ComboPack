function s=speechDiscrim(varargin)
% speechDiscrim class constructor.
% s =
% speechDiscrim(mean,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% mean normalized (0 <= value <= 1)
% Description of arguments:
% =========================
% mean - Mean brightness
% soundParams.soundType = {'allOctaves','tritones', 'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'} (valid sound clip types)
% soundParams.freq - (Fundamental) frequency of sound to play
% soundParams.duration sound duration in ms
% soundParams.amps - sound amplitudes from 0<=x<=1 (array of possible amps)
% soundParams.discrimBoundary; classification boundary for use by calcStim
% soundParams.discrimSide; boolean. if true, stimuli < classification boundary go to left

s.mean = 0;
s.freq = 0;
s.amplitude = [];
s.duration = [];
s.stimSound = []; % Sound to play for the stimulus
s.audioStimulus = true;
s.soundType='';
s.wav1='';
s.wav2='';
s.stimLevel = [];
s.pct1 = []; %Generalized Variables to hold percentages from setProtocolSpeech
s.pct2 = [];
        
switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'speechDiscrim',stimManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'speechDiscrim'))
            s = varargin{1};
        else
            error('Input argument is not a intensityDiscrim object')
        end
    case 6
        % create object using specified values
        if varargin{1} >=0
            s.mean=varargin{1};
        else
            error('0 <= mean <= 1')
        end
        
        soundParams=varargin{2};
        s.soundType=soundParams.soundType;
        
        %error checking on soundParams and assign to s:
        if all(soundParams.amp>=0) & all(soundParams.amp<=1)
            s.amplitude=soundParams.amp;
        else
            error(' amplitudes  must be 0 <= x <= 1')
        end
        if all(soundParams.duration>=0)
            s.duration=soundParams.duration; %mw 04.05.2012
        else
            error(' duration  must be >0')
        end
        
        s.freq=soundParams.freq;

        
        switch s.soundType
            case {'allOctaves','tritones'}
                if soundParams.freq > 0
                    s.freq=soundParams.freq;
                else
                    error('freq must be > 0')
                end
                
            case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
                %no specific error checking here
            case 'tone'
            case 'speechWav'
                s.stimLevel = soundParams.stimLevel;
                if s.stimlevel == 6 %If we are on experimental level 15, get pcts.
                    s.pct1 = soundParams.pctLearned;
                    s.pct2 = soundParams.pctNovel;
                end
            case 'speechWavAll'
                s.pct1 = soundParams.pctLearned;
                s.pct2 = soundParams.pctNovel;                
            case 'phoneTone'
            case 'toneThenSpeech'
            case 'morPhone'
                s.pct1 = soundParams.pctVOT;
                s.pct2 = soundParams.pctMorph;
            case 'speechComponent'
                s.pct1 = soundParams.pctMask;
                s.pct2 = soundParams.pctSingle;
            otherwise
                error('speechDiscrim: soundType not recognized')
        end
        s = class(s,'speechDiscrim',stimManager(varargin{3},varargin{4},varargin{5},varargin{6}));
        
    otherwise
        error('Wrong number of input arguments')
end