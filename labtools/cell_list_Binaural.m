

function animals=cell_list_Binaural
%cell list for the Binaural project
%
% Last update: 20feb2011 by mak
% Whit's last experiment added was: 090910
% mak's last experiment added was 021111

% % Copy and paste as needed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i=i+1; % i=experiment number
% j=0; % j=cell number; resets for each animal
% animals(i).experimentID=''; 
% animals(i).age=; % in post-natal days
% animals(i).mass=; % in grams
% animals(i).earpiececheck_notes=''; % Both sealed, unobstructed, patent, & disease free
% animals(i).a1=''; % y=yes, n=no, m=maybe: as established by tonotopy
% 
% j=j+1;
% k=0;% k=file number; resets for each cell
% animals(i).ephys.site(j).user='';
% animals(i).ephys.site(j).depth=; % um
% animals(i).ephys.site(j).CF=; % kHz; 0 for unknown 
% animals(i).ephys.site(j).vout=; % mV
% animals(i).ephys.site(j).notes='';
% animals(i).ephys.site(j).lostat1performed='no'; % yes or no
% animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?
% 
% k=k+1; % 
% animals(i).ephys.site(j).file(k).session='00';
% animals(i).ephys.site(j).file(k).filenum='00';
% animals(i).ephys.site(j).file(k).mode=''; % vc, i0, inorm, sa, lca, ca, lfp
% % animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=0; % Let's begin, shall we :) GO SCIENCE!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='021111'; 
animals(i).age=22; % in post-natal days
animals(i).mass=48; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=435; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.6; % mV
animals(i).ephys.site(j).notes='Some escaped spikes need to be removed, lostat was done';
animals(i).ephys.site(j).lostat1performed='yes'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=100; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='020411'; 
animals(i).age=22; % in post-natal days
animals(i).mass=46; % in grams
animals(i).earpiececheck_notes='R ear piece completely blocked! L ear piece partially blocked; Both sealed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=592; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.7; % mV
animals(i).ephys.site(j).notes='Data is wonky, I will need to fix the holdcmds so they are accurate!';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=137; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='012811'; 
animals(i).age=22; % in post-natal days
animals(i).mass=43; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=531; % um
animals(i).ephys.site(j).CF=4; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=5.2; % mV
animals(i).ephys.site(j).notes='Some escaped spikes in VC';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='012111'; 
animals(i).age=22; % in post-natal days
animals(i).mass=39; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=387; % um
animals(i).ephys.site(j).CF=2.4; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.8; % mV
animals(i).ephys.site(j).notes='Need to remove spikes in VC, small G';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=48; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='012011'; 
animals(i).age=20; % in post-natal days
animals(i).mass=37; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=276; % um
animals(i).ephys.site(j).CF=2; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4.6; % mV
animals(i).ephys.site(j).notes='Nothing special, but it did spike a little and it has decent VC';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='011911'; 
animals(i).age=20; % in post-natal days
animals(i).mass=37; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=303; % um
animals(i).ephys.site(j).CF=4; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=10.4; % mV
animals(i).ephys.site(j).notes='Spiked & good VC!';
animals(i).ephys.site(j).lostat1performed='yes'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=86; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='011411'; 
animals(i).age=22; % in post-natal days
animals(i).mass=43; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=206; % um
animals(i).ephys.site(j).CF=4.3; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2; % mV
animals(i).ephys.site(j).notes='escaped spikes in vc, no spikes in i=0';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='010611'; 
animals(i).age=20; % in post-natal days
animals(i).mass=33; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=234; % um
animals(i).ephys.site(j).CF=2.8; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.6; % mV
animals(i).ephys.site(j).notes='This is the second cell from 010511 but recorded after midnight';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='010511'; 
animals(i).age=20; % in post-natal days
animals(i).mass=33; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=198; % um
animals(i).ephys.site(j).CF=2.8; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.2; % mV
animals(i).ephys.site(j).notes='There is a second cell from today but from after midnight, thus it is listed as exp 010611';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=54; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='121910'; 
animals(i).age=23; % in post-natal days
animals(i).mass=46; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=217; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.2; % mV
animals(i).ephys.site(j).notes='lost cell 700/725 on file 002';
animals(i).ephys.site(j).lostat1performed='yes'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='121310'; 
animals(i).mass=62; % in grams
animals(i).age=25; % in post-natal days
animals(i).earpiececheck_notes='L mic partial obstruction; Both sealed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='n'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=211; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=6.4; % mV
animals(i).ephys.site(j).notes='Crappy data set';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=143; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='120810'; 
animals(i).mass=49; % in grams
animals(i).age=27; % in post-natal days
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=347; % um
animals(i).ephys.site(j).CF=4.3; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=378; % um
animals(i).ephys.site(j).CF=6.7; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4.2; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=357; % um
animals(i).ephys.site(j).CF=6.7; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.6; % mV
animals(i).ephys.site(j).notes='For file 006 I forced it +50 even thought the vctc was set to +20';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='102710'; 
animals(i).age=28; % in post-natal days
animals(i).mass=65; % in grams
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='n'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=321; % um
animals(i).ephys.site(j).CF=3.2; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0.7; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=233; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lfp'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=271; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.3; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=90; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=224; % um
animals(i).ephys.site(j).CF=6.7; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.2; % mV
animals(i).ephys.site(j).notes='Cell fell off during first file';
animals(i).ephys.site(j).lostat1performed='yes'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=225; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.3; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=200; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='102510'; 
animals(i).age=26; % in post-natal days
animals(i).mass=57; % in grams
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='m'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=346; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-3.8; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=327; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-0.9; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=175; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='102010'; 
animals(i).mass=54; % in grams
animals(i).age=27; % in post-natal days
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=326; % um
animals(i).ephys.site(j).CF=5; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0.2; % mV
animals(i).ephys.site(j).notes='I took the TC at 548 um';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lfp'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=450; % um
animals(i).ephys.site(j).CF=10.3; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-1.4; % mV
animals(i).ephys.site(j).notes='didn''t really ever go into depo block';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=95; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=116; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=214; % um
animals(i).ephys.site(j).CF=3.7; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-0.2; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=106; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='101910'; 
animals(i).mass=49; % in grams
animals(i).age=26; % in post-natal days
animals(i).earpiececheck_notes='R ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=175; % um
animals(i).ephys.site(j).CF=3.7; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-2.2; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=126; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=126; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='101810'; 
animals(i).mass=45; % in grams
animals(i).age=26; % in post-natal days
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=206; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.9; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=365; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=143; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.8; % mV
animals(i).ephys.site(j).notes='Cell fell off, then I got WC again !!!???';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=290; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=6.2; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='101110'; 
animals(i).mass=60; % in grams
animals(i).age=26; % in post-natal days
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=327; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.2; % mV
animals(i).ephys.site(j).notes='fell off during BinVCTC';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=229; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-1.5; % mV
animals(i).ephys.site(j).notes='fell off during BinVCTC';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='100610'; 
animals(i).mass=33; % in grams
animals(i).age=20; % in post-natal days
animals(i).earpiececheck_notes='L ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=218; % um
animals(i).ephys.site(j).CF=5.8; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-1.7; % mV
animals(i).ephys.site(j).notes='full data set with cf!!!; CF binvctc had poor vc';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=73; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='100410'; 
animals(i).mass=54; % in grams
animals(i).age=26; % in post-natal days
animals(i).earpiececheck_notes='L ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=552; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-0.3; % mV
animals(i).ephys.site(j).notes='Unstable recording; cell knocked off due to insistent cpu control';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='092910'; 
animals(i).mass=31; % in grams
animals(i).age=20; % in post-natal days
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=407; % um
animals(i).ephys.site(j).CF=12; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-14.3; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=100.4; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=390; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.5; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='partial data set';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=178; % um
animals(i).ephys.site(j).CF=12; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=13.3; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=50; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=131; % um
animals(i).ephys.site(j).CF=12; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='092710'; 
animals(i).mass=54; % in grams
animals(i).age=26; % in post-natal days
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=156; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4.5; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='092210'; 
animals(i).mass=68; % in grams
animals(i).age=26; % in post-natal days
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=238; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0.5; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='very poor recording';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=117; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=250; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=14.3; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='unresponsive to stimuli';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1;
j=0; 
animals(i).experimentID='090910'; 
animals(i).mass=42;
animals(i).age=20; 
animals(i).earpiececheck_notes='R ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=730; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='Spiked in burst like pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=855; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='Spikes fired in island of activity';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=528; 
animals(i).ephys.site(j).CF=6.7;  
animals(i).ephys.site(j).notes='Very clear spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='017';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='018';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=6.7

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='019';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF, might have lost cell during recording

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1;
j=0; 
animals(i).experimentID='090810'; 
animals(i).mass=53;
animals(i).age=27; 
animals(i).earpiececheck_notes='L ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;% k=file number

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=77; % um
animals(i).ephys.site(j).CF=2.1; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.7; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lfp'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=256; 
animals(i).ephys.site(j).CF=4.3;  
animals(i).ephys.site(j).notes='Few spikes but in a pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=4.3

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=358; 
animals(i).ephys.site(j).CF=5.8;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=5.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=790; 
animals(i).ephys.site(j).CF=4.3;  
animals(i).ephys.site(j).notes='Spiked in clear pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='017';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC CF=4.3

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='018';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=359; 
animals(i).ephys.site(j).CF=5.8;  
animals(i).ephys.site(j).notes='Cell had small spikes in clear pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='019';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='020';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, TC=5.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='021';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=470; 
animals(i).ephys.site(j).CF=5.8;  
animals(i).ephys.site(j).notes='Cell fired in an island of activity but no very apparent spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='022';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='023';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=5.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='024';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=630; 
animals(i).ephys.site(j).CF=5.8;  
animals(i).ephys.site(j).notes='Cell had distinctive spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='025';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='026';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=5.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='027';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=423; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='Fery few spikes and no apparent spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='028';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=568; 
animals(i).ephys.site(j).CF=6.7;  
animals(i).ephys.site(j).notes='No apparent spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='029';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='030';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=6.3

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='031';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=664; 
animals(i).ephys.site(j).CF=4.3;  
animals(i).ephys.site(j).notes='Cell had clear spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='031';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='033';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=5.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='034';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1;
j=0; 
animals(i).experimentID='090710'; 
animals(i).mass=47;
animals(i).age=26; 
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=475; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='No apparent spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=610; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=800; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='Only a few small spikes';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=530; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='No apparent spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=470; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='No apparent spiking pattern';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=684; 
animals(i).ephys.site(j).CF=5.8;  
animals(i).ephys.site(j).notes='Possible island of facilitation';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=5.8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='082610'; 
animals(i).mass=42;
animals(i).age=21; 
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;% k=file number

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=187; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4.4; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
j=j+1;
k=0;% k=file number

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=174; % um
animals(i).ephys.site(j).CF=16; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-3.4; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='Cortex was damaged nearby, before taking this recording';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=85; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=371; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='082510'; 
animals(i).mass=40;
animals(i).age=20; 
animals(i).earpiececheck_notes='R ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=296; 
animals(i).ephys.site(j).CF=5.0;  
animals(i).ephys.site(j).notes='Began losing cell by file 082510-002-002';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, cf=5.0

k=k+1;
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='081910'; 
animals(i).mass=31;
animals(i).age=21; 
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=269; % um
animals(i).ephys.site(j).CF=1.3; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-2.5; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='File 002-001 needs a catch in ProcessBinVCData to bypass event 723, it''s been done on rig2';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=230; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca, lfp
animals(i).ephys.site(j).file(k).inorm=230; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=361; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='081810'; 
animals(i).mass=30;
animals(i).age=20; 
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=228; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.6; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='File 001-002 cap comp adjusted on trial 13/360';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=450; 
animals(i).ephys.site(j).CF=1.8;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=1.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='081210'; 
animals(i).mass=36;
animals(i).age=21; 
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy
animals(i).earpiececheck_notes='Neither sealed, L ear mic tube partially blocked; Both patent & disease free'; % Both sealed, unobstructed, patent, & disease free

j=j+1;
k=0;% k=file number; resets for each cell

animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=205; % um
animals(i).ephys.site(j).CF=4.3; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.2; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes=sprintf('File 003-002 cap comp was adjusted at file 180/360\nGreat Bin suppression example!\nFile 003-005 needs a catch in ProcessBinVCData to bypass event 720, it''s been done on rig2');
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=111; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=424; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
animals(i).experimentID='081110'; 
animals(i).mass=33;
animals(i).age=20; 
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=0; 
j=j+1;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=604; 
animals(i).ephys.site(j).CF=2.1;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=0;
k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=2.1

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='081010'; 
animals(i).mass=66;
animals(i).age=27; 
animals(i).a1='y';
animals(i).earpiececheck_notes='Incorrect speaker calibration, see pg 121 of my notebook; R ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=159; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-0.7; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='file 002-002 had 20 trials';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=784; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=863; 
animals(i).ephys.site(j).CF=2.4;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=2.4

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=726; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=2.1

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=671; 
animals(i).ephys.site(j).CF=2.4;  %CF not very clear
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=2.4

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='017';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=412; 
animals(i).ephys.site(j).CF=2.4;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='019';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='020';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=2.4

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='021';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=853; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='022';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='023';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='080910'; 
animals(i).mass=56;
animals(i).age=26; 
animals(i).a1='y';
animals(i).earpiececheck_notes='L ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=207; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=7; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=150; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=247; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=5.6; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=124; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=503; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1;
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=643; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=576; 
animals(i).ephys.site(j).CF=2.1;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=2.1

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF
 
j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=675; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=846; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='009';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='080410'; 
animals(i).mass=63;
animals(i).age=26; 
animals(i).a1='y';
animals(i).earpiececheck_notes='R ear not sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=254; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.6; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=257; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.6; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=119; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=140; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=140; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=341; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=7; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=170; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=592; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=6; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='This is an excellent example of Bin Suppression with a large hotspot.';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=122; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='005';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=271; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.6; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='006';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='006';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='006';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=210; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='006';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=151; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=236; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=5.2; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='007';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='007';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=536; 
animals(i).ephys.site(j).CF=2.8;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=2.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=726; 
animals(i).ephys.site(j).CF='1.5';  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=1.5

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='080210'; 
animals(i).mass=49;
animals(i).age=24; 
animals(i).a1='y';
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=239; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-1; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=195; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
% k=k+1; % 
% animals(i).ephys.site(j).file(k).session='003';
% animals(i).ephys.site(j).file(k).filenum='003';
% animals(i).ephys.site(j).file(k).mode='sa'; % vc, i0, inorm, sa, lca, ca
% % animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=387; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.2; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=253; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0.3; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='006';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='006';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=417; 
animals(i).ephys.site(j).CF=6.7;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=6.7

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF


j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=733; 
animals(i).ephys.site(j).CF='7.7';  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=7.7

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=544; 
animals(i).ephys.site(j).CF=6.7;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='017';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC CF=6.7

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='018';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=925; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='019';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='021';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='072910'; 
animals(i).mass=38;
animals(i).age=21; 
animals(i).a1='y';
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=268; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-8.8; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=201; % um
animals(i).ephys.site(j).CF=2.1; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=25; % mV
animals(i).ephys.site(j).lostat1performed='yes'; % yes or no
animals(i).ephys.site(j).notes='tuned 2.1 to 2.4 kHz';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=437; 
animals(i).ephys.site(j).CF=1.8;  
animals(i).ephys.site(j).notes='Good cell, small but frequent spiker';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=1.8

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF


j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=658; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, not tuned

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=422; 
animals(i).ephys.site(j).CF=1.8;  
animals(i).ephys.site(j).notes='Good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='022';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='023';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC CF=1.8

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='024';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='072810'; 
animals(i).mass=33;
animals(i).age=20; 
animals(i).earpiececheck_notes='Neither sealed; Both unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=150; % um
animals(i).ephys.site(j).CF=10; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-4.1; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='file 002-002 appear to show another cell, possible gap junction?';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=50; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=151; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=368; % um
animals(i).ephys.site(j).CF=10.3; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0.8; % mV
animals(i).ephys.site(j).lostat1performed='no'; % yes or no 
animals(i).ephys.site(j).notes='during file 003-002 i turned the pipette offset knob';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='inorm'; % vc, i0, inorm, sa, lca, ca
animals(i).ephys.site(j).file(k).inorm=100; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca
% animals(i).ephys.site(j).file(k).inorm=; % in pA

 
j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=754; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC,not tuned

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=541; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, not tuned

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=682; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=887; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='021';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='022';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, not tuned

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=573; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='025';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='026';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='072710'; 
animals(i).mass=67;
animals(i).age=25; 
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=340; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-0.6; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=238; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-1; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=347; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC,not tuned

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=441; 
animals(i).ephys.site(j).CF=7.2;  
animals(i).ephys.site(j).notes='great cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC,CF=7.2

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=566; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth, responces not stimulous locked

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=698; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, not tuned

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=474; 
animals(i).ephys.site(j).CF=7.2;  
animals(i).ephys.site(j).notes='Great cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, CF=7.2

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=910; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, not tuned
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='072310'; 
animals(i).mass=45;
animals(i).age=22; 
animals(i).earpiececheck_notes=''; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=281; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-4.2; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=276; 
animals(i).ephys.site(j).CF=15.5;  
animals(i).ephys.site(j).notes='could be a good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth, could show supression

k=k+1; 
animals(i).ephys.site(j).file(k).session='011';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC,CF=15.5

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=725; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='Cell became a lot more active, probably dying';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, not tuned, cell became more active hear

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='017';
animals(i).ephys.site(j).file(k).mode='lca'; %taken because cell's more active, so many spikes data could be unclear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='072210'; 
animals(i).mass=41;
animals(i).age=21; 
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=596; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='011';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC,not tuned


j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=584; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, not tuned

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=751; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth, small spikes

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, not tuned
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='071910'; 
animals(i).age=25; 
animals(i).mass=50;
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=244; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='ca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=120; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=6.5; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='ca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;
animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=550; 
animals(i).ephys.site(j).CF=2.1;  
animals(i).ephys.site(j).notes='could be good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='008';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='009';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=2.1

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='010';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=552; 
animals(i).ephys.site(j).CF=4.6;  
animals(i).ephys.site(j).notes='could be good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, CF=4.6

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=705; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='017';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='018';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=961; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='020';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='021';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=443; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='could be a good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='022';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='023';
animals(i).ephys.site(j).file(k).mode='lca';  %plotTC, not tuned
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='071810'; 
animals(i).age=24; % in post-natal days
animals(i).mass=49; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=161; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='ca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='071610'; 
animals(i).mass=43;
animals(i).age=21; 
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=211; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='though there was an occlusion, after removing ear saw it was not occluded and glued ear back on';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=941; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='cell became more active so took another Bin tuning curve';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, not tuned

k=k+1; 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken due to more active cell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='071510'; 
animals(i).mass=38;
animals(i).age=20; 
animals(i).earpiececheck_notes='R mic partially obstructed; Both sealed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=582; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='could be good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='011';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, lost cell before playing whole tuning curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=i+1; 
j=0; 
animals(i).experimentID='071410'; 
animals(i).age=19; 
animals(i).mass=33;
animals(i).earpiececheck_notes='L mic partially obstructed; Both sealed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y';

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=360; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=6.4; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=280; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2; % mV
animals(i).ephys.site(j).notes='woke up after trial 250';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=681; 
animals(i).ephys.site(j).CF=0;  
animals(i).ephys.site(j).notes='could be good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='012';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='013';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC, not tuned

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=396; 
animals(i).ephys.site(j).CF=2.9;  
animals(i).ephys.site(j).notes='could be good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='014';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='015';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC CF=2.9

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=304; 
animals(i).ephys.site(j).CF=2.1;  
animals(i).ephys.site(j).notes='not sure if any good';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='016';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='017';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC CF=2.1

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=697; 
animals(i).ephys.site(j).CF=2.9;  
animals(i).ephys.site(j).notes='not sure if any good';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='018';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='019';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC CF=2.9

j=j+1;
k=0;

animals(i).ephys.site(j).user='whit';
animals(i).ephys.site(j).depth=854; 
animals(i).ephys.site(j).CF=3.4;  
animals(i).ephys.site(j).notes='could be good cell';
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='021';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='022';
animals(i).ephys.site(j).file(k).mode='lca'; %plotTC CF=3.4

k=k+1; 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='023';
animals(i).ephys.site(j).file(k).mode='lca'; %plotBinTC_psth taken at CF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='071210'; 
animals(i).age=25; % in post-natal days
animals(i).mass=57; % in grams
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=190; % um
animals(i).ephys.site(j).CF=6.2; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0; % mV
animals(i).ephys.site(j).notes='lca first, then fell off when trying for wc';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=215; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0; % mV
animals(i).ephys.site(j).notes='lca first, then fell off when trying for wc';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=210; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0; % mV
animals(i).ephys.site(j).notes='lca first, then fell off when trying for wc';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='lca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='060910'; 
animals(i).age=21; % in post-natal days
animals(i).mass=56; % in grams
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=400; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.7; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='051910'; 
animals(i).age=27; % in post-natal days
animals(i).mass=65; % in grams
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=320; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0; % mV
animals(i).ephys.site(j).notes='ca first, then fell off when trying for wc';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='ca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal
animals(i).experimentID='050710'; 
animals(i).age=22; % in post-natal days
animals(i).mass=32; % in grams
animals(i).earpiececheck_notes='not done'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1=''; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=302; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0.6; % mV
animals(i).ephys.site(j).notes='probably lost very early';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='050610'; 
animals(i).age=21; % in post-natal days
animals(i).mass=29; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='n'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=700; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=4.2; % mV
animals(i).ephys.site(j).notes='Xiang got this cell';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='050410'; 
animals(i).age=26; % in post-natal days
animals(i).mass=56; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='n'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=330; % um
animals(i).ephys.site(j).CF=1.8; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=2.0; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='ca'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='001';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='050310'; 
animals(i).age=25; % in post-natal days
animals(i).mass=58; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1=''; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=220; % um
animals(i).ephys.site(j).CF=5.3; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.9; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='006';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='007';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=215; % um
animals(i).ephys.site(j).CF=4.6; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=0.6; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='040610'; 
animals(i).age=26; % in post-natal days
animals(i).mass=57; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='n'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=313; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=8.7; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number; resets for each animal and k resets for each cell
animals(i).experimentID='040410'; 
animals(i).age=24; % in post-natal days
animals(i).mass=42; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='m'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;% k=file number; resets for each cell
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=0; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=17; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

j=j+1;
k=0;% k=file number
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=232; % um
animals(i).ephys.site(j).CF=7.2; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=-3.4; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='003';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number
animals(i).experimentID='040110'; 
animals(i).age=21; % in post-natal days
animals(i).mass=32; % in grams
animals(i).earpiececheck='done'; % done or not done
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='m'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;%k=file number
animals(i).ephys.site(j).user='mak'; 
animals(i).ephys.site(j).depth=340; % um
animals(i).ephys.site(j).CF=8.4; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=3.4; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='002';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='003';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1; % 
animals(i).ephys.site(j).file(k).session='004';
animals(i).ephys.site(j).file(k).filenum='004';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number
animals(i).experimentID='033010'; 
animals(i).age=26; % in post-natal days
animals(i).mass=59; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='n'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;%k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=490; % um
animals(i).ephys.site(j).CF=0; % kHz; 0 for unknown
animals(i).ephys.site(j).vout=1.3; % mV
animals(i).ephys.site(j).notes='';
animals(i).ephys.site(j).lostat1performed='yes'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1; % 
animals(i).ephys.site(j).file(k).session='002';
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=i+1; % i=experiment number
j=0; % j=cell number
animals(i).experimentID='032410'; 
animals(i).age=20; % in post-natal days
animals(i).mass=34; % in grams
animals(i).earpiececheck_notes='Both sealed, unobstructed, patent, & disease free'; % Both sealed, unobstructed, patent, & disease free
animals(i).a1='y'; % y=yes, n=no, m=maybe: as established by tonotopy

j=j+1;
k=0;%k=file number
animals(i).ephys.site(j).user='mak';
animals(i).ephys.site(j).depth=180; % um
animals(i).ephys.site(j).CF=6.2; % kHz; 0 for unknown 
animals(i).ephys.site(j).vout=1.6; % mV
animals(i).ephys.site(j).notes='Ear pieces not equalized';
animals(i).ephys.site(j).lostat1performed='no'; % yes or no
animals(i).ephys.site(j).keep=''; % keep, poorVC, ??? others?

k=k+1;
animals(i).ephys.site(j).file(k).session='006'; % BinVCTC
animals(i).ephys.site(j).file(k).filenum='001';
animals(i).ephys.site(j).file(k).mode='vc'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA
k=k+1;
animals(i).ephys.site(j).file(k).session='006'; % TC
animals(i).ephys.site(j).file(k).filenum='005';
animals(i).ephys.site(j).file(k).mode='i0'; % vc, i0, inorm, sa, lca, ca, lfp
% animals(i).ephys.site(j).file(k).inorm=; % in pA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



