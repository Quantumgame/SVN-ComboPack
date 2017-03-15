function makeSoundfileProtocol(varargin)
%usage: makeSoundfileProtocol(amplitude, start, duration, isi, nreps,whentostart)
%opens a dialog box to select the sound file 
%sound file must be in .wav format, and if stereo only the right channel will be used
%
%creates an exper2 stimulus protocol file that plays sound from a file
% inputs:
% amplitude: peak instantaneous amplitude in dB SPL, defaults to pref.maxSPL
% start (in seconds): length of silent baseline period before sound starts,
%   (defaults to zero)
% duration (in seconds): how much of the soundfile to use
%   (defaults to total duration of the soundfile)
% isi (in seconds): interval between repeats (defaults to 1s)
% nreps: number of repeats, defaults to 1
% whentostart: time point of sound file when you want to start playing file
%      (in seconds), defaults to very beginning of file
% outputs:
% creates a suitably named stimulus protocol in
% exper2.2\protocols\soundfiles
%
%example call: makeSoundfileProtocol(1, 20)
% added nreps to use this with MakeTCHoldCmdProtocol
% mak 31aug2012
% 


global pref

if nargin==0
    amp=pref.maxSPL;
    duration=[];
    start=0;
    isi=[];
    nreps=[];
    whentostart=[];
elseif nargin==1
    amp=varargin{1};
    start=0;
    duration=[];
    isi=[];
    whentostart=[];
elseif nargin==2
    amp=varargin{1};
    start=varargin{2};
    duration=[];
    isi=[];
    nreps=[];
    whentostart=[];
elseif nargin==3
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=duration/2;
    nreps=[];
    whentostart=[];
elseif nargin==4
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    nreps=[];
    whentostart=[];
elseif nargin==5
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    nreps=varargin{5};
    whentostart=[];
elseif nargin==6
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    nreps=varargin{5};
    whentostart=varargin{6};
else error('makeSoundfileProtocol: wrong number of arguments')
end
    
if isempty(amp)
        amp=pref.maxSPL;
end
if isempty(nreps)
        nreps=1;
end
if isempty(whentostart)
        whentostart=1;
end
if isempty(start)
        start=0;
end
if isempty(isi)
        isi=1;
end
if isempty(pref); Prefs;end
    cd(pref.stimuli)
cd ../
cd stimuli
if ~exist('Sound Files', 'dir')
    mkdir('Sound Files')
end
cd('Sound Files')
% cd ('soundfiles')


[filename_ext, path] = uigetfile('*.wav', 'please choose source file');
if isequal(filename_ext,0) || isequal(path,0)
       disp('User pressed cancel')
return
end
 cd (path)
[path, filename]=fileparts(filename_ext);
[s, Fs]=wavread(filename_ext);
if isempty(duration)
    duration=length(s)/Fs;
end
if duration*Fs>length(s)
    duration=length(s)/Fs;
    fprintf('requested duration longer than sound, using duration %.1f s', duration)
end
if isempty(isi) isi=duration/2;end
 isi=max(isi, 1);
if whentostart==1
    wts=0;
else
    wts=whentostart;
end
% s=s(1:duration*Fs); %load only partial stim
s=s(1+(wts*Fs):(wts+duration)*Fs); %load only partial stim

s=resample(s, pref.SoundFs , Fs); %resample to soundcard samprate

%normalize and set to requested SPL;
s=s./max(abs(s));
    amplitude=1*(10.^((amp-pref.maxSPL)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
s=amplitude.*s;
sample.param.description='soundfile stimulus';
sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('soundfile_%s_%ddB_%.1fs_isi%.1fs%dnreps', filename, amp, duration, isi, nreps);
stimuli(1).param.description= sprintf('sound from soundfile %s %ddB duration=%.1fs isi=%.1fs nreps=%d', filename, amp, duration, isi, nreps);

outfilename=sprintf('soundfile_protocol_%s_%ddB_%.1fs_isi%.1fs%dnreps.mat', filename, amp, duration, isi, nreps);
sourcefilename=sprintf('soundfile_sourcefile_%s_%ddB_%.1fs_isi%.1fs%dnreps.mat', filename, amp, duration, isi, nreps);

for nn=1:nreps
    stimuli(nn+1).type='naturalsound';
    stimuli(nn+1).param.file=['soundfiles\sourcefiles\',sourcefilename];
    stimuli(nn+1).param.duration=duration*1e3; %in ms
    stimuli(nn+1).param.amplitude=amplitude; %
    stimuli(nn+1).param.next=isi*1000;
end

cd (pref.stimuli)
if ~exist('soundfiles', 'dir')
    mkdir('soundfiles')
end
cd ('soundfiles')
save(outfilename, 'stimuli');
if ~exist('sourcefiles', 'dir')
    mkdir('sourcefiles')
end
cd sourcefiles
save(sourcefilename, 'sample');
fprintf('\nwrote files %s \nand %s \nin directory %s\n',outfilename,sourcefilename,pwd )

