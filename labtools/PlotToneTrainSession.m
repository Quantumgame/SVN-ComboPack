
expdate='111406';
session='002';


%  process
for filenum={ '002','003'}
%     ProcessToneTrain(expdate, session, filenum{:})
%     PlotToneTrain(expdate, session, filenum{:})

    %ProcessToneTrain_A1(expdate, session, filenum{:})
end
for filenum={ '003','006', '008', '010'}
%    ProcessToneTrain_A1(expdate, session, filenum{:})
    PlotToneTrain_A1(expdate, session, filenum{:})
end

return



%plot
i=0;
yl=[-6 30];

i=i+1;
filenum='030';
PlotToneTrain_A1(expdate, session, filenum)
ylim(yl)
h(i)=gcf;

i=i+1;
filenum='031';
PlotToneTrain_A1(expdate, session, filenum)
ylim(yl)
h(i)=gcf;

i=i+1;
filenum='032';
PlotToneTrain_A1(expdate, session, filenum)
ylim(yl)
h(i)=gcf;


i=i+1;
filenum='033';
PlotToneTrain_A1(expdate, session, filenum)
ylim(yl)
h(i)=gcf;


i=i+1;
filenum='034';
PlotToneTrain_A1(expdate, session, filenum)
ylim(yl)
h(i)=gcf;

combplot(h, [5 1])