function MakeTuningCurve( varargin )

% MakeTuningCurve( minimum_frequency, maximum_frequency, frequency_steps, ...
%                     minimum_attenuation, maximum_attenuation, attenuation_steps, ...
%                     nrepeats, duration, spacing )

% Make a tuning curve for playstimuli.
% Attenuation at 0, 15, 30, 45, 60 dB
% 32 frequencies between 2 kHz & 40 kHz log spaced.
% 25 ms long.
% First tone at 0.25 s. Then a tone every 1 s following.
% 100 ms duration unless specified otherwise.
% spacing = 1000 ms between tone onsets unless specified otherwise

%hack onset hardwire
%-mike wehr 09-03-01
if ( nargin >= 9 ) & ~isempty( varargin{9} )
    spacing=varargin{9};
else
    spacing=1000;
end
if ( nargin >= 8 ) & ~isempty( varargin{8} )
    duration=varargin{8};
else
    duration=100;
end
if ( nargin >= 7 ) & ~isempty( varargin{7} )
	nrepeats=varargin{7};
else
	nrepeats=10;
end
if ( nargin >= 6 ) & ~isempty( varargin{6} )
	attensteps=varargin{6};
else
	attensteps=5;
end
if ( nargin >= 5 ) & ~isempty( varargin{5} )
	maxatten=varargin{5};
else
	maxatten=60;
end
if ( nargin >= 4 ) & ~isempty( varargin{4} )
	minatten=varargin{4};
else
	minatten=0;
end
if ( nargin >= 3 ) & ~isempty( varargin{3} )
	freqsteps=varargin{3};
else
	freqsteps=32;
end
if ( nargin >= 2 ) & ~isempty( varargin{2} )
	maxfreq=varargin{2};
else
	maxfreq=4e4;
end
if ( nargin >= 1 ) & ~isempty( varargin{1} )
	minfreq=varargin{1};
else
	minfreq=2e3;
end

% Delay 250 ms, then a tone every spacing ms for nrepeats.
%onset = 250 : spacing : (freqsteps*attensteps*nrepeats * spacing);
onset = 1000 : spacing : (freqsteps*attensteps*nrepeats * spacing);

% Linearly spaced attenuations.
atten = linspace( minatten , maxatten , attensteps );

% All dur ms duration
dur = duration*ones(size(onset));

% Frequencies log spaced.
logspacedfreq = logspace( log10(minfreq) , log10(maxfreq) , freqsteps );

% Make all possible pairings of frequencies and attenuations.
[Atten,Freq]=meshgrid( atten , logspacedfreq );

% Shuffle them.
neworder=randperm( freqsteps * attensteps );

% Form variables that hold the new shuffled ones.
atten=zeros(size(onset));
freq=zeros(size(onset));

% Fill them with randomly ordered. Repeat until full.
for nn=1:nrepeats
	atten( prod(size(Atten))*(nn-1) + (1:prod(size(Atten))) ) = Atten( neworder );
	freq( prod(size(Freq))*(nn-1) + (1:prod(size(Freq))) ) = Freq( neworder );
end

% Create a matrix for all the repeats.
%freq=zeros(size(onset));
% Shuffle the order of presentation to build up ten.
%for nn=1:nrepeats
%	freq( (1:nsteps) + ((nn-1)*nsteps) ) = logspacedfreq( randperm(nsteps) );
%end

%figure;
%plot( atten, freq, '.');
%figure;
%hist( atten, unique(atten) );
%figure;
%hist( freq , unique(freq));

%%
% Now write to file
fid=fopen('TuningCurveOutput.txt','wt');
for nn=1:length(onset)
	fprintf(fid,'%e %e %e %e\n',onset(nn),dur(nn),atten(nn),freq(nn));
end
fclose(fid);