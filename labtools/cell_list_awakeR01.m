function cells=cell_list_awakeR01
%cell list for awake rat project- RO1.
% **mode should be one of: 'i=0', 'vclamp', 'iclamp', 'lca', 'mua', 'lfp'
% **iext indicates the current injected in 'iclamp' mode. If iext line does
% not exist for a data file, assume iext=0
% **anesthetized indicates whether cell was from anesthetized control
% animal. If line does not exist, assume awake animal
% **description should be one of: 'WNtrain'- click trains with varing isi
%                                 'WNlong'-2s WN with 2s isi
%                                 'WNfast'-clicktrains with short click
%                                  durations and low isi (0.25ms)
%                                 'Pulsetrain'-fast trains with WN pulses instead of clicks   
%                                 'TC'-regular tuning curve
%                                 'Tonelong'-2s CF tone with 2s isi
% **'nan' indicates an unknown value
%last update:08/03/2011 XG

i=0;
i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='120710';
cells(i).session='001';
cells(i).animalID='1246.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=109; %micrometers
cells(i).Vout=-14; %mV unknown
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='iclamp';
cells(i).iext{2}=-206; %pA

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='120710';
cells(i).session='002';
cells(i).animalID='1246.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=89; %micrometers
cells(i).Vout=0; %mV unknown
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='120710';
cells(i).session='002';
cells(i).animalID='1246.1-3';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=123; %micrometers
cells(i).Vout=7.5; %mV
cells(i).filenum(1,:)='005'; %cell fell off partway through
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='122010';
cells(i).session='001';
cells(i).animalID='1250.1-4';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=125; %micrometers
cells(i).Vout=3.3; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='122010';
cells(i).session='002';
cells(i).animalID='1250.1-4';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=68; %micrometers
cells(i).Vout=-33; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg'; %nonsync
cells(i).rig='rig1';
cells(i).expdate='011011';
cells(i).session='001';
cells(i).animalID='1253.1-3';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=94; %micrometers
cells(i).Vout=7.7; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='007';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=-60; %pA

i=i+1;
cells(i).user='xg'; %nonsync
cells(i).rig='rig1';
cells(i).expdate='011211';
cells(i).session='001';
cells(i).animalID='1253.1-8';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=105; %micrometers
cells(i).Vout=-15; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='011311';
cells(i).session='001';
cells(i).animalID='1253.1-10';
cells(i).age=28; %post-natal days
cells(i).diazepam=1;
cells(i).depth=98; %micrometers
cells(i).Vout=3.3; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='011311';
cells(i).session='003';
cells(i).animalID='1253.1-10';
cells(i).age=28; %post-natal days
cells(i).diazepam=1;
cells(i).depth=138; %micrometers
cells(i).Vout=-12; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='011811';
cells(i).session='001';
cells(i).animalID='1255.1-3';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=75; %micrometers
cells(i).Vout=8; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='011811';
cells(i).session='002';
cells(i).animalID='1255.1-3';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=102; %micrometers
cells(i).Vout=8; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg'; %huge off-responses
cells(i).rig='rig1';
cells(i).expdate='011911';
cells(i).session='001';
cells(i).animalID='1255.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=57; %micrometers
cells(i).Vout=-7.8;
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';%nonsync
cells(i).rig='rig1';
cells(i).expdate='012411';
cells(i).session='001';
cells(i).animalID='1256.1-8';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=43; %micrometers
cells(i).Vout=0; %mV unknown
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%sync
cells(i).rig='rig1';
cells(i).expdate='012411';
cells(i).session='002';
cells(i).animalID='1256.1-8';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=189; %micrometers
cells(i).Vout=20; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';%responsive?
cells(i).rig='rig1';
cells(i).expdate='012411';
cells(i).session='004';
cells(i).animalID='1256.1-8';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=48; %micrometers
cells(i).Vout=50; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%nonsync
cells(i).rig='rig1';
cells(i).expdate='012511';
cells(i).session='001';
cells(i).animalID='1256.1-9';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=112; %micrometers
cells(i).Vout=3.6; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%i=0 only
cells(i).rig='rig1';
cells(i).expdate='012511';
cells(i).session='002';
cells(i).animalID='1256.1-9';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=103; %micrometers
cells(i).Vout=0; %mV unknown
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';%nonsync?
cells(i).rig='rig1';
cells(i).expdate='013111';
cells(i).session='001';
cells(i).animalID='1257.1-8';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=96; %micrometers
cells(i).Vout=6.5; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='013111';
cells(i).session='002';
cells(i).animalID='1257.1-8';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=114; %micrometers
cells(i).Vout=0; %mV unknown
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%animal restless, cell seems wn responsive, 2 VC files
cells(i).rig='rig1';
cells(i).expdate='020811';
cells(i).session='003';
cells(i).animalID='1259.1-7';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=128; %micrometers
cells(i).Vout=11; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='004';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg';%nonsync
cells(i).rig='rig1';
cells(i).expdate='020911';
cells(i).session='001';
cells(i).animalID='1259.1-8';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=120; %micrometers
cells(i).Vout=-16; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';%nonsync
cells(i).rig='rig1';
cells(i).expdate='020911';
cells(i).session='002';
cells(i).animalID='1259.1-8';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=94; %micrometers
cells(i).Vout=0; %mV unknown
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='020911';
cells(i).session='004';
cells(i).animalID='1259.1-8';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=180; %micrometers
cells(i).Vout=6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%sync
cells(i).rig='rig1';
cells(i).expdate='021411';
cells(i).session='001';
cells(i).animalID='1260.2-2';
cells(i).age=25; %post-natal days
cells(i).diazepam=1;
cells(i).depth=81; %micrometers
cells(i).Vout=-18; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='iclamp';
cells(i).iext{2}=0; %pA unknown
cells(i).filenum(3,:)='006';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';%i=0 only
cells(i).rig='rig1';
cells(i).expdate='021511';
cells(i).session='001';
cells(i).animalID='1260.2-3';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=nan; %micrometers
cells(i).Vout=0; %mV unknown
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='021511';
cells(i).session='002';
cells(i).animalID='1260.2-3';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=24; %micrometers
cells(i).Vout=7; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';%nonsync
cells(i).rig='rig1';
cells(i).expdate='021611';
cells(i).session='001';
cells(i).animalID='1260.2-2';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=134; %micrometers
cells(i).Vout=7; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='021611';
cells(i).session='002';
cells(i).animalID='1260.2-2';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=37; %micrometers
cells(i).Vout=-1.6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';%lots of motion artifact
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='022811';
cells(i).session='001';
cells(i).animalID='1263.1-2';
cells(i).age=25; %post-natal days
cells(i).diazepam=0;
cells(i).depth=117; %micrometers
cells(i).Vout=18; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='004';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';%sync?
cells(i).rig='rig1';
cells(i).expdate='030111';
cells(i).session='001';
cells(i).animalID='1263.1-3';
cells(i).age=26; %post-natal days
cells(i).diazepam=1;
cells(i).depth=200; %micrometers
cells(i).Vout=19; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%sync
cells(i).rig='rig1';
cells(i).expdate='030111';
cells(i).session='002';
cells(i).animalID='1263.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=1;
cells(i).depth=139; %micrometers
cells(i).Vout=7; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%lots of motion artifact
cells(i).rig='rig1';
cells(i).expdate='030311';
cells(i).session='001';
cells(i).animalID='1263.1-4';
cells(i).age=28; %post-natal days
cells(i).diazepam=0;
cells(i).depth=145; %micrometers
cells(i).Vout=19; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%lots of motion artifact, 2 VCs
cells(i).rig='rig1';
cells(i).expdate='030311';
cells(i).session='002';
cells(i).animalID='1263.1-4';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=100; %micrometers
cells(i).Vout=10; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg';%lots of motion artifact (chewing)
cells(i).rig='rig1';
cells(i).expdate='030311';
cells(i).session='003';
cells(i).animalID='1263.1-4';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=99; %micrometers
cells(i).Vout=10; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%lots of motion artifact (chewing)
cells(i).rig='rig1';
cells(i).expdate='030311';
cells(i).session='004';
cells(i).animalID='1263.1-4';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=88; %micrometers
cells(i).Vout=3.2; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='030811';
cells(i).session='001';
cells(i).animalID='1266.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=284; %micrometers
cells(i).Vout=-17; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='007';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='030911';
cells(i).session='001';
cells(i).animalID='1266.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=150; %micrometers
cells(i).Vout=0.6; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='iclamp';
cells(i).iext{2}=nan;

i=i+1;
cells(i).user='xg';%sync?
cells(i).rig='rig1';
cells(i).expdate='030911';
cells(i).session='002';
cells(i).animalID='1266.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=58; %micrometers
cells(i).Vout=7; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNlong';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=-169;%pA
cells(i).filenum(4,:)='004';
cells(i).description{4}='WNlong';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=-169;%pA

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='030911';
cells(i).session='003';
cells(i).animalID='1266.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=324; %micrometers
cells(i).Vout=-4; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

i=i+1;
cells(i).user='xg';%spikes!
cells(i).rig='rig1';
cells(i).expdate='031511';
cells(i).session='001';
cells(i).animalID='1268.1-1';
cells(i).age=25; %post-natal days
cells(i).diazepam=0;
cells(i).depth=202; %micrometers
cells(i).Vout=2; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=-144;%pA
cells(i).filenum(4,:)='006';
cells(i).description{4}='WNlong';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=-144;%pA

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='031511';
cells(i).session='002';
cells(i).animalID='1268.1-1';
cells(i).age=25; %post-natal days
cells(i).diazepam=0;
cells(i).depth=nan; %micrometers
cells(i).Vout=nan; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='031811';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=22; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=139; %micrometers
cells(i).Vout=0.6; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='008';
cells(i).description{3}='WNlong';
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='006';%Vm~-50
cells(i).description{4}='WNlong';
cells(i).mode{4}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='031811';
cells(i).session='002';
cells(i).animalID=nan;
cells(i).age=22; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=221; %micrometers
cells(i).Vout=2.3; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNlong';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='004';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032111';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=25; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=131; %micrometers
cells(i).Vout=3.2; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='008';%Vm~-50
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='009';
cells(i).description{3}='WNlong';
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='010';%Vm~-20
cells(i).description{4}='WNlong';
cells(i).mode{4}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032111';
cells(i).session='002';
cells(i).animalID=nan;
cells(i).age=25; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=124; %micrometers
cells(i).Vout=4.6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='004';
cells(i).description{3}='WNlong';
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='005';
cells(i).description{4}='WNlong';
cells(i).mode{4}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032211';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=232; %micrometers
cells(i).Vout=12; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='008';
cells(i).description{3}='WNlong';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032211';
cells(i).session='002';
cells(i).animalID=nan;
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=178; %micrometers
cells(i).Vout=6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';%only took 2 reps by accident, so took 2nd i=0 file
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032211';
cells(i).session='003';
cells(i).animalID=nan;
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=223; %micrometers
cells(i).Vout=1.3; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNlong';
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='004';
cells(i).description{4}='WNlong';
cells(i).mode{4}='i=0';
cells(i).filenum(5,:)='005';
cells(i).description{5}='TC';%CF=6.7
cells(i).mode{5}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032211';
cells(i).session='004';
cells(i).animalID=nan;
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=87; %micrometers
cells(i).Vout=3; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='004';
cells(i).description{3}='WNlong';
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='005';
cells(i).description{4}='WNlong';
cells(i).mode{4}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032311';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=198; %micrometers
cells(i).Vout=2; %mV
cells(i).filenum(1,:)='006';%poor vcontrol at +50. Can't see anything, but responsive as reflected in e currents
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';

%data not really usable for this cell -mike
% i=i+1;
% cells(i).user='xg';%fluctuating Vm? Hard to see any responses, usable data?
% cells(i).rig='rig1';
% cells(i).expdate='032311';
% cells(i).session='002';
% cells(i).animalID=nan;
% cells(i).age=27; %post-natal days
% cells(i).diazepam=0;
% cells(i).anesthetized=1;
% cells(i).depth=92; %micrometers
% cells(i).Vout=1.2; %mV
% cells(i).filenum(1,:)='001';
% cells(i).description{1}='WNtrain';
% cells(i).mode{1}='vclamp';
% cells(i).filenum(2,:)='002';
% cells(i).description{2}='WNtrain';
% cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032311';
cells(i).session='004';
cells(i).animalID=nan;
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=73; %micrometers
cells(i).Vout=2; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032411';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=21; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=137; %micrometers
cells(i).Vout=-2.2; %mV
cells(i).filenum(1,:)='005';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='006';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='007';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=262; %pA

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032411';
cells(i).session='002';
cells(i).animalID=nan;
cells(i).age=21; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=129; %micrometers
cells(i).Vout=3.2; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=164; %pA

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032411';
cells(i).session='003';
cells(i).animalID=nan;
cells(i).age=21; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=108; %micrometers
cells(i).Vout=-2.2; %mV
cells(i).filenum(1,:)='001';%great!
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=205; %pA
cells(i).filenum(4,:)='004';
cells(i).description{4}='TC'; %CF=6.7
cells(i).mode{4}='i=0';
cells(i).filenum(5,:)='005';
cells(i).description{5}='Tonelong';%6.7kHz
cells(i).mode{5}='i=0';

i=i+1;
cells(i).user='xg';%evoked responses?
cells(i).rig='rig1';
cells(i).expdate='041211';
cells(i).session='001';
cells(i).animalID='1273.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=258; %micrometers
cells(i).Vout=2.1; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';%messy spikes
cells(i).rig='rig1';
cells(i).expdate='041311';
cells(i).session='001';
cells(i).animalID='1273.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=163; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='041311';
cells(i).session='002';
cells(i).animalID='1273.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=114; %micrometers
cells(i).Vout=18; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='041311';
cells(i).session='002';
cells(i).animalID='1273.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=154; %micrometers
cells(i).Vout=2.1; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='041811';
cells(i).session='001';
cells(i).animalID='1275.1-1';
cells(i).age=25; %post-natal days
cells(i).diazepam=0;
cells(i).depth=193; %micrometers
cells(i).Vout=7.4; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=118; %pA

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='041911';
cells(i).session='001';
cells(i).animalID='1275.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=76; %micrometers
cells(i).Vout=4.6; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='041911';
cells(i).session='002';
cells(i).animalID='1275.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=78; %micrometers
cells(i).Vout=12; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=129; %pA
cells(i).filenum(4,:)='004';
cells(i).description{4}='WNlong';
cells(i).mode{4}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='041911';
cells(i).session='003';
cells(i).animalID='1275.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=100; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042011';
cells(i).session='001';
cells(i).animalID='1275.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=132; %micrometers
cells(i).Vout=4.6; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';%more spikes, i=0 again
cells(i).description{3}='WNtrain';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042011';
cells(i).session='002';
cells(i).animalID='1275.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=242; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042011';
cells(i).session='003';
cells(i).animalID='1275.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=176; %micrometers
cells(i).Vout=-3; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=625; %pA
cells(i).filenum(4,:)='006';%sustained response
cells(i).description{4}='WNlong';
cells(i).mode{4}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042011';
cells(i).session='003';
cells(i).animalID='1275.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=107; %micrometers
cells(i).Vout=2; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='009';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042011';
cells(i).session='004';
cells(i).animalID='1275.1-3';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=242; %micrometers
cells(i).Vout=6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNtrain';
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042111';
cells(i).session='001';
cells(i).animalID='1275.1-4';
cells(i).age=28; %post-natal days
cells(i).diazepam=0;
cells(i).depth=88; %micrometers
cells(i).Vout=8.9; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042611';
cells(i).session='001';
cells(i).animalID='1276.1-1';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=171; %micrometers
cells(i).Vout=5; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';%1.5 trials, lots of escaped spikes on later trials
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051011';
cells(i).session='001';
cells(i).animalID='1281.1-1';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=160; %micrometers
cells(i).Vout=8.4; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011';
cells(i).description{2}='WNtrain';
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051011';
cells(i).session='002';
cells(i).animalID='1281.1-1';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=140; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051711';
cells(i).session='001';
cells(i).animalID='1282.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=111; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='010';%not a complete set of trials
cells(i).description{2}='WNtrainfast';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051711';
cells(i).session='002';
cells(i).animalID='1282.1-1';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=59; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051711';
cells(i).session='003';
cells(i).animalID='1282.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=74; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051711';
cells(i).session='004';
cells(i).animalID='1282.1-2';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=169; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='052411';
cells(i).session='001';
cells(i).animalID='1283.1-4';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=240; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='052511';
cells(i).session='001';
cells(i).animalID='1283.1-5';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=140; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004';
cells(i).description{2}='WNtrainfast';
cells(i).mode{2}='iclamp';
cells(i).iext{2}=-312; %pA

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='052511';
cells(i).session='002';
cells(i).animalID='1283.1-5';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=276; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='053111';
cells(i).session='001';
cells(i).animalID='1285.1-4';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=82; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='005';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='053111';
cells(i).session='001';
cells(i).animalID='1285.1-4';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=224; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(1,:)='007';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060111';
cells(i).session='001';
cells(i).animalID='1285.1-5';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=233; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060211';
cells(i).session='001';
cells(i).animalID='1285.1-10';
cells(i).age=28; %post-natal days
cells(i).diazepam=0;
cells(i).depth=63; %micrometers
cells(i).Vout=5; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';
cells(i).filenum(1,:)='004';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(1,:)='005';
cells(i).description{1}='WNtrainfast';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060211';
cells(i).session='002';
cells(i).animalID='1285.1-10';
cells(i).age=25; %post-natal days
cells(i).diazepam=0;
cells(i).depth=88; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNtrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060811';
cells(i).session='001';
cells(i).animalID='1286.1-4';
cells(i).age=27; %post-natal days
cells(i).diazepam=0;
cells(i).depth=68; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='003';%not sustained, huge off-response
cells(i).description{1}='WNlong';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005';%poor vc
cells(i).description{2}='WNlong';
cells(i).mode{2}='vclamp';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first Pulsetrain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060911';
cells(i).session='001';
cells(i).animalID='1286.1-5';
cells(i).age=28; %post-natal days
cells(i).diazepam=0;
cells(i).depth=120; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='WNlong';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061611';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=21; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=88; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='WNlong';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061611';
cells(i).session='002';
cells(i).animalID=nan;
cells(i).age=21; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=196; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNlong';
cells(i).mode{2}='i=0';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061611';
cells(i).session='003';
cells(i).animalID=nan;
cells(i).age=21; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=206; %micrometers
cells(i).Vout=6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNlong';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNlong';
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061611';
cells(i).session='004';
cells(i).animalID=nan;
cells(i).age=21; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=126; %micrometers
cells(i).Vout=8; %mV
cells(i).filenum(1,:)='001';%woken up?
cells(i).description{1}='WNlong';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNlong';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='Pulsetrain';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061711';
cells(i).session='001';
cells(i).animalID='1288.1-6';
cells(i).age=29; %post-natal days
cells(i).diazepam=0;
cells(i).depth=49; %micrometers
cells(i).Vout=20; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='WNlong';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='009';
cells(i).description{2}='WNlong';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='010';
cells(i).description{3}='Pulsetrain';
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='011';
cells(i).description{4}='Pulsetrain';
cells(i).mode{4}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061711';
cells(i).session='002';
cells(i).animalID='1288.1-6';
cells(i).age=29; %post-natal days
cells(i).diazepam=0;
cells(i).depth=154; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';%not sustained
cells(i).description{1}='WNlong';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='071911';
cells(i).session='001';
cells(i).animalID='1295.1-1';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=79; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='071911';
cells(i).session='002';
cells(i).animalID='1295.1-1';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=76; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='071911';
cells(i).session='003';
cells(i).animalID='1295.1-1';
cells(i).age=26; %post-natal days
cells(i).diazepam=0;
cells(i).depth=70; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='WNlong';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='WNlong';
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='ag';
cells(i).rig='rig1';
cells(i).expdate='072711';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=20; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=119; %micrometers
cells(i).Vout=2; %mV
cells(i).filenum(1,:)='011';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='013';
cells(i).description{2}='Pulsetrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='014';
cells(i).description{3}='TC'; %CF 19kHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='015';
cells(i).description{4}='Tonelong';%1 amplitude
cells(i).mode{4}='i=0';
cells(i).filenum(5,:)='016';
cells(i).description{5}='Tonelong';%3 amplitudes (20-70dB)
cells(i).mode{5}='i=0';

i=i+1;
cells(i).user='ag';
cells(i).rig='rig1';
cells(i).expdate='072711';
cells(i).session='002';
cells(i).animalID=nan;
cells(i).age=20; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=57; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='TC';%CF 16kHz
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='Tonelong';
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='ag';
cells(i).rig='rig1';
cells(i).expdate='072911';
cells(i).session='001';
cells(i).animalID=nan;
cells(i).age=22; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=161; %micrometers
cells(i).Vout=3; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='Pulsetrain';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='008';
cells(i).description{3}='TC'; %CF 19kHz
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='ag';
cells(i).rig='rig1';
cells(i).expdate='072911';
cells(i).session='002';
cells(i).animalID=nan;
cells(i).age=22; %post-natal days
cells(i).diazepam=0;
cells(i).anesthetized=1;
cells(i).depth=163; %micrometers
cells(i).Vout=0; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='Pulsetrain';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='TC';
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='WNlong';
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='004';
cells(i).description{4}='Tonelong';
cells(i).mode{4}='i=0';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%end Xiang's Data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

