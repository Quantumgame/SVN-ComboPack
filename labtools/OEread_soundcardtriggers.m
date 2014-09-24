function [soundcardtriggerPos]=OEread_soundcardtriggers(varargin)
%extracts soundcard triggers from an Open Ephys '100_CH**.continuous' file
%file.
%hard coding to CH36 for now
%usage:  call with no arguments to use a dialog box to select the event
%file, or use expdate, session filenum to look in that data dir
% [soundcardtriggerPos]=OEread_soundcardtriggers;
% [soundcardtriggerPos]=OEread_soundcardtriggers(expdate, session filenum);

filename='100_CH37.continuous';
soundcardtriggerPos=[];

if nargin==0
    [filename, pathname] = uigetfile('*.continuous', 'Pick soundcard trigger file');
    if isequal(filename,0) || isequal(pathname,0)
        return;
    else
        cd(pathname)
    end
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    
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
    cd(oepathname)
    
end

dur=stimuli{1}.param.duration;
isi=stimuli{2}.param.next;
% try
[data, alltimestamps, info] = load_open_ephys_data(filename);
samprate=info.header.sampleRate;
[b,a]=butter(3, 100/15000, 'high');
fdata=filtfilt(b,a,data); 
thresh=10*std(fdata);%((max(data)-mean(data))/2.1);
thdata=fdata>thresh;
sdata=sparse([0; diff(thdata)]);
soundcardtriggerPos=find(sdata==1);

%check point #1, make sure that there is only one SCT per sound

% refract=(dur+isi/2)/1000; %convert to sec
% wrong_triggers=find(diff(soundcardtriggerPos/samprate)<refract);
% soundcardtriggerPos(wrong_triggers)=NaN;
% soundcardtriggerPos=soundcardtriggerPos(~isnan(soundcardtriggerPos));
% fprintf('\napplying a refractory period of %.4f s to soundcard triggers.', refract)
% fprintf('\nthis refractory period eliminated %d soundcard triggers.', length(wrong_triggers))

%checkpoint #2
min_isi=min(diff(soundcardtriggerPos/samprate));
max_isi=max(diff(soundcardtriggerPos/samprate));
fprintf('\n interval between soundcardtriggers-- min: %0.4f sec, max: %0.4f sec', min_isi, max_isi)
% if min_isi<(isi)/1000
%     warning(' Minimal time period between SCTs is shorter than duration and isi!')
%     fprintf('\n min SCT interval is %0.4f sec, max SCT interval is %0.4f sec', min_isi, max_isi)
% else
%     fprintf('\n min SCT interval is %0.4f sec, max SCT interval is %0.4f sec', min_isi, max_isi)
% end

% get the absolute positions (in samples) RISING EDGE
% soundcardtriggerPos=1000*soundcardtriggerPos/30e3;
% dur=50 %ms
% k=0;
% for i=1:length(soundcardtriggerPos)
%     stop=soundcardtriggerPos(i)+dur+1;
%     repeats=soundcardtriggerPos(soundcardtriggerPos>soundcardtriggerPos(i) & soundcardtriggerPos<stop);
%     if ~isempty(repeats)
%         k=k+1;
%         repeated_triggers(k).repeats=repeats;
%     end
%     if soundcardtriggerPos(i)==repeats
%        newsoun
%     
% end

figure
t=1:length(fdata);
sec_to_plot=10; 
%warning: plotting more than a minute or two of data will take a long time
%plotting >20 minutes can completely hang the computer
start=max(soundcardtriggerPos(1)-30e3*sec_to_plot, 1);
stop=soundcardtriggerPos(1)+30e3*sec_to_plot;

region=start:stop;
plot(t(region), fdata(region), t(region), thdata(region), t(region), sdata(region))
hold on
plot(soundcardtriggerPos, thresh, 'ro')
xlim([start stop])
title(sprintf('OEread soundcardtriggers: only plotting %d seconds of data surrounding first soundcard trigger', sec_to_plot))

fprintf('\nfound %d soundcard triggers\n', length(soundcardtriggerPos))

  if isempty(soundcardtriggerPos)
      fprintf('\n|n|nHelp!!!!!!!!!!!!!!!!    No soundcard triggers detected. Resorting to hardware triggers.\n\n')
  end

% catch
%     fprintf('\nNo soundcard trigger file found. Resorting to hardware triggers.\n\n')
% end
end
  