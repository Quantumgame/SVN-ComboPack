function out=OnlineR(varargin)

% simple module for watching the data. Waits until the data is available
%  and plots it

global exper pref shared

if nargin > 0
    if isobject(varargin{1})    % callback function from exper.ai.daq
        action='show';
    else
        action = lower(varargin{1});
    end
else
    action = lower(get(gcbo,'tag'));
end

switch action
    case 'init'
        ModuleNeeds(me,{'dataguru'}); 
        dataChannels=GetChannel('ai','datachannel');
        AIChannels=AI('GetChannelIdx',[dataChannels.number]);
        InitParam(me,'DataChannels','value',AIChannels);
        InitParam(me,'DataChannelColors','value',{dataChannels.color});   
        InitializeGUI;
        
    case 'getready'
        samplerate=AI('GetSampleRate');
        SetParam(me,'AISamplerate',samplerate);
        
    case 'edataavailable'
        if GetParam(me,'Watch')
            stim=GetSharedParam('CurrentStimulus');
            switch stim.type
                case 'pulse'
                    v_onset=stim.param.start;
                    pw=stim.param.width;
                    ph=stim.param.height;
                    numpulses=stim.param.npulses;
                case 'holdcmd'
                    ramp=stim.param.ramp;
                    holdduration=stim.param.holdduration;
                    traindelay=stim.param.start;
                    v_onset=stim.param.pulse_start;
                    pw=stim.param.pulse_width;
                    ph=stim.param.pulse_height;
                    numpulses=stim.param.npulses;
                    pulse_isi=stim.param.pulse_isi;
                    pulseduration=stim.param.pulseduration;
                    %not using pulse_isi... assuming pulse_isi==pw and
                    %using 2*pw instead
                    %not using pulseduration... not sure why I had that in
                otherwise
                    return
            end
            data=GetSharedParam('CurrentData');
            datalength=length(data);
            samprate=GetParam(me,'AISampleRate')/1000;
            dataChannels=GetParam(me,'DataChannels');
            time=1:length(data);
            time=time/samprate;
            Mode=PatchPreProcess('GetMode');
            Mode=Mode{:};
            if isempty(data)
                return
            end
            trainstart=ramp+holdduration+traindelay-pulseduration;
            pulse_=[];
            for i=1:numpulses
                onset=trainstart+v_onset+2*pw*(i-1);
                pulse_region=find( ( time > onset-10 ) & ( time < (onset+pw+10)  ) );
                if max(pulse_region)<datalength
                    pulse_(i,:)=data(pulse_region,1)';
                end
            end
            meanpulse=mean(pulse_);
            t=1:length(meanpulse);            
            t=t/samprate;
            lines=GetParam(me,'ScopeLines');
            % assuming only one axopatch channel
            switch Mode
                case { 'I=0' }    
                    set(lines,'XData',0,'YData',0);
                    Message(me, 'I=0');  
                    return
                case { 'V-Clamp' }
                    % Get the baseline.
                    baseline_region = find( (t  > 0) & (t  < 10 ));
                    %the first stim is a blank, pulse follows it
                    Baseline = mean( meanpulse( baseline_region ) );
                    
                    % Look for peak in +/- 1 ms around pulse onset.        
                    peak_region = find( ( t > 9 ) &   ( t < 11) );
                    Peak = sign(ph) * max( sign(ph) * meanpulse( peak_region ) );
                    Peak = Peak - Baseline;
                    
                    % Look for tail in last 1 ms of pulse.
                    offset=10+pw;
                    tail_region = find( ( t > offset-1 ) & ( t < offset  ) );
                    Tail=mean(meanpulse(tail_region));
                    Tail = Tail - Baseline;
                    
                    % ph in mV, current in pA and resistance in MOhm.
                    if (Peak~=0) & (Tail~=0)
                        Rs=(ph * 1e-3)/( Peak * 1e-12) / (1e6);
                        Rt=(ph * 1e-3)/( Tail * 1e-12) / (1e6);
                        Rin=Rt-Rs;
                    else 
                        Rs=inf;Rt=inf;Rin=inf;
                    end        
                case { 'I-Clamp Normal','I-Clamp Fast' }    
                    % Get the baseline.
                    baseline_region = find( (t  > 0) & (time  < 10 ));
                    %the first stim is a blank, pulse follows it
                    Baseline = mean( meanpulse( baseline_region ) );
                    
                    % Find time index that pulse started and look +/- 1 ms for steepness.
                    start_region = find( ( t > 9 ) &   ( time < 15) );
                    [dum,onset_index]=max( sign(ph)*diff( meanpulse( start_region ) ) );
                    Onset=meanpulse( start_region(onset_index + 1 ));
                    Onset = Onset - Baseline;
                    
                    % Look for peak charging in +/- 1 ms around pulse termination.
                    offset=pw+10;
                    peak_region = find( ( t > offset-1 ) & ( t < offset  ) );
                    Peak = sign(ph) * max( sign(ph) * meanpulse( peak_region ) );
                    Peak = Peak - Baseline;
                    
                    % ph in mV, current in pA and resistance in MOhm.
                    if (Peak~=0) & (Onset~=0)
                        Rs=( Onset * (1e-3 ) ) / ( ph * (1e-12) ) / (1e6);;
                        Rt=( Peak * (1e-3) ) / ( ph * (1e-12) ) / (1e6);
                        Rin=Rt-Rs;
                    else 
                        Rs=inf;Rt=inf;Rin=inf;
                    end                
                    
            end %switch mode
            
            %plot and display values
            t=1:length(meanpulse);t=t/samprate;
            set(lines,'XData',t,'YData',meanpulse);
            Rstring= sprintf('Rt: %.1f     Rin: %.1f     Rs: %.1f', Rt, Rin, Rs);   
            Message(me, Rstring);        
            if isempty(pulse_); Message(me, 'insufficent data peek'); end

            
        end
        
        
    case 'watch'
        if GetParam(me,'Watch');
            SetParamUI(me,'Watch','background',[0 0.9 0.9],'String','Watching...');
        else
            SetParamUI(me,'Watch','background',[0 0.9 0],'String','Watch');
        end
        
        
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
fig = ModuleFigure(me);
set(fig,'doublebuffer','on','Position',[300 300 400 300]);

scopeAxes=axes('units','normal','position',[0.1 0.25 0.8 0.7]);    
InitParam(me,'ScopeAxes','value',scopeAxes);

channels=GetParam(me,'DataChannels');
channelColors=GetParam(me,'DataChannelColors');
nChannels=length(channels);
scopeLines=zeros(1:nChannels);
for pos=1:nChannels
    scopeLines(pos)=line([0 1],[0.5 0.5],'Color',channelColors{pos});
end
InitParam(me,'ScopeLines','value',scopeLines);

samplerate=AI('GetSampleRate');
InitParam(me,'AISamplerate','value',samplerate);

% Run button. 
InitParam(me,'Watch','value',0,'ui','togglebutton','pref',0,'units','normal','pos',[0.1 0.05 0.2 0.1]);
SetParamUI(me,'Watch','string','Watch','backgroundcolor',[0 0.9 0],'label','');

InitParam(me,'Data','value',[]);

% message box
uicontrol('parent',fig,'tag','message','style','text','units','normal','fontweight','bold',...
    'enable','inact','horiz','left','pos',[0.35 0.0 0.60 0.15]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
