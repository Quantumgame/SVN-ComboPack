function s=gap(varargin)
% gap class constructor.
% s =
% gap(mean,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance)
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
s.gapDurs = []; %list of gap durations in ms
s.pct2 = [];
s.stimMap = [];
        
switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'gap',stimManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'gap'))
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

        if length(soundParams.gapDurs) > 0
            s.gapDurs = soundParams.gapDurs;
        else
            error(' need to provide gap durations')
        end
        
        switch s.soundType
            case 'gap'
            otherwise
                error('gap: soundType not recognized')
        end
        s = class(s,'gap',stimManager(varargin{3},varargin{4},varargin{5},varargin{6}));
        
    otherwise
        error('Wrong number of input arguments')
end