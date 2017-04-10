function MakeWNHoldCmdProtocol(ramp, lo_holdduration, hi_holdduration,...
    lo_potential, hi_potential, WN_duration, WN_ramp, WN_isi)
global pref
% specify a Voltage Clamp command protocol designed for testing DSI
% compares WN responses before and after a depolarization step
% usage: MakeTCHoldCmdProtocol(...)
% inputs:
% ramp -   holdcmd ramp duration (ms)
% lo_holdduration -    duration of the low step holding command after ramp (ms)
% hi_holdduration -    duration of the hi step holding command after ramp (ms)
% lo_potential - low step holding command potential
% hi_potential - hi step holding command potential
% WN_duration - duration of white noise burst (ms)
% WN_ramp - WN onset/offset ramp (ms)
% WN_isi - isi for WN bursts (ms)
% outputs:
%   creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%example call:
% MakeWNHoldCmdProtocol(500, 40e3, 5e3, -50, 20, 25, 3, 500)
%
%no pseudorandom sequences! only 2 potentials and 1 WN burst

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('WNHoldCmd, ramp%dms/durations:lo%dms/hi%dms/%d/%d/isi%dms',...
    ramp, lo_holdduration, hi_holdduration, lo_potential, hi_potential, WN_isi);
stimuli(1).param.description=sprintf('WNHoldCmd, ramp: %dms, durations:lo%dms/hi%dms/%d/%d/isi%dms',ramp, lo_holdduration, hi_holdduration, lo_potential, hi_potential, WN_isi);
filename=sprintf('WNholdcmd-%d-%dms-%d-%dmV-%dms', lo_holdduration, hi_holdduration, lo_potential, hi_potential, WN_isi);

num_hi_WNbursts=round(hi_holdduration/(200+WN_isi)); %adding the mysterious extra  ms isi to get a correct holdduration
num_lo_WNbursts=round(lo_holdduration/(200+WN_isi));

stimuli(2).type='holdcmd';
stimuli(2).param.start=1;
stimuli(2).param.ramp=ramp;
stimuli(2).param.holdduration=100+ramp;
stimuli(2).param.holdcmd_from=hi_potential;
stimuli(2).param.holdcmd_to=lo_potential;
stimuli(2).param.duration=100;

%hard coding params for series pulses.
stimuli(2).param.pulse_start= 1;
stimuli(2).param.pulse_width= 1;
stimuli(2).param.pulse_height= 0;
stimuli(2).param.npulses= 1;
stimuli(2).param.pulse_isi= 1;
stimuli(2).param.pulseduration= 5;

%low WN bursts

for nn=3:3+num_lo_WNbursts
    stimuli(nn).type='whitenoise';
    stimuli(nn).param.amplitude=80;
    stimuli(nn).param.duration=WN_duration;
    stimuli(nn).param.ramp=WN_ramp;
    stimuli(nn).param.next=WN_isi;
end

jj=3+num_lo_WNbursts+1;

stimuli(jj).type='holdcmd';
stimuli(jj).param.start=100;
stimuli(jj).param.ramp=ramp;
stimuli(jj).param.holdduration=1000+ramp;
stimuli(jj).param.holdcmd_from=lo_potential;
stimuli(jj).param.holdcmd_to=lo_potential;
stimuli(jj).param.duration=2000+ramp;

%hard coding params for series pulses.
stimuli(jj).param.pulse_start= 50;
stimuli(jj).param.pulse_width= 50;
stimuli(jj).param.pulse_height= -10;
stimuli(jj).param.npulses= 5;
stimuli(jj).param.pulse_isi= 50;
stimuli(jj).param.pulseduration= 500;


kk=3+num_lo_WNbursts+2;

stimuli(kk).type='holdcmd';
stimuli(kk).param.start=100;
stimuli(kk).param.ramp=ramp;
stimuli(kk).param.holdduration=1000+ramp;
stimuli(kk).param.holdcmd_from=lo_potential;
stimuli(kk).param.holdcmd_to=hi_potential;
stimuli(kk).param.duration=ramp;

%hard coding params for series pulses.
stimuli(kk).param.pulse_start= 50;
stimuli(kk).param.pulse_width= 50;
stimuli(kk).param.pulse_height= 0;
stimuli(kk).param.npulses= 5;
stimuli(kk).param.pulse_isi= 50;
stimuli(kk).param.pulseduration= 500;

%high WN bursts

for nn=kk+1:kk+1+num_hi_WNbursts
    stimuli(nn).type='whitenoise';
    stimuli(nn).param.amplitude=80;
    stimuli(nn).param.duration=25;
    stimuli(nn).param.ramp=WN_ramp;
    stimuli(nn).param.next=WN_isi;
end
    stimuli(nn).param.next=0;

cd(pref.stimuli) %where stimulus protocols are saved
cd('Voltage Clamp protocols')
save(filename, 'stimuli')



