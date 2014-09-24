function oepathname=getOEdatapath(expdate, session, filenum)
%get OE data path from exper
    gorawdatadir(expdate, session, filenum)
    expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filenum);
    expstructurename=sprintf('exper_%s', filenum);
    if exist(expfilename)==2 %try current directory
        load(expfilename)
        exp=eval(expstructurename);
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
            isrecording=exp.openephyslinker.param.isrecording.value;
            oepathname=exp.openephyslinker.param.oepathname.value;
        else
            fprintf('\ncould not find exper structure. Cannot get OE file info.')
        end
    end
