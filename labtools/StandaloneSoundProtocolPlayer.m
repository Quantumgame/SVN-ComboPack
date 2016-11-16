function StandaloneSoundProtocolPlayer(varargin)
%a standalone function that will play stimulus protocols over your
%computer's default soundcard. The point is to be able to play a tuning
%curve from just about any computer, without running exper. But, it uses
%helper functions from exper to play the stimuli, so exper needs to be
%installed on your machine. Any non-sound stimuli in the protocol are
%ignored.
%usage: StandaloneSoundProtocolPlayer([path to stimulus protocol])
%if you omit the input [path to stimulus protocol] you'll get a dialogue
%box to choose a file.

global pref
currentdir=pwd;
cd(pref.stimuli);

if nargin==1
    filename=varargin{1};
else
    [filename, pathname] = uigetfile('*.mat', 'Pick a protocol file');
    if isequal(filename,0) || isequal(pathname,0)
        fprintf('\ncancelled.')
        return;
    end
    cd(pathname)
    fprintf('\n%s\n', fullfile(pathname, filename))
end



try
    f1=figure;
    f2=figure;
    pos=get(f2, 'pos');
    pos(1)=pos(1)+pos(3); 
    set(f2, 'pos', pos);
    figure(f1)
    stoph=uicontrol('Style','togglebutton','String','Stop','units', 'normal', 'pos', [.9 .01 .05 .05] );
    isih=uicontrol('Style','togglebutton','String','use ISI','units', 'normal', 'pos', [.8 .01 .09 .05]);
    
    stimuli=load( filename);
    f=fieldnames(stimuli);
    stimuli=eval(['stimuli.' f{1}]);        % we take the first field in the loaded structure
    if strcmpi(stimuli(1).type,'exper2 stimulus protocol')
        desc=stimuli(1).param.description;
        nam=stimuli(1).param.name;
        stimuli(1)=[];
    end
    for n=2:length(stimuli)
        stimulus=stimuli(n);
        stimtype={stimulus.type};
        stimparams={stimulus.param};
        try
            typeidx=strcmp(pref.stimulitypes(:,1),stimtype);
            typefcn=pref.stimulitypes(typeidx,2);
            typefcn=typefcn{:};
            typetrg=pref.stimulitypes(typeidx,3);
            typetrg=typetrg{:};
        catch
            fprintf(['Unknown stimulus type: ' stimtype]);
        end
        notfile=~isfield(stimparams,'file');     % we want to load the stimulus from file
        samplerate=pref.SoundFs;
        if notfile
            %calibrate tone amplitudes
            stimparams=CalibrateSound(stimparams);
            
            sample=feval(typefcn,stimparams{1},samplerate);
        else
            sample=load([pref.stimuli '\' stimparams{stimidx}.file]);    % we know this field exists. the path to filename is relative to pref.stimuli (=main stimuli directory)
            f=fieldnames(sample);
            if isfield(eval(['sample.' f{1} '.param']),'description')
                stimulus.param.description=eval(['sample.' f{1} '.param.description']);
            end
            sample=eval(['sample.' f{1} '.sample']);        % we take the first field in the loaded structure
        end
        
        figure(f1)
%         t=1:length(sample);
%          t=1000*t/samplerate;
%          plot(t, sample)
         
%         [Pxx,F] = pwelch(sample,[],[],[], samplerate);
%         semilogx(F, Pxx)

        spectrogram(sample,[512],[],[], samplerate, 'yaxis');
        ylim([1000 100000]);
        set(gca, 'yscale', 'log')

        fields=fieldnames(stimparams{1});
        str=[];
        for f=1:length(fields)
            str=[str sprintf('%s %g, ', fields{f}, (getfield(stimparams{1}, fields{f})))];
        end
        str=str(1:end-1);
        figure(f2)
         
        if length(str)>72
           %str=wrap_string(str);
            title(sprintf('\n%d/%d  %s: %s', n, length(stimuli), stimtype{1}, str))
            fprintf('\n%d/%d  %s: %s\n', n, length(stimuli), stimtype{1}, str)
        else
            title(sprintf('\n%d/%d  %s: %s', n, length(stimuli), stimtype{1}, str))
            fprintf('\n%d/%d  %s: %s\n', n, length(stimuli), stimtype{1}, str)

        end
        drawnow
        if strcmp(typetrg, 'sound')
            soundsc(sample, samplerate)
        end
        
        if get(stoph, 'value')
            break
        end
        if get(isih, 'value')
            pause(stimparams{1}.next/1000)
        end
        
    end
catch
    fprintf('\ncould not play stimuli')
end




function stimparams=CalibrateSound(stimparams)

%     don't bother to calibrate for now



