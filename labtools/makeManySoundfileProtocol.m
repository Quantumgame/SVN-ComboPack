function makeSoundfileProtocol(varargin)
%usage: makeSoundfileProtocol(amplitude, start, duration, isi, nreps,whentostart)
%opens a dialog box to select the sound files
%sound file must be in .wav format, and if stereo only the right channel will be used
%
%creates an exper2 stimulus protocol file that plays sound from multiple
%files in pseudorandom order, rather than a single file. -JLS042216
% inputs:
% amplitude: peak instantaneous amplitude in dB SPL, defaults to pref.maxSPL
% start (in seconds): length of silent baseline period before sound starts,
%   (defaults to zero)
% duration (in seconds): how much of the soundfile to use
%   (defaults to total duration of the soundfile)
% isi (in ms): interval between repeats (defaults to 1s)
% nreps: number of repeats, defaults to 1
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
elseif nargin==1
    amp=varargin{1};
    start=0;
    duration=[];
    isi=[];
elseif nargin==2
    amp=varargin{1};
    start=varargin{2};
    duration=[];
    isi=[];
    nreps=[];
elseif nargin==3
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=duration/2;
    nreps=[];
elseif nargin==4
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    nreps=[];
elseif nargin==5
    amp=varargin{1};
    start=varargin{2};
    duration=varargin{3};
    isi=varargin{4};
    nreps=varargin{5};
else error('makeSoundfileProtocol: wrong number of arguments')
end
    
if isempty(amp)
        amp=pref.maxSPL;
end
if isempty(nreps)
        nreps=1;
end

if isempty(start)
        start=0;
end
if isempty(isi)
    error('isi cant be undefined in multisound files')
end
if isempty(pref); Prefs;end

cd(pref.stimuli)
if ~exist('soundfiles', 'dir')
    mkdir('soundfiles')
end
cd ('soundfiles')
if ~exist('sourcefiles', 'dir')
    mkdir('sourcefiles')
end

cd(pref.stimuli)
cd ../
cd stimuli
if ~exist('Sound Files', 'dir')
    mkdir('Sound Files')
end
cd('Sound Files')
% cd ('soundfiles')


[filename_ext, path] = uigetfile('*.wav', 'please choose source files','MultiSelect','on');
[descriptname] = inputdlg('Please name the protocol');
descriptname = char(descriptname);
if isequal(filename_ext,0) || isequal(path,0)
       disp('User pressed cancel')
return
end
 
 %Start stimuli stx
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('manysoundfile_%s_%ddB_%disi_%dnreps', descriptname, amp, isi, nreps);
stimuli(1).param.description= sprintf('many sound file named %s, %ddB isi=%.1fs nreps=%d', descriptname, amp, isi, nreps);

cd(pref.stimuli)
cd ('soundfiles')
cd sourcefiles
s = []; %Get cell array of all sounds and put into stx
for i = 1:length(filename_ext)
    [s, Fs]=wavread(char(strcat(path,filename_ext(i))));
    duration = (length(s)/Fs);

    %if isempty(duration) Enable/fix this if you want anything but the
    %whole file.
    %    duration(i)=length(s{i})/Fs(i);
    %end
    
    s=resample(s, pref.SoundFs , Fs); %resample to soundcard samprate
    
    %normalize and set to requested SPL;
    s=s./max(abs(s));
    amplitude=1*(10.^((amp-pref.maxSPL)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
    s=amplitude.*s;

    %Make/save sourcefile stx    
    sample.param.description='soundfile stimulus';
    sample.param.sourcefile=strcat(path,filename_ext(i));
    sample.param.sourcename=filename_ext(i);
    sample.sample=s;
    
    sourcefilename=sprintf('soundfile_sourcefile_%s_%d_%ddB_%.1fs.mat', char(filename_ext(i)),i, amp, duration);
    save(sourcefilename, 'sample');
    
    %Make stim structure
    stimuli(i+1).type='naturalsound';
    stimuli(i+1).param.file=['soundfiles\sourcefiles\',sourcefilename];
    stimuli(i+1).param.duration=duration*1e3; %in ms
    stimuli(i+1).param.amplitude=amplitude; %
    stimuli(i+1).param.next=isi;
end

%Make random permutations
for nn = 1:nreps-1
    stimuli(end+1:end+length(filename_ext)) = stimuli(randperm(length(filename_ext))+1);
end

outfilename=sprintf('soundfile_protocol_%s_%ddB_isi%.1fs%dnreps.mat', descriptname, amp, isi, nreps);

cd (pref.stimuli)
if ~exist('soundfiles', 'dir')
    mkdir('soundfiles')
end
cd ('soundfiles')
save(outfilename, 'stimuli');

fprintf('\nwrote files %s \nand %s \nin directory %s\n',outfilename,sourcefilename,pwd )

