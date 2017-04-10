function MakeRisetimeProtocol(frequencies, amps, risetimes, duration, isi, nrepeats)
%usage: MakeRisetimeProtocol([frequencies], [amps], [risetimes], duration, isi, nrepeats)
%
% creates an exper2 stimulus protocol file for tones with varying
% frequency, anmplitude, and risetime
% mw 081108
% inputs:
% frequencies: tone frequencies in Hz. If you want them log spaced, you have to do it yourself
%     use -1 for whitenoise
% amps: tone amplitudes in dB SPL
% duration: duration in ms
% risetimes: cosine-squared ramp duration (10-90%) in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
%
% outputs:
% creates a suitably named stimulus protocol in
% D:\lab\exper2.2\protocols\Risetime protocols
%
%
%example calls: 
% MakeRisetimeProtocol(10000, 70, [1 2 4 8 16 32 64], 200, 500, 10)
% MakeRisetimeProtocol([1000 2000 4000 8000 16000 32000], [20 40 60 80], [1 3 5], 25, 500, 10)
% MakeRisetimeProtocol([-1 13000], 70, [1 2 4 8 16] , 100, 500, 10)

global pref
if nargin~=6 error('\n MakeRisetimeProtocol: wrong number of arguments.'); end

logspacedfreqs = frequencies;
linspacedamplitudes = amps;
numfreqs=length(frequencies);
numamplitudes=length(amps);
numrisetimes=length(risetimes);

[Amplitudes,Freqs,Risetimes]=meshgrid( linspacedamplitudes , logspacedfreqs,risetimes );
neworder=randperm( numfreqs * numamplitudes *numrisetimes );
amplitudes=zeros(1,length(neworder)*nrepeats);
freqs=zeros(1,length(neworder)*nrepeats);
rise_times=zeros(1,length(neworder)*nrepeats);

tdur=numrisetimes* numfreqs * numamplitudes*(duration+isi)/1000;%duration per repeat

for nn=1:nrepeats
    neworder=randperm( numfreqs * numamplitudes *numrisetimes );
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
    rise_times( prod(size(Risetimes))*(nn-1) + (1:prod(size(Risetimes))) ) = Risetimes( neworder );
end

freqstring=sprintf('%d-', frequencies);freqstring=freqstring(1:end-1);
ampstring=sprintf('%d-', amps);ampstring=ampstring(1:end-1);
risetimestring=sprintf('%g-', risetimes);risetimestring=risetimestring(1:end-1);

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('risetime-%shz-%sdB-%smsRT-%dmsdur-%dmsISI',...
    freqstring,ampstring,risetimestring, duration,isi);
stimuli(1).param.description=sprintf(...
    'Risetime Protocol, freqs: %s hz, amps: %s dB, risetimes: %s ms, dur: %d ms, ISI: %d ms ', ...
freqstring,ampstring,risetimestring, duration,isi);

filename=[stimuli(1).param.name, '.mat'];


for k=1:length(amplitudes)
    nn=nn+1;
    switch freqs(k)
        case -1
            stimuli(nn).type='whitenoise';
            stimuli(nn).param.amplitude=amplitudes(k);
            stimuli(nn).param.duration=duration;
            stimuli(nn).param.ramp=rise_times(k);
            stimuli(nn).param.next=isi;
        otherwise
            stimuli(nn).type='tone';
            stimuli(nn).param.frequency=freqs(k);
            stimuli(nn).param.amplitude=amplitudes(k);
            stimuli(nn).param.duration=duration;
            stimuli(nn).param.ramp=rise_times(k);
            stimuli(nn).param.next=isi;
    end
end

global pref
Prefs
cd(pref.stimuli)
cd('Risetime protocols')
save(filename, 'stimuli')

