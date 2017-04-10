function CombineStimulusProtocols
%simple function for combining stimulus protocols into a single protocol
%uses a dialog box to select protocols
%they are combined in the order you select them
%no limit on number to combine

global pref
cont=1;
%alltcs=[];
name={};
description={};
tcfilenames={};
i=1; %individual tone index
k=0; %protocol index
while cont
    cd(pref.stimuli)
    [tcfilename, tcpathname] = uigetfile('*.mat', 'Choose stimulus protocol, or cancel to finish');
    if isequal(tcfilename,0) || isequal(tcpathname,0)
        disp('User pressed cancel')
        cont=0;
    else
        disp(['User selected ', fullfile(tcpathname, tcfilename)])
    end
    
    if cont
k=k+1;
        tc=load(fullfile(tcpathname, tcfilename));
 %       alltcs=[alltcs tc];
name{k}= tc.stimuli(1).param.name;
description{k}= tc.stimuli(1).param.description;
tcfilenames{k}=tcfilename;
        for nn=2:length(tc.stimuli)
            i=i+1;
            stimuli(i).type=tc.stimuli(nn).type;
            stimuli(i).param=tc.stimuli(nn).param;
                        
        end
    end
    
end
    %finalize stimuli structure
    
    
    
    stimuli(1).type='exper2 stimulus protocol';
    stimuli(1).param.name= sprintf('Comb_%s', strcat(name{:}));
    stimuli(1).param.description= sprintf('Comb_%s', strcat(description{:}));
    filename=sprintf('Comb_%s', strcat(tcfilenames{:}));
    
    cd(pref.stimuli) %where stimulus protocols are saved
    cd('Combined Protocols')
    save(filename, 'stimuli')
    fprintf('\nwrote file %s in directory %s', filename, pwd)
    
    
