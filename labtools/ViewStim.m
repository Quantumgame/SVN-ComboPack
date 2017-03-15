function ViewStim(varargin)
%spits out all fields of stimulus protocol structure
if nargin==0
    wd=pwd;
    cd D:\wehr\exper2.2\protocols
    [filename, path] = uigetfile('*.mat', 'choose stimulus protocol file');
    cd(path)
    load(filename)
    cd(wd)
elseif nargin==1
    filename=varargin{1};
    load(filename)
else error('wrong number of inputs')
end

% fprintf('\n%s\n%s\n%s', stimuli(1).type, stimuli(1).param.description, stimuli(1).param.name)
% for i=2:length(stimuli)
%     if strcmp( stimuli(i).type,'tone')
%         fprintf('\n%s %.1f \t%d %d %d',  stimuli(i).type, stimuli(i).param.frequency, stimuli(i).param.amplitude, stimuli(i).param.ramp, stimuli(i).param.duration);
%     elseif strcmp(stimuli(i).type,'whitenoise')
%         fprintf('\n%s \t%d %d %d',  stimuli(i).type, stimuli(i).param.amplitude, stimuli(i).param.ramp, stimuli(i).param.duration);
%     end
% end

for i=1:length(stimuli)
    fprintf('\n%s ',stimuli(i).type)
    for fn=fieldnames(stimuli(i).param)'
        if isnumeric(stimuli(i).param.(fn{:}))
            fprintf(' %.0f\t', stimuli(i).param.(fn{:}))
        elseif ischar(stimuli(i).param.(fn{:}))
            if i==1 fprintf('\n');end
            fprintf(' %s', stimuli(i).param.(fn{:}))
        end
    end
end
