function expLogData=E2ProcessDAQFile(daqfilename, expType, saveit, outputdir, spikeMethod)

% Processes a single (E2) DAQ file and extracts triggers, timestamp, responses, etc.,
% and saves everything into corresponding mat files

% Input:
%       daqfilename     -   daq file to process
%       expType         -   type of experiment (lfp, cell-attached,
%                           whole-cell,etc.). Determines what will be done.
%
%       spikeMethod     -   'auto' default: extract spikes automagically
%                       -   'manual': extract spikes manually:-)
%
%adding support for soundcard triggers (delivered on one of the soundcard
%channels) %mw 12-11-08
global pref
if ~isfield(pref, 'rigconfig')
    pref.rigconfig='axopatch'; %default if not specified in prefs
end

if isfield(pref, 'numchannels')
     numchannels=getfield(pref, 'numchannels'); %(this used to be a binary
%     flag called 'twochannels' but now updating to allow tetrode data for example) mw 12-18-2011 

else
    numchannels=1;
end

expLogData=[];

if nargin<4 || isempty(spikeMethod)
    spikeMethod='auto';
end

if nargin<4 || isempty(outputdir) || strcmp(outputdir,'.')
    outputdir=pwd;
end

if nargin<3 || isempty(saveit)
    saveit=0;
end
saveit=saveit>0;            % make sure it's 0 or 1 %nm 09.12.08 really only checks if it is greater than 0, 
% for desired function should also check that value is less than 2 or less than or equal to 1

if nargin<2 || isempty(expType)
    expType='lfp';
end

if nargin<1 || isempty(daqfilename)
    return;
end

if ~exist(daqfilename,'file')
    disp(['Can''t find ' daqfilename '!']);
    return;
end

try
  daqinfo=daqread(daqfilename,'info');
catch
  disp(['Can''t read ' daqfilename '!']);
  return;
end

channels=daqinfo.ObjInfo.Channel;	% structure containing information about the channels
channelnames={channels.ChannelName};
% find out the channel numbers
triggerchannel=find(strcmpi(channelnames,'Triggers'));	    % find the Triggers channel
timestampchannel=find(strcmpi(channelnames,'Timestamp'));	% find the Timestamp channel
soundcardtriggerchannel=find(strcmpi(channelnames,'soundcardtrigchannel'));	    % find the soundcard trigger channel
tetrodechannels=strmatch('TetrodeData', channelnames);	    % find the tetrode channels
AOPulsechannels=strmatch('AOPulse', channelnames);	    % find the AOPulse channels

% somehow I have to come up with a better method of obtaining the channel
% info
switch pref.rigconfig
    case 'axopatch'
        datachannel(1).number=1;
        datachannel(1).name='AxopatchData1';
        datachannel(2).number=4;
        datachannel(2).name='AxopatchData2';

    case 'tetrode'
        for ch=1:length(tetrodechannels)
            datachannel(ch).number=tetrodechannels(ch);
            datachannel(ch).name=channelnames(tetrodechannels(ch));
        end
        n=length(tetrodechannels);
         for ch=1:length(AOPulsechannels)
            datachannel(ch+n).number=AOPulsechannels(ch);
            datachannel(ch+n).name=channelnames(AOPulsechannels(ch));
        end
end
%now we sometimes want multiple channels of axopatch data %mw 032207
%this is where you specify which hardware channel the data is plugged into
%(I should really put it in Prefs, but that conflicts with the axopatch
%gain/mode chans) %mw 12-18-2011
% for ch=1:numchannels
%     datachannel(2).number=4
%     datachannel(2).name='AxopatchData2';
% end
% if numchannels==2
%     datachannel(2).number=4;
%     datachannel(2).name='AxopatchData2';
% end
% if numchannels==3
%     datachannel(2).number=4;
%     datachannel(2).name='AxopatchData2';
%     datachannel(3).number=6;
%     datachannel(3).name='AxopatchData3';
% end
% if numchannels==4
%     datachannel(2).number=4;
%     datachannel(2).name='AxopatchData2';
%     datachannel(3).number=6;
%     datachannel(3).name='AxopatchData3';
%     datachannel(4).number=7;
%     datachannel(4).name='AxopatchData4';
% end
% if numchannels==5
%     datachannel(2).number=4;
%     datachannel(2).name='AxopatchData2';
%     datachannel(3).number=6;
%     datachannel(3).name='AxopatchData3';
%     datachannel(4).number=7;
%     datachannel(4).name='AxopatchData4';
%     datachannel(5).number=8;
%     datachannel(5).name='AxopatchData5';
% end
% datachannel=find(strcmpi(channelnames,'Axopatch Data'));	% find the Data channel
    % eegchannel=find(strcmpi(channelnames,'Cyberamp Data'));

daqsamplerate=daqinfo.ObjInfo.SampleRate;           % sampling rate

% get the Exper structure
% [daqpath,daqname,ext,ver]=fileparts(daqfilename); old command, kept
% giving waring msg and was thus fixed by mk 3may2011
[daqpath,daqname,ext]=fileparts(daqfilename);
experfile=fullfile(daqpath,daqname);

% now process the file: For now we're extracting only the Axopatch Data channel
% First, get the timestamp from the timestamp channel
if ~isempty(timestampchannel)
    daqdata=daqread(daqfilename,'Channel',timestampchannel,'DataFormat','native'); %int16 makes the file CONSIDERABLY smaller
    expLogTimestamp=E2GetTimeStamp(daqdata); % returns a structure with timestamp events
    % daqTimestampName=fullfile(outputdir,[daqname '-timestamp']);
    daqTimestampName=[daqname '-timestamp'];
else
    daqTimestampName='';
end
    
% Second, get the triggers from the hardware trigger channel
daqdata=daqread(daqfilename,'Channel',triggerchannel,'DataFormat','native');
[triggerPos_rising, triggerPos_falling]=E2GetTriggers(daqdata);

% also, get the soundcardtriggers from the soundcard trigger channel
 daqdata=daqread(daqfilename,'Channel',soundcardtriggerchannel,'DataFormat','native');
 [soundcardtriggerPos, dummy]=E2GetTriggers(daqdata);
  if isempty(soundcardtriggerPos)
      fprintf('\n|n|nHelp!!!!!!!!!!!!!!!!    No soundcard triggers detected. Resorting to hardware triggers.\n\n')
  end
%if for some reason the soundcardtriggers weren't recorded (e.g. BNC not hooked
%up) comment out the 5 lines above and uncomment the 2 lines below:
%   soundcardtriggerPos=[];
%   fprintf('\nNOT USING SOUNDCARD TRIGGERS')
%
%the following is a hack to work around the unfortunate double-triggering
%we sometimes get from soundcard buffer under-runs (esp. with long sounds)
%mw 041709
% if length(soundcardtriggerPos)>length(triggerPos_rising)
%  i=find(diff(soundcardtriggerPos)>200);
%  i=[i ;length(soundcardtriggerPos)];
%  soundcardtriggerPos=soundcardtriggerPos(i); %this throws out soundcard triggers that come too close together
% end
% Third, get the data itself
daqdata=daqread(daqfilename,'Channel',[datachannel.number],'DataFormat','native');
if isempty(daqdata) return; end %mw 052306
nativeScalingAll=[daqinfo.ObjInfo.Channel([datachannel.number]).NativeScaling];   % conversion factors for the conversion from int16 to double
nativeOffsetAll=[daqinfo.ObjInfo.Channel([datachannel.number]).NativeOffset];

% Also, get the stimuli (mw 100206)
getstim=1;%don't bother if we didn't record stim channel, i.e. for speaker calibration %mw 040307
if getstim
    stimchannel=2;
    if ~strcmp(channels(stimchannel).ChannelName, 'TDT')
        error('can''t find stimulus channel')
    end
    stim=daqread(daqfilename,'Channel',stimchannel,'DataFormat','native');
    if isempty(stim) error('can''t read stimulus data'); end %mw 052306
    nativeScalingStim=[daqinfo.ObjInfo.Channel(stimchannel).NativeScaling];   % conversion factors for the conversion from int16 to double
    nativeOffsetStim=[daqinfo.ObjInfo.Channel(stimchannel).NativeOffset];
else
stim=[];
nativeScalingStim=[];
nativeOffsetStim=[];
end

% prepare the log entries
expLogData.Type='trace';
expLogData.Label={};
expLogData.Trace={};
expLogData.SpikeTrace={};   % this is sort of redundant, think about it more!!!
expLogData.Events={};
expLogData.Timestamp=daqTimestampName;
expLogData.Samplerate=daqsamplerate;



% and then process the data
for traceNum=1:length(datachannel)
    channel=datachannel(traceNum);
    if iscell(channel.name)
        channel.name=channel.name{:};
    end
    daqTraceName=[daqname '-' channel.name '-trace'];
    % daqTraceName=fullfile(outputdir,[daqname '-trace']);

    % determine whether we need to extract the spikes
    if strcmpi(expType,'cell-attached') || strcmpi(expType,'whole-cell')
        switch spikeMethod
            case 'auto'
                spikePos=E2GetSpikes(daqdata(:,traceNum),nativeScalingAll(traceNum),nativeOffsetAll(traceNum));
                getspikes=1;
                daqSpikesName=[daqname '-' chname '-spike_trace'];
                %     daqSpikesName=fullfile(outputdir,[daqname '-spike_trace']);
            case 'manual'
                spikePos=E2GetSpikesManual(daqdata(:,traceNum),nativeScalingAll(traceNum),nativeOffsetAll(traceNum));
                getspikes=1;
                daqSpikesName=[daqname '-' channel.name '-spike_trace'];
                %     daqSpikesName=fullfile(outputdir,[daqname '-spike_trace']);
            otherwise
                spikePos=[];
                getspikes=0;
                daqSpikesName=[];
        end
    else
        spikePos=[];
        getspikes=0;
        daqSpikesName=[];
    end

    % Finally, get all the events (spikes, stimuli, etc., except timestamp)
    expLogEvents=E2GetEvents(experfile,triggerPos_rising, triggerPos_falling,spikePos, soundcardtriggerPos);
    daqEventsName=[daqname '-' channel.name '-events'];
    % daqEventsName=fullfile(outputdir,[daqname '-events']);

    % and then finish the log
%     expLogData.Type='trace';
    expLogData.Label={expLogData.Label{:} channel.name};
    expLogData.Trace={expLogData.Trace{:} daqTraceName};
    expLogData.SpikeTrace={expLogData.SpikeTrace{:} daqSpikesName};   % this is sort of redundant, think about it more!!!
    expLogData.Events={expLogData.Events{:} daqEventsName};
%     expLogData.Timestamp=daqTimestampName;
%     expLogData.Samplerate=daqsamplerate;

    if saveit
        current=pwd;
        if ~isdir(outputdir)
           pos=find(outputdir==filesep);
           root=outputdir(1:pos(1));
           cd(root);
           mkdir(outputdir(pos(1)+1:end));
    %        cd(current);
        end
       cd(outputdir); 
       % save the raw data trace (int16 format plus the scaling factors)
       trace=daqdata(:,traceNum);
       nativeScaling=nativeScalingAll(traceNum);
       nativeOffset=nativeOffsetAll(traceNum);
       save(daqTraceName,'trace','nativeScaling','nativeOffset');
       daqStimName=[daqname '-stim'];
       save(daqStimName,'stim','nativeScalingStim','nativeOffsetStim');
    if getspikes % if requested, save the spikes as well
           spike_trace=spikePos;
           save(daqSpikesName,'spike_trace');
       end
       if ~isempty(daqTimestampName)
            event=expLogTimestamp;
            save(daqTimestampName,'event');
       end
       event=expLogEvents;
       save(daqEventsName,'event');
       cd(current);
    end
    
end % for traceNum=1:length(datachannel)
