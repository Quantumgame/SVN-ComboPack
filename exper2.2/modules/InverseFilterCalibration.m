function InverseFilterCalibration(varargin)
%Help for CalibrateSpeaker
%
% 
% Description:
% This function creates an equalization table of attenuation values for
% amplitude/frequency pairs in a file called "calibration.mat" in the
% calibration directory.
% This table is esentially the inverse of the speaker's frequency response
% curve. This look-up table is then used by StimulusCzar to equalize sounds
% such tones and white noise. This module should properly be called
% EqualizeSpeaker, but I haven't changed the name since everybody seems to
% call this process Calibration.
% First this help describes closed-field and then free-field calibration.
% 
% -------------------------------------------------------------------------
% 
% Directions for closed-field calibration:
% Here's the idea: we want to use the tiny Knowles in-ear microphone to
% calibrate the etymotics earphones in closed-field (inserted into ear
% canal). But when attached via a PE160 cannula, the Knowles microphone is
% very un-flat. We first need to equalize the microphone in order to equalize 
% the earphones. We will equalize the Knowles by comparing it to the B&K
% microphone, which we know is very flat. To do this, mount the cannula on
% the Knowles, and tape it to the side of the B&K such that the opening of
% the cannula is co-planar with the face of the B&K, and they are facing the
% Stax speaker. With the B&K output hooked up to ACh3, calibrate until flat
% (dont bother going above 18 kHz, the high limit of the etymotics).
%
% Then hook the Knowles output (through Audio-Buddy amp - must be calibrated
% - see below) to ACh3, set Save to 0, and run calibrate. You are now looking
% at the frequency response of the Knowles/cannula combination. Click "Store Mic"
% to store this frequency response. Then if you click "Apply Mic," you will
% see the frequency response of the speaker with the microphone frequency response
% removed. It will be flat, by definition. Then place the Knowles/cannula in situ,
% in the ear canal along with the etymotics earphone. Switch the soundcard output
% from Stax to Etymotics. Now, with Apply Mic still clicked, and save turned
% on, go ahead and calibrate. After you have gotten it flat, you can see the
% effect of turning Apply_Mic on and off (with save turned off). With it
% off, you are again looking at the frequency response of the microphone,
% re-measured each time.
%
% How to calibrate the Audio-Buddy: 
% The above instructions assume that the Knowles/Audio-Buddy combination 
% has a known sensitivity (usually 1 V/Pa). Take the longer Knowles microphone 
% and place it into a probe tube (1cc syringe body with 1-2 layers of tape 
% around it) with foam, such that the end of the cannula is co-planar with the 
% opening of the probe tube. Then insert this into the B&K sound calibrator 
% (it should go in exactly 8 mm) and press play. This produces a 1kHz 94 dB 
% (1 Pa) sound. Looking at the output of the Audio-Buddy on the oscilloscope, 
% adjust the gain until it is 1Vrms (cycle RMS). Tape the knob. Audio-Buddy 
% is now calibrated to 1V/Pa.
%
% -------------------------------------------------------------------------
% 
% Directions for free-field calibration:
% First hook up microphone BNC to ACH3.  Then turn down the amplifier that
% the speaker is connected to in order to avoid damaging
% the speaker.  The value in the target dB field will be used to calculate
% the needed attenuation.  Currently the function loops a number of times
% to produce a more even attenuation curve.  To change the number of loops put
% desired number in num_loops field.  The value in the maxfreq field
% should be ~32000, depending on the speakers ability to play high
% frequency tones.
% After an initial calibration, turn up the amplifier a
% small amount if target dB value is not being achieved.
%
% -num_freqs how many frequencies to play between the minfreq and maxfreq
%   values. Note that an extra frequency is added to calibrate whitenoise.
% -save: whether to overwrite the saved calibration table. Set save=0
%   (the default) to just check the current calibration status. If
%   you want to re-calibrate (and overwrite the saved calibration!) then
%   set save=1
%   Note: you have to Run once with save=1 before it will save to a file
% -num_loops: how many times to iterate.
% -convergence: inverse filter convergence factor. Controls how fast to converge
%   towards inverse filter (defaults to 1.0, reduce to maybe .9 or lower if oscillating
%   around target amplitude)
% -reset_atten: how much to reset the minimum attenuation towards zero each
%   iteration. Start with 0. If min attenuation starts to
%   accumulate (e.g. more than 5 dB) set it to 0.5 or so. Setting to 1
%   will work faster but can sometimes oscillate.
% -Reset: click this button to erase data stored in the calibration file
%   and start over from scratch.
% -mic_sensitivity: the gain setting on the B&K Nexus amplifier. Defaults to
%   1 V/Pa. If for some reason you change the B&K gain (e.g. to .316 V/Pa)
%   then set this value accordingly.
% -override_atten: do not use this, leave it set to zero. Advanced users:
%   this overrides atten by directly subtracting the specified value from atten.
% Notes:
% -Negative attenuation values are set to 0.
% -AI sampling rate and number of channels is set for you, so you don't need to worry
%   about it
% -If you change the min, max, or number of frequencies, the table will be
%   erased and calibration will start over from scratch.
% - pure tone amplitude is computed from the peak in the power spectrum.
%   white noise amplitude is computed as rms. I'm now high-pass filtering
%   at 500 hz to remove low-frequency ambient noise contamination
%   (mw 01-30-09)
% Warnings:
% A bug prevents closing from modules menu in exper.  You must close using the exit
%   button at the top of the window or else exper crashes. I should fix this
%   bug.
% NOTE: to save the most recent calibrate speaker speaker settings (e.g.
% for binaural experiments enter 'savecal' at the command line
% mak 3Aug2012

global  pref
persistent ax1 ax2 ai2 ao2 dio2 DataCh fig
persistent LearnH TestH

% global exper pref
% persistent ax1 ax2 ai2 ao2 dio2 DataCh GainCh ModeCh ph pw samples fig curaxes curline curpoint
% persistent RunningH RsH RtH aoSampleRate

if nargin > 0
    if isobject(varargin{1})
        %  action = 'freerun';
        action = '';
    else
        action = lower(varargin{1});
    end
else
    action = lower(get(gcbo,'tag'));
    if isempty(action)
        %   action = 'freerun';     %
        action = '';
    end
end

% fprintf('\n%s', action)
set(fig, 'name', ['InverseFilterCalibration: ', action])


switch action
    case 'init'
        ModuleNeeds(me,{'ai','ao','patchpreprocess'});
        SetParam(me,'priority','value', GetParam('patchpreprocess','priority')+1);
        
        fig = ModuleFigure(me);
        set(fig,'DoubleBuffer','on','Position',[360 460 600 500]);
        
        %gain on Bruel&Kjaer amplifier (Nexus), in V/Pa
        mic_sensitivity=1;
        InitParam(me,'mic_sensitivity','value',mic_sensitivity,...
            'ui','edit','units','normal','pos',[0.1 0.25 0.08 0.04]);
        h=findobj('string', 'mic_sensitivity');
        pos=get(h,'pos');
        pos(3)=.12;
        set(h, 'pos', pos);
        
        InitParam(me, 'soundmethod', 'value', pref.soundmethod);
        %whether to use AOSound or PPASound is set in Prefs.m
        
        %how much to reset the minimum attenuation towards zero each
        %iteration. Start with 0, and then if min attenuation starts to
        %accumulate (e.g. more than 5 dB) set it to 0.5 or so. Setting to 1
        %will work faster but can sometimes oscillate.
        InitParam(me,'reset_atten','value',0,...
            'ui','edit','units','normal','pos',[0.3 0.25 0.08 0.04]);
        h=findobj('string', 'reset_atten');
        pos=get(h,'pos');
        pos(3)=.12;
        set(h, 'pos', pos);
        
        target_amplitude=70; %dB SPL
        InitParam(me,'target_amplitude','value',target_amplitude,...
            'ui','edit','units','normal','pos',[0.5 0.25 0.08 0.04]);
        h=findobj('string', 'target_amplitude');
        pos=get(h,'pos');
        pos(3)=.12;
        set(h, 'pos', pos, 'string', 'target_amp');
        
        InitParam(me,'override_atten','value',0,...
            'ui','edit','units','normal','pos',[0.5 0.3 0.08 0.04]);
        h=findobj('string', 'override_atten');
        pos=get(h,'pos');
        pos(3)=.12;
        set(h, 'pos', pos);
        
        %         inverse filter convergence factor. controls how fast to converge
        %         towards inverse filter (defaults to 1.0, reduce to maybe .9 if oscillating
        %         around target amplitude?)
        convergence=1.0;
        InitParam(me,'convergence','value',convergence,...
            'ui','edit','units','normal','pos',[0.3 0.30 0.08 0.04]);
        h=findobj('string', 'convergence');
        pos=get(h,'pos');
        pos(3)=.12;
        set(h, 'pos', pos);
        
        %whether to save the results each time. Set to 0 if you just want
        %to check the current calibration, set to 1 in order to
        %re-calibrate.
        InitParam(me,'save','value',0,...
            'ui','edit','units','normal','pos',[0.7 0.25 0.08 0.04]);
        
        %number of times to iterate at a time
        lpnum = 1;
%         InitParam(me,'loop_num','value',lpnum,...
%             'ui','edit','units','normal','pos',[0.85 0.25 0.08 0.04]);

                InitParam(me,'order','value',100,...
            'ui','edit','units','normal','pos',[0.85 0.25 0.08 0.04]);

        
        minfreq=1000;
    
            maxfreq=32000;
            numfreqs=11;
        
        InitParam(me,'minfreq','value',minfreq,...
            'ui','edit','units','normal','pos',[0.1 0.2 0.08 0.04]);
        InitParam(me,'maxfreq','value',maxfreq,...
            'ui','edit','units','normal','pos',[0.3 0.2 0.08 0.04]);
        InitParam(me,'numfreqs','value',numfreqs,...
            'ui','edit','units','normal','pos',[0.1 0.15 0.08 0.04]);
        InitParam(me,'logspacedfreqs','value',[]);
        
        
        % v_width=30;
        % InitParam(me,'v_width','value',v_width,'range',[26 Inf],...
        % 'ui','edit','units','normal','pos',[0.28 0.002 0.08 0.04],'save',1);
        
        uicontrol(fig,'tag','message','style','edit','fontweight','bold','units','normal',...
            'enable','inact','horiz','left','pos',[0.47 0.02 0.52 0.22], 'max', 25, 'min', 0);
        
        aisamprate=200e3;
        InitParam(me,'aisamprate','value',aisamprate);
        InitParam(me,'atten','value',[]);
        InitParam(me,'DB','value',[]);
        InitParam(me, 'Rmic_applied_during_Run','value', 0);
        InitParam(me, 'Lmic_applied_during_Run','value', 0);

        InitParam(me,'inverse_filter','value',0);

        try
            cd(pref.experhome)
            cd calibration
            cal=load('calibration');
            SetParam(me,'atten','value',cal.atten);
            SetParam(me,'logspacedfreqs','value',cal.logspacedfreqs);
            if cal.logspacedfreqs(1)==-1
                SetParam(me,'minfreq','value',cal.logspacedfreqs(2));
                SetParam(me,'numfreqs','value',length(cal.logspacedfreqs)-1);
            else
                SetParam(me,'minfreq','value',cal.logspacedfreqs(1));
                SetParam(me,'numfreqs','value',length(cal.logspacedfreqs));
            end
            SetParam(me,'maxfreq','value',cal.logspacedfreqs(end));
        catch
            Message('failed to initialize calibration');
        end
        % Now get all channels we need
        % NOTE: related channels should correspond to the same indices in
        % related variables, ie DataChannels(1), ModeChannels(1),
        % GainChannels(1), CommandChannels(1), etc.
        % get all the data channels
        % dataChannels=GetChannel('ai','datachannel-patch');
        dataChannels=GetChannel('ai','datachannel2-patch'); %hook up microphone BNC to ACH3
        InitParam(me,'DataChannels','value',[dataChannels.number]);
        InitParam(me,'DataChannelNames','value',{dataChannels.name});
        dataChannelColors={dataChannels.color};
        InitParam(me,'DataChannelColors','value',dataChannelColors);
        nChannels=length(dataChannels);
        InitParam(me,'nChannels','value',nChannels);
        
        %assuming nChannels = 1
        if nChannels~=1
            fprintf('not sure if we can handle nChannels ~=1')
        end
        
        
        % Initialize some DAQ objects for freely running mode.
        oldai=daqfind('type','Analog Input','tag',me);
        if isempty(oldai)
            ai2=InitDAQAI;
        else
            ai2=oldai{1};
        end
        set(ai2,'tag',me);
        
        olddio=daqfind('type','Digital IO','tag',me);
        if isempty(olddio)
            dio2=InitDAQDIO;
        else
            dio2=olddio{1};
        end
        set(dio2,'tag',me);
        
        % Axes
        ax1=axes('units','normal','position',[0.1 0.40 0.8 0.25]);
        ax2=axes('units','normal','position',[0.1 0.7 0.8 0.25]);
        ylabel('Response');
        xlabel('Time');
        
        fig = findobj('type','figure','tag',me);
        
        
        %         reset button
        uicontrol('style','pushbutton','string','reset',...
            'callback',[me ';'],'tag','reset','fontname','Arial',...
            'fontsize',10,'fontweight','bold','backgroundcolor',[1 0 0],...
            'units','normal','pos',[0.3 0.15 0.15 0.04]);
        
        % create the run button
        
        LearnH = uicontrol('style','togglebutton','string','Learn',...
            'callback',[me ';'],'tag','learn','fontname','Arial',...
            'fontsize',14,'fontweight','bold','backgroundcolor',[0 1 0],...
            'units','normal','pos',[0.1 0.02 0.15 0.123]);
        
          TestH = uicontrol('style','togglebutton','string','Test','value', 0,...
            'callback',[me ';'],'tag','test','fontname','Arial',...
            'fontsize',14,'fontweight','bold','backgroundcolor',[0 1 0],...
            'units','normal','pos',[0.27 0.02 0.15 0.123]);
        
        Message(me, sprintf('pref.maxSPL is %d',pref.maxSPL ), 'append')
        
        %microphone calibration stuff
        uicontrol('style','pushbutton','string','storeRmic',...
            'callback',[me ';'],'tag','storeRmic',...
            'units','normal','pos',[0.84 0.30 0.09 0.04]);
        uicontrol('style','pushbutton','string','applyRmic',...
            'callback',[me ';'],'tag','applyRmic',...
            'units','normal','pos',[0.825 0.35 0.12 0.04]);
        
        uicontrol('style','pushbutton','string','storeLmic',...
            'callback',[me ';'],'tag','storeLmic',...
            'units','normal','pos',[0.715 0.30 0.09 0.04]);
        uicontrol('style','pushbutton','string','applyLmic',...
            'callback',[me ';'],'tag','applyLmic',...
            'units','normal','pos',[0.7 0.35 0.12 0.04]);
        
        InitParam(me,'Rmic_freq_resp','value',[]);
        InitParam(me,'Lmic_freq_resp','value',[]);
        if exist('cal')
            if isfield(cal, 'Rmic_freq_resp')
                SetParam(me,'Rmic_freq_resp','value',cal.Rmic_freq_resp);
            end
            if isfield(cal, 'Lmic_freq_resp')
                SetParam(me,'Lmic_freq_resp','value',cal.Lmic_freq_resp);
            end
        end
        InitParam(me,'last_atten','value',[]);
        InitParam(me,'last_DB','value',[]);
        InitParam(me,'Rmic_applied','value',0);
        InitParam(me,'Lmic_applied','value',0);
        
        InitParam(me, 'channel', 'value', 1); %1=mono, 2=R, 3=L i.e. which channel you are calibrating
        uicontrol('style','popup','string','mono|R|L','value', 1,...
            'callback',[me ';'],'tag','channel',...
            'units','normal','pos',[0.1 0.3 0.08 0.04])
        
        uicontrol('style','pushbutton','string','help',...
            'callback',[me ';'],'tag','help',...
            'units','normal','pos',[0.94 0.95 0.05 0.04]);
        
%         warndlg('!!!WARNING!!! Turn the Samson Amp all the way down before calibrating the speaker. See the note taped to the speaker.', 'DON''T BLOW THE SPEAKER!!!')
        
    case 'help'
        helpstr=help(me);
        m = figure;
        set(m, 'position', [360   100   600   600]);
        OKHandle=uicontrol(m                             , ...
            'Style'              ,'pushbutton'                      , ...
            'Units'              ,'normal'                          , ...
            'Position'           , [.44 .04 .08 .04]                            , ...
            'CallBack'           ,'delete(gcbf)'                    , ...
            'String'             ,'OK'                              , ...
            'HorizontalAlignment','center'                          , ...
            'Tag'                ,'OKButton'                          ...
            ); 
        uicontrol('Parent',m,...
            'Units','normalized',...
            'Position',[0.02,0.1,0.96,0.9],...
            'Style','edit',...
            'Max',100,...
            'Enable','inactive',...
            'HorizontalAlignment','left'                          , ...
            'String',helpstr)
       
    case 'storermic'
        StoreRMicFreqResponse
        
    case 'applyrmic'
        ApplyRMicFreqResponse(ax1)
        
    case 'storelmic'
        StoreLMicFreqResponse
        
    case 'applylmic'
        ApplyLMicFreqResponse(ax1)
        
    case 'channel'
        h=findobj('tag', 'channel', 'style', 'popup');
        val = get(h(1),'Value');
        Message(me, int2str(val))
        SetParam(me, 'channel', val);
        
    case 'reset'
        SetParam(me,'atten','value',[]);
        SetParam(me,'DB','value',[]);
        
    case 'close'
        if exist('ao2','var') && ~isempty(ao2)
            stop(ao2);
            delete(ao2);
        end
        if exist('ai2','var') && ~isempty(ai2)
            stop(ai2);
            delete(ai2);
        end
        if exist('dio2','var') && ~isempty(dio2)       %modified by Lung-Hao Tai
            stop(dio2);
            delete(dio2);
        end
        SendEvent('esealtestoff',[],me,'all');
        clear ai2 ao2 dio2 DataCh   samples ph pw fig curaxes curline RunningH RsH RtH
        
    case 'getready'
        fig=findobj('type','figure','name',me);
        set(findobj('type','uicontrol','tag','run','parent',fig),'enable','off');
        set(findobj('type','uicontrol','tag','channelbutton','parent',fig),'enable','off');
        
    case 'trialend'
        fig=findobj('type','figure','name',me);
        set(findobj('type','uicontrol','tag','run','parent',fig),'enable','on');
        set(findobj('type','uicontrol','tag','channelbutton','parent',fig),'enable','on');
        
        % Now for its own modes.
        
    case 'learn'
        Message(me, 'learn')
                        set(LearnH,'backgroundcolor',[1 0 0]);
                SendEvent('esealteston',[],me,'all');
                %         if ~isempty(gcbo) & (gcbo==RunningH) ...
                % This run is the first one. Set up some parameters.
                set(LearnH,'string','learning...');

        % Stop other modules.
                ai('pause');
                
                ai2.Channel(:).InputRange=[-10 10];
                ai2.Channel(:).SensorRange=[-10 10];
                ai2.Channel(:).UnitsRange=[-10 10];
                set(ai2,'TriggerType','HwDigital');
                % Copy the sample rate from the other module.
                set(ai2,'SampleRate',GetParam(me,'aisamprate'));
                ai2SampleRate=ai2.SampleRate/1000;
                
                % Do not let ai use interrupts if DMA is possible.
                % Get possible transfer modes.
                possibs=set(ai2,'TransferMode');
                % Set transfer mode to DualDMA if possible and SingleDMA as alternate.
                if sum(strcmp(possibs,'DualDMA'))
                    set(ai2,'TransferMode','DualDMA');
                elseif sum(strcmp(possibs,'SingleDMA'))
                    set(ai2,'TransferMode','SingleDMA');
                end
                % Call this file at the end.
                set(ai2,'StopFcn',me);
                set(ai2,'TriggerType','HwDigital');
                
                dataChannels=GetParam(me,'DataChannels');
                nChannels=GetParam(me,'nChannels');
                
                DataCh=zeros(1,nChannels);
                
                for channel=1:nChannels
                    DCh=daqfind(ai2,'HwChannel',dataChannels(channel));
                    DataCh(channel)=DCh{1}.Index;
                end
                sampleLength=500;   % sample length in ms
                set(ai2,'SamplesPerTrigger',ceil(sampleLength*ai2SampleRate));
                tonedur=sampleLength;
                
                    Message(me, sprintf('playing WN'), 'append')
                    %start playing tone
                    samples=PlayCalibrationTone(-1, tonedur, 0);
                    
                    % Trigger.
                    start(ai2);
                    % Flip dio bit to trigger.
                    putvalue(dio2,1);
                    putvalue(dio2,0);
                    
                    wait(ai2,sampleLength/1000+100);
                    %getData
                    if (ai2.SamplesAvailable>0) % we might have some data available
                        wait(ai2,1);
                        
                        [data,time]=getdata(ai2);
                        activeChannel=1;
                        
                        % Scale data.
                        RawData=data(:,DataCh(activeChannel));
                        ScaledData=detrend(RawData, 'constant'); %in volts
                        
                        GetInverseFilter(ScaledData, samples, ai2.SampleRate)
                        Message(me, 'learned inverse filter', 'append')
                    end
                       set(LearnH,'backgroundcolor',[0 1 0]);
                       set(LearnH, 'value', 0)
                SendEvent('esealtestoff',[],me,'all');
                set(LearnH,'string','Learn');
                
                if exist('ao2','var') && ~isempty(ao2)
                    stop(ao2);
                end
                if exist('ai2','var') && ~isempty(ai2)
                    stop(ai2);
                end
                ai('reset');
    case 'test'
        Message(me, 'test')
        % Set the button to red or green to indicate whether running.
        %     RunningH=findobj('type','uicontrol','tag','run');
        %         safety check:
        target_amp=GetParam(me, 'target_amplitude');
        if target_amp>pref.maxSPL
            error(sprintf('target amp of %ddB is higher than pref.maxSPL of %ddB', target_amp,pref.maxSPL))
        end
        wb=waitbar(0, 'calibrating...');
        set(wb, 'pos', [870 700 270  50])
        cla(ax1)
        cla(ax2)
        Message(me, 'Running...')
        Testing=get(TestH,'value');
%         for lp = 1:GetParam(me, 'loop_num')
        for lp = 1
            if Testing
                set(TestH,'backgroundcolor',[1 0 0]);
                SendEvent('esealteston',[],me,'all');
                %         if ~isempty(gcbo) & (gcbo==RunningH) ...
                % This run is the first one. Set up some parameters.
                set(TestH,'string','Testing...');
                % Stop other modules.
                ai('pause');
                
                ai2.Channel(:).InputRange=[-10 10];
                ai2.Channel(:).SensorRange=[-10 10];
                ai2.Channel(:).UnitsRange=[-10 10];
                set(ai2,'TriggerType','HwDigital');
                % Copy the sample rate from the other module.
                set(ai2,'SampleRate',GetParam(me,'aisamprate'));
                ai2SampleRate=ai2.SampleRate/1000;
                
                % Do not let ai use interrupts if DMA is possible.
                % Get possible transfer modes.
                possibs=set(ai2,'TransferMode');
                % Set transfer mode to DualDMA if possible and SingleDMA as alternate.
                if sum(strcmp(possibs,'DualDMA'))
                    set(ai2,'TransferMode','DualDMA');
                elseif sum(strcmp(possibs,'SingleDMA'))
                    set(ai2,'TransferMode','SingleDMA');
                end
                % Call this file at the end.
                set(ai2,'StopFcn',me);
                set(ai2,'TriggerType','HwDigital');
                
                dataChannels=GetParam(me,'DataChannels');
                nChannels=GetParam(me,'nChannels');
                
                DataCh=zeros(1,nChannels);
                
                for channel=1:nChannels
                    DCh=daqfind(ai2,'HwChannel',dataChannels(channel));
                    DataCh(channel)=DCh{1}.Index;
                end
                sampleLength=500;   % sample length in ms
                set(ai2,'SamplesPerTrigger',ceil(sampleLength*ai2SampleRate));
                tonedur=sampleLength+200;
                
                %logspacedfreqs=GetParam(me, 'logspacedfreqs');
                numfreqs=GetParam(me, 'numfreqs');
                maxfreq=GetParam(me, 'maxfreq');
                minfreq=GetParam(me, 'minfreq');
                if minfreq==-1; error('minfreq not supposed to be -1'); end
                logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );
                logspacedfreqs=[-1 logspacedfreqs];
                SetParam(me,'logspacedfreqs','value',logspacedfreqs);
                if isempty (GetParam(me,'atten'))
                    SetParam(me,'atten','value',zeros(size(logspacedfreqs)));
                elseif length(GetParam(me,'atten'))~=length(logspacedfreqs)
                    SetParam(me,'atten','value',zeros(size(logspacedfreqs)));
                end
                
                for i=1:numfreqs+1 %play tones + whitenoise at end
                    Message(me, sprintf('playing tone %d/%d',i, numfreqs+1), 'append')
                    tonefreq=logspacedfreqs(i);
                    %start playing tone
                    

                    samples=PlayCalibrationTone(tonefreq, tonedur, 1);
                    
                    % Trigger.
                    start(ai2);
                    % Flip dio bit to trigger.
                    putvalue(dio2,1);
                    putvalue(dio2,0);
                    
                    wait(ai2,sampleLength/1000+100);
                    
                    %getData
                    if (ai2.SamplesAvailable>0) % we might have some data available
                        wait(ai2,1);
                        
                        [data,time]=getdata(ai2);
                        activeChannel=1;
                        
                        % Scale data.
                        RawData=data(:,DataCh(activeChannel));
                        ScaledData=detrend(RawData, 'constant'); %in volts
                        
%                         GetInverseFilter(ScaledData, samples, ai2.SampleRate)
                        
                        %high pass filter a little bit to remove rumble
                        %for display purposes only
                        [b,a]=butter(1,100/(ai2SampleRate*1000), 'high');
                        
                        
                        % Display trace.
                        % plot(ax1,time(1:1000),ScaledData(1:1000));
                        plot(ax1,time(:),filtfilt(b,a,ScaledData));
                        fig = findobj('type','figure','tag',me);
                        xlabel(ax1, 'Time (s)');
                        ylabel(ax1, 'Microphone Voltage (V)');
                        
                        %estimate frequency
                        hold(ax2, 'on')
                        xlim(ax2, [0 1.25*maxfreq])
                        [Pxx,f] = pwelch(ScaledData,[],[],[],ai2SampleRate*1000);
                        fmaxindex=(find(Pxx==max(Pxx(100:end)))); %skip freqs<250hz
                        fmaxindex=fmaxindex(1);
                        fmax=round(f(fmaxindex));
                        Message(me, sprintf('est. freq: %d', fmax), 'append');
                        
                        c=repmat('rgbkm', 1, ceil(numfreqs/5)+1);
                        semilogy(ax2, f(100:end), Pxx(100:end), c(i))
                        semilogy(ax2, f(fmaxindex), Pxx(fmaxindex), ['o',c(i)])
                        xlabel(ax2, 'Frequency, Hz');
                        ylabel(ax2, 'PSD');
                        
                        if tonefreq==-1
                            %estimate amplitude -- RMS method
                            % high-pass filtering at 500 hz (mw 01-30-09)
                            %ai2SampleRate
                            [b,a]=butter(5, 500/(1000*ai2SampleRate/2), 'high');
                            Vrms=sqrt(mean(filtfilt(b,a,ScaledData).^2));
                            db=dBSPL(Vrms, GetParam(me, 'mic_sensitivity'));
                            Message(me, sprintf('estimated tone amp: %.2f', db), 'append');
                            
                           % GetInverseFilter(ScaledData, samples)
                            
                        else
                            %estimate amplitude -- Pxx method
                            fidx=closest(f, tonefreq);
                            db=dBPSD(Pxx(fmaxindex), GetParam(me, 'mic_sensitivity'));%should return 94 for B&K calibrator
                            %db=dBPSD(Pxx(fidx), GetParam(me, 'mic_sensitivity'));
                            Message(me, sprintf('estimated tone amp: %.2f', db), 'append');
                            %                             pause(.35)
                        end
                        FMAX(i)=fmax;
                        DB(i)=db;
                        
                        waitbar(i/(numfreqs+1), wb)
                        
                    else
                        Message(me, 'did not AnalyzeData')
                    end
                    
                    switch GetParam(me, 'soundmethod')
                        case 'AOSound'
                            %pause until aosound has finished playing
                            %%mw123110
                            aohandle=GetParam('aosound', 'aohandle');
                            while strcmp(get(aohandle, 'Running'), 'On')
                                pause(.01)
                            end
                    end
                end %play tones
                
                % for i=1:numfreqs
                %   fprintf('\nestimated tone freq: %d, amp: %.2f', FMAX(i), DB(i));
                % end
                Message(me, 'measured freqs: ', 'append')
                Message(me, sprintf('%d ',FMAX), 'append')
                
                
                %apply a microphone correction if selected
                %need to also store whether a mic freq response was applied
                %during this run

                if GetParam(me, 'Rmic_applied')
                    mic_freq_resp=GetParam(me,'Rmic_freq_resp');
                    DB=DB-mic_freq_resp;
                    R_DB=DB;
                    SetParam(me, 'Rmic_applied_during_Run', 1);
                    SetParam(me, 'Lmic_applied_during_Run', 0);
                elseif GetParam(me, 'Lmic_applied')
                    mic_freq_resp=GetParam(me,'Lmic_freq_resp');
                    DB=DB-mic_freq_resp;
                    L_DB=DB;
                    SetParam(me, 'Rmic_applied_during_Run', 0);
                    SetParam(me, 'Lmic_applied_during_Run', 1);
                else
                    SetParam(me, 'Rmic_applied_during_Run', 0);
                    SetParam(me, 'Lmic_applied_during_Run', 0);
                end
                
                plot(ax1, logspacedfreqs, DB, '-o')
                xlabel(ax1, 'Frequency, Hz');
                ylabel(ax1, 'dB SPL');
                xlim(ax1, [-2 1.25*maxfreq])
                grid(ax1, 'on')
                
                %  create inverse filter
                %atten=DB-min(DB); %this is the inverse filter
                target_amp=GetParam(me, 'target_amplitude');
                convergence=GetParam(me, 'convergence');
                atten=convergence*(DB-target_amp); %this is the inverse filter
                atten(atten<0)=0;
                
                %apply over ride value if any
                atten=atten-GetParam(me, 'override_atten', 'value');
                
                % iteratively save calibration data
                if GetParam(me, 'save')
                    stored_atten=GetParam(me, 'atten');
                    if length(atten)==length(stored_atten)
                        atten=atten+stored_atten; %iteratively add to stored calibration
                    end
                    reset_amount=GetParam(me, 'reset_atten');
                    atten=atten-reset_amount*min(atten); %reset min atten towards 0 to avoid saturating
                    Rmic_freq_resp=GetParam(me,'Rmic_freq_resp');
                    Lmic_freq_resp=GetParam(me,'Lmic_freq_resp');
                    atten(atten<0)=0;
                    cd(pref.experhome)
                    cd calibration
                    try
                        cal=load('calibration.mat');
                    catch %#ok
                        cal=[];
                    end
                                     if ~exist('R_DB','var');
                                         try 
                                             R_DB=cal.R_DB; 
                                         catch
                                             R_DB=[];
                                         end
                                     end
                                     if ~exist('L_DB','var');
                                       try
                                           L_DB=cal.L_DB;
                                       catch
                                           L_DB=[];
                                       end
                                     end
                    
                    if ~isfield(cal, 'Ratten'); cal.Ratten=[];end
                    if ~isfield(cal, 'Latten'); cal.Latten=[];end
                    switch GetParam(me, 'channel')
                        case 1 %mono
                            Ratten=cal.Ratten;
                            Latten=cal.Latten;
                        case 2 %right
                            Ratten=atten;
                            Latten=cal.Latten;
                        case 3 %left
                            Ratten=cal.Ratten;
                            Latten=atten;
                    end
                    timestampstr=['last saved ', datestr(now)];
                    save calibration logspacedfreqs timestampstr DB R_DB L_DB atten Rmic_freq_resp Lmic_freq_resp Ratten Latten
                    SetParam(me,'atten','value',atten);
                    SetParam(me,'DB','value',DB);
                end
                %store a copy of atten & DB in case we want to use it for mic calibration
                SetParam(me,'last_atten', DB-target_amp); %non-truncated version
                SetParam(me,'last_DB', DB);
                
                stored_atten=GetParam(me, 'atten');
                Message(me, [sprintf('\nmin dB %.2f', min(DB)), sprintf('\nmax dB %.2f', max(DB)), ...
                    sprintf('\nmean dB %.2f', mean(DB)), sprintf('\nstd dB %.2f', std(DB)), ...
                    sprintf('\nmin atten %.2f', min(stored_atten)),  ...
                    sprintf('\nmax atten %.2f', max(stored_atten)), ...
                    sprintf('\npref.maxSPL is %d',pref.maxSPL )])
%                 Message(me, {sprintf('min dB %.2f', min(DB)), sprintf('max dB %.2f', max(DB)), ...
%                     sprintf('mean dB %.2f', mean(DB)), sprintf('std dB %.2f', std(DB)), ...
%                     sprintf('min atten %.2f', min(stored_atten)),  ...
%                     sprintf('max atten %.2f', max(stored_atten)), ...
%                     sprintf('pref.maxSPL is %d',pref.maxSPL )})
             
              
                StdDB(lp)=std(DB);
                %stop and turn off Run button
                set(TestH,'value', 0);
                set(TestH,'enable','off');
                set(TestH,'string','Test');
                set(TestH,'backgroundcolor',[0 1 0]);
                
                if exist('ao2','var') && ~isempty(ao2)
                    stop(ao2);
                end
                if exist('ai2','var') && ~isempty(ai2)
                    stop(ai2);
                end
                ai('reset');
                % ao('reset');
                
                SendEvent('esealtestoff',[],me,'all');
                % 20041124 - foma
                %         eval([ me '(''reset'');' ]);
                set(TestH,'enable','on');
            end %if Running
            %             pause(1)
        end %loop_num
        close(wb)
        if ~isempty(ax2)
            hold(ax2, 'off')
            plot(ax2, StdDB, '-o')
            ylabel(ax2, 'std dB')
            xlabel(ax2, 'iterations')
        end
        % title('std dB across iterations')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function samples=PlayCalibrationTone(tonefreq, tonedur, f) %f = filter?

param.frequency=tonefreq; %hz
param.amplitude=GetParam(me, 'target_amplitude');

% calibrate amplitude
%try
% if tonefreq==-1
%     attenuation=atten(end);
% else
logspacedfreqs=GetParam(me, 'logspacedfreqs');
atten=GetParam(me, 'atten');
findex=find(logspacedfreqs<=tonefreq, 1, 'last');
attenuation=atten(findex);
param.amplitude=param.amplitude-attenuation;

% if GetParam(me, 'mic_applied')
%     mic_freq_resp=GetParam(me,'mic_freq_resp');
%     attenuation=mic_freq_resp(findex);
%     param.amplitude=param.amplitude-attenuation;
% end
param.duration=tonedur; %ms
param.ramp=10;
switch GetParam(me, 'soundmethod')
    case 'PPAsound'
        samplerate=PPASound('samplerate');
    case 'AOSound'
        samplerate=AOSound('samplerate');
    case 'soundmachine'
        samplerate=SoundLoadSM('samplerate');                             %  sampling frequency
end
%samplerate=200e3;
if tonefreq==-1
    samples=MakeWhiteNoise(param, samplerate);
else
    samples=MakeTone(param, samplerate);
end

if f %apply previously learned inverse filter
    a=GetParam(me, 'inverse_filter');
    samples=filter(a, 1, samples);
    samples=samples./(max(samples));
end

switch GetParam(me, 'channel')
    case 1 %mono
        % samples already on mono=right side
    case 2 %right
        % samples already on mono=right side
    case 3 %left
        samples=[0*samples;samples];
end


% uncomment to use soundmachine:
% triggernum=2;
% loop_flg=0;
% predelay_s=0;
% side='both';
% stop_ramp_tau_ms=1;
% sm=GetParam('soundloadsm','SM');
% sm=Initialize(sm); %Initialize
% sm=SetSampleRate(sm, 200000); %mw 060606 Warning: For now, RTLSoundMachine is limited to a sample rate of 200kHz only!  Please fix your code!
% sm=LoadSound(sm, triggernum, samples, side, stop_ramp_tau_ms, predelay_s, loop_flg);
% sm=PlaySound(sm, triggernum);
switch GetParam(me, 'soundmethod')
    case 'PPAsound'
        PPASound('load', 'var',samples,param)
        pause(.1)
        PPASound('playsound')
        pause(.1)
    case 'AOSound'
        AOSound('load', 'var',samples,param)
        pause(.1)
        AOSound('playsound')
        pause(.1)
    case 'soundmachine'
        SoundLoadSM('load','var',sample,param)
        pause(.1)
        SoundLoadSM('playsound')
        pause(.1)
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function StoreRMicFreqResponse
% %you're not allowed to store it if mic was applied during run - that's a
% %violation %mw081512
% if GetParam(me, 'Rmic_applied_during_Run') | GetParam(me, 'Lmic_applied_during_Run')
%     warndlg('Cannot store mic since it was applied during last Run')
% else
%     
%     sure = questdlg('Do you want to store this frequency response for future microphone calibration?', ...
%         'Are you sure?', ...
%         'Store this curve', 'Nevermind', 'Nevermind');
%     switch sure
%         case 'Nevermind'
%         case 'Store this curve'
%             %         atten=GetParam(me,'last_atten');
%             %         SetParam(me,'Rmic_freq_resp', atten);
%             cal=load('calibration.mat');
%             logspacedfreqs=cal.logspacedfreqs;
%             DB=cal.DB;
%             atten=cal.atten;
%             Rmic_freq_resp=GetParam(me,'last_atten');
%             atten2=GetParam(me,'last_atten');
%             SetParam(me,'Rmic_freq_resp', atten2);
%             Lmic_freq_resp=cal.Lmic_freq_resp;
%             Ratten=cal.Ratten;
%             Latten=cal.Latten;
%             R_DB=cal.R_DB;
%             L_DB=cal.L_DB;
%             timestampstr=['last saved ', datestr(now)];
%             save calibration logspacedfreqs timestampstr DB R_DB L_DB atten Rmic_freq_resp Lmic_freq_resp Ratten Latten
%             
%             Message(me, 'Stored this curve as right microphone frequency response')
%     end
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function StoreLMicFreqResponse
% %you're not allowed to store it if mic was applied during run - that's a
% %violation %mw081512
% if GetParam(me, 'Rmic_applied_during_Run') | GetParam(me, 'Lmic_applied_during_Run')
%     warndlg('Cannot store mic since it was applied during last Run')
% else
%     sure = questdlg('Do you want to store this frequency response for future microphone calibration?', ...
%         'Are you sure?', ...
%         'Store this curve', 'Nevermind', 'Nevermind');
%     switch sure
%         case 'Nevermind'
%         case 'Store this curve'
%             %         atten=GetParam(me,'last_atten');
%             %         SetParam(me,'Lmic_freq_resp', atten);
%             cal=load('calibration.mat');
%             logspacedfreqs=cal.logspacedfreqs;
%             DB=cal.DB;
%             atten=cal.atten;
%             Rmic_freq_resp=cal.Rmic_freq_resp;
%             Lmic_freq_resp=GetParam(me,'last_atten');
%             atten3=GetParam(me,'last_atten');
%             SetParam(me,'Lmic_freq_resp', atten3);
%             Ratten=cal.Ratten;
%             Latten=cal.Latten;
%             R_DB=cal.R_DB;
%             L_DB=cal.L_DB;
%             timestampstr=['last saved ', datestr(now)];
%             save calibration logspacedfreqs timestampstr DB R_DB L_DB atten Rmic_freq_resp Lmic_freq_resp Ratten Latten
%             
%             Message(me, 'Stored this curve as left microphone frequency response')
%     end
% end
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ApplyRMicFreqResponse(ax1)
% %ApplyMicFreqResponse
% 
% if GetParam(me,'Rmic_applied','value') %it's on, turn it off
%     SetParam(me,'Rmic_applied','value',0);
%     h=findobj('tag','applyRmic');
%     set(h,'backgroundcolor',[0.92549 0.913725 0.847059],'string','applyRmic' );
%     atten=GetParam(me,'Rmic_freq_resp');
%     DB=GetParam(me,'last_DB');
%     logspacedfreqs=GetParam(me,'logspacedfreqs','value');
%     if ~isempty(DB)
%         if ~GetParam(me, 'Rmic_applied_during_Run')
%             %this works if mic not applied during run
%             plot(ax1, logspacedfreqs, DB, '-o')
%             xlabel(ax1, 'Frequency, Hz');
%             ylabel(ax1, 'dB SPL');
%         else %mic was applied during run
%             plot(ax1, logspacedfreqs, DB+atten, '-o')
%             xlabel(ax1, 'Frequency, Hz');
%             ylabel(ax1, 'dB SPL');
%         end
%     end
% else %it's off, turn it on
%     sure = questdlg('Do you want to correct this curve using the stored right microphone frequency response?', ...
%         'Are you sure?', ...
%         'Apply stored curve', 'Nevermind', 'Nevermind');
%     switch sure
%         case 'Nevermind'
%         case 'Apply stored curve'
%             SetParam(me,'Rmic_applied','value',1);
%             if GetParam(me,'Lmic_applied','value') %R and L mic are mutually exclusive, so if L is on, turn it off
%                 ApplyLMicFreqResponse(ax1)
%             end
%             h=findobj('tag','applyRmic');
%             set(h,'backgroundcolor',[1 0 0],'string','Rmic_applied');
%             atten=GetParam(me,'Rmic_freq_resp');
%             DB=GetParam(me,'last_DB');
%             logspacedfreqs=GetParam(me,'logspacedfreqs','value');
%             if ~isempty(DB)
%                 if ~GetParam(me, 'Rmic_applied_during_Run')
%                     %this works if mic not applied during run
%                     DB=DB-atten; %apply correction
%                 else %mic was applied during run
%                 end
%                 plot(ax1, logspacedfreqs, DB, '-o')
%                 xlabel(ax1, 'Frequency, Hz');
%                 ylabel(ax1, 'dB SPL');
%                 xlim(ax1, [-2 1.25*logspacedfreqs(end)])
%             end
%             %SetParam(me,'Rmic_freq_resp', atten); %commented out bc seems unnecessary mw081512
%             
%             Message(me, 'corrected for stored right microphone frequency response')
%     end
% end
% 
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ApplyLMicFreqResponse(ax1)
% %ApplyMicFreqResponse
% 
% if GetParam(me,'Lmic_applied','value') %it's on, turn it off
%     SetParam(me,'Lmic_applied','value',0);
%     h=findobj('tag','applyLmic');
%     set(h,'backgroundcolor',[0.92549 0.913725 0.847059],'string','applyLmic' );
%     atten=GetParam(me,'Lmic_freq_resp');
%     DB=GetParam(me,'last_DB');
%             logspacedfreqs=GetParam(me,'logspacedfreqs','value');
%    if ~isempty(DB)
%         if ~GetParam(me, 'Lmic_applied_during_Run')
%             %this works if mic not applied during run
%             plot(ax1, logspacedfreqs, DB, '-o')
%             xlabel(ax1, 'Frequency, Hz');
%             ylabel(ax1, 'dB SPL');
%         else %mic was applied during run
%             plot(ax1, logspacedfreqs, DB+atten, '-o')
%             xlabel(ax1, 'Frequency, Hz');
%             ylabel(ax1, 'dB SPL');
%         end
%     end
% else %it's off, turn it on
%     sure = questdlg('Do you want to correct this curve using the stored left microphone frequency response?', ...
%         'Are you sure?', ...
%         'Apply stored curve', 'Nevermind', 'Nevermind');
%     switch sure
%         case 'Nevermind'
%         case 'Apply stored curve'
%             SetParam(me,'Lmic_applied','value',1);
%             if GetParam(me,'Rmic_applied','value') %R and L mic are mutually exclusive, so if R is on, turn it off
%                 ApplyRMicFreqResponse(ax1)
%             end
%             h=findobj('tag','applyLmic');
%             set(h,'backgroundcolor',[1 0 0],'string','Lmic_applied');
%             atten=GetParam(me,'Lmic_freq_resp');
%             DB=GetParam(me,'last_DB');
%             logspacedfreqs=GetParam(me,'logspacedfreqs','value');
%             if ~isempty(DB)
%                  if ~GetParam(me, 'Lmic_applied_during_Run')
%                     %this works if mic not applied during run
%                     DB=DB-atten; %apply correction
%                 else %mic was applied during run
%                 end
%                 plot(ax1, logspacedfreqs, DB, '-o')
%                 xlabel(ax1, 'Frequency, Hz');
%                 ylabel(ax1, 'dB SPL');
%                 xlim(ax1, [-2 1.25*logspacedfreqs(end)])
%             end
% %             SetParam(me,'Lmic_freq_resp', atten);%commented out bc seems unnecessary mw081512
%             
%             Message(me, 'corrected for stored left microphone frequency response')
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newai=InitDAQAI
global exper

stopandstartai=isfield(exper,'ai') & isfield(exper.ai,'daq') & isobject(exper.ai.daq) & ...
    strcmp(get(exper.ai.daq,'Running'),'On');
if stopandstartai
    stop(exper.ai.daq);
end

RawCh=GetParam(me,'DataChannels');


% Create ai.
boardn=daqhwinfo('nidaq', 'BoardNames');
v=ver('daq'); %daq toolbox version number
if str2num(v.Version) >= 2.12
    %mw 08.28.08
    %new version of matlab uses nidaqmx rather than nidaq_trad
    %driver
    newai=analoginput('nidaq','Dev1');
else
    switch boardn{1} %mw 04.18.06
        case 'PCI-6052E'
            newai=analoginput('nidaq',1);
        case 'PCI-6289'
            newai=analoginput('nidaq','Dev1'); %mw 12.16.05
    end
end


% NOTE: originally sealtest used differential inputs for nidaq, which,
% in our case meant up to 8 channels. With single ended inputs, as in
% case of AI, we can use 16 channels
%get the type of input types the board likes
% 	inputs=propinfo(newai,'InputType');
%if its possible to set the InputType to SingleEnded, then do it
% 2004/11/10 - foma - I talked to Mike Wehr, and decided to switch to
% differential
% We're going to use differential inputs
% see also open_ai above
% 	if ~isempty(find(strcmpi(inputs.ConstraintValue, 'SingleEnded')))
% 		ai.InputType='SingleEnded';
% 	end

addchannel(newai,[RawCh]);
newai.Channel(:).InputRange=[-10 10];
newai.Channel(:).SensorRange=[-10 10];
newai.Channel(:).UnitsRange=[-10 10];
% Set trigger.
newai.TriggerType='HwDigital';
% Copy the sample rate from the other module.
%newai.SampleRate=GetParam('ai','samplerate');

newai.SampleRate=GetParam(me,'aisamprate');
% Set length to be twice the pulse length.
newai.SamplesPerTrigger=ceil(newai.SampleRate);
% Call this file at the end.

if stopandstartai
    start(exper.ai.daq);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newdio=InitDAQDIO
boardn=daqhwinfo('nidaq', 'BoardNames');
v=ver('daq'); %daq toolbox version number
if str2num(v.Version) >= 2.12
    %mw 08.28.08
    %new version of matlab uses nidaqmx rather than nidaq_trad
    %driver
    newdio=digitalio('nidaq','Dev1'); %mw 12.16.05
else
    switch boardn{1} %mw 04.18.06
        case 'PCI-6052E'
            newdio=digitalio('nidaq',1);
        case 'PCI-6289'
            newdio=digitalio('nidaq','Dev1'); %mw 12.16.05
    end
end
trigchan=GetParam('dio','trigchan');
if ischar(trigchan)
    trigchan=str2double(trigchan);
end
addline(newdio,trigchan,'out');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out=me
out=lower(mfilename);

function GetInverseFilter(ScaledData, samples, ai2SampleRate)
%ai2SampleRate is daq samprate for mic data

%get playsound sampling rate
switch GetParam(me, 'soundmethod')
    case 'PPAsound'
        samplerate=PPASound('samplerate');
    case 'AOSound'
        samplerate=AOSound('samplerate');
    case 'soundmachine'
        samplerate=SoundLoadSM('samplerate');        
end


% resample original sound to match mic data
x=resample(samples, ai2SampleRate, samplerate);
delay=zeros(1, 30);
d=[delay x(1:length(x)-length(delay))];
%played sound is intentionally longer than mic data, truncate for now
%(might be able to trim start as well?)
d=d(1:length(ScaledData));
O=GetParam(me, 'order'); %17
p0 = 2*eye(O);
lambda = 0.99;
ha = adaptfilt.rls(O,lambda,p0);

tic
[y] = filter(ha,ScaledData,d); %learns the inverse filter
toc

SetParam(me,'inverse_filter','value',ha.Coefficients);

% t=1:length(x);
% plot(t, x, t, y, t, xdata)
% shg
window=round(length(x)/128);
noverlap=[];
nfft=1024;
%window=[];
figure
[Ppre, F]=pwelch(samples, window, noverlap, nfft, ai2SampleRate);
[Ppost, F]=pwelch(ScaledData,  window, noverlap, nfft, ai2SampleRate);
[PEQ, F]=pwelch(y, window, noverlap, nfft, ai2SampleRate);
F2=F/1000;
z=filter(ha.Coefficients, 1, x);
[Pinv, F]=pwelch(z, window, noverlap, nfft, ai2SampleRate);
semilogy(F2, Ppre, F2, Ppost, F2, PEQ,F2, Pinv);
shg
xlabel('frequency, kHz')
% set(gca, 'xscal', 'log')



% keyboard
