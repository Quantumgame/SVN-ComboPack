function mainLog=E2MergeExperimentalLogs(datadir)

mainLog=[];

if nargin<1 | isempty(datadir)
    datadir=pwd;
end

% get all dirs in datadir (=sessions)
origDir=pwd;
cd(datadir);
sessiondirs=dir('*');
sessiondirs=sessiondirs([sessiondirs.isdir]);
sessiondirnames={sessiondirs.name};
sessiondirnames(1:2)=[];

for session=sessiondirnames
    current=pwd;
    cd(session{:});
    
    expdirs=dir('*');
    expdirs=expdirs([expdirs.isdir]);
    expdirnames={expdirs.name};
    expdirnames(1:2)=[];
    
    for exp=expdirnames
        current2=pwd;
        cd(exp{:});
        files=dir('*-log*');
        if ~isempty(files)
            load(files(1).name);
            expLog.RelativePath=[session{:} '/' exp{:}];
            mainLog=[mainLog expLog];
        end
        cd(current2);
    end
    cd(current);
end
    
cd(origDir);