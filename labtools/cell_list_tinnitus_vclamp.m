function cells=cell_list_tinnitus_vclamp
% cell list for whole cell v-clamp data for tinnitus project
% first pre TC is in i=0 mode (to establish CF), second is in v-clamp mode
% trauma is presented at 0.5 octave below CF

% last update: 03/08/10

i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='030510';
cells(i).session='001';
cells(i).depth=184; %micrometers
cells(i).CF=11300; %Hz
cells(i).trauma_freq=7990; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= unknown; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='009';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='011';
cells(i).description{3}='post 1 min';
cells(i).filenum(4,:)='012';
cells(i).description{4}='post 9 min';
cells(i).filenum(5,:)='013';
cells(i).description{5}='post 18 min';
cells(i).filenum(6,:)='014';
cells(i).description{6}='post 26 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='030310';
cells(i).session='001';
cells(i).depth=365; %micrometers
cells(i).CF=13500; %Hz
cells(i).trauma_freq=9546; %Hz
cells(i).trauma_level=113; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= +0.3; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='008';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='post 2 min';
cells(i).filenum(4,:)='011';
cells(i).description{4}='post 11 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='030210';
cells(i).session='001';
cells(i).depth=150; %micrometers
cells(i).CF=19000; %Hz
cells(i).trauma_freq=13435; %Hz
cells(i).trauma_level=115; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= -9.4; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='010';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='011';
cells(i).description{3}='post 1 min';
cells(i).filenum(4,:)='012';
cells(i).description{4}='post 13 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='020810';
cells(i).session='001';
cells(i).depth=244; %micrometers
cells(i).CF=13500; %Hz
cells(i).trauma_freq=9546; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= +10; %mV
cells(i).filenum(1,:)='012';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='013';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='014'; %cell opened up, recording much improved
cells(i).description{3}='post 1 min';
cells(i).filenum(4,:)='015';
cells(i).description{4}='post 10 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='012910';
cells(i).session='001';
cells(i).depth=497; %micrometers
cells(i).CF=22600; %Hz
cells(i).trauma_freq=15981; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= +7; %mV
cells(i).filenum(1,:)='019';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='020';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='022';
cells(i).description{3}='post 3 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='012810';
cells(i).session='001';
cells(i).depth=350; %micrometers
cells(i).CF=19000; %Hz
cells(i).trauma_freq=13435; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= unknown; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='post 1 min';
cells(i).filenum(4,:)='007';
cells(i).description{4}='post 10 min';
cells(i).filenum(5,:)='008';
cells(i).description{5}='post 20 min';
cells(i).filenum(6,:)='009';
cells(i).description{6}='post 30 min';
cells(i).filenum(7,:)='010';
cells(i).description{7}='post 40 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='011510';
cells(i).session='001';
cells(i).depth=146; %micrometers
cells(i).CF=22600; %Hz
cells(i).trauma_freq=15981; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= unknown; %mV
cells(i).filenum(1,:)='005';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='007';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='008';
cells(i).description{3}='post 1 min';
cells(i).filenum(4,:)='009';
cells(i).description{4}='post 10 min';
cells(i).filenum(5,:)='010';
cells(i).description{5}='post 20 min';
cells(i).filenum(6,:)='011';
cells(i).description{6}='post 28 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='011410';
cells(i).session='001';
cells(i).depth=224; %micrometers
cells(i).CF=19000; %Hz
cells(i).trauma_freq=13455; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= +6; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='008';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='009';
cells(i).description{3}='post 1 min';


i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='120309';
cells(i).session='001';
cells(i).depth=263; %micrometers
cells(i).CF=11700; %Hz
cells(i).trauma_freq=8270; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= -14; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='009';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='013';
cells(i).description{3}='post 7 min';
cells(i).filenum(4,:)='014';
cells(i).description{4}='post 18 min';
cells(i).filenum(5,:)='015';
cells(i).description{5}='post 25 min';

i=0;
i=i+1;
cells(i).user='xg';
cells(i).mode='i=0/vclamp';
cells(i).expdate='112409';
cells(i).session='001';
cells(i).depth=168; %micrometers
cells(i).CF=9700; %Hz
cells(i).trauma_freq=6860; %Hz
cells(i).trauma_level=110; %dB
cells(i).trauma_dur=1; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).Vout= unknown; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='pre i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='pre vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='post 1 min';
cells(i).filenum(4,:)='007';
cells(i).description{4}='post 8 min';
cells(i).filenum(5,:)='008';
cells(i).description{5}='post 15 min';
cells(i).filenum(6,:)='009';
cells(i).description{6}='post 23 min';