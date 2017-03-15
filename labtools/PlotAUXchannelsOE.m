function PlotAUXchannelsOE(expdate, session, filenum)
% load AUX data from Open Ephys and plots it. AUX data contains movements
% in x, y, and z coorinates.

dbstop if error
x='100_AUX1.continuous';
y='100_AUX2.continuous';
z='100_AUX3.continuous';
filenames={x; y; z};

%get OE data path from exper
gorawdatadir(expdate, session, filenum)
expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filenum);
expstructurename=sprintf('exper_%s', filenum);
if exist(expfilename)==2 %try current directory
    load(expfilename)
    exp=eval(expstructurename);
    stimuli=exp.stimulusczar.param.stimuli.value;
    isrecording=exp.openephyslinker.param.isrecording.value;
    oepathname=exp.openephyslinker.param.oepathname.value;
else %try data directory
    cd ../../..
    try
        cd(sprintf('Data-%s-backup',user))
        cd(sprintf('%s-%s',expdate,user))
        cd(sprintf('%s-%s-%s',expdate,user, session))
    end
    if exist(expfilename)==2
        load(expfilename)
        exp=eval(expstructurename);
        stimuli=exp.stimulusczar.param.stimuli.value;
        isrecording=exp.openephyslinker.param.isrecording.value;
        oepathname=exp.openephyslinker.param.oepathname.value;
    else
        fprintf('\ncould not find exper structure. Cannot get OE file info.')
    end
end
%used to be on C drive
if strcmp(oepathname(1),'c')
    oepathname(1)='d';
    fprintf('\n changing drive from c to d in oepathname. the data has been moved\n');
    
end
dur=stimuli{1}.param.duration;
isi=stimuli{2}.param.next;
cd(oepathname)

%load files
for i=1:3
    filename=filenames{i,:};
[data, alltimestamps, info] = load_open_ephys_data(filename);
samprate=info.header.sampleRate;

figure; plot(data);
title(sprintf('raw AUX data #%.0f in SR, %s-%s-%s', i, expdate, session, filenum));
end


