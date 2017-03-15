% expdate1='072106'; %I=0
% session1='006';
% expdate2=expdate1; 
% session2=session1;
% filename1='002';%: pre TC19f2a + 60 s spont act at end
% filename2='003';%: post TC19f2a + 60 s spont act at start & end
% findex=12;
% aindex=2;
expdate1='110406'; %I=0
session1='002';
expdate2=expdate1; 
session2=session1;
filename1='004';%: pre TC19f2a + 60 s spont act at end
filename2='006';%: post TC19f2a + 60 s spont act at start & end
findex=7;
aindex=2;


processed_data_dir1=sprintf('D:\\lab\\Data-processed\\%s-lab',expdate1);
processed_data_session_dir1=sprintf('%s-lab-%s',expdate1, session1);
cd(processed_data_dir1)
cd(processed_data_session_dir1)
eval(sprintf('load out_%s_%s_%s;', expdate1, session1, filename1));
eval(sprintf('load out_%s_%s_%s;', expdate2, session2, filename2));
eval(sprintf('outfile1=out_%s_%s_%s;', expdate1, session1, filename1));
eval(sprintf('outfile2=out_%s_%s_%s;', expdate2, session2, filename2));



ge1=(squeeze(outfile1.GE(findex,aindex, :)));
ge2=(squeeze(outfile2.GE(findex,aindex, :)));
gi1=(squeeze(outfile1.GI(findex,aindex, :)));
gi2=(squeeze(outfile2.GI(findex,aindex, :)));

t=1:length(ge1);
t=t/10;
figure
r=plot(t, ge1, 'g', t, gi1, 'r');
set(r, 'linewidth', 2)

hold on
tpost=t+400;
r=plot(tpost, ge2, 'g', tpost, gi2, 'r');
set(r, 'linewidth', 2)

 t1=text(300, 1.2, '\rightarrow')
 set(t1, 'fontsize', 72)


title(sprintf('%s %s %s: %.1fkHz %ddB', expdate2, session2, filename2, outfile1.freqs(findex)/1000, outfile1.amps(aindex)))
%scale bar
L3=line([650 650], [1 3]);
set(L3, 'linewidth', 2);
T1=text(660, 2, '2nS');

shg










% expdate1='063006'; %I=0
% session1='001';
% expdate2='063006'; %I=0
% session2='001';
% filename1='002';%: pre TC19f2a + 60 s spont act at end
% filename2='003';%: post TC19f2a + 60 s spont act at start & end
% findex=14;
% aindex=2;

% expdate1='062706'; %I=0
% session1='003';
% expdate2=expdate1; 
% session2=session1;
% filename1='002';%: pre TC19f2a + 60 s spont act at end
% filename2='003';%: post TC19f2a + 60 s spont act at start & end
% findex=12;
% aindex=2;
% out=AnalyzePrePostTC(expdate1, session1, filename1, expdate2, session2, filename2);
