function out=Scope(varargin)

% simple scope for continuously watching the data

global exper pref

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
    dataChannels=GetChannel('ai','datachannel');
    stimuliChannels=GetChannel('ai','stimulichannel');
    
    myChannels=[[dataChannels.number] [stimuliChannels.number]];
    AIChannels=AI('GetChannelIdx',myChannels);
    
    scopeChannels=AIChannels;
    scopeChannelNames=[{dataChannels.name} {stimuliChannels.name}];
    scopeChannelColors=[{dataChannels.color} {stimuliChannels.color}];
    InitParam(me,'ScopeChannels','value',scopeChannels);
    InitParam(me,'ScopeChannelNames','value',scopeChannelNames);
    InitParam(me,'ScopeChannelColors','value',scopeChannelColors);
    InitializeGUI;
    
case 'getready'
    samplerate=AI('GetSampleRate');
    SetParam(me,'AISamplerate',samplerate);
    
case 'show'
    samplerate=GetParam(me,'AISampleRate')/1000;
    duration=GetParam(me,'Duration')*samplerate;
    if exper.ai.daq.SamplesAvailable>duration
        data=peekdata(exper.ai.daq,duration);
        scopeChannels=GetParam(me,'ScopeChannels');
        dataLength=size(data,1);
        d=data(:,scopeChannels);                % extract the channels we want to show
        d=d-repmat(min(d),dataLength,1);         % and normalize them
        d=d./repmat(max(d)+eps,dataLength,1);

        scopeLines=GetParam(me,'ScopeLines');
        nLines=length(scopeLines);
        xData=1/samplerate:1/samplerate:dataLength/samplerate;
        for sLine=1:nLines
            set(scopeLines(sLine),'XData',xData,'YData',d(:,sLine)+sLine-1);
        end
    end
    
case 'run'
    if GetParam(me,'Run');
        duration=GetParam(me,'Duration')/1000;       % in sec
        samplerate=GetParam(me,'AISampleRate');      % in Hz
        count=duration*samplerate/10; % renewal period= 1/10 of the total number of samples plotted
        if strcmpi(get(exper.ai.daq,'Running'),'Off')   % we can only set SamplesAcquiredFcnCount when daq is NOT running
            exper.ai.daq.SamplesAcquiredFcnCount=count;
        end
        exper.ai.daq.SamplesAcquiredFcn={me};
        SetParamUI(me,'Run','background',[0 0.9 0.9],'String','Watching...');
    else
        exper.ai.daq.SamplesAcquiredFcn='';
        SetParamUI(me,'Run','background',[0 0.9 0],'String','Watch');
    end
end	
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
global pref
    fig = ModuleFigure(me);
    set(fig,'doublebuffer','on','Position',[200 200 600 300]);

    scopeAxes=axes('units','normal','position',[0.1 0.25 0.8 0.7]); 
    InitParam(me,'ScopeAxes','value',scopeAxes);

    channelNames=GetParam(me,'ScopeChannelNames');
    channelColors=GetParam(me,'ScopeChannelColors');
    nChannels=length(channelNames);
    scopeLines=zeros(1:nChannels);
    set(scopeAxes,'YLim',[0 nChannels]);    
    for pos=1:nChannels
        scopeLines(pos)=line([0 1],[pos-0.5 pos-0.5],'Color',channelColors{pos});
        text(0.01,pos-0.9,channelNames{pos},'FontSize',8);
    end
    InitParam(me,'ScopeLines','value',scopeLines);
    set(scopeAxes,'YTickLabel',[]);

    samplerate=AI('GetSampleRate');
    InitParam(me,'AISamplerate','value',samplerate);
    
        % Watch button. 
    InitParam(me,'Run','value',0,'ui','togglebutton','pref',0,'units','normal','pos',[0.1 0.05 0.2 0.1]);
	SetParamUI(me,'Run','string','Watch','backgroundcolor',[0 0.9 0],'label','');
    InitParam(me,'Duration','value',1000,'ui','edit','units','normal','pos',[0.72 0.05 0.1 0.1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
