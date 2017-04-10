function PlayProtocol

% standalone function (not an exper module) that loads a stimulus protocol and
% plays it. The idea is to be able to play a tuning curve or other stimulus
% over the speakers of any computer, instead of having to use a rig
% computer and listen to the sound inside the booth. Non-sound stimuli
% such as voltage clamp commands or analog out pulses are plotted to a figure window.
%note: doesn't quite work yet for voltage cammand protocols
%mw 112410

global  pref
if isempty(pref)
    Prefs;
end

%select and load protocol
currentdir=pwd;
cd(pref.stimuli);
[filename, pathname] = uigetfile('*.mat', 'Pick a protocol file');
cd(currentdir);
if isequal(filename,0) | isequal(pathname,0)
    fprintf('\nCancelled\n')
    return;
else

    stimuli=load(fullfile(pathname , filename));
    f=fieldnames(stimuli);
    stimuli=eval(['stimuli.' f{1}]);        % we take the first field in the loaded structure
    if strcmpi(stimuli(1).type,'exper2 stimulus protocol')

        desc=stimuli(1).param.description;

        fprintf('\ndescription:\n%s', desc)
        name=stimuli(1).param.name;
        fprintf('\nname:\n%s',name)

    end
end

soundfig=figure;
aofig=figure;
pos=get(aofig, 'pos');
pos(2)=pos(2)-pos(4);
set(aofig, 'pos', pos);




for stimnum=2:length(stimuli)

    stimulus=stimuli(stimnum);

    if ~isstruct(stimulus)
        fprintf('\nNot a correct stimulus');
        return;
    end

    if iscell(stimulus.type)            % multiple stimuli
        stimtypes=stimulus.type(:)';    % this makes sure, it's a row vector
        stimparams=stimulus.param(:)';
    else
        stimtypes={stimulus.type};
        stimparams={stimulus.param};
    end

    stimlength=[]; % duration (length) of stimulus

    n=length(stimtypes);
    for stimidx=1:n                     % stimulus index

        atype=stimtypes{stimidx};
        try
            typeidx=strcmp(pref.stimulitypes(:,1),atype);
            typefcn=pref.stimulitypes(typeidx,2);
            typefcn=typefcn{:};
            typetrg=pref.stimulitypes(typeidx,3);
            typetrg=typetrg{:};
        catch
            error(['Unknown stimulus type: ' atype]);
        end



        notfile=~isfield(stimparams{stimidx},'file');     % we want to load the stimulus from file

        % load the required stimulus
        switch typetrg
            case 'sound'

                samplerate=44100;
                if notfile
                    %note: we do not calibrate tone amplitudes
                    sample=feval(typefcn,stimparams{stimidx},samplerate);
                else
                    sample=load(fullfile(pref.stimuli, stimparams{stimidx}.file));    % we know this field exists. the path to filename is relative to pref.stimuli (=main stimuli directory)
                    f=fieldnames(sample);
                    if isfield(eval(['sample.' f{1} '.param']),'description')
                        stimulus.param.description=eval(['sample.' f{1} '.param.description']);
                    end
                    sample=eval(['sample.' f{1} '.sample']);        % we take the first field in the loaded structure
                end
                if~isempty(sample)
                    figure(soundfig)
                    t=1:length(sample);
                    t=1000*t/samplerate;
                    plot(t, sample);
                    shg
                    sound(sample, samplerate)
                    title('sound')
                end

            case 'visual'


            case 'ao'
                samplerate=10e4;
                if notfile
                    sample=feval(typefcn,stimparams{stimidx},samplerate);
                else
                    sample=load([pref.stimuli '\' stimparams{stimidx}.file]);    % we know this field exists. the path to filename is relative to pref.stimuli (=main stimuli directory)
                    f=fieldnames(sample);
                    if isfield(eval(['sample.' f{1} '.param']),'description')
                        stimulus.param.description=eval(['sample.' f{1} '.param.description']);
                    end
                    sample=eval(['sample.' f{1} '.sample']);        % we take the first field in the loaded structure
                end
                if ~isempty(sample)
                    sample=sample(:);  % let's make sure it's a column vector
                    figure(aofig);
                    t=1:length(sample);
                    t=1000*t./samplerate;
                    plot(t, 20*sample);

                    xl=xlim;
                    xl(1)=xl(1)-50;
                    xlim(xl);
                    yl=ylim;
                    yl(2)=1.1*yl(2);
                    ylim(yl);
                    title('AO')
                    shg
                end
        end
    end
    if isfield(stimulus.param, 'next')
        next=stimulus.param.next/1000;
        pause(next)
    end
end %stimnum







