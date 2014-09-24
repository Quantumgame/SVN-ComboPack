function out=SoundLoad(varargin)

% simple module that loads data to RP2, either from a file or from a
% variable
%
% SoundLoad('load','file',some_COMPLETE_file_name) : Just try to pass the
% COMPLETE (ie with the full path) file name. Partial file name is usually
% sufficient, but you just cannot assume it would ALWAYS work
%
% SoundLoad('load','var',variable) : The variable is a vector sampled at RP2
% sampling rate.
%
% rp2fs=SoundLoad('samplerate'); : Returns RP2's samplerate. ALL MODULES
% using SoundLoad should check this and use it!
% rp2=SoundLoad('rp2object'); : Returns an RP2 object used by SoundLoad.
%
% SoundLoad('sethwtrigger'): enables RP2's hardware trigger
%

global exper pref

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
case 'init'
    ModuleNeeds(me,{'rp2control'}); % needs RP2Control to find out how to talk to RP2
    SetParam(me,'priority',GetParam('rp2control','priority')+1);
    InitializeGUI;                  % show the gui = message box:-)
    InitRP2;                        % load the circuit
    
case 'reset'
    InitRP2;
           
case 'load'
    if nargin<3
        return;
    end
    try 
        if nargin==4
            LoadRP2(varargin{2},varargin{3},varargin{4});
        else
            param.channel=1;
            LoadRP2(varargin{2},varargin{3},param); % first channel is the default channel
        end
    catch
        Message(me,'Cannot load RP2');
    end
    
case 'samplerate'
    out=GetParam(me,'RP2Fs');
    
case 'rp2object'
    out=GetParam(me,'RP2');
    
case 'sethwtrigger'
    rp2=GetParam(me,'RP2');
    if nargin>1
        channel=varargin{2};   % channel should be the second argument
    end
    if isempty(channel)             % if no channel is specified, set up all
        invoke(rp2,'SoftTrg',1);    % channel 1
        invoke(rp2,'SoftTrg',2);    % channel 2
    else
        invoke(rp2,'SoftTrg',channel);  % start specific channel
    end

case 'resetbuffers'
    rp2=GetParam(me,'RP2');
    % stop and reset the buffer
    invoke(rp2,'SoftTrg',10);
    
case 'setchannel'
    rp2=GetParam(me,'RP2');
    channel=[];
    if nargin>1
        channel=str2num(varargin{2});   % channel should be the second argument
    end
    if isempty(channel)
        channel=1;                      % if there are no arguments, or the second argument is not a number, let's make it 1
    end
    invoke(rp2,'SetTagVal','channel',channel); % set the output channel
    Message(me,['Channel set: ' num2str(channel)]);
    
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitRP2
global exper pref
        if ExistParam(me,'RP2') % take the existing ActiveX control
            RP2=GetParam(me,'RP2');
        else
            RP2=RP2Control('GetRP2','sound');
            if isempty(RP2)            
                Message(me,'Can''t find RP2...');
                return;
            end
            InitParam(me,'RP2','value',RP2); %param to hold the RP2 activex object
        end

        if ~isempty(RP2)
            if existparam(me,'DefID')
                DefID=GetParam(me,'DefID');
                while invoke(RP2,'DefStatus',DefID)>0  %% wait for def write 
                    Message(me,'waiting for def write...');
                    pause(.1);
                end
            end
        end
        
        invoke(RP2,'Halt');
        invoke(RP2,'ClearCOF');
        
        circuit=RP2Control('GetRP2Circuit','sound');
        if ~invoke(RP2,'LoadCOF',[pref.tdt circuit]); % Load the sound circuit
            Message(me, 'LoadCOF Failure');
            return;
        else
            Message(me,'Circuit loaded');
        end
        
        invoke(RP2,'Run');
        % Stop and reset the buffer.
        invoke(RP2,'SoftTrg',10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadRP2(type,where,param)
% loads data to RP2. type can be either 'file' or 'var'
    switch type
        case 'file'
            try
                load(where,'samples');
                str=[where ' loaded'];  % string to be displayed in the message box
            catch
                Message(sprintf('Cannot load %s', where));
                return;
            end
        case 'var'
            samples=where;              % string to be displayed in the message box
            str='vector loaded';
        otherwise
            return;
    end
    
    if isfield(param,'channel')
        channel=param.channel(1);
    else
        channel=1;  % default channel
    end
    
    samples=full(samples);
    % Reshape and record length.
    samples=reshape(samples,1,prod(size(samples)));
    lsamples=length(samples);    
    %grab activex object from param
    RP2=GetParam(me,'RP2');
    RP2Fs=GetParam(me,'RP2Fs');
%     if (lsamples/RP2Fs)>2000
%         waittime=.3;
%     else
%         waittime=.3;
%     end
    % stop and reset the buffer
    invoke(RP2,'SoftTrg',10);
    % Write to the buffer.
    
    datasize=['datasize' num2str(channel)];
    datain=['datain' num2str(channel)];
    
    invoke(RP2,'SetTagVal',datasize,lsamples); % set the length of data to be played
    % foma - 09/23/2004 Halting the circuit before uploading the data speeds up
    % the transmission considerably!!!
    invoke(RP2,'Halt');
%     tic;
    DefID=invoke(RP2,'WriteTagVEX',datain,0,'F32',samples);
%     DefID=invoke(RP2,'WriteTagVEX',datain,0,'F32~',samples);
%     pause(waittime);
    % Obviously, you have to start the circuit again:-)
    invoke(RP2,'Run');
    invoke(RP2,'SoftTrg',channel);  % enable triggering for the channel (Software trigger numbers correspond to channel numbers for now)    
    SetParam(me,'DefID',DefID);    
%     Message(me,[str ': ' num2str(DefID) ' ' num2str(toc)]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitializeGUI
    fig = ModuleFigure(me);
    set(fig,'doublebuffer','on','visible','off');

    hs = 120;
    h = 5;
    vs = 20;
    n = 0;
    % message box
    uicontrol('parent',fig,'tag','message','style','text',...
              'enable','inact','horiz','left','pos',[h n*vs hs vs]); n=n+1;
    screensize=get(0,'screensize');
    set(fig,'pos', [screensize(3)-128 screensize(4)-n*vs-120 128 n*vs] ,'visible','on'); 
    RP2Fs=50e6/512;
    InitParam(me,'RP2Fs','value',RP2Fs);        % stores RP2's sample rate we use

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=me
% Simple function for getting the name of this m-file.
out=lower(mfilename);
