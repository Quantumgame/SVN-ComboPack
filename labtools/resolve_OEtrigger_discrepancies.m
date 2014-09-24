function resolve_OEtrigger_discrepancies(expdate, session, filename)
%the idea of this function is to serve as a monitor and problem resolver.
%When the soundcard triggers, HW triggers, and exper stimuli don't match
%up, hopefully this will allow the user to see the nature of the error and
%do the right thing.

oepathname=getOEdatapath(expdate, session, filename);
samprate=OEget_samplerate(oepathname);

[timestamps stimid]=OEread_stimIDs(expdate, session, filename);
soundcardtriggerPos=OEread_soundcardtriggers(expdate, session, filename);

%read stimuli from exper structure
gorawdatadir(expdate, session, filename)
expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filename);
expstructurename=sprintf('exper_%s', filename);
if exist(expfilename)==2 %try current directory
    load(expfilename)
    exp=eval(expstructurename);
    stimuli=exp.stimulusczar.param.stimuli.value;
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
    else
        stimuli=[];
        fprintf('\ncould not find exper structure. Cannot find stimuli.')
    end
end

dur=stimuli{1}.param.duration;
isi=stimuli{2}.param.next;
 refract=(dur+isi)/1000; %convert to sec
 wrong_triggers=find(diff(soundcardtriggerPos/samprate)<refract);
% soundcardtriggerPos(wrong_triggers)=NaN;
% soundcardtriggerPos=soundcardtriggerPos(~isnan(soundcardtriggerPos));
% fprintf('\napplying a refractory period of %.4f s to soundcard triggers.', refract)
% fprintf('\nthis refractory period eliminated %d soundcard triggers.', length(wrong_triggers))

%plot CH36 and 37 to see if a static spike occurs simultaneously on both
%channels
cd(oepathname)
[data, alltimestamps, info] = load_open_ephys_data('100_CH36.continuous');
[data2, alltimestamps, info] = load_open_ephys_data('100_CH37.continuous');

godatadir(expdate, session, filename)
fid=fopen(sprintf('soundcardtrigs_to_ignore-%s-%s-%s.txt', expdate, session, filename), 'w+t');
win=1e3;
win2=1e5;
for w=1:length(wrong_triggers)
    figure
    subplot(211)
    pos=soundcardtriggerPos(wrong_triggers(w));
    plot(data(pos-win:pos+win), 'c');
    hold on
    plot(data2(pos-win:pos+win)+1000, 'g');
    plot(win, 10000, 'o')
    title(sprintf('event number %d', wrong_triggers(w)));
    legend({'laser signal', 'soundcard trigger'})
   subplot(212)
   plot(data(pos-win2:pos+win2), 'c');
    hold on
    plot(data2(pos-win2:pos+win2)+1000, 'g');
    plot(win2, 10000, 'o')
    
%       keyboard
    answer=input('flag this soundcard trigger to be ignored? (y or n)', 's');
    %     flag(w)=answer;
    if strcmp(answer, 'y')
        subplot(211)
        plot(win, 10000, 'rx')
        subplot(212)
        plot(win2, 10000, 'rx')
        fprintf(fid, '%d ',wrong_triggers(w));
    end
    pos2=soundcardtriggerPos(wrong_triggers(w)+1);
        subplot(211)
    plot(pos2-pos+win, 10000, 'o')
        subplot(212)
    plot(pos2-pos+win2, 10000, 'o')
    answer=input('flag the next soundcard trigger to be ignored? (y or n)', 's');
    
    %     flag()=answer;
    if strcmp(answer, 'y')
        subplot(211)
        plot(pos2-pos+win, 10000, 'rx')
        subplot(212)
        plot(pos2-pos+win2, 10000, 'rx')
        fprintf(fid, '%d ',wrong_triggers(w)+1);
    end
    
end

% godatadir(expdate, session, filename)
% fid=fopen('soundcardtrigs_to_ignore.txt', 'w+t');
% for w=1:length(wrong_triggers)
% if strcmp(flag(w), 'y')
%     fprintf(fid, '%d ',wrong_triggers(w));
% end
% end
fclose(fid);