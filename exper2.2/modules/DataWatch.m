function out=DataWatch(varargin)

% simple module for watching the data. Waits until the data is available
% (from stimuluswatch) and plots it

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
        data=GetSharedParam('CurrentData');
        samplerate=GetParam(me,'AISampleRate')/1000;
        dataChannels=GetParam(me,'DataChannels');
        if ~isempty(data)
            lines=GetParam(me,'ScopeLines');
            xData=1/samplerate:1/samplerate:size(data,1)/samplerate;
            for pos=1:length(dataChannels)
                d=fft(data(:,pos));
                d=d(1:round(end/2));
                set(lines(pos),'XData',1:length(d),'YData',d);
            end
        end
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
    set(fig,'doublebuffer','on','Position',[300 300 400 200]);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
