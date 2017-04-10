function CatStimulusProtocol(stimuli, varargin)
%usage: CatStimulusProtocol(stimuli)
%       CatStimulusProtocol(stimuli, 'all') to list every single stimulus
%unpacks a stimulus protocol and lists all the stimuli in it
%input:
%either the "stimuli" variable stored in the protocol file, or the protocol filename
if nargin==0 fprintf('\nno input\n');return;end
if ischar(stimuli)
    stimfile=stimuli;
    load(stimfile)
end

fprintf('\nname: %s',  stimuli(1).param.name)
fprintf('\ndescription: %s\n',  stimuli(1).param.description)

if nargin==2
    if strcmp(varargin{1}, 'all')
        for i=2:length(stimuli)
            fprintf('\n%s', stimuli(i).type)
            names=fieldnames(stimuli(i).param);
            for j=1:length(names)
                fprintf(', %s %g', names{j}, getfield(stimuli(i).param, names{j}))
            end
        end
    end
end

fprintf('\nunique stimulus types:')
for i=2:length(stimuli)
alltypes{i-1}=stimuli(i).type;
end
alltypes=unique(alltypes);
fprintf('\n%s', alltypes{:})

    
    
%get all field names
allnames={};
for i=2:length(stimuli)
    names=fieldnames(stimuli(i).param);
    allnames={allnames{:}, names{:}};
end
allnames=unique(allnames);
allvalues(length(allnames)).values=[]; %initialize struct array

%now accumulate all values for those field names
for i=2:length(stimuli)
    for j=1:length(allnames)
        if isfield(stimuli(i).param, allnames{j})
            allvalues(j).values= [allvalues(j).values getfield(stimuli(i).param, allnames{j})];
        end
    end
end

fprintf('\n\nunique values:')
for j=1:length(allnames)
    fprintf('\n%s (%d)', allnames{j}, length(unique(allvalues(j).values)))
    fprintf(' %g', unique(allvalues(j).values))
end


fprintf('\n')


