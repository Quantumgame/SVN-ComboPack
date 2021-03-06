function out=StimulusCzar(varargin)

% simple module that takes the stimulus (sound, water delivery, pulse, etc) as a paramater, prepares the
% corresponding devices (RP2, ao, triggers) and sends the stimulus out
%
% use as StimulusCzar('send',stimulus), where stimulus is a structure:
%   stimulus.type='tone' (for example) or {'pulse','tone'}
%   stimulus.param contains parameters of the stimulus:
%       stimulus.param.duration=100;
%       stimulus.param.amplitude=10; and so on
%
%   if the third parameter is 'notrigger' then no hardware trigger is sent out and the stimulus is
%   only loaded into the corresponding device
%

%soundmethod is set in prefs mw 02082011

global exper pref shared calibrationmethod
% calibrationmethod can be 'look-up' or 'inversefilter'
% this determines whether sound level calibration uses the
% standard look-up-table for tones and noise, or the new inverse adaptive filtering approach 
%calibrationmethod='inversefilter'; 
calibrationmethod='look-up';

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
    case 'init'

        InitParam(me, 'soundmethod', 'value', pref.soundmethod);
        %whether to use AOSound or PPASound is set in Prefs.m
        
        switch GetParam(me, 'soundmethod')
            case 'PPAsound'
                ModuleNeeds(me,{'ppasound'}); %
            case 'AOSound'
                ModuleNeeds(me,{'aosound'}); %
            case 'soundmachine'
                ModuleNeeds(me,{'soundloadsm'}); %

        end
        
        SetParam(me,'priority',GetParam('patchpreprocess','priority')+1);   %mw 12.16.05
        InitializeGUI;                  % show the gui = message box:-)
        fname=[control('getdatafilename') '-stimuli.bak'];
        InitParam(me,'BackupFileName','value',fname);
        commandChannels=GetChannel('ao','commandchannel');
        AOChannels=AO('GetChannelIdx',[commandChannels.number]);
        InitParam(me,'CommandChannels','value',[[commandChannels.number]; AOChannels]);

        %try to load calibration data
        try
            cd(pref.experhome)
            cd calibration
            cal=load('calibration');
            InitParam(me,'Calibration','value',cal);
            Message(me, 'loaded calibration')
            pause(.5)
        catch
            InitParam(me,'Calibration','value',[]);
            Message(me, 'failed to load calibration')
            pause(.5)
        end


    case 'getready'
        ResetMyVariables;           % local function

    case 'reset'
        ResetMyVariables;           % local function

    case 'send'
        if nargin<2
            return;
        end
        try
            if (nargin<3) | (~strcmpi(varargin{3},'notrigger')) % we want the hardware trigger
                SendStimulus(varargin{2},1);                    % local function
            else                                                % just load the data and set the triggers
                SendStimulus(varargin{2},0);                    % local function
            end
        catch
            Message(me,'Cannot send the stimulus out');
        end

    case 'epathchange'                      %response to pathchange event - the path has changed, if it's datapath, we need to update the backup file
        if nargin<2
            return;
        end
        if strcmpi(varargin{2},'datapath')
            fname=[control('getdatafilename') '-stimuli.bak'];
            SetParam(me,'BackupFileName',fname);
        end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
fig = ModuleFigure(me);
set(fig,'doublebuffer','on','visible','off');

hs = 110;
h = 5;
vs = 20;
n = 5;
% message box
uicontrol('parent',fig,'tag','message','style','text','units','normal','fontweight','bold',...
    'enable','inact','horiz','left','pos',[0.05 0.6 0.9 0.35]);

uicontrol(fig,'tag','stimulus_description','style','text','units','normal',...
    'enable','inact','horiz','left','pos',[0.05 0.05 0.9 0.5]);


screensize=get(0,'screensize');
set(fig,'pos', [screensize(3)-128 screensize(4)-n*vs-240 128 n*vs] ,'visible','on');

InitParam(me,'Stimuli','value',{}); % cell array that keeps track of all the stimuli sent out
InitParam(me,'NStimulus','value',1);    % current stimulus
InitParam(me,'stimulus_bytes','value',{});    % cell array that keeps track of stimulus ID bytes that ar sent out

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SendStimulus(stimulus,trigger)
% expects a structure in stimulus to send out
global exper pref calibrationmethod
if ~isstruct(stimulus)
    Message(me,'Not a correct stimulus');
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
        Message(['Unknown stimulus type: ' atype]);
    end

    % set the required triggers
    switch typetrg
        case 'sound'
            % This is now handled by SoundLoad itself.
            %             SoundLoad('sethwtrigger');
        case 'waterdelivery'
            WaterDelivery('sethwtrigger');
        case 'ao'
            AO('pause');
    end

    notfile=~isfield(stimparams{stimidx},'file');     % we want to load the stimulus from file

    % load the required stimulus
    switch typetrg
        case 'sound'
            %mw051308
            switch GetParam(me, 'soundmethod')
                case 'PPAsound'
                    samplerate=PPASound('samplerate');
                case 'AOSound'
                    samplerate=AOSound('samplerate');
                case 'soundmachine'
                    samplerate=SoundLoadSM('samplerate');                             %  sampling frequency
            end
            if notfile
                %calibrate tone amplitudes
                if strcmp(calibrationmethod, 'look-up')
                    stimparams=CalibrateSound(stimparams, stimidx, stimtypes);
                end
                sample=feval(typefcn,stimparams{stimidx},samplerate);
            else
                sample=load([pref.stimuli '\' stimparams{stimidx}.file]);    % we know this field exists. the path to filename is relative to pref.stimuli (=main stimuli directory)
                f=fieldnames(sample);
                if isfield(eval(['sample.' f{1} '.param']),'description')
                    stimulus.param.description=eval(['sample.' f{1} '.param.description']);
                end
                sample=eval(['sample.' f{1} '.sample']);        % we take the first field in the loaded structure
            end
            if~isempty(sample)
                % SoundLoad enables triggering for appropriate channels
                % and loads the sound
                %mw051308

                if strcmp(calibrationmethod, 'inversefilter')
                   sample= InverseFilter(sample, samplerate, stimparams{stimidx});
                end

                switch GetParam(me, 'soundmethod')
                    case 'PPAsound'
                        PPASound('load', 'var',sample,stimparams{stimidx})
                    case 'AOSound'
                        AOSound('load', 'var',sample,stimparams{stimidx})
                    case 'soundmachine'
                        SoundLoadSM('load','var',sample,stimparams{stimidx});
                end


                %right channel serves as trigger
                %                trigsample=0*sample;
                %                trigsample(1:10)=-1*ones(size(1:10));
                %                sample=[sample', trigsample'];
            end
            stimlength(stimidx)=ceil(length(sample)/samplerate*1000);   % in ms
        case 'visual'
            %             mw072108
            VisLoad('load', 'var', [], stimparams{stimidx});
            stimlength(stimidx)=stimparams{stimidx}.duration;
        case 'ao'
            %reset soundmachine so that the hardware trigger doesn't
            %deliver a sound
            if ExistParam('soundloadsm', 'sm')
                soundloadsm('reset');
            end

            samplerate=GetParam('ao','samplerate'); 
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
                commandChannels=GetParam(me,'CommandChannels');
                CommandChannel=[];
                AO('duration',length(sample)/samplerate);
                if isfield(stimparams{stimidx},'channel')    % we want to load a particular channel
                    channel=stimparams{stimidx}.channel;
                    channel=GetChannel('ao',channel);
                    if ~isempty(channel)
                        idx=find(commandChannels==channel(1).number);
                        %idx=find(commandChannels(1,:)==channel(1).number); %mw 03.14.06
                        if ~isempty(idx)
                            %ledchan=1 -> idx=2 -> CommandChannel=1
                            CommandChannel=idx;
                            %                            CommandChannel=commandChannels(idx);
                            %                            CommandChannel=commandChannels(2,idx); %mw 03.14.06
                        end
                    end
                else                                        % send the same waveform in all channels
                    CommandChannel=1; %send the waveform only in first channel
                    %                     CommandChannel=commandChannels(:); % send the same waveform in all channels
                    %                     CommandChannel=commandChannels(2,:); %mw 03.14.06
                    sample=repmat(sample,1,length(CommandChannel));
                end
                %   for debugging stimuli: (mw 02.01.06)
                %                 cs=getparam('stimulusprotocol', 'currentstimulus');cs=cs(getparam('stimulusprotocol', 'protocol'));
                %                 figure(100); title(cs);hold on; t=1:length(sample); t=t+(cs-1)*length(sample); t=t./samplerate;
                %                 plot(t, 20*sample); plot([t(1) t(1)], ylim, 'r');shg
                % figure(100)
                % plot(sample)
                if ~isempty(CommandChannel)
                    %AO('really_reset'); %mw 6-10-10
                    AO('setchandata',CommandChannel,sample);
                    
                    AO('reset'); %mw01302011 commented out; mw02082011 uncommented 
                    
                    %hack to minimize holdcmd blip since I can't seem to
                    %prevent it on Rig 2. %mw 6-10-10
                    if strcmp(stimulus.type, 'holdcmd')
                        %fprintf('\nfrom: %d', stimulus.param.holdcmd_from)
                        ao('putsample',[stimulus.param.holdcmd_from/20 0])
                    end
                    AO('start');
                end
            end
            stimlength(stimidx)=ceil(length(sample)/samplerate*1000); % in ms
        case 'waterdelivery'
            stimlength(stimidx)=stimparams{stimidx}.npulses*stimparams{stimidx}.pulse_width+(stimparams{stimidx}.npulses-1)*stimparams{stimidx}.pulse_isi; %in ms
    end

end     %for stimidx=1:n                     % stimulus index

stimlength=max(stimlength);

%save the stimulus info
if ~iscell(stimulus.param) & ~isfield(stimulus.param,'duration')
    stimulus.param.duration=stimlength;
end

obj=findobj('tag','stimulus_description');
if isfield(stimulus.param,'description')
    outstring=textwrap(obj(1),{stimulus.param.description});
else
    outstring='';
end
set(obj,'String',outstring);

stimuli=GetParam(me,'Stimuli');
nstimulus=GetParam(me,'NStimulus');
if nstimulus>length(stimuli)    % we're starting a new stimulus
    mystim.type=stimulus.type;
    mystim.param=stimulus.param;
    mystim.stimlength=stimlength;
else
    mystim=stimuli{nstimulus};
    if iscell(mystim.type)          % adding to stimulus with a cell-array in it=at least two elements
        mystim.type={mystim.type{:} stimtypes{:}};
        mystim.param={mystim.param{:} stimparams{:}};
    else                        %this is the second thing in the stimulus, we need to create a cell array
        mystim.type={mystim.type stimtypes{:}};
        mystim.param={mystim.param stimparams{:}};
    end
    mystim.stimlength=max([mystim.stimlength stimlength]);
end
stimuli{nstimulus}=mystim;
SetParam(me,'Stimuli',stimuli);


if trigger
    % prepare the backup
    if iscell(mystim.type)            % multiple stimuli
        stimtypes=mystim.type(:)';    % this makes sure, it's a row vector
        stimparams=mystim.param(:)';
    else
        stimtypes={mystim.type};
        stimparams={mystim.param};
    end
    alltypes=[];
    allparams=[];
    for k=1:length(stimtypes)
        typeidx=find(strcmp(pref.stimulitypes(:,1),stimtypes{k}));
        alltypes=[alltypes typeidx];
        try
            paramvec=struct2cell(stimparams{k});
            warning off MATLAB:nonIntegerTruncatedInConversionToChar
            paramvec=int16([paramvec{:}]);
            warning on MATLAB:nonIntegerTruncatedInConversionToChar
            allparams=[allparams paramvec];
        catch
            allparams=[];
        end
    end
    output=[0 32767 length(alltypes) alltypes length(allparams) allparams];
    fid=fopen(GetParam(me,'BackupFileName'),'a');
    if fid>0 %mw062408
        fwrite(fid,output,'int16');
        fclose(fid);
    end

    %             SetSharedParam('CurrentStimulus',mystim);
    % current stimulus is now set by dataguru, when the data
    % becomes available
    SetParam(me,'NStimulus',nstimulus+1);
    %              exper.ai.daq.TimerFcn={'dataguru',(stimlength+0.5)*exper.ai.param.samplerate.value,stimlength*exper.ai.param.samplerate.value};
    exper.ai.daq.TimerPeriod=stimlength/1000+.5;
    exper.ai.daq.TimerFcn={'dataguru', mystim};
    %dio('trigger'); % now send it out!
    %now using 0-line of the stimulus-ID byte as the trigger, it will always be
    %high

    %send a stimulus-ID byte to dio
    %mw 2.3.2014
    %since exper's dio module doesn't support bytes and I'm too lazy to
    %extend it, I'm just using putvalue
%for now, wrapping around at 255, but we could simply send 2 bytes in a row
%to extend the range to a large number
    binID = dec2binvec(mod(nstimulus, 127),7);
    binID=[1 binID]; %always have 1-line high to act as trigger, lines 2-8 are coding ID
    putvalue(exper.dio.dio.Line(1:8), binID)
    pause(.001);
    putvalue(exper.dio.dio.Line(1:8), 0)
    stimulus_bytes{nstimulus}=binID;
    SetParam(me,'stimulus_bytes',stimulus_bytes);

    
    %             send soft trig to SoundMachine (comment out for hardware
    %             triggering)
    if strcmp(typetrg, 'sound')
        switch GetParam(me, 'soundmethod')
            case 'AOSound'
                AOSound('playsound')
            case 'PPAsound'
%                 if isfield(stimulus.param, 'loop_flg')
%                     loop_flg=stimulus.param.loop_flg; %addding loop support mw 051209
%                 else loop_flg=0;
%                 end
%                 if loop_flg==0
                    PPASound('playsound')
%                 elseif loop_flg==1
%                     PPASound('playsoundloop');
%                 else
%                     error('stimulusczar: loop flag confusion')
%                 end
            case 'soundmachine'
                sm=SoundLoadSM('SMobject');
                if isfield(stimulus.param, 'triggernum') %mw 021508
                    triggernum=stimulus.param.triggernum;
                else
                    triggernum=1;
                end
                PlaySound(sm, triggernum);

        end

    elseif strcmp(typetrg, 'visual')
        VisLoad('play')
    else
        %     dio('trigger'); % now send it out!
    end

    %         SetParam(me,'Stimulus',mystim);
    %         SendEvent('Eaddstimulus','Stimulus',me,'all');
end

Message(me,sprintf('stim %d:', nstimulus), 'append');

if isfield(stimulus.param, 'frequency') & isfield(stimulus.param, 'amplitude')
    Message(me,[' ', stimulus.type, ' ',int2str(stimulus.param.frequency),' Hz ',int2str(stimulus.param.amplitude), ' dB'] , 'append');
elseif  isfield(stimulus.param, 'carrier_frequency')
    Message(me,[' ', stimulus.type, ' ',int2str(stimulus.param.carrier_frequency), ' Hz'], 'append')
elseif  isfield(stimulus.param, 'angle')
    Message(me,[' ', stimulus.type, ' ',int2str(stimulus.param.angle), ' deg'], 'append')
elseif  isfield(stimulus.param, 'amplitude')
    Message(me,sprintf(' %s, %g',stimulus.type, stimulus.param.amplitude), 'append')
elseif  isfield(stimulus.param, 'prepulsedur')
    Message(me,sprintf(' %s, %g ms',stimulus.type, stimulus.param.prepulsedur), 'append')
else
    Message(me,stimulus.type, 'append');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimparams=CalibrateSound(stimparams, stimidx, stimtypes);
cal=GetParam(me, 'Calibration');
if ~isempty(cal) %it will be empty if Init failed to load calibration
    if strcmp(stimtypes{:}, '2tone') %special case since 2tone has both a frequency and a probefreq
        try
            findex=find(cal.logspacedfreqs<=stimparams{stimidx}.frequency, 1, 'last');
            atten=cal.atten(findex);
            stimparams{stimidx}.amplitude=stimparams{stimidx}.amplitude-atten;
           
            findex=find(cal.logspacedfreqs<=stimparams{stimidx}.probefreq, 1, 'last');
            atten=cal.atten(findex);
            stimparams{stimidx}.probeamp=stimparams{stimidx}.probeamp-atten;
           
            Message(me, 'calibrated', 'append')
        catch
            Message(me, 'NOT calibrated', 'append')
                                pause(.1)
        end
        
        
    elseif isfield(stimparams{stimidx}, 'frequency') %it has a freq and therefore is calibratable by frequency
        try
            findex=find(cal.logspacedfreqs<=stimparams{stimidx}.frequency, 1, 'last');
            atten=cal.atten(findex);
            switch stimtypes{:}
                case 'bintone'
                    Ratten=cal.Ratten(findex);
                    Latten=cal.Latten(findex);
                    stimparams{stimidx}.Ramplitude=stimparams{stimidx}.Ramplitude-Ratten;
                    stimparams{stimidx}.Lamplitude=stimparams{stimidx}.Lamplitude-Latten;
                otherwise
                    stimparams{stimidx}.amplitude=stimparams{stimidx}.amplitude-atten;
            end
            Message(me, 'calibrated', 'append')
        catch
            Message(me, 'NOT calibrated', 'append')
                                pause(.1)
        end
        
    else
        switch stimtypes{:}
            case {'clicktrain', 'whitenoise', 'amnoise'} %stimuli that consist of white noise
                try
                    findex=find(cal.logspacedfreqs==-1); %freq of -1 indicates white noise
                    atten=cal.atten(findex);
                    switch stimtypes{:}
                        case 'binwhitenoise'
                            Ratten=cal.Ratten(findex);
                            Latten=cal.Latten(findex);
                            stimparams{stimidx}.Ramplitude=stimparams{stimidx}.Ramplitude-Ratten;
                            stimparams{stimidx}.Lamplitude=stimparams{stimidx}.Lamplitude-Latten;
                        otherwise
                            stimparams{stimidx}.amplitude=stimparams{stimidx}.amplitude-atten;
                    end
                    Message(me, sprintf('calibrated'), 'append')
                catch
                    Message(me, 'NOT calibrated', 'append');pause(.5)
                end
            case {'fmtone'} %stimuli that have a carrier frequency
                try
                    findex=find(cal.logspacedfreqs<=stimparams{stimidx}.carrier_frequency, 1, 'last');
                    atten=cal.atten(findex);
                    stimparams{stimidx}.amplitude=stimparams{stimidx}.amplitude-atten;
                    Message(me, 'calibrated', 'append')
                catch
                    Message(me, 'NOT calibrated', 'append');pause(.5)
                end
            case {'noise'} %narrow-band noise stimuli (use center frequency calibration)
                try
                    findex=find(cal.logspacedfreqs<=stimparams{stimidx}.center_frequency, 1, 'last');
                    atten=cal.atten(findex);
                    stimparams{stimidx}.amplitude=stimparams{stimidx}.amplitude-atten;
                    Message(me, 'calibrated', 'append')
                catch
                    Message(me, 'NOT calibrated', 'append')
                end
            case {'GPIAS'} %startle pulse (use whitenoise calibration)
                %plus narrow-band noise (use center frequency calibration)
                try
                    findex=find(cal.logspacedfreqs<=stimparams{stimidx}.center_frequency, 1, 'last');
                    atten=cal.atten(findex);
                    stimparams{stimidx}.amplitude=stimparams{stimidx}.amplitude-atten;
                    findex2=find(cal.logspacedfreqs==-1); %freq of -1 indicates white noise
                    atten=cal.atten(findex2);
                    stimparams{stimidx}.pulseamp=stimparams{stimidx}.pulseamp-atten;
                    
                    Message(me, 'calibrated', 'append')
                catch
                    Message(me, 'NOT calibrated', 'append')
                end
            case {'ASR'} %startle pulse (use whitenoise calibration)
                try
                    findex=find(cal.logspacedfreqs==-1); %freq of -1 indicates white noise
                    atten=cal.atten(findex);
                    stimparams{stimidx}.prepulseamp=stimparams{stimidx}.prepulseamp-atten;
                    stimparams{stimidx}.pulseamp=stimparams{stimidx}.pulseamp-atten;
                    
                    Message(me, 'calibrated', 'append')
                catch
                    Message(me, 'NOT calibrated', 'append')
                end
            case {'NBASR'} %startle pulse (use whitenoise calibration)
                %plus narrow-band noise pulse (use center frequency calibration)
                try %
                    findex=find(cal.logspacedfreqs<=stimparams{stimidx}.prepulsefreq, 1, 'last');
                    atten=cal.atten(findex);
                    stimparams{stimidx}.prepulseamp=stimparams{stimidx}.prepulseamp-atten;
                    findex2=find(cal.logspacedfreqs==-1); %freq of -1 indicates white noise
                    atten=cal.atten(findex2);
                    stimparams{stimidx}.pulseamp=stimparams{stimidx}.pulseamp-atten;
                    Message(me, 'calibrated', 'append')
                catch
                    Message(me, 'NOT calibrated', 'append')
                end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function samples=InverseFilter(samples, samplerate, stimparams);
%stuff will go here eventually
%mw 09-25-2014


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResetMyVariables
global pref
Message(me,'');
SetParam(me,'Stimuli',{});
SetParam(me,'NStimulus',1);
fid=fopen(GetParam(me,'BackupFileName'),'w');   % clear the backup file
fclose(fid);
fname=[control('getdatafilename') '-stimuli.bak']; % and set a new name, it might have changed
SetParam(me,'BackupFileName',fname);

%try to load calibration data
try
    cd(pref.experhome)
    cd calibration
    cal=load('calibration');
    SetParam(me,'Calibration','value',cal);
    Message(me, 're-loaded calibration')
catch
    SetParam(me,'Calibration','value',[]);
    Message(me, 'failed to re-load calibration')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
