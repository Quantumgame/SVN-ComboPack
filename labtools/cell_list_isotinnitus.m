function cells=cell_list_isotinnitus
%cell list for GPIAS/tinnitus with/without isoflurane (Maddie/Katherines)
%time format is pretty flexible, e.g. '1:46 pm', '1:46PM', '13:46' all work
% note that filenum(n,:) must be sequential even if filenames are not
% e.g. if file 002 was crap, do this: 
% cells(i).filenum(1,:)='001'; %GPIAS
% cells(i).filenum(2,:)='003'; %GPIAS
% cells(i).filenum(3,:)='004'; %GPIAS


% Last update 11/30/10
i=0;

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='071410kta';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='8:30am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='071410';
cells(i).session='001';
cells(i).trauma_start='2:46pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='005'; %GPIAS
cells(i).filenum(6,:)='007'; %NBASR
cells(i).filenum(7,:)='009'; %GPIAS
cells(i).filenum(8,:)='010'; %GPIAS very restless
cells(i).filenum(9,:)='011'; %GPIAS
cells(i).filenum(10,:)='012'; %GPIAS
cells(i).filenum(11,:)='014'; %GPIAS
cells(i).filenum(12,:)='016'; %NBASR
cells(i).filenum(13,:)='018'; %GPIAS
cells(i).filenum(14,:)='019'; %GPIAS
cells(i).filenum(15,:)='020'; %NBASR restless
cells(i).filenum(16,:)='021'; %GPIAS
cells(i).filenum(17,:)='022'; %GPIAS
cells(i).filenum(18,:)='023'; %NBASR
cells(i).filenum(19,:)='024'; %GPIAS
cells(i).filenum(20,:)='026'; %GPIAS restless
cells(i).filenum(21,:)='027'; %GPIAS
cells(i).filenum(22,:)='028'; %GPIAS
cells(i).filenum(23,:)='029'; %NBASR
cells(i).filenum(24,:)='031'; %GPIAS
cells(i).ratout={'09:51','14:50', '17:09', '19:30', '21:13', '22:46'}; %best estimates from notebook
cells(i).ratin={'08:30', '14:45', '15:22', '17:50', '19:50', '21:42'};
%commenting out just so we only have 2 days each per animal
% i=i+1; 
% cells(i).user='kt';
% cells(i).rig='rig3';
% cells(i).animalID='071410kta';
% cells(i).day=2; %1=day1, 2=day2, etc
% cells(i).iso=0; %0=no iso, 1=iso
% cells(i).rat_in='8:45am'; %time rat first put into chamber, use 24hr or am/pm
% cells(i).expdate='072010';
% cells(i).session='001';
% cells(i).trauma_start='10:20am'; %use 24hr or am/pm
% cells(i).trauma_freq=17000; %Hz
% cells(i).trauma_level=115; %dB 
% cells(i).trauma_dur=2; %minutes
% cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
% cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
% cells(i).filenum(1,:)='001'; %GPIAS
% cells(i).filenum(2,:)='002'; %GPIAS
% cells(i).filenum(3,:)='003'; %GPIAS
% cells(i).filenum(4,:)='004'; %NBASR
% cells(i).filenum(5,:)='005'; %NBASR
% cells(i).filenum(6,:)='006'; %GPIAS
% cells(i).filenum(7,:)='007'; %GPIAS
% cells(i).filenum(8,:)='008'; %GPIAS
% cells(i).filenum(9,:)='009'; %GPIAS
% cells(i).filenum(10,:)='010'; %NBASR
% cells(i).filenum(11,:)='013'; %GPIAS
% cells(i).filenum(12,:)='014'; %GPIAS
% cells(i).filenum(13,:)='015'; %GPIAS
% cells(i).filenum(14,:)='016'; %GPIAS
% cells(i).filenum(15,:)='017'; %GPIAS
% cells(i).filenum(16,:)='018'; %NBASR

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='071410kta';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='12:30pm'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='072610';
cells(i).session='001';
cells(i).trauma_start='2:45pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR %%I think this is the wonky time point that shows up as 498 minutes
cells(i).filenum(5,:)='005'; %NBASR
cells(i).filenum(6,:)='006'; %GPIAS restless
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %GPIAS
cells(i).filenum(9,:)='009'; %GPIAS
cells(i).filenum(10,:)='010'; %NBASR
cells(i).filenum(11,:)='011'; %GPIAS
cells(i).ratin={'12:30pm', '14:40 '}; %best estimates from notebook
cells(i).ratout={'14:15', '4:43 pm'};
    
%commenting out just so we only have 2 days each per animal
% i=i+1; 
% cells(i).user='kt';
% cells(i).rig='rig3';
% cells(i).animalID='071410kta';
% cells(i).day=4; %1=day1, 2=day2, etc
% cells(i).iso=1; %0=no iso, 1=iso
% cells(i).rat_in='3:15pm'; %time rat first put into chamber, use 24hr or am/pm
% cells(i).expdate='072810';
% cells(i).session='001';
% cells(i).trauma_start='4:40pm'; %use 24hr or am/pm
% cells(i).trauma_freq=17000; %Hz
% cells(i).trauma_level=115; %dB 
% cells(i).trauma_dur=2; %minutes
% cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
% cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
% cells(i).filenum(1,:)='001'; %GPIAS first file of the day was actually mad-072810-002-006, forgot to switch user
% cells(i).filenum(2,:)='002'; %GPIAS
% cells(i).filenum(3,:)='003'; %GPIAS
% cells(i).filenum(4,:)='004'; %NBASR
% cells(i).filenum(5,:)='005'; %NBASR
% cells(i).filenum(6,:)='006'; %GPIAS
% cells(i).filenum(7,:)='007'; %GPIAS
% cells(i).filenum(8,:)='008'; %GPIAS little restless

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='072110kta';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='8:20am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='072110';
cells(i).session='001';
cells(i).trauma_start='10:25am'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='002'; %GPIAS
cells(i).filenum(2,:)='003'; %GPIAS
cells(i).filenum(3,:)='004'; %GPIAS
cells(i).filenum(4,:)='005'; %NBASR
cells(i).filenum(5,:)='006'; %NBASR "issues with this file" not sure what that means
cells(i).filenum(6,:)='007'; %GPIAS
cells(i).filenum(7,:)='008'; %GPIAS
cells(i).filenum(8,:)='009'; %GPIAS
cells(i).filenum(9,:)='010'; %NBASR
cells(i).filenum(10,:)='011'; %GPIAS
cells(i).filenum(11,:)='012'; %GPIAS
cells(i).filenum(12,:)='013'; %GPIAS
cells(i).filenum(13,:)='014'; %GPIAS
cells(i).filenum(14,:)='015'; %NBASR
cells(i).filenum(15,:)='016'; %GPIAS
cells(i).filenum(16,:)='018'; %GPIAS
cells(i).filenum(17,:)='019'; %NBASR small startles
cells(i).ratin={'8:20am', '10:23am', '10:41am',  '1:00pm' }; %best estimates from notebook
cells(i).ratout={'9:56 am','10:27am', '12:45pm', '3:55pm' }; 

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='072110kta';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='4:55pm'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='072610';
cells(i).session='002';
cells(i).trauma_start='6:14pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='005'; %NBASR
cells(i).filenum(6,:)='006'; %GPIAS
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %GPIAS
cells(i).ratin={'4:55pm', '6:14 pm', '6:30pm' }; %best estimates from notebook
cells(i).ratout={'5:50 pm','6:16 pm' '7:45 pm'}; 
    

%commenting out just so we only have 2 days each per animal
% i=i+1; %this experiment as two expdates because matlab retarted after midnight
% cells(i).user='mad';
% cells(i).rig='rig3';
% cells(i).animalID='072110kta';
% cells(i).day=3; %1=day1, 2=day2, etc
% cells(i).iso=0; %0=no iso, 1=iso
% cells(i).rat_in='9:56pm'; %time rat first put into chamber, use 24hr or am/pm
% cells(i).trauma_start='11:46pm'; %use 24hr or am/pm
% cells(i).trauma_freq=17000; %Hz
% cells(i).trauma_level=115; %dB 
% cells(i).trauma_dur=2; %minutes
% cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
% cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
% cells(i).expdate(1,:)='072810';
% cells(i).session(1,:)='001';
% cells(i).filenum(1,:)='001'; %GPIAS
% cells(i).expdate(2,:)='072810';
% cells(i).session(2,:)='001';
% cells(i).filenum(2,:)='002'; %GPIAS
% cells(i).expdate(3,:)='072810';
% cells(i).session(3,:)='001';
% cells(i).filenum(3,:)='003'; %GPIAS
% cells(i).expdate(4,:)='072810';
% cells(i).session(4,:)='001';
% cells(i).filenum(4,:)='004'; %NBASR
% cells(i).expdate(5,:)='072810';
% cells(i).session(5,:)='001';
% cells(i).filenum(5,:)='005'; %GPIAS
% cells(i).expdate(6,:)='072810';
% cells(i).session(6,:)='001';
% cells(i).filenum(6,:)='006'; %NBASR
% cells(i).expdate(7,:)='072910';
% cells(i).session(7,:)='001';
% cells(i).filenum(7,:)='001'; %GPIAS few/no/small startles
% cells(i).expdate(8,:)='072910';
% cells(i).session(8,:)='001'; 
% cells(i).filenum(8,:)='003'; %GPIAS
% cells(i).expdate(9,:)='072910';
% cells(i).session(9,:)='001';
% cells(i).filenum(9,:)='004'; %GPIAS
% cells(i).expdate(10,:)='072910';
% cells(i).session(10,:)='001';
% cells(i).filenum(10,:)='005'; %NBASR

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='080410kta';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='8:10am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='080410';
cells(i).session='001';
cells(i).trauma_start='10:10am'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2.5; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='002'; %GPIAS
cells(i).filenum(2,:)='003'; %GPIAS
cells(i).filenum(3,:)='004'; %GPIAS
cells(i).filenum(4,:)='005'; %NBASR
cells(i).filenum(5,:)='006'; %NBASR
cells(i).filenum(6,:)='007'; %GPIAS
cells(i).filenum(7,:)='008'; %GPIAS
cells(i).filenum(8,:)='009'; %GPIAS
cells(i).filenum(9,:)='010'; %GPIAS
cells(i).filenum(10,:)='013'; %NBASR
cells(i).filenum(11,:)='014'; %GPIAS
cells(i).filenum(12,:)='015'; %GPIAS
cells(i).filenum(13,:)='016'; %GPIAS
cells(i).filenum(14,:)='017'; %NBASR
cells(i).filenum(15,:)='018'; %GPIAS
cells(i).filenum(16,:)='019'; %GPIAS
cells(i).filenum(17,:)='022'; %GPIAS
cells(i).filenum(18,:)='023'; %GPIAS
cells(i).filenum(19,:)='024'; %GPIAS these file numbers may be off
cells(i).filenum(20,:)='025'; %GPIAS these file numbers may be off
cells(i).filenum(21,:)='026'; %GPIAS these file numbers may be off
% cells(i).filenum(22,:)='027'; %NBASR these file numbers may be off
%temporarily commenting out 027 since I think it may have been different
%ASR levels
cells(i).ratin={'8:10am', '10:05am', '10:30am', '1:20pm', '2:40pm'}; 
cells(i).ratout={'9:43am', '10:13am', '1:10pm', '2:00pm', '4:40pm'};

i=i+1; 
cells(i).user='mad';
cells(i).rig='rig3';
cells(i).animalID='080410kta';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='8:45am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='080710';
cells(i).session='001';
cells(i).trauma_start='10:47am'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %GPIAS restless
cells(i).filenum(5,:)='005'; %NBASR
cells(i).filenum(6,:)='008'; %GPIAS restless
cells(i).filenum(7,:)='009'; %NBASR
cells(i).filenum(8,:)='010'; %GPIAS
cells(i).filenum(9,:)='011'; %GPIAS
cells(i).filenum(10,:)='012'; %GPIAS

%commenting out just so we only have 2 days each per animal
% i=i+1; 
% cells(i).user='mad';
% cells(i).rig='rig3';
% cells(i).animalID='080410kta';
% cells(i).day=3; %1=day1, 2=day2, etc
% cells(i).iso=0; %0=no iso, 1=iso
% cells(i).rat_in='7:52am'; %time rat first put into chamber, use 24hr or am/pm
% cells(i).expdate='081110';
% cells(i).session='001';
% cells(i).trauma_start='10:02'; %use 24hr or am/pm
% cells(i).trauma_freq=17000; %Hz
% cells(i).trauma_level=115; %dB 
% cells(i).trauma_dur=2; %minutes
% cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
% cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
% cells(i).filenum(1,:)='001'; %GPIAS
% cells(i).filenum(2,:)='002'; %GPIAS
% cells(i).filenum(3,:)='003'; %GPIAS
% cells(i).filenum(4,:)='004'; %NBASR
% cells(i).filenum(5,:)='006'; %GPIAS
% cells(i).filenum(6,:)='007'; %GPIAS
% cells(i).filenum(7,:)='008'; %NBASR
% cells(i).filenum(8,:)='009'; %GPIAS
% cells(i).filenum(9,:)='010'; %GPIAS

i=i+1; %no NBASR for first ~3 hours post-trauma
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='091610kta';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='10:30am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='092310';
cells(i).session='001';
cells(i).trauma_start='12:00pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='002'; %GPIAS
cells(i).filenum(2,:)='004'; %GPIAS
cells(i).filenum(3,:)='005'; %GPIAS
cells(i).filenum(4,:)='006'; %NBASR
cells(i).filenum(5,:)='008'; %GPIAS
cells(i).filenum(6,:)='009'; %GPIAS
cells(i).filenum(7,:)='010'; %GPIAS
cells(i).filenum(8,:)='013'; %GPIAS
cells(i).filenum(9,:)='015'; %GPIAS
cells(i).filenum(10,:)='017'; %NBASR
cells(i).filenum(11,:)='018'; %GPIAS restless
cells(i).filenum(12,:)='019'; %GPIAS restless
cells(i).filenum(13,:)='020'; %GPIAS
cells(i).filenum(14,:)='021'; %NBASR
cells(i).filenum(15,:)='022'; %GPIAS
cells(i).filenum(16,:)='023'; %GPIAS small/no startles, last ~8 trials messed up
cells(i).filenum(17,:)='024'; %GPIAS few/no startles
cells(i).filenum(18,:)='025'; %NBASR
cells(i).filenum(19,:)='026'; %GPIAS restless, no startles
cells(i).filenum(20,:)='027'; %GPIAS
cells(i).ratin={'10:30am',  '12:24pm','2:50pm','5:40pm'};  
cells(i).ratout={'11:30am', '2:27pm', '5:22pm', '6:51pm'};


i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='091610kta';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='7:00pm'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='092510';
cells(i).session='001';
cells(i).trauma_start='8:26pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='006'; %GPIAS
cells(i).filenum(6,:)='007'; %GPIAS
cells(i).filenum(7,:)='008'; %GPIAS
cells(i).filenum(8,:)='009'; %NBASR
cells(i).ratin={'7:00pm', '8:48pm'};
cells(i).ratout={'8:08pm', '10:13pm'};


i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='101210kta';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='9:05am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='101210';
cells(i).session='001';
cells(i).trauma_start='10:50am'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='005'; %GPIAS
cells(i).filenum(6,:)='006'; %GPIAS
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %NBASR
cells(i).filenum(9,:)='010'; %GPIAS
cells(i).filenum(10,:)='011'; %GPIAS
cells(i).filenum(11,:)='012'; %GPIAS
cells(i).filenum(12,:)='013'; %NBASR
cells(i).filenum(13,:)='014'; %GPIAS
cells(i).filenum(14,:)='015'; %GPIAS restless
cells(i).ratin={'9:05am', '11:08am'};
cells(i).ratout={'10:20am', '2:20pm'};

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='101210kta';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='4:00pm'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='101810';
cells(i).session='001';
cells(i).trauma_start='5:50pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS restless
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %GPIAS
cells(i).filenum(5,:)='005'; %NBASR
cells(i).filenum(6,:)='006'; %GPIAS
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %GPIAS
cells(i).filenum(9,:)='009'; %NBASR
cells(i).ratin={'4:00pm', '6:05pm'}; 
cells(i).ratout={'5:31pm', '7:10pm'};

i=i+1; 
cells(i).user='mad';
cells(i).rig='rig3';
cells(i).animalID='101010mada';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='10:20am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='101610';
cells(i).session='001';
cells(i).trauma_start='1:03pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='004'; %GPIAS
cells(i).filenum(2,:)='005'; %GPIAS
cells(i).filenum(3,:)='006'; %GPIAS
cells(i).filenum(4,:)='007'; %NBASR
cells(i).filenum(5,:)='009'; %GPIAS
cells(i).filenum(6,:)='010'; %GPIAS
cells(i).filenum(7,:)='011'; %GPIAS
cells(i).filenum(8,:)='012'; %NBASR
cells(i).filenum(9,:)='013'; %GPIAS restless

% I think this animal is 101010mada, not 101610mada as was written mw12.21.2010
i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='101010mada';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='9:25am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='101910';
cells(i).session='001';
cells(i).trauma_start='10:56'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='007'; %GPIAS
cells(i).filenum(6,:)='008'; %GPIAS
cells(i).filenum(7,:)='009'; %GPIAS rat turned around
cells(i).filenum(8,:)='010'; %NBASR
cells(i).filenum(9,:)='011'; %GPIAS
cells(i).filenum(10,:)='014'; %GPIAS
cells(i).filenum(11,:)='015'; %NBASR
cells(i).filenum(12,:)='016'; %GPIAS
cells(i).filenum(13,:)='017'; %GPIAS
cells(i).filenum(14,:)='018'; %GPIAS
cells(i).filenum(15,:)='019'; %NBASR
cells(i).ratin={'9:25am', '11:15am', '12:35pm', '2:12pm' }; 
cells(i).ratout={'10:38am', '12:23pm', '1:38pm', '4:08pm'};

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='102510kta';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='3:35pm'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='102510';
cells(i).session='001';
cells(i).trauma_start='5:21pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='005'; %GPIAS
cells(i).filenum(6,:)='006'; %GPIAS
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %NBASR a bit restless

i=i+1; 
cells(i).user='mad';
cells(i).rig='rig3';
cells(i).animalID='102510kta';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='11:52am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='102810';
cells(i).session='001';
cells(i).trauma_start='1:46 pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='005'; %GPIAS
cells(i).filenum(6,:)='006'; %GPIAS
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %NBASR
cells(i).filenum(9,:)='009'; %GPIAS

i=i+1; 
cells(i).user='mad';
cells(i).rig='rig3';
cells(i).animalID='103010mada';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='6:03am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='103110';
cells(i).session='001';
cells(i).trauma_start='7:40am'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes !!!!!RAT WOKE UP AFTER 20s PUT BACK UNDER AND DID FULL 2min!!!!!
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='006'; %GPIAS
cells(i).filenum(6,:)='007'; %GPIAS
cells(i).filenum(7,:)='008'; %GPIAS
cells(i).filenum(8,:)='009'; %NBASR
cells(i).filenum(9,:)='010'; %GPIAS

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='103010mada';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='9:55am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='110210';
cells(i).session='001';
cells(i).trauma_start='11:35'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='005'; %GPIAS
cells(i).filenum(6,:)='006'; %GPIAS
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %NBASR

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='112210kta';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='3:30pm'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='112210';
cells(i).session='001';
cells(i).trauma_start='5:02pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='002'; %GPIAS !!!!!001 was accidentaily overwritten by 4th file due to matlab restart!!!!!
cells(i).filenum(2,:)='003'; %GPIAS
cells(i).filenum(3,:)='004'; %NBASR
cells(i).filenum(4,:)='001'; %GPIAS
cells(i).filenum(5,:)='006'; %GPIAS
cells(i).filenum(6,:)='007'; %GPIAS
cells(i).filenum(7,:)='008'; %NBASR

i=i+1; 
cells(i).user='mad';
cells(i).rig='rig3';
cells(i).animalID='112210kta';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='4:29am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='112510';
cells(i).session='001';
cells(i).trauma_start='6:18am'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %GPIAS
cells(i).filenum(2,:)='002'; %GPIAS
cells(i).filenum(3,:)='003'; %GPIAS
cells(i).filenum(4,:)='004'; %NBASR
cells(i).filenum(5,:)='005'; %GPIAS
cells(i).filenum(6,:)='006'; %GPIAS
cells(i).filenum(7,:)='007'; %GPIAS
cells(i).filenum(8,:)='008'; %NBASR
cells(i).filenum(9,:)='009'; %GPIAS

i=i+1; 
cells(i).user='mad';
cells(i).rig='rig3';
cells(i).animalID='012411mada';
cells(i).day=1; %1=day1, 2=day2, etc
cells(i).iso=1; %0=no iso, 1=iso
cells(i).rat_in='6:48m'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='012411';
cells(i).session='001';
cells(i).trauma_start='8:57pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='beyma'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='001'; %
cells(i).filenum(2,:)='002'; %
cells(i).filenum(3,:)='003'; %
cells(i).filenum(4,:)='004'; %
cells(i).filenum(5,:)='006'; %
cells(i).filenum(6,:)='007'; %
cells(i).filenum(7,:)='008'; %
cells(i).filenum(8,:)='009'; %

i=i+1; 
cells(i).user='kt';
cells(i).rig='rig3';
cells(i).animalID='012411mada';
cells(i).day=2; %1=day1, 2=day2, etc
cells(i).iso=0; %0=no iso, 1=iso
cells(i).rat_in='8:45am'; %time rat first put into chamber, use 24hr or am/pm
cells(i).expdate='012711';
cells(i).session='001';
cells(i).trauma_start='12:21pm'; %use 24hr or am/pm
cells(i).trauma_freq=17000; %Hz
cells(i).trauma_level=115; %dB 
cells(i).trauma_dur=2; %minutes
cells(i).trauma_speaker='beyma'; %'PO-55T' or 'beyma'
cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
cells(i).filenum(1,:)='005'; %
cells(i).filenum(2,:)='006'; %
cells(i).filenum(3,:)='007'; %
cells(i).filenum(4,:)='008'; %
cells(i).filenum(5,:)='009'; %
cells(i).filenum(6,:)='010'; %
cells(i).filenum(7,:)='011'; %
cells(i).filenum(8,:)='012'; %


%template
%i=i+1; 
%cells(i).user='';
%cells(i).rig='rig3';
%cells(i).animalID='';
%cells(i).day=; %1=day1, 2=day2, etc
%cells(i).iso=; %0=no iso, 1=iso
%cells(i).rat_in=''; %time rat first put into chamber, use 24hr or am/pm
%cells(i).expdate='';
%cells(i).session='';
%cells(i).trauma_start=''; %use 24hr or am/pm
%cells(i).trauma_freq=17000; %Hz
%cells(i).trauma_level=115; %dB 
%cells(i).trauma_dur=2; %minutes
%cells(i).trauma_speaker='PO-55T'; %'PO-55T' or 'beyma'
%cells(i).earplug='left'; %ear plugged during trauma: 'left', 'right', 'none'
%cells(i).filenum(1,:)=''; %
%cells(i).filenum(2,:)=''; %
%cells(i).filenum(3,:)=''; %
%cells(i).filenum(4,:)=''; %
%cells(i).filenum(5,:)=''; %
%cells(i).filenum(6,:)=''; %
%cells(i).filenum(7,:)=''; %
%cells(i).filenum(8,:)=''; %
%cells(i).filenum(9,:)=''; %
%cells(i).filenum(10,:)=''; %

