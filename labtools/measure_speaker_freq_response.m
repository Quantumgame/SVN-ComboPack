function measure_speaker_freq_response

fs=1e5;
cd D:\lab\Data-processed\021608-lab\021608-lab-003
D=load('021608-lab-003-001-AxopatchData1-trace.mat');
E=load('021608-lab-003-001-AxopatchData1-events.mat');
event1=E.event;

%20 seconds of 80 dB white noise collected by microphone at 100 mV/Pa
scaledtrace=D.nativeScaling*double(D.trace)+D.nativeOffset;

cd d:\lab\exper2.2\protocols
load WNforSpeakerCalibration_sourcefile_20s.mat

t=1:length(scaledtrace);
t=t/fs;

tracelength=20e3;
if strcmp(event1(1).Type, 'soundfile')
    pos=event1(1).Position;
    start=(pos);
    stop=(start+tracelength*1e-3*fs)-1;
    region=start:stop;
    microphone_data=  scaledtrace(region);
end

[Pmd, Fmd]=pwelch(microphone_data, [], [], [], fs);
[Psample, Fsamp]=pwelch(sample, [], [], [], 2e5);
figure
semilogy(Fmd, Pmd, Fsamp, Psample)


keyboard

microphone_data=data(:,2);
speaker_command_voltage=data(:,1);
figure
subplot(3,1,2)
plot(t, microphone_data);
ylabel({'microphone', 'voltage, mV'})
subplot(3,1,3)
plot(t, speaker_command_voltage);
xlabel('time, s')
ylabel({'speaker', 'voltage, V'})
xl=xlim;

freqs=500:500:22000;
duration=100; % ms
for f=1:length(freqs)
    %get power for individual beeps using RMS method, integrated over central 60 ms
    beepdata=microphone_data(((f-1)*duration*round(fs)/1000+1):f*duration*round(fs)/1000);
    bd=(1/17)*beepdata; %microphone calibration is 17mV/Pa
    bd=bd(round(fs*20/1000):round(length(bd)-fs*20/1000)); %trim 20 ms ramps from edges
    bd=bd-mean(bd);
    RMS=sqrt( mean( bd.^2 ) );
    power(f)=20*log10( RMS / 2e-5 )-40; %subtract microphone gain of 40 dB
end
subplot(3,1,1)
f=1:length(freqs);
plot(t(((f-1)*duration*fs/1000+1)), power, 'o-')
xlim(xl)
ylabel('dB SPL')
title('power of 10 V sine waves, .5-22 kHz')

function generate_samples
%create a train of beeps of linearly increasing frequency
freqs=500:500:22000;
duration=100; % ms
RP2Fs=(50e6/512); %RP2 sampling rate
fs=RP2Fs;
t=(1/fs):(1/fs):duration/1000;

% Make cos^2 edges for the tone pips.
RiseFalls=20;
Edge=MakeEdge( fs , RiseFalls );
LEdge=length(Edge);

beeptrain=zeros(1, round(length(freqs)*duration*fs/1000));
for f=1:length(freqs)
    beep =  sin(2*pi*freqs(f)*t);
    beep(1:LEdge)=beep(1:LEdge) .* fliplr(Edge);
    beep((end-LEdge+1) : end )=beep( (end-LEdge+1) : end ) .* Edge;
    beeptrain(((f-1)*length(beep)+1):f*length(beep))=beep;
end

cd D:\home\Wehr\Matlab\calibrate
status=mkdir('measure_speaker_freq_response');
cd measure_speaker_freq_response
samples=10*beeptrain';
save RP2Samples1 samples


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MakeEdge
%		Generate the rising/falling edge as an accessory to MakeBeep.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Edge=MakeEdge( SRate, RiseFall )

% Usage:
% Edge=MakeEdge( SRate, RiseFall )
% Calculate a cos^2 gate for the trailing edge that has a 10%-90%
% fall time of RiseFall in milliseconds given sample rate SRate in Hz.

omega=(1e3/RiseFall)*(acos(sqrt(0.1))-acos(sqrt(0.9)));
t=0 : (1/SRate) : pi/2/omega;
t=t(1:(end-1));
Edge=( ( cos(omega*t) ).^2 );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MakeEdge : End of function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

