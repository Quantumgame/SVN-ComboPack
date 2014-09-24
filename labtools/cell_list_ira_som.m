function cells=cell_list_ira_som
% cell list for ira's speech noise project.
% **"A1" refers to whether recording was taken from A1, as estabilished by
% tonotopic gradient and tuning curve. y= yes, n= no, m= maybe
% **mode should be one of: 'i=0', 'vclamp', 'iclamp', 'lca', 'mua', 'lfp'
% **iext indicates the current injected in 'iclamp' mode. If iext line does
% not exist for a data file, assume iext=0
% **genotype indicates transgenic line of mouse
% **'NAN' indicates an unknown value
%You can leave CF as nan if you don't know it, or haven't looked at the
%tuning curve yet
%Format: each session represents a recording from one site or cell;
%no exceptions. 
%last update: 09-16-2013
%

%test
y='yes';
n='no';
m='maybe';
CB='channel blockers';
N='normal internal solution';
ut='untuned';
nr='not responsive';
i=0;
i=i+1;
cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='001';
cells(i).depth=280; %micrometers
cells(i).internalSolution='nan'; %
cells(i).A1=m;
cells(i).CF=12000; %Hz
cells(i).Vout=nan; %mV
cells(i).filenum(1,:)='003'; %
cells(i).description{1}='TC'; %noisy
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WN'; %WN with laser on/off
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

i=i+1;
cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='002';
cells(i).depth=307; %micrometers
cells(i).internalSolution='nan'; %
cells(i).A1=n;
cells(i).CF=ut; %Hz, but resonds to WN
cells(i).Vout=nan; %mV
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %noisy, rhythmic bursts
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WN'; %WN with laser on/off, no effect
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

i=i+1;
cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='003';
cells(i).depth=325; %micrometers
cells(i).internalSolution='nan'; %
cells(i).A1=n;
cells(i).CF=ut; %Hz
cells(i).Vout=nan; %mV
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %noisy
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WN'; %WN with laser on/off, no effect
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

i=i+1;
cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='004';
cells(i).depth=203; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=ut; %Hz, responds to WN
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %noisy
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WN'; %WN with laser on/off, 
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

i=i+1;
cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='005';
cells(i).depth=313; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=ut; %Hz, responds to WN
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WN'; %WN with laser on/off, 
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3
i=i+1;

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='006';
cells(i).depth=394; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=ut; %Hz, responded to WN 
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WN'; %WN with laser on/off, 
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='007';
cells(i).depth=210; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=ut; %Hz, responded to WN strongly
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WN'; %WN with laser on/off, 
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='008';
cells(i).depth=119; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=7000; %Hz, broadly tuned
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %8, 16 KHz with laser on/off, 
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='008';%different site
cells(i).depth=149; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=10000; %Hz, broadly tuned
cells(i).filenum(1,:)='003'; %
cells(i).description{1}='TC'; %
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %10, 15, 20 KHz with laser on/off, 
cells(i).mode{2}='mu','lfp';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091713';
cells(i).session='009';% previous site
cells(i).depth=149; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=y;
cells(i).CF=11000; %Hz, broadly tuned
cells(i).filenum(1,:)='002'; %
cells(i).description{1}='TC'; % short 50 ms tones with laser on/off from 5-40 kHz
cells(i).mode{1}='mu';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091913';
cells(i).session='005';
cells(i).depth=197; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=ut; %Hz, broadly tuned
cells(i).filenum(1,:)='003'; %
cells(i).description{1}='NBN'; % 14 khz
cells(i).mode{1}='su';
cells(i).filenum(2,:)='011';
cells(i).description{2}='NBN'; % increased off responses?
cells(i).mode{2}='su';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='091913';
cells(i).session='006';
cells(i).depth=268; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=10000; %Hz, 
cells(i).filenum(1,:)='002'; %
cells(i).description{1}='TC'; %
cells(i).mode{1}='su';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; % 10 Khz
cells(i).mode{2}='su';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='092013';
cells(i).session='001';
cells(i).depth=277; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=6000; %Hz, 
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; % 
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; % no effect
cells(i).mode{2}='mu';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='092013';
cells(i).session='002';
cells(i).depth=352; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=4000; %Hz, 
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; % 
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; % no effect
cells(i).mode{2}='mu';
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; % WN, to see if laser was working
cells(i).mode{3}='mu';
cells(i).extra1
cells(i).extra2
cells(i).extra3

cells(i).user='ira';
cells(i).rig='rig1';
cells(i).expdate='092013';
cells(i).session='004';
cells(i).depth=360; %micrometers
cells(i).internalSolution='nan'; %
cells(i).Vout=nan; %mV
cells(i).A1=n;
cells(i).CF=7000; %Hz, 
cells(i).filenum(1,:)='001'; %
cells(i).description{1}='TC'; %
cells(i).mode{1}='mu','lfp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; % 7khz at different sound levels
cells(i).mode{2}='mu';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; % short 50 ms sounds
cells(i).mode{3}='mu';
cells(i).extra1
cells(i).extra2
cells(i).extra3
