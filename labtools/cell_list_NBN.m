function cells=cell_list_NBN
% cell list for narrow band noise project.
% **"A1" refers to whether recording was taken from A1, as estabilished by
% tonotopic gradient and tuning curve. y= yes, n= no, m= maybe
% **mode should be one of: 'i=0', 'vclamp', 'iclamp', 'lca', 'mua', 'lfp'
% **iext indicates the current injected in 'iclamp' mode. If iext line does
% not exist for a data file, assume iext=0
% **mouse indicates whether cell was from a mouse with 1=mouse, 0=not mouse
% (rat). If mouse line does not exist, assume mouse=0
% **transline indicates transgenetic line of mouse
% **'NAN' indicates an unknown value
%last update: 11/19/2010
%

y='yes';
n='no';
m='maybe';

i=0;
i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='032410';
cells(i).session='001';
cells(i).depth=307; %micrometers
cells(i).A1=y;
cells(i).CF=4000; %Hz
cells(i).Vout=4.6; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='TC'; %CF=4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %2KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005';
cells(i).description{3}='NBN'; %4KHz
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='041610';
cells(i).session='001';
cells(i).depth=136; %micrometers
cells(i).A1=n; %likely AAF
cells(i).CF=6700; %Hz
cells(i).Vout=2.4; %mV
cells(i).filenum(1,:)='012';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='013';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='014';
cells(i).description{3}='NBN'; %2KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='015';
cells(i).description{4}='NBN'; %9.5KHz
cells(i).mode{4}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042110';
cells(i).session='001';
cells(i).depth=184; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=-15; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
%cells(i).filenum(2,:)='004';
%cells(i).description{2}='NBN'; %2.8KHz
%cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='vclamp';
%cells(i).filenum(4,:)='006';
%cells(i).description{4}='NBN'; %2KHz
%cells(i).mode{4}='vclamp';

% i=i+1;
% cells(i).user='xg';
% cells(i).rig='rig1';
% cells(i).expdate='042110';
% cells(i).session='002';
% cells(i).depth=240; %micrometers
% cells(i).A1=n;
% cells(i).CF=2000; %Hz, double peak at 19 KHz?
% cells(i).Vout=10; %mV
% cells(i).filenum(1,:)='002';
% cells(i).description{1}='TC';
% cells(i).mode{1}='i=0';
% cells(i).filenum(2,:)='004';
% cells(i).description{2}='TC';
% cells(i).filenum(3,:)='005';
% cells(i).description{3}='NBN'; %6.7KHz
% cells(i).mode{3}='vclamp';
% cells(i).filenum(4,:)='006';
% cells(i).description{4}='NBN'; %19KHz
% cells(i).mode{4}='vclamp';
% cells(i).filenum(5,:)='007';
% cells(i).description{5}='NBN'; %2KHz
% cells(i).mode{5}='vclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042210';
cells(i).session='001';
cells(i).depth=570; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=-1; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %4.8KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='007';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042610';
cells(i).session='001';
cells(i).depth=236; %micrometers
cells(i).A1=y;
cells(i).CF=8000; %Hz
cells(i).Vout=2; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011';
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %3.4KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='013';
cells(i).description{4}='NBN'; %11.3KHz
cells(i).mode{4}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042610';
cells(i).session='002';
cells(i).depth=170; %micrometers
cells(i).A1=y;
cells(i).CF=11300; %Hz
cells(i).Vout=-7.5; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='042810';
cells(i).session='001';
cells(i).depth=92; %micrometers
cells(i).A1=m;
cells(i).CF=4000; %Hz
cells(i).Vout=-16; %mV
cells(i).filenum(1,:)='005';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='006';
cells(i).description{2}='NBN'; %4KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='007';
cells(i).description{3}='NBN'; %2KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %6.7KHz
cells(i).mode{4}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='043010';
cells(i).session='001';
cells(i).depth=176; %micrometers
cells(i).A1=m;
cells(i).CF=2000; %Hz
cells(i).Vout=3; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011';
cells(i).description{2}='NBN'; %2KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %4KHz
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='050310';
cells(i).session='001';
cells(i).depth=214; %micrometers
cells(i).A1=n;
cells(i).CF=4000; %Hz
cells(i).Vout=5.6; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='009';
cells(i).description{2}='NBN'; %4KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='NBN'; %2KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='011';
cells(i).description{4}='NBN'; %5.7KHz
cells(i).mode{4}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='050410';
cells(i).session='001';
cells(i).depth=252; %micrometers
cells(i).A1=y;
cells(i).CF=4000; %Hz
cells(i).Vout=3.2; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC';
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='050410';
cells(i).session='002';
cells(i).depth=213; %micrometers
cells(i).A1=y;
cells(i).CF=11300; %Hz
cells(i).Vout=4; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='vclamp';


i=i+1;
cells(i).user='xg'; %Cell attached TC was also taken for this cell. Did not take cell attached NBN data.
cells(i).rig='rig1';
cells(i).expdate='050610';
cells(i).session='001';
cells(i).depth=396; %micrometers
cells(i).A1=n;
cells(i).CF=4000; %Hz
cells(i).Vout=1.5; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='006';
cells(i).description{2}='NBN'; %4KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='007';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='010';
cells(i).description{5}='NBN'; %6.7KHz
cells(i).mode{5}='vclamp';


% i=i+1;
% cells(i).user='xg';
% cells(i).rig='rig1';
% cells(i).expdate='050610';
% cells(i).session='002';
% cells(i).depth=210; %micrometers
% cells(i).CF=4000; %Hz
% cells(i).Vout=-3.5; %mV
% cells(i).filenum(1,:)='005';
% cells(i).description{1}='TC';
% cells(i).mode{1}='vclamp';
% cells(i).filenum(2,:)='007';
% cells(i).description{2}='NBN'; %4.8KHz
% cells(i).mode{2}='vclamp';
% cells(i).filenum(3,:)='008';
% cells(i).description{3}='NBN'; %2KHz
% cells(i).mode{3}='vclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051110';
cells(i).session='001';
cells(i).depth=223; %micrometers
cells(i).A1=y;
cells(i).CF=4000; %Hz
cells(i).Vout=0.7; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='010';
cells(i).description{2}='NBN'; %4KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='011';
cells(i).description{3}='NBN'; %2KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='012';
cells(i).description{4}='NBN'; %4.8KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='013';
cells(i).description{5}='NBN'; %4.8KHz
cells(i).mode{5}='vclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051110';
cells(i).session='001';
cells(i).depth=307; %micrometers
cells(i).A1=y;
cells(i).CF=4000; %Hz
cells(i).Vout=0.3; %mV
cells(i).filenum(1,:)='016';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='018';
cells(i).description{2}='NBN'; %4KHz
cells(i).mode{2}='vclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051110';
cells(i).session='001';
cells(i).depth=163; %micrometers
cells(i).A1=y;
cells(i).CF=4800; %Hz
cells(i).Vout=-3.8; %mV
cells(i).filenum(1,:)='021';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='022';
cells(i).description{2}='NBN'; %4.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='024';
cells(i).description{3}='NBN'; %4.8KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='026';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='028';
cells(i).description{5}='NBN'; %1.7KHz
cells(i).mode{5}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051210';
cells(i).session='001';
cells(i).depth=579; %micrometers
cells(i).A1=y;
cells(i).CF=6700; %Hz
cells(i).Vout=-6.7; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='008';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='051810';
cells(i).session='001';
cells(i).depth=78; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=-13; %mV
cells(i).filenum(1,:)='012';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='013';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='015';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='016';
cells(i).description{4}='NBN'; %4KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='017';
cells(i).description{5}='NBN'; %4KHz
cells(i).mode{5}='iclamp';
cells(i).filenum(6,:)='018';
cells(i).description{6}='NBN'; %1.7KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='019';
cells(i).description{7}='NBN'; %1.7KHz
cells(i).mode{7}='iclamp';
cells(i).filenum(8,:)='020';
cells(i).description{8}='NBN'; %2.8KHz, again
cells(i).mode{8}='vclamp';
cells(i).filenum(9,:)='021';
cells(i).description{9}='NBN'; %2.8KHz, again
cells(i).mode{9}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='052110';
cells(i).session='001';
cells(i).depth=280; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=3; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='008';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='009';
cells(i).description{4}='NBN'; %4KHz, no iclamp data on this freq.
cells(i).mode{4}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='052410';
cells(i).session='001';
cells(i).depth=128; %micrometers
cells(i).A1=n;
cells(i).CF=1700; %Hz
cells(i).Vout=5.3; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='011';
cells(i).description{2}='NBN'; %1.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %1.7KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='014';
cells(i).description{4}='NBN'; %2.8KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='015';
cells(i).description{5}='NBN'; %2.8KHz
cells(i).mode{5}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='052510';
cells(i).session='001';
cells(i).depth=613; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=8.7; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='008';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='009';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='010';
cells(i).description{4}='NBN'; %2KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='011';
cells(i).description{5}='NBN'; %2KHz
cells(i).mode{5}='iclamp';
cells(i).filenum(6,:)='012';
cells(i).description{6}='NBN'; %8KHz, no iclamp data
cells(i).mode{6}='vclamp';


i=i+1;
cells(i).user='xg';%good cell
cells(i).rig='rig1';
cells(i).expdate='052510';
cells(i).session='002';
cells(i).depth=297; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=3.9; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='007';
cells(i).description{3}='NBN'; %5.7KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %2.8KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='009';
cells(i).description{5}='NBN'; %2.8KHz
cells(i).mode{5}='iclamp';
cells(i).filenum(6,:)='011';
cells(i).description{6}='NBN'; %1.7KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='012';
cells(i).description{7}='NBN'; %1.7KHz
cells(i).mode{7}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='052610';
cells(i).session='001';
cells(i).depth=93; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=-1.3; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='008';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='009';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='011';
cells(i).description{4}='NBN'; %6.7KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='012';
cells(i).description{5}='NBN'; %2.8KHz
cells(i).mode{5}='iclamp';
cells(i).filenum(6,:)='013';
cells(i).description{6}='NBN'; %1.7KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='014';
cells(i).description{7}='NBN'; %1.7KHz
cells(i).mode{7}='iclamp';


i=i+1;
cells(i).user='xg'; %great cell!
cells(i).rig='rig1';
cells(i).expdate='052910';
cells(i).session='001';
cells(i).depth=266; %micrometers
cells(i).A1=y;
cells(i).CF=5700; %Hz
cells(i).Vout=-1.2; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %5.7KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %9.5KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='009';
cells(i).description{5}='NBN'; %9.5KHz
cells(i).mode{5}='iclamp';


i=i+1;
cells(i).user='xg';%good cell
cells(i).rig='rig1';
cells(i).expdate='052910';
cells(i).session='002';
cells(i).depth=653; %micrometers
cells(i).A1=y;
cells(i).CF=13500; %Hz
cells(i).Vout=-1.8; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='006';
cells(i).description{4}='NBN'; %13.5KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='007';
cells(i).description{5}='NBN'; %13.5KHz
cells(i).mode{5}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060310';
cells(i).session='001';
cells(i).depth=214; %micrometers
cells(i).A1=y;
cells(i).CF=5700; %Hz
cells(i).Vout=0.1; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='009';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='NBN'; %5.7KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='011';
cells(i).description{4}='NBN'; %6.7KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='012';
cells(i).description{5}='NBN'; %6.7KHz
cells(i).mode{5}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060410';
cells(i).session='001';
cells(i).depth=90; %micrometers
cells(i).A1=y;
cells(i).CF=2800; %Hz
cells(i).Vout=-0.5; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC';
cells(i).mode{1}='lca';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %2.8KHz, cell eventually broke in fully in this mode
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='004';
cells(i).description{3}='TC';
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %2.8KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %2.8KHz
cells(i).mode{5}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='060410';
cells(i).session='001';
cells(i).depth=325; %micrometers
cells(i).A1=y;
cells(i).CF=8000; %Hz
cells(i).Vout=1.3; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='TC';
cells(i).mode{1}='lca';
cells(i).filenum(2,:)='010';
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='011';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='012';
cells(i).description{4}='NBN'; %8KHz
cells(i).mode{4}='iclamp';
cells(i).filenum(5,:)='013';
cells(i).description{5}='TC';
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='014';
cells(i).description{6}='NBN'; %11.3KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='015';
cells(i).description{7}='NBN'; %11.3KHz
cells(i).mode{7}='iclamp';

i=i+1;
cells(i).user='xg';%nice cell!
cells(i).rig='rig1';
cells(i).expdate='060410';
cells(i).session='002';
cells(i).depth=460; %micrometers
cells(i).A1=y;
cells(i).CF=4800; %Hz
cells(i).Vout=0.8; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %4.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %4.8KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %6.7KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %6.7KHz
cells(i).mode{5}='iclamp';
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %1.7KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %1.7KHz
cells(i).mode{7}='iclamp';

i=i+1;
cells(i).user='xg';%V-control so-so
cells(i).rig='rig1';
cells(i).expdate='060710';
cells(i).session='001';
cells(i).depth=293; %micrometers
cells(i).A1=m;
cells(i).CF=4800; %Hz
cells(i).Vout=3.3; %mV
cells(i).filenum(1,:)='014';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='015';
cells(i).description{2}='NBN'; %4.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='016';
cells(i).description{3}='NBN'; %4.8KHz
cells(i).mode{3}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061010';
cells(i).session='001';
cells(i).depth=93; %micrometers
cells(i).A1=y;
cells(i).CF=1400; %Hz
cells(i).Vout=0.5; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %1.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='008';
cells(i).description{3}='NBN'; %1.7KHz
cells(i).mode{3}='iclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='061010';
cells(i).session='002';
cells(i).depth=425; %micrometers
cells(i).A1=y;
cells(i).CF=1700; %Hz
cells(i).Vout=3.8; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %1.7KHz
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='062210';
cells(i).session='001';
cells(i).depth=210; %micrometers
cells(i).A1=y;
cells(i).CF=5700; %Hz
cells(i).Vout=-1.5; %mV
cells(i).filenum(1,:)='012';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='013';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';


i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='062210';
cells(i).session='002';
cells(i).depth=357; %micrometers
cells(i).A1=y;
cells(i).CF=2400; %Hz
cells(i).Vout=-2.6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %2.4KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %2.4KHz
cells(i).mode{3}='iclamp';

i=i+1;
cells(i).user='xg';%good cell!
cells(i).rig='rig1'; 
cells(i).expdate='062310';
cells(i).session='001';
cells(i).depth=357; %micrometers
cells(i).A1=y;
cells(i).CF=6700; %Hz
cells(i).Vout=4.6; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC';
cells(i).mode{1}='lca';%CS+ spikes, broken in
cells(i).filenum(2,:)='006';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='007';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %6.7KHz
cells(i).mode{4}='iclamp';
cells(i).filenum(5,:)='010';
cells(i).description{5}='TC';
cells(i).mode{5}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='062310';
cells(i).session='002';
cells(i).depth=154; %micrometers
cells(i).A1=y;
cells(i).CF=8000; %Hz
cells(i).Vout=8.6; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1'; 
cells(i).expdate='062610';
cells(i).session='001';
cells(i).depth=133; %micrometers
cells(i).A1=m;
cells(i).CF=1700; %Hz
cells(i).Vout=-1.3; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC';
cells(i).mode{1}='lca';%cell only spiked once during lca NBN, may not be reliable
cells(i).filenum(2,:)='008';
cells(i).description{2}='NBN'; %1.7KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='009';
cells(i).description{3}='TC';
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='010';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='iclamp';
cells(i).filenum(5,:)='011';
cells(i).description{5}='NBN'; %1.7Khz
cells(i).mode{5}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='062710';
cells(i).session='001';
cells(i).depth=75; %micrometers
cells(i).A1=n;
cells(i).CF=2000; %Hz, also 5.7, double peaked
cells(i).Vout=4; %mV
cells(i).filenum(1,:)='005';
cells(i).description{1}='TC';
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='006';
cells(i).description{2}='NBN'; %2KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='007';
cells(i).description{3}='NBN'; %2KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %5.7KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='009';
cells(i).description{5}='NBN'; %5.7KHz
cells(i).mode{5}='iclamp';
cells(i).filenum(6,:)='010';
cells(i).description{6}='NBN'; %13.5KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='013';
cells(i).description{7}='NBN'; %13.5KHz
cells(i).mode{7}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='001';
cells(i).depth=305; %micrometers
cells(i).A1=y;
cells(i).CF=5700; %Hz
cells(i).Vout=5.5; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='009';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='NBN'; %4KHz
cells(i).mode{3}='iclamp';
cells(i).filenum(4,:)='011';
cells(i).description{4}='NBN'; %13.5KHz
cells(i).mode{4}='vclamp';
cells(i).filenum(5,:)='012';
cells(i).description{5}='NBN'; %4KHz
cells(i).mode{5}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='002';
cells(i).depth=335; %micrometers
cells(i).A1=y;
cells(i).CF=26900; %Hz
cells(i).Vout=-0.1; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC'; %CF=26.9
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %26.9KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %26.9KHz
cells(i).mode{3}='iclamp';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='071510';
cells(i).session='001';
cells(i).depth=263; %micrometers
cells(i).A1=y;
cells(i).CF=6700; %Hz
cells(i).Vout=8.4; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';%great cell!
cells(i).rig='rig1';
cells(i).expdate='071510';
cells(i).session='002';
cells(i).depth=378; %micrometers
cells(i).A1=y;
cells(i).CF=6.7; %Hz
cells(i).Vout=12.8; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='i=0';%was trying to get lca but then broke in completely, some cs+ spikes
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';

i=i+1;
cells(i).user='xg';%good cell
cells(i).rig='rig1';
cells(i).expdate='071710';
cells(i).session='001';
cells(i).depth=210; %micrometers
cells(i).A1=y;
cells(i).CF=6.7; %Hz
cells(i).Vout=-0.4; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='011';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='iclamp';

i=i+1;
cells(i).user='xg';%
cells(i).rig='rig1';
cells(i).expdate='071810';
cells(i).session='001';
cells(i).depth=100; %micrometers
cells(i).A1=m;
cells(i).CF=2.8; %Hz
cells(i).Vout=4.5; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC'; %CF=2.8, tunning is not great
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='012';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='013';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='iclamp';

i=i+1;%SPIKE & vc
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='072810';
cells(i).session='001';
cells(i).depth=210; %micrometers
cells(i).A1=y;
cells(i).CF=13.5; %Hz
cells(i).Vout=-0.6; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='TC'; %CF=13.5 SPIKING DATA
cells(i).mode{1}='lca';
cells(i).filenum(2,:)='010';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='011'; %poor v control
cells(i).description{3}='NBN'; %13.5KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='013';
cells(i).description{4}='NBN'; %13.5KHz
cells(i).mode{4}='iclamp';

% Experiments after 07/30/10 used K+ internal soln

i=i+1;%SPIKE & vc
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='082010';
cells(i).session='001';
cells(i).depth=100; %micrometers
cells(i).A1=y;
cells(i).CF=11.3; %Hz
cells(i).Vout=-1; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005'; 
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='006'; %cell began spiking, stimulus evoked? Vm rose to ~-55mV (from ~-75mV previously)
cells(i).description{4}='NBN'; %11.3KHz
cells(i).mode{4}='i=0';
cells(i).filenum(5,:)='007'; %11.3KHz
cells(i).description{5}='NBN'; %13.5KHz
cells(i).mode{5}='iclamp';
cells(i).iext{5}=79; %pA

i=i+1;
cells(i).user='xg';%Spiking only
cells(i).rig='rig1';
cells(i).expdate='091310';
cells(i).session='001';
cells(i).depth=366; %micrometers
cells(i).A1=y;
cells(i).CF=2.4; %Hz
cells(i).Vout=nan; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='TC'; %CF=2.4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='009';
cells(i).description{2}='NBN'; %2.4KHz
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%Spiking only
cells(i).rig='rig1';
cells(i).expdate='091410';
cells(i).session='001';
cells(i).depth=150; %micrometers
cells(i).A1=y;
cells(i).CF=2.4; %Hz
cells(i).Vout=-2; %mV
cells(i).filenum(1,:)='011';
cells(i).description{1}='TC'; %CF=2.4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='012';
cells(i).description{2}='NBN'; %2.4KHz
cells(i).mode{2}='i=0';

i=i+1;
cells(i).user='xg';%Spiking only
cells(i).rig='rig1';
cells(i).expdate='091610';
cells(i).session='001';
cells(i).depth=100; %micrometers
cells(i).A1=y;
cells(i).CF=2.4; %Hz
cells(i).Vout=nan; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='TC'; %CF=2.4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='008';
cells(i).description{2}='NBN'; %2.4KHz
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='009';
cells(i).description{3}='NBN'; %4KHz
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='091610';
cells(i).session='001';
cells(i).depth=140; %micrometers
cells(i).A1=y;
cells(i).CF=2.4; %Hz
cells(i).Vout=4.6; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC'; %CF=2.4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011'; % cell is spiking
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';%spiking!
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='013';
cells(i).description{4}='TC'; %retook to get cleaner TC, CF:2.4
cells(i).mode{4}='i=0';

i=i+1;
cells(i).user='xg';%Spiking only
cells(i).rig='rig1';
cells(i).expdate='092310';
cells(i).session='001';
cells(i).depth=nan; %micrometers
cells(i).A1=y;
cells(i).CF=1.7; %Hz
cells(i).Vout=nan; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='TC'; %CF=1.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='008';
cells(i).description{2}='NBN'; %1.7KHz
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='009';
cells(i).description{3}='NBN'; %2KHz
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';%VC & Vm
cells(i).rig='rig1';
cells(i).expdate='092810';
cells(i).session='001';
cells(i).depth=90; %micrometers
cells(i).A1=m;
cells(i).CF=4; %Hz
cells(i).Vout=-7.2; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC'; %CF=4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011';
cells(i).description{2}='NBN'; %4KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %4KHz
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';%SPIKE & vc, EXEMPLARY CELL
cells(i).rig='rig1';
cells(i).expdate='092910';
cells(i).session='001';
cells(i).depth=300; %micrometers
cells(i).A1=y;
cells(i).CF=8; %Hz
cells(i).Vout=5; %mV
cells(i).filenum(1,:)='005';
cells(i).description{1}='TC'; %CF=8
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='006'; %
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='007';%minimal spiking
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=30; %pA
cells(i).filenum(5,:)='009';
cells(i).description{5}='NBN';
cells(i).mode{5}='iclamp';
cells(i).iext{5}=60; %pA
cells(i).filenum(6,:)='010'; %
cells(i).description{6}='NBN'; %5.7KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='011';
cells(i).description{7}='NBN'; %5.7KHz
cells(i).mode{7}='i=0';
cells(i).filenum(8,:)='012';
cells(i).description{8}='NBN';
cells(i).mode{8}='iclamp';
cells(i).iext{8}=nan; %Vm = ~-40mV
cells(i).filenum(9,:)='013';%took I=0 at 5.7 kHz again
cells(i).description{9}='NBN'; %5.7KHz
cells(i).mode{9}='i=0';
cells(i).filenum(10,:)='014'; %
cells(i).description{10}='NBN'; %6.7KHz
cells(i).mode{10}='vclamp';
cells(i).filenum(11,:)='015';
cells(i).description{11}='NBN'; %6.7KHz
cells(i).mode{11}='i=0';
cells(i).filenum(12,:)='016';
cells(i).description{12}='NBN';
cells(i).mode{12}='iclamp';
cells(i).iext{12}=nan;

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='093010';
cells(i).session='001';
cells(i).depth=229; %micrometers
cells(i).A1=y;
cells(i).CF=6.7; %Hz
cells(i).Vout=-2; %mV
cells(i).filenum(1,:)='009';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011'; %
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='014';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=180; %pA
cells(i).filenum(5,:)='016';
cells(i).description{5}='NBN';
cells(i).mode{5}='iclamp';
cells(i).iext{5}=170; %pA
cells(i).filenum(6,:)='017'; %
cells(i).description{6}='NBN'; %5.7KHz
cells(i).mode{6}='iclamp';
cells(i).iext{6}=179; %pA

i=i+1;
cells(i).user='xg';%Vm & Iclamp only
cells(i).rig='rig1';
cells(i).expdate='093010';
cells(i).session='002';
cells(i).depth=100; %micrometers
cells(i).A1=y;
cells(i).CF=19; %Hz
cells(i).Vout=2.3; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=19
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='003'; %
cells(i).description{2}='NBN'; %19KHz
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %19KHz
cells(i).mode{3}='iclamp';
cells(i).iext{3}=98; %pA
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %19KHz
cells(i).mode{4}='iclamp';
cells(i).iext{4}=122; %pA

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='093010';
cells(i).session='002';
cells(i).depth=125; %micrometers
cells(i).A1=y;
cells(i).CF=6.7; %Hz
cells(i).Vout=8.2; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='009'; %
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='012';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=87; %pA
cells(i).filenum(5,:)='013'; %
cells(i).description{5}='NBN'; %2.8KHz
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='014';
cells(i).description{6}='NBN'; %2.8KHz
cells(i).mode{6}='i=0';

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='100710';
cells(i).session='002';
cells(i).depth=187; %micrometers
cells(i).A1=y;
cells(i).CF=2.8; %Hz
cells(i).Vout=-7; %mV
cells(i).filenum(1,:)='007';
cells(i).description{1}='TC'; %CF=2.8
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='009'; %
cells(i).description{2}='NBN'; %2.8KHz, cell is spiking
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='011';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=130; %pA

i=i+1;
cells(i).user='xg';%Vm & vc
cells(i).rig='rig1';
cells(i).expdate='100810';
cells(i).session='001';
cells(i).depth=231; %micrometers
cells(i).A1=y;
cells(i).CF=5.7; %Hz
cells(i).Vout=15; %mV
cells(i).filenum(1,:)='003';%yes, the file numbers are correct (3=TC, 1=Vclamp, 2=I=0)
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='001'; %
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='002';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='100810';
cells(i).session='002';
cells(i).depth=194; %micrometers
cells(i).A1=y;
cells(i).CF=8; %Hz
cells(i).Vout=3.5; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=8
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{4}='iclamp';
cells(i).iext{4}=122; %pA
cells(i).filenum(5,:)='005'; %
cells(i).description{5}='NBN'; %3.4KHz
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %3.4KHz
cells(i).mode{6}='i=0';
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{7}='iclamp';
cells(i).iext{7}=125; %pA
cells(i).filenum(8,:)='008'; %
cells(i).description{8}='NBN'; %11.3KHz
cells(i).mode{8}='vclamp';
cells(i).filenum(9,:)='009';
cells(i).description{9}='NBN'; %11.3KHz
cells(i).mode{9}='i=0';
cells(i).filenum(10,:)='010';
cells(i).description{10}='NBN'; %responses look splatter-y
cells(i).mode{10}='iclamp';
cells(i).iext{10}=92; %pA
cells(i).filenum(11,:)='011'; %
cells(i).description{11}='NBN'; %8KHz, 50dB
cells(i).mode{11}='vclamp';
cells(i).filenum(12,:)='012';
cells(i).description{12}='NBN'; %8KHz, 50dB
cells(i).mode{12}='i=0';
cells(i).filenum(13,:)='013';
cells(i).description{13}='NBN'; %responses look splatter-y
cells(i).mode{13}='iclamp';
cells(i).iext{13}=100; %pA

i=i+1;
cells(i).user='xg';%SPIKE & vc, NBNs PLAYED AT WRONG FREQ (i.e. NON-CF)
cells(i).rig='rig1';
cells(i).expdate='101110';
cells(i).session='002';
cells(i).depth=233; %micrometers
cells(i).A1=y;
cells(i).CF=4; %Hz
cells(i).Vout=-8.4; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %spikes are delayed- ~75 ms post stim onset
cells(i).mode{4}='iclamp';
cells(i).iext{4}=172; %pA
cells(i).filenum(5,:)='006'; %
cells(i).description{5}='NBN'; %2.4KHz
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='007';%sparse spiking
cells(i).description{6}='NBN'; %2.4KHz
cells(i).mode{6}='i=0';
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{7}='iclamp';
cells(i).iext{7}=146; %pA

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='101110';
cells(i).session='001';
cells(i).depth=118; %micrometers
cells(i).A1=y;
cells(i).CF=5.7; %Hz
cells(i).Vout=-0.4; %mV
cells(i).filenum(1,:)='005';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='006'; %
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='007';%sparse spiking
cells(i).description{3}='NBN'; %5.7KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{4}='iclamp';
cells(i).iext{4}=80; %pA
cells(i).filenum(5,:)='010'; %
cells(i).description{5}='NBN'; %2KHz
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='011';
cells(i).description{6}='NBN'; %2KHz
cells(i).mode{6}='i=0';
cells(i).filenum(7,:)='012';
cells(i).description{7}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{7}='iclamp';
cells(i).iext{7}=122; %pA
cells(i).filenum(8,:)='013'; %
cells(i).description{8}='NBN'; %8KHz
cells(i).mode{8}='vclamp';
cells(i).filenum(9,:)='014';
cells(i).description{9}='NBN'; %8KHz
cells(i).mode{9}='i=0';
cells(i).filenum(10,:)='015';
cells(i).description{10}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{10}='iclamp';
cells(i).iext{10}=91; %pA
cells(i).filenum(11,:)='016'; %
cells(i).description{11}='NBN'; %5.7KHz again, vcontrol might be better than file 006
cells(i).mode{11}='vclamp';

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='101410';
cells(i).session='002';
cells(i).depth=137; %micrometers
cells(i).A1=y;
cells(i).CF=2.8; %Hz
cells(i).Vout=0.6; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=2.8
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %i is sustained
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{4}='iclamp';
cells(i).iext{4}=189; %pA
cells(i).filenum(5,:)='005'; %
cells(i).description{5}='NBN'; %1.7KHz
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %1.7KHz
cells(i).mode{6}='i=0';
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{7}='iclamp';
cells(i).iext{7}=165; %pA

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='101410';
cells(i).session='002';
cells(i).depth=235; %micrometers
cells(i).A1=y;
cells(i).CF=8; %Hz
cells(i).Vout=2.3; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC'; %CF=8
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='012'; %sparse spiking
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='013';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='014';
cells(i).description{4}='NBN'; %not many spikes
cells(i).mode{4}='iclamp';
cells(i).iext{4}=70; %pA
cells(i).filenum(5,:)='015'; 
cells(i).description{5}='NBN'; %8KHz, again
cells(i).mode{5}='i=0';

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='101510';
cells(i).session='001';
cells(i).depth=97; %micrometers
cells(i).A1=y;
cells(i).CF=11.3; %Hz
cells(i).Vout=4.5; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='009'; %
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='011';
cells(i).description{4}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{4}='iclamp';
cells(i).iext{4}=70; %pA
cells(i).filenum(5,:)='012'; %
cells(i).description{5}='NBN'; %11.3KHz
cells(i).mode{5}='iclamp';
cells(i).iext{5}=104; %pA
cells(i).filenum(6,:)='013';
cells(i).description{6}='NBN'; %8KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='014';
cells(i).description{7}='NBN';
cells(i).mode{7}='i=0';

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='101510';
cells(i).session='001';
cells(i).depth=309; %micrometers
cells(i).A1=y;
cells(i).CF=9.5; %Hz
cells(i).Vout=-1.8; %mV
cells(i).filenum(1,:)='016';
cells(i).description{1}='TC'; %CF=9.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='018'; %not many spikes, but stim evoked
cells(i).description{2}='NBN'; %9.5KHz
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='019';%V control not great- weird thing at bw=3.2
cells(i).description{3}='NBN'; %9.5KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='020';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=129; %pA

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='102210';
cells(i).session='003';
cells(i).depth=164; %micrometers
cells(i).A1=y;
cells(i).CF=4; %Hz
cells(i).Vout=-8.3; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %
cells(i).description{2}='NBN'; %4KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %4KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{4}='iclamp';
cells(i).iext{4}=200; %pA
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %hard to tell if responses are stim. evoked
cells(i).mode{5}='iclamp';
cells(i).iext{5}=238; %pA

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='102210';
cells(i).session='002';
cells(i).depth=159; %micrometers
cells(i).A1=y;
cells(i).CF=6.7; %Hz
cells(i).Vout=-0.3; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';% cell spiked constantly w/ Vm~ -30mV so gave neg. current.
cells(i).description{3}='NBN';
cells(i).mode{3}='iclamp';
cells(i).iext{3}=-75; %pA

i=i+1;
cells(i).user='xg';%SPIKE & vc
cells(i).rig='rig1';
cells(i).expdate='102210';
cells(i).session='001';
cells(i).depth=163; %micrometers
cells(i).A1=y;
cells(i).CF=5.7; %Hz
cells(i).Vout=-5; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011'; %
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %5.7KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='013';
cells(i).description{4}='NBN'; %delayed spiking (75ms post stim onset)
cells(i).mode{4}='iclamp';
cells(i).iext{4}=140; %pA
cells(i).filenum(5,:)='014';
cells(i).description{5}='NBN'; %5.7kHz, again
cells(i).mode{5}='i=0';

i=i+1;
cells(i).user='xg'; %VC+Vm, maybe spikes
cells(i).rig='rig1';
cells(i).expdate='102810';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='algfp/ck2';
cells(i).depth=143; %micrometers
cells(i).A1=y;
cells(i).CF=8; %Hz
cells(i).Vout=3.5; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC'; %CF=8
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='007'; %
cells(i).description{2}='NBN'; %8KHz losing vcontrol near end of file
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='008';
cells(i).description{3}='NBN'; %8KHz Vm~-35, constant spiking, probably not reliably tone-evoked
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='009';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=-292; %pA note NEGATIVE current

i=i+1;
cells(i).user='xg'; %VC only
cells(i).rig='rig1';
cells(i).expdate='102810';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='algfp/ck2';
cells(i).depth=108; %micrometers
cells(i).A1=y;
cells(i).CF=9.5; %Hz
cells(i).Vout=-3; %mV
cells(i).filenum(1,:)='010';
cells(i).description{1}='TC'; %CF=9.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='011'; 
cells(i).description{2}='NBN'; %poor vcontrol. OFF responses!
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='012';
cells(i).description{3}='NBN'; %no evoked responses
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg'; %VC+Vm
cells(i).rig='rig1';
cells(i).expdate='110410';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='wgaal/ck2';
cells(i).depth=94; %micrometers
cells(i).A1=y;
cells(i).CF=16; %Hz
cells(i).Vout=-6; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC'; %CF=16
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005'; %
cells(i).description{2}='NBN'; %16KHz so-so vcontrol
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %16KHz
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg'; %VC+Vm+SPIKES
cells(i).rig='rig1';
cells(i).expdate='110410';
cells(i).session='002';
cells(i).mouse=1;
cells(i).transline='wgaal/ck2';
cells(i).depth=189; %micrometers
cells(i).A1=y;
cells(i).CF=11.3; %Hz
cells(i).Vout=9; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %
cells(i).description{2}='NBN'; %11.3KHz Vm=-40, SPIKING
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='vclamp';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=0; %pA cell stopped spiking
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %22.6kHZ, starting to spike again.
cells(i).mode{5}='i=0';
cells(i).filenum(6,:)='005';
cells(i).description{6}='NBN'; %22.6kHZ, cell fell off during file. OFF tunned to bandwidth
cells(i).mode{6}='vclamp';

i=i+1;
cells(i).user='xg'; %Vm
cells(i).rig='rig1';
cells(i).expdate='111110';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=141; %micrometers
cells(i).A1=y;
cells(i).CF=9.5; %Hz
cells(i).Vout=8; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='TC'; %CF=9.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004'; %
cells(i).description{2}='NBN'; %9.5KHz poor vcontrol, cell fell partially off
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005';
cells(i).description{3}='NBN'; %9.5KHz
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg'; %VC+Vm+SPIKES
cells(i).rig='rig1';
cells(i).expdate='111110';
cells(i).session='002';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=96; %micrometers
cells(i).A1=y;
cells(i).CF=16; %Hz
cells(i).Vout=3.2; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=16
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %
cells(i).description{2}='NBN'; %16KHz so-so vcontrol
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %16KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN';
cells(i).mode{4}='iclamp';
cells(i).iext{4}=275; %pA Vm~20mV

i=i+1;
cells(i).user='xg'; %VC+SPIKES
cells(i).rig='rig1';
cells(i).expdate='111110';
cells(i).session='003';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=173; %micrometers
cells(i).A1=y;
cells(i).CF=9.5; %Hz
cells(i).Vout=-1; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=9.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002'; %
cells(i).description{2}='NBN'; %16KHz NICE SPIKES!
cells(i).mode{2}='i=0';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %16KHz so-so Vcontrol
cells(i).mode{3}='vclamp';

i=i+1;
cells(i).user='xg'; %Vm+SPIKES
cells(i).rig='rig1';
cells(i).expdate='111810';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=89; %micrometers
cells(i).A1=y;
cells(i).CF=26.9; %Hz maybe 16KHz, used 16KHz b/c lacked 26.9 VCTC NBN
cells(i).Vout=0.9; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC'; %CF=16
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %16KHz spiking at -50mV
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %16KHz excitation correlates with Vm
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='007';
cells(i).description{4}='NBN'; %not many evoked spikes
cells(i).mode{4}='iclamp';
cells(i).iext{4}=237; %pA Vm~-10mV

i=i+1;
cells(i).user='xg'; %VC+Vm+SPIKES
cells(i).rig='rig1';
cells(i).expdate='111810';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=173; %micrometers
cells(i).A1=y;
cells(i).CF=13.5; %Hz maybe 16KHz, used 16KHz b/c lacked 13.5 VCTC NBN
cells(i).Vout=3.5; %mV
cells(i).filenum(1,:)='008';
cells(i).description{1}='TC'; %CF=13.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='009';
cells(i).description{2}='NBN'; %16KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='010';
cells(i).description{3}='NBN'; %16KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='011';
cells(i).description{4}='NBN';%16KHz
cells(i).mode{4}='iclamp';
cells(i).iext{4}=237; %pA Vm~-30mV

i=i+1;
cells(i).user='xg'; %bad cell, poor v control
cells(i).rig='rig1';
cells(i).expdate='112210';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=158; %micrometers
cells(i).A1=n;
cells(i).CF=NAN; %Hz
cells(i).Vout=6; %mV
cells(i).filenum(1,:)='004';
cells(i).description{1}='TC'; %
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %32KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %32KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='007';
cells(i).description{4}='NBN';%16KHz
cells(i).mode{4}='iclamp';
cells(i).iext{4}=117;%pA

i=i+1;
cells(i).user='xg'; %bad cell, poor v control
cells(i).rig='rig1';
cells(i).expdate='112210';
cells(i).session='002';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=93; %micrometers
cells(i).A1=n;
cells(i).CF=NAN; %Hz
cells(i).Vout=4.8; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %26.9KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %26.9KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN';%26.9KHz
cells(i).mode{4}='iclamp';
cells(i).iext{4}=57;%pA

i=i+1;
cells(i).user='xg'; %great cell!!
cells(i).rig='rig1';
cells(i).expdate='112310';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=193; %micrometers
cells(i).A1=y;
cells(i).CF=11.3; %Hz
cells(i).Vout=6; %mV
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='008';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='009';
cells(i).description{4}='NBN';%16KHz evoked spikes!
cells(i).mode{4}='iclamp';
cells(i).iext{4}=111;%pA
cells(i).filenum(5,:)='010';
cells(i).description{5}='NBN'; %4.8KHz
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='011';
cells(i).description{6}='NBN'; %4.8KHz spikes!
cells(i).mode{6}='i=0';
cells(i).filenum(7,:)='016';
cells(i).description{7}='NBN';%4.8KHz evoked spikes!
cells(i).mode{7}='iclamp';
cells(i).iext{7}=136;%pA
cells(i).filenum(8,:)='013';
cells(i).description{8}='NBN'; %26.9KHz
cells(i).mode{8}='vclamp';
cells(i).filenum(9,:)='014';
cells(i).description{9}='NBN'; %26.9KHz
cells(i).mode{9}='i=0';
cells(i).filenum(10,:)='015';
cells(i).description{10}='NBN';%26.9KHz
cells(i).mode{10}='iclamp';
cells(i).iext{10}=136;%pA

i=i+1;
cells(i).user='xg'; %great cell!!
cells(i).rig='rig1';
cells(i).expdate='112310';
cells(i).session='002';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=65; %micrometers
cells(i).A1=y;
cells(i).CF=8; %Hz
cells(i).Vout=3.5; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=8
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %8KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %8KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN';%8KHz evoked spikes!
cells(i).mode{4}='iclamp';
cells(i).iext{4}=75;%pA
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %8KHz
cells(i).mode{5}='iclamp';
cells(i).iext{5}=85;%pA
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %13.5KHz
cells(i).mode{6}='vclamp';
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN';%13.5KHz
cells(i).mode{7}='i=0';
cells(i).filenum(8,:)='008';
cells(i).description{8}='NBN'; %13.5KHz
cells(i).mode{8}='iclamp';
cells(i).iext{8}=41;%pA
cells(i).filenum(9,:)='009';
cells(i).description{9}='NBN'; %4KHz
cells(i).mode{9}='vclamp';
cells(i).filenum(10,:)='010';
cells(i).description{10}='NBN';%4KHz
cells(i).mode{10}='i=0';
cells(i).filenum(11,:)='011';
cells(i).description{11}='NBN';%4KHz
cells(i).mode{11}='iclamp';
cells(i).iext{11}=32;%pA
cells(i).filenum(12,:)='012';
cells(i).description{12}='NBN'; %6.7KHz
cells(i).mode{12}='vclamp';
cells(i).filenum(13,:)='012';
cells(i).description{13}='NBN';%6.7KHz evoked spikes!
cells(i).mode{13}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='113010';
cells(i).session='001';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=84; %micrometers
cells(i).A1=y;
cells(i).CF=13.5; %Hz
cells(i).Vout=10.5; %mV
cells(i).filenum(1,:)='003';
cells(i).description{1}='TC'; %CF=13.5
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='005';
cells(i).description{3}='NBN'; %13.5KHz
cells(i).mode{3}='i=0';
cells(i).filenum(4,:)='006';
cells(i).description{4}='NBN';%13.5KHz evoked spikes?
cells(i).mode{4}='iclamp';
cells(i).iext{4}=93;%pA
cells(i).filenum(5,:)='007';
cells(i).description{5}='NBN'; %26.9KHz
cells(i).mode{5}='vclamp';
cells(i).filenum(6,:)='008';
cells(i).description{6}='NBN'; %26.9KHz spikes!
cells(i).mode{6}='i=0';
cells(i).filenum(7,:)='009';
cells(i).description{7}='NBN';%26.9KHz evoked spikes!
cells(i).mode{7}='iclamp';
cells(i).iext{7}=115;%pA

i=i+1;
cells(i).user='xg';%noisy
cells(i).rig='rig1';
cells(i).expdate='113010';
cells(i).session='002';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=119; %micrometers
cells(i).A1=y;
cells(i).CF=13.5; %Hz
cells(i).Vout=-2.4; %mV
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=13.5
cells(i).mode{1}='vclamp';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %13.5KHz NOISY
cells(i).mode{3}='i=0';

i=i+1;
cells(i).user='xg';
cells(i).rig='rig1';
cells(i).expdate='113010';
cells(i).session='003';
cells(i).mouse=1;
cells(i).transline='wgaal/pv';
cells(i).depth=199; %micrometers
cells(i).A1=y;
cells(i).CF=11.3; %Hz
cells(i).Vout=7; %mV
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %11.3KHz poor vcontrol
cells(i).mode{2}='vclamp';
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='i=0';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070510';
cells(i).session='001';
cells(i).depth=698; %micrometers
cells(i).A1=m;
cells(i).CF=4800; %Hz
cells(i).filenum(1,:)='011';
cells(i).description{1}='TC';
cells(i).mode{1}='lca';
cells(i).filenum(2,:)='012';
cells(i).description{2}='NBN'; %4.8KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(2,:)='013';
cells(i).description{2}='NBN'; %1.7KHz 
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(2,:)='014';
cells(i).description{2}='NBN'; %1.7KHz played again
cells(i).mode{2}='lca'; %supposed to be a 5.7 recording

i=i+1;
cells(i).user='jb';%sounds mostly multi-unit, 2 single spikes
cells(i).rig='rig1';
cells(i).expdate='070610';
cells(i).session='001';
cells(i).depth=330; %micrometers
cells(i).A1=m;
cells(i).CF=2800; %Hz
cells(i).filenum(1,:)='007';
cells(i).description{1}='TC'; %CF=2.8 or 3.4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='008';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='009';
cells(i).description{3}='NBN'; %3.4KHz
cells(i).mode{3}='lca'; %80-80db

i=i+1;
cells(i).user='jb';%not a clean TC
cells(i).rig='rig1';
cells(i).expdate='070610';
cells(i).session='001';
cells(i).depth=330; %micrometers, didn't record exact, based on previous penetrations
cells(i).A1=m;
cells(i).CF=2400; %Hz
cells(i).filenum(1,:)='012';
cells(i).description{1}='TC'; %CF=2.4, 2.8 or 4.0
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='013';
cells(i).description{2}='NBN'; %2.4KHz
cells(i).mode{2}='lca'; %35-35db
cells(i).filenum(3,:)='014';
cells(i).description{3}='NBN'; %2.8KHz
cells(i).mode{3}='lca'; %50-50db
cells(i).filenum(4,:)='015';
cells(i).description{4}='NBN'; %4.0KHz
cells(i).mode{4}='lca'; %50-50db
cells(i).filenum(5,:)='016';
cells(i).description{5}='NBN'; %2.4KHz
cells(i).mode{5}='lca'; %35-35db, better attachment

i=i+1;
cells(i).user='jb';%
cells(i).rig='rig1';
cells(i).expdate='070610';
cells(i).session='002';
cells(i).depth=600; %micrometers
cells(i).A1=n; %not tuned and probably not A1, may be PAF
cells(i).CF=16000; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=16.0 or 8.0
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %16.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %8.0KHz
cells(i).mode{3}='lca'; %80-80db

i=i+1;
cells(i).user='jb';% lots of ground wire problems
cells(i).rig='rig1';
cells(i).expdate='070710';
cells(i).session='001';
cells(i).depth=300; %micrometers based off TC's not certain
cells(i).A1=m; % could be but CF's should have been lower
cells(i).CF=9500; %Hz
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC'; %CF=not well characterized, more reactive at 9.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %9.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='008';
cells(i).description{3}='NBN'; %9.5KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(3,:)='009';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='lca'; %80-80db

i=i+1;
cells(i).user='jb';%may be a multi-unit
cells(i).rig='rig1';
cells(i).expdate='070710';
cells(i).session='002';
cells(i).depth=500; %micrometers
cells(i).A1=m; %
cells(i).CF=2400; %Hz,
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=2.4
cells(i).mode{1}='i=0'; %no distinct tuning
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %16.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %2.4KHz
cells(i).mode{3}='lca'; %80-80db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070810';
cells(i).session='001';
cells(i).depth=172; %
cells(i).A1=y; 
cells(i).CF=11300; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='lca'; %80-80db, may have broken in Rs really high
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %13.5KHz
cells(i).mode{3}='lca'; %80-80db, lost cell 

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070810';
cells(i).session='002';
cells(i).depth=200; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=5700; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='001';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %5.7KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %6.7KHz
cells(i).mode{4}='lca'; %65-65db, lost spiking

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070810';
cells(i).session='003';
cells(i).depth=500; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=22600; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=22.6
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %22.6KHz
cells(i).mode{2}='lca'; %65-65db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %2.0KHz
cells(i).mode{3}='lca'; %65-65db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %22.6KHz
cells(i).mode{4}='lca'; %65-65db, better resistance

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070810';
cells(i).session='004';
cells(i).depth=200; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=13500; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=13.5
cells(i).mode{1}='i=0'; %stopped spiking in the middle of TC
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca'; %80-80db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070810';
cells(i).session='005';
cells(i).depth=200; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=13500; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=13.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca'; %50-50db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %8.0KHz
cells(i).mode{3}='lca'; %50-50db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %8.0KHz
cells(i).mode{4}='lca'; %80-80db


i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070810';
cells(i).session='006';
cells(i).depth=200; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=9500; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=9.5 or 13.5
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %9.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='lca'; %65-65db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %11.3KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %13.5KHz
cells(i).mode{5}='lca'; %80-80db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070910';
cells(i).session='001';
cells(i).depth=267; 
cells(i).A1=y; 
cells(i).CF=6700; %Hz
cells(i).filenum(1,:)='005';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='006';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='lca'; %50-50db
cells(i).filenum(3,:)='007';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='lca'; %50-50db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='070910';
cells(i).session='003'; 
cells(i).depth=300; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=6700; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=6.7 or 8.0
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %8.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %9.5KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %6.7KHz
cells(i).mode{5}='lca'; %65-65db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %9.5KHz
cells(i).mode{6}='lca'; %65-65db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=481; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=4000; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=4.0 or 3.4
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %4.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %3.4KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %4.0KHz
cells(i).mode{4}='lca'; %50-50db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %3.4KHz
cells(i).mode{5}='lca'; %50-50db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071210';
cells(i).session='002'; 
cells(i).depth=482; 
cells(i).A1=y; 
cells(i).CF=4000; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=4.0
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %4.0KHz
cells(i).mode{2}='lca'; %35-35db
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %3.4KHz
cells(i).mode{3}='lca'; %65-65db
cells(i).filenum(4,:)='007';
cells(i).description{4}='NBN'; %2.4KHz
cells(i).mode{4}='lca'; %35-35db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071210';
cells(i).session='004'; 
cells(i).depth=450; %didn't record best guess based on TC
cells(i).A1=y; 
cells(i).CF=6700; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=6.7 
cells(i).mode{1}='i=0'; %didn't look tuned to anything
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='lca'; %50-50db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='lca'; %65-65db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071210';
cells(i).session='005'; 
cells(i).depth=482; 
cells(i).A1=y; 
cells(i).CF=4800; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=4.8
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='lca'; %65-65db
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %4.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='007';
cells(i).description{4}='NBN'; %4.8KHz
cells(i).mode{4}='lca'; %35-35db
cells(i).filenum(5,:)='008';
cells(i).description{5}='NBN'; %4.8KHz
cells(i).mode{5}='lca'; %50-50db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071310';
cells(i).session='002'; 
cells(i).depth=695; 
cells(i).A1=y; 
cells(i).CF=4000; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=3.4
cells(i).mode{1}='i=0'; %80-80db
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %3.4KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %4.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %4.8KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %8.0KHz
cells(i).mode{5}='lca'; %80-80db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071310';
cells(i).session='006'; 
cells(i).depth=398; 
cells(i).A1=y; 
cells(i).CF=4800; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=4.8
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %4.8KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %4.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %5.7KHz
cells(i).mode{4}='lca'; %80-80db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071310';
cells(i).session='007'; 
cells(i).depth=500; %guess based on TC
cells(i).A1=m; 
cells(i).CF=11300; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=11.3, 9.5 or 32.0
cells(i).mode{1}='i=0'; %80-80db
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %9.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='lca'; %80-80db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='001'; 
cells(i).depth=562; 
cells(i).A1=m; 
cells(i).CF=13500; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=13.5 not very well tuned
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca'; %50-50db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %16.0KHz
cells(i).mode{3}='lca'; %65-65db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %11.3KHz
cells(i).mode{4}='lca'; %65-65db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %26.9KHz
cells(i).mode{5}='lca'; %50-50db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='002'; 
cells(i).depth=710; 
cells(i).A1=m; 
cells(i).CF=32000; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=32.0
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %26.9KHz
cells(i).mode{2}='lca'; %50-50db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %32.0KHz
cells(i).mode{3}='lca'; %50-50db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %22.6KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %22.6KHz
cells(i).mode{5}='lca'; %35-35db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %32.0KHz
cells(i).mode{6}='lca'; %35-35db
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %32.0KHz
cells(i).mode{7}='lca'; %65-65db
cells(i).filenum(8,:)='008';
cells(i).description{8}='NBN'; %26.9KHz
cells(i).mode{8}='lca'; %35-35db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='004'; 
cells(i).depth=557; 
cells(i).A1=m; %most likely it is in A1 
cells(i).CF=6700; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='lca'; %65-65db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %5.7KHz
cells(i).mode{4}='lca'; %50-50db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %5.7KHz
cells(i).mode{5}='lca'; %65-65db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='005'; 
cells(i).depth=450; %resistance gave no characteristic jump, unsure how deep the cell was
cells(i).A1=y; 
cells(i).CF=6700; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=6.7 not very many spikes
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='lca'; %50-50db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %6.7KHz
cells(i).mode{4}='lca'; %35-35db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %8.0KHz
cells(i).mode{5}='lca'; %65-65db
cells(i).filenum(6,:)='007';
cells(i).description{6}='NBN'; %6.7KHz
cells(i).mode{6}='lca'; %50-50db
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %5.7KHz
cells(i).mode{7}='lca'; %80-80db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='007'; 
cells(i).depth=450; %resistance gave no characteristic jump, unsure how deep the cell was
cells(i).A1=m; %was really far lateral but the TC looked fine
cells(i).CF=2400; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=2.4
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %2.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %2.0KHz
cells(i).mode{3}='lca'; %35-35db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %38.1KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %2.4KHz
cells(i).mode{5}='lca'; %35-35db

i=i+1;
cells(i).user='jb';
cells(i).rig='rig1';
cells(i).expdate='071410';
cells(i).session='008'; 
cells(i).depth=450; %based on previous found celll ranges
cells(i).A1=n; %was really far posterior
cells(i).CF=1700; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=1.7, most spiking
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %1.7KHz
cells(i).mode{2}='lca'; %50-50db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %2.0KHz
cells(i).mode{3}='lca'; %better response than 1.7
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %2.0KHz
cells(i).mode{4}='lca'; %not as many spikes

i=i+1;
cells(i).user='jb'; %Great Tuning!
cells(i).rig='rig1';
cells(i).expdate='071510';
cells(i).session='004'; 
cells(i).depth=300; %based on the range on Xiang's cells, didn't record
cells(i).A1=y; 
cells(i).CF=13500; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=13.5
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='005';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='006';
cells(i).description{4}='NBN'; %16.0KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='007';
cells(i).description{5}='NBN'; %13.5KHz
cells(i).mode{5}='lca'; %50-50db
cells(i).filenum(6,:)='008';
cells(i).description{6}='NBN'; %11.3KHz
cells(i).mode{6}='lca'; %65-65db

i=i+1;
cells(i).user='jb'; %MATLAB froze same cell as session 004 from 07/15
cells(i).rig='rig1';
cells(i).expdate='071510';
cells(i).session='005'; 
cells(i).depth=300; %based on the range on Xiang's cells, didn't record
cells(i).A1=y; 
cells(i).CF=13500; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='NBN'; %16.0KHz
cells(i).mode{1}='lca'; %65-65db
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca'; %65-65db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='lca'; %50-50db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %13.5KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %19.0KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %22.6KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %26.9KHz
cells(i).mode{7}='lca'; %80-80db
cells(i).filenum(8,:)='008';
cells(i).description{8}='NBN'; %32.0KHz
cells(i).mode{8}='lca'; %80-80db
cells(i).filenum(9,:)='009';
cells(i).description{9}='NBN'; %38.1KHz
cells(i).mode{9}='lca'; %80-80db
cells(i).filenum(10,:)='010';
cells(i).description{10}='NBN'; %9.5KHz
cells(i).mode{10}='lca'; %80-80db
cells(i).filenum(11,:)='011';
cells(i).description{11}='NBN'; %8.0KHz
cells(i).mode{11}='lca'; %80-80db
cells(i).filenum(12,:)='012';
cells(i).description{12}='NBN'; %6.7KHz
cells(i).mode{12}='lca'; %80-80db
cells(i).filenum(13,:)='013';
cells(i).description{13}='NBN'; %5.7KHz
cells(i).mode{13}='lca'; %80-80db
cells(i).filenum(14,:)='014';
cells(i).description{14}='NBN'; %4.8KHz
cells(i).mode{14}='lca'; %80-80db
cells(i).filenum(15,:)='015';
cells(i).description{15}='NBN'; %4.0KHz
cells(i).mode{15}='lca'; %80-80db
cells(i).filenum(16,:)='016';
cells(i).description{16}='NBN'; %3.4KHz
cells(i).mode{16}='lca'; %80-80db
cells(i).filenum(17,:)='017';
cells(i).description{17}='NBN'; %2.8KHz
cells(i).mode{17}='lca'; %80-80db
cells(i).filenum(18,:)='018';
cells(i).description{18}='NBN'; %2.4KHz
cells(i).mode{18}='lca'; %80-80db
cells(i).filenum(19,:)='019';
cells(i).description{19}='NBN'; %2.0KHz
cells(i).mode{19}='lca'; %80-80db
cells(i).filenum(21,:)='021';
cells(i).description{21}='NBN'; %1.4KHz
cells(i).mode{21}='lca'; %35-35db

i=i+1;
cells(i).user='jb'; %Great Tuning!
cells(i).rig='rig1';
cells(i).expdate='071610';
cells(i).session='001'; 
cells(i).depth=379; 
cells(i).A1=y; 
cells(i).CF=6700; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=6.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %6.7KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='005';
cells(i).description{3}='NBN'; %8.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='006';
cells(i).description{4}='NBN'; %5.7KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='007';
cells(i).description{5}='NBN'; %22.6KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='008';
cells(i).description{6}='NBN'; %2.0KHz
cells(i).mode{6}='lca'; %35-35db
cells(i).filenum(7,:)='009';
cells(i).description{7}='NBN'; %6.7KHz
cells(i).mode{7}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='071610';
cells(i).session='003'; 
cells(i).depth=490; 
cells(i).A1=m; 
cells(i).CF=26900; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=26.9
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %26.9KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %26.9KHz
cells(i).mode{3}='lca'; %35-35db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %22.6KHz
cells(i).mode{4}='lca'; %35-35db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %32.0KHz
cells(i).mode{5}='lca'; %35-35db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %38.1KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %2.0KHz
cells(i).mode{7}='lca'; %35-35db
cells(i).filenum(8,:)='008';
cells(i).description{8}='NBN'; %2.0KHz
cells(i).mode{8}='lca'; %35-35db

i=i+1;
cells(i).user='jb'; %Cortex damaged with electrode
cells(i).rig='rig1';
cells(i).expdate='071910';
cells(i).session='002'; 
cells(i).depth=300; 
cells(i).A1=m; 
cells(i).CF=19000; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=19.0
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %8.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %8.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %19.0KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %26.9KHz
cells(i).mode{5}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; %Cortex damaged with electrode
cells(i).rig='rig1';
cells(i).expdate='071910';
cells(i).session='003'; 
cells(i).depth=660; 
cells(i).A1=m; 
cells(i).CF=13500; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=13.5
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %13.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %11.3KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %16.0KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %32.0KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %2.0KHz
cells(i).mode{6}='lca'; %35-35db
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %13.5KHz
cells(i).mode{7}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; %Cortex damaged with electrode
cells(i).rig='rig1';
cells(i).expdate='071910';
cells(i).session='004'; 
cells(i).depth=708; 
cells(i).A1=m; 
cells(i).CF=22600; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=22.6
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %9.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %8.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %19.0KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %22.6KHz
cells(i).mode{5}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072110';
cells(i).session='001'; 
cells(i).depth=658; 
cells(i).A1=m; 
cells(i).CF=1400; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=1.4
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %4.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %1.4KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %4.8KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='007';
cells(i).description{6}='NBN'; %1.4KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %38.1KHz
cells(i).mode{7}='lca'; %80-80db
cells(i).filenum(8,:)='009';
cells(i).description{8}='NBN'; %1.2KHz
cells(i).mode{8}='lca'; %35-35db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072110';
cells(i).session='001'; 
cells(i).depth=658; 
cells(i).A1=m; 
cells(i).CF=1400; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=1.4
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %4.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %1.4KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %4.8KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='007';
cells(i).description{6}='NBN'; %1.4KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %38.1KHz
cells(i).mode{7}='lca'; %80-80db
cells(i).filenum(8,:)='009';
cells(i).description{8}='NBN'; %38.1KHz
cells(i).mode{8}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072110';
cells(i).session='002'; 
cells(i).depth=536; 
cells(i).A1=m; 
cells(i).CF=5700; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %5.7KHz
cells(i).mode{3}='lca'; %65-65db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %4.8KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %6.7KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='007';
cells(i).description{6}='NBN'; %38.1KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %2.4KHz
cells(i).mode{7}='lca'; %35-35db
cells(i).filenum(8,:)='009';
cells(i).description{8}='NBN'; %2.0KHz
cells(i).mode{8}='lca'; %35-35db
cells(i).filenum(9,:)='010';
cells(i).description{9}='NBN'; %26.9KHz
cells(i).mode{9}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072110';
cells(i).session='003'; 
cells(i).depth=466; 
cells(i).A1=m; 
cells(i).CF=8000; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=8.0, not many spikes to determine
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %8.0KHz
cells(i).mode{2}='lca'; %80-80db

i=i+1;
cells(i).user='whit';
cells(i).rig='rig2';
cells(i).expdate='070910';
cells(i).session='001'; 
cells(i).depth=nan; %micrometers 
cells(i).A1=y; 
cells(i).CF=1200; %Hz
cells(i).filenum(1,:)='022';
cells(i).description{1}='TC';
cells(i).mode{1}='lca'; 
cells(i).filenum(2,:)='023';
cells(i).description{2}='NBN'; %1.4 KHz !CHECK TO SEE IF STIMULI WAS DELIVERED PROPERLY AT SUCH A LOW FREQUENCY!
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='024';
cells(i).description{3}='NBN'; %1.2 KHz !CHECK TO SEE IF STIMULI WAS DELIVERED PROPERLY AT SUCH A LOW FREQUENCY!
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='025';
cells(i).description{4}='NBN'; %1.0 KHz !CHECK TO SEE IF STIMULI WAS DELIVERED PROPERLY AT SUCH A LOW FREQUENCY!
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072210';
cells(i).session='001'; 
cells(i).depth=269; 
cells(i).A1=y; 
cells(i).CF=5700; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='004';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='005';
cells(i).description{3}='NBN'; %4.8KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='006';
cells(i).description{4}='NBN'; %4.0KHz
cells(i).mode{4}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072210';
cells(i).session='002'; 
cells(i).depth=742; 
cells(i).A1=y; 
cells(i).CF=9500; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=9.5
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %9.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %9.5KHz
cells(i).mode{3}='lca'; %65-65db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072210';
cells(i).session='003'; 
cells(i).depth=662; 
cells(i).A1=y; 
cells(i).CF=11300; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %9.5KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %2.4KHz
cells(i).mode{5}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072310';
cells(i).session='003'; 
cells(i).depth=550; 
cells(i).A1=y; 
cells(i).CF=5700; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %4.8KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='006';
cells(i).description{3}='NBN'; %4.8KHz
cells(i).mode{3}='lca'; %65-65db
cells(i).filenum(4,:)='007';
cells(i).description{4}='NBN'; %4.0KHz
cells(i).mode{4}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072310';
cells(i).session='004'; 
cells(i).depth=405; 
cells(i).A1=y; 
cells(i).CF=1700; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=1.7, Rs really high but still not fully single unit sounding = 50
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='005';
cells(i).description{2}='NBN'; %2.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='007';
cells(i).description{3}='NBN'; %2.4KHz
cells(i).mode{3}='lca'; %80-80db Rs = 60
cells(i).filenum(4,:)='008';
cells(i).description{4}='NBN'; %1.7KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='009';
cells(i).description{5}='NBN'; %1.4KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='010';
cells(i).description{6}='NBN'; %1.7KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='011';
cells(i).description{7}='NBN'; %2.8KHz
cells(i).mode{7}='lca'; %80-80db
cells(i).filenum(8,:)='012';
cells(i).description{8}='NBN'; %3.4KHz
cells(i).mode{8}='lca'; 


i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072310';
cells(i).session='006'; 
cells(i).depth=615; 
cells(i).A1=y; 
cells(i).CF=9500; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=9.5
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %9.5KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %8.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %22.6KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %19.0KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %8.0KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %16.0KHz
cells(i).mode{7}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072710';
cells(i).session='001'; 
cells(i).depth=127; 
cells(i).A1=m; 
cells(i).CF=32000; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=32.0
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %32.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %19.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='006';
cells(i).description{4}='NBN'; %26.9KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='007';
cells(i).description{5}='NBN'; %32.0KHz
cells(i).mode{5}='lca'; %65-65db

i=i+1;
cells(i).user='jb'; %not a good cell, not tuned to anything 
cells(i).rig='rig1';
cells(i).expdate='072710';
cells(i).session='002'; 
cells(i).depth=535; 
cells(i).A1=m; 
cells(i).CF=11300; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=11.3
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %11.3KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %13.5KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %16.0KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %22.6KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %11.3KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %32.0KHz
cells(i).mode{7}='lca'; %80-80db
cells(i).filenum(8,:)='008'; % Raised Rs, spiking a lot more
cells(i).description{8}='NBN'; %11.3KHz
cells(i).mode{8}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072810';
cells(i).session='001'; 
cells(i).depth=355; 
cells(i).A1=m; 
cells(i).CF=19000; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=19.0
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %19.0KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %16.0KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %22.6KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %2.0KHz
cells(i).mode{5}='lca'; %35-35db
cells(i).filenum(6,:)='007';
cells(i).description{6}='NBN'; %38.1KHz
cells(i).mode{6}='lca'; %80-80db
cells(i).filenum(7,:)='007';
cells(i).description{7}='NBN'; %38.1KHz
cells(i).mode{7}='lca'; %80-80db
cells(i).filenum(8,:)='008'; 
cells(i).description{8}='NBN'; %19.0KHz
cells(i).mode{8}='lca'; %80-80db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072810';
cells(i).session='002'; 
cells(i).depth=255; 
cells(i).A1=y; 
cells(i).CF=2800; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=2.8
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %2.4KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %3.4KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %38.1KHz
cells(i).mode{5}='lca'; %80-80db
cells(i).filenum(6,:)='007';
cells(i).description{6}='NBN'; %2.0KHz
cells(i).mode{6}='lca'; %35-35db

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='072810';
cells(i).session='004'; 
cells(i).depth=409; 
cells(i).A1=y; 
cells(i).CF=5700; %Hz
cells(i).filenum(1,:)='001';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='002';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='003';
cells(i).description{3}='NBN'; %6.7KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='004';
cells(i).description{4}='NBN'; %4.8KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='005';
cells(i).description{5}='NBN'; %4.8KHz
cells(i).mode{5}='lca'; %65-65db
cells(i).filenum(6,:)='006';
cells(i).description{6}='NBN'; %4.8KHz
cells(i).mode{6}='lca'; %50-50db
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %5.7KHz
cells(i).mode{7}='lca'; %50-50db
cells(i).filenum(8,:)='009';
cells(i).description{8}='NBN'; %38.1KHz
cells(i).mode{8}='lca'; %80-80db
cells(i).filenum(9,:)='010';
cells(i).description{9}='NBN'; %5.7KHz
cells(i).mode{9}='lca'; %80-80db
cells(i).filenum(5,:)='011';
cells(i).description{5}='NBN'; %2.0KHz
cells(i).mode{5}='lca'; %35-35db

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='070910';
cells(i).session='001'; 
cells(i).depth=578; 
cells(i).A1=y; 
cells(i).CF=2100; %Hz
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC'; %CF=2.1
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='008';
cells(i).description{2}='NBN'; %2.1KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='009';
cells(i).description{3}='NBN'; %2.5KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='010';
cells(i).description{4}='NBN'; %2.7KHz
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='070910';
cells(i).session='001'; 
cells(i).depth=592; 
cells(i).A1=y; 
cells(i).CF=3600; %Hz
cells(i).filenum(1,:)='012';
cells(i).description{1}='TC'; %CF=3.6
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='013';
cells(i).description{2}='NBN'; %3.6KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='014';
cells(i).description{3}='NBN'; %5.2KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='015';
cells(i).description{4}='NBN'; %3.0KHz
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='070910';
cells(i).session='001'; 
cells(i).depth=74; 
cells(i).A1=y; 
cells(i).CF=1400; %Hz
cells(i).filenum(1,:)='017';
cells(i).description{1}='TC'; %CF=1.4
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='019';
cells(i).description{2}='NBN'; %1.4KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='020';
cells(i).description{3}='NBN'; %1.7KHz
cells(i).mode{3}='lca';

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=150; 
cells(i).A1=y; 
cells(i).CF=2100; %Hz
cells(i).filenum(1,:)='006';
cells(i).description{1}='TC'; %CF=2.1
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='007';
cells(i).description{2}='NBN'; %2.1KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='008';
cells(i).description{3}='NBN'; %2.5KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='010';
cells(i).description{4}='NBN'; %1.4KHz
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=210; 
cells(i).A1=y; 
cells(i).CF=2100; %Hz
cells(i).filenum(1,:)='011';
cells(i).description{1}='TC'; %CF=2.1
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='012';
cells(i).description{2}='NBN'; %2.1KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='013';
cells(i).description{3}='NBN'; %1.7KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='014';
cells(i).description{4}='NBN'; %1.4KHz
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=664; 
cells(i).A1=y; 
cells(i).CF=3000; %Hz
cells(i).filenum(1,:)='015';
cells(i).description{1}='TC'; %CF=3.0
cells(i).mode{1}='i=0'; %cell became more active through data collection
cells(i).filenum(2,:)='016';
cells(i).description{2}='NBN'; %3.0KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='017';
cells(i).description{3}='NBN'; %2.5KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='018';
cells(i).description{4}='NBN'; %3.6KHz
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=509; 
cells(i).A1=y; 
cells(i).CF=2500; %Hz
cells(i).filenum(1,:)='020';
cells(i).description{1}='TC'; %CF=2.5
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='021';
cells(i).description{2}='NBN'; %2.5KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='022';
cells(i).description{3}='NBN'; %2.1KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='023';
cells(i).description{4}='NBN'; %3.0KHz
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=541; 
cells(i).A1=y; 
cells(i).CF=3000; %Hz
cells(i).filenum(1,:)='026';
cells(i).description{1}='TC'; %CF=3.0
cells(i).mode{1}='i=0';
cells(i).filenum(2,:)='027';
cells(i).description{2}='NBN'; %3.0KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='028';
cells(i).description{3}='NBN'; %3.6KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='029';
cells(i).description{4}='NBN'; %2.5KHz
cells(i).mode{4}='lca'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=407; 
cells(i).A1=y; 
cells(i).CF=3600; %Hz
cells(i).filenum(1,:)='032';
cells(i).description{1}='TC'; %CF=3.6
cells(i).mode{1}='i=0'; %Cell became more active
cells(i).filenum(2,:)='033';
cells(i).description{2}='NBN'; %6.2KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='034';
cells(i).description{3}='NBN'; %7.4KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='035';
cells(i).description{4}='NBN'; %5.2KHz
cells(i).mode{4}='lca'; 
cells(i).filenum(5,:)='036';
cells(i).description{5}='TC';%Taken due to increased cell activity
cells(i).mode{5}='I=0'; 

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='071210';
cells(i).session='001'; 
cells(i).depth=735;
cells(i).CF=5200; %Hz
cells(i).filenum(1,:)='039';
cells(i).description{1}='TC'; %CF=5.2
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='040';
cells(i).description{2}='NBN'; %5.2KHz
cells(i).mode{2}='lca';
cells(i).filenum(3,:)='041';
cells(i).description{3}='NBN'; %6.2KHz
cells(i).mode{3}='lca'; 
cells(i).filenum(4,:)='042';
cells(i).description{4}='NBN'; %4.3KHz
cells(i).mode{4}='lca'; 
 

i=i+1;
cells(i).user='jb'; 
cells(i).rig='rig1';
cells(i).expdate='073010';
cells(i).session='001'; 
cells(i).depth=440; 
cells(i).A1=y; 
cells(i).CF=2800; %Hz
cells(i).filenum(1,:)='002';
cells(i).description{1}='TC'; %CF=2.8
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='003';
cells(i).description{2}='NBN'; %2.8KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='004';
cells(i).description{3}='NBN'; %3.4KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='005';
cells(i).description{4}='NBN'; %4.0KHz
cells(i).mode{4}='lca'; %80-80db
cells(i).filenum(5,:)='006';
cells(i).description{5}='NBN'; %2.8KHz
cells(i).mode{5}='lca'; %65-65db
cells(i).filenum(6,:)='007';
cells(i).description{6}='NBN'; %3.4KHz
cells(i).mode{6}='lca'; %65-65db
cells(i).filenum(7,:)='008';
cells(i).description{7}='NBN'; %4KHz
cells(i).mode{7}='lca'; %50-50db
cells(i).filenum(8,:)='009';
cells(i).description{8}='NBN'; %2.8KHz
cells(i).mode{8}='lca'; %50-50db

i=i+1;
cells(i).user='ab'; 
cells(i).rig='rig1';
cells(i).expdate='090710';
cells(i).session='001'; 
cells(i).depth=nan; 
cells(i).A1=y; 
cells(i).CF=5.7; %Hz
cells(i).filenum(1,:)='013';
cells(i).description{1}='TC'; %CF=5.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='014';
cells(i).description{2}='NBN'; %5.7KHz
cells(i).mode{2}='lca'; %80-80db

i=i+1;
cells(i).user='whit'; 
cells(i).rig='rig2';
cells(i).expdate='070810';
cells(i).session='001'; 
cells(i).depth=nan; 
cells(i).A1=y; 
cells(i).CF=26.7; %Hz
cells(i).filenum(1,:)='008';
cells(i).description{1}='TC'; %CF=26.7
cells(i).mode{1}='i=0'; 
cells(i).filenum(2,:)='010';
cells(i).description{2}='NBN'; %26.7KHz
cells(i).mode{2}='lca'; %80-80db
cells(i).filenum(3,:)='011';
cells(i).description{3}='NBN'; %26.7KHz
cells(i).mode{3}='lca'; %80-80db
cells(i).filenum(4,:)='016';
cells(i).description{4}='NBN'; %22.2KHz
cells(i).mode{4}='lca'; %80-80db